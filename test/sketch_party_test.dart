import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import 'package:design/features/games/sketch_party/models/sketch_party_player.dart';
import 'package:design/features/games/sketch_party/models/sketch_party_state.dart';
import 'package:design/features/games/sketch_party/models/sketch_party_word.dart';
import 'package:design/features/games/sketch_party/models/sketch_stroke.dart';
import 'package:design/features/games/sketch_party/screens/sketch_party_lobby_screen.dart';
import 'package:design/features/games/sketch_party/screens/sketch_party_menu_screen.dart';
import 'package:design/features/games/sketch_party/screens/sketch_party_screen.dart';
import 'package:design/features/games/sketch_party/services/sketch_party_engine.dart';
import 'package:design/features/games/sketch_party/services/sketch_word_catalog.dart';
import 'package:design/features/games/sketch_party/widgets/sketch_round_result_modal.dart';
import 'package:design/features/games/sketch_party/widgets/sketch_scoreboard.dart';
import 'package:design/features/games/sketch_party/widgets/sketch_word_select_modal.dart';

void main() {
  setUp(() {
    AuthService.instance = MockAuthService(
      initialUser: const AuthUser(
        uid: 'user_sketch_001',
        email: 'sketcher@playpal.com',
      ),
    );
    ProfileService.instance = MockProfileService();
  });

  group('Sketch Party - Word & Catalog Tests', () {
    test('matches exact word and synonyms case-insensitively', () {
      const SketchPartyWord word = SketchPartyWord(
        word: 'Apple',
        category: 'Food',
        difficulty: WordDifficulty.easy,
        synonyms: <String>['Fruit'],
      );

      expect(word.matches('apple'), isTrue);
      expect(word.matches('APPLE'), isTrue);
      expect(word.matches('  apple  '), isTrue);
      expect(word.matches('fruit'), isTrue);
      expect(word.matches('banana'), isFalse);
    });

    test('detects close guesses off by 1 letter via Levenshtein distance', () {
      const SketchPartyWord word = SketchPartyWord(
        word: 'Rocket',
        category: 'Vehicles',
        difficulty: WordDifficulty.medium,
      );

      expect(word.isClose('rockt'), isTrue);   // missing 'e'
      expect(word.isClose('rockett'), isTrue); // extra 't'
      expect(word.isClose('pocket'), isTrue);  // replaced 'r' with 'p'
      expect(word.isClose('banana'), isFalse); // completely different
    });

    test('generateMaskedHint progressively reveals letters based on progress', () {
      const String word = 'PLANET';
      final String hint0 = SketchWordCatalog.generateMaskedHint(word, 0.0);
      expect(hint0, equals('_ _ _ _ _ _'));

      final String hintMid = SketchWordCatalog.generateMaskedHint(word, 0.50);
      expect(hintMid.contains('P'), isTrue); // First letter revealed

      final String hintLate = SketchWordCatalog.generateMaskedHint(word, 0.75);
      expect(hintLate.contains('P'), isTrue);
      expect(hintLate.contains('T'), isTrue); // End letter revealed
    });
  });

  group('Sketch Party - Engine Logic Tests', () {
    late SketchPartyEngine engine;

    setUp(() {
      engine = SketchPartyEngine();
      engine.initializeRoom(
        localUserId: 'user_sketch_001',
        localDisplayName: 'Artist',
        localAvatarId: 'avatar_cyber',
        totalPlayers: 4,
      );
    });

    tearDown(() {
      engine.dispose();
    });

    test('initializes with 4 players, 1 host and 3 bots', () {
      final SketchPartyState state = engine.state;
      expect(state.phase, equals(SketchPartyPhase.lobby));
      expect(state.players.length, equals(4));
      expect(state.players.first.isHost, isTrue);
      expect(state.players.first.isBot, isFalse);
      expect(state.players.skip(1).every((p) => p.isBot), isTrue);
    });

    test('starting match moves to wordSelect phase with 3 choices', () {
      engine.startMatch();
      final SketchPartyState state = engine.state;
      expect(state.phase, equals(SketchPartyPhase.wordSelect));
      expect(state.wordChoices.length, equals(3));
      expect(state.activeDrawerId, equals('user_sketch_001'));
    });

    test('selecting word begins 60s drawing phase', () {
      engine.startMatch();
      final SketchPartyWord chosenWord = engine.state.wordChoices.first;
      engine.selectWord(chosenWord);

      final SketchPartyState state = engine.state;
      expect(state.phase, equals(SketchPartyPhase.drawing));
      expect(state.currentWord, equals(chosenWord));
      expect(state.timeRemaining, equals(60));
    });

    test('drawer submitting strokes adds to strokes list with undo and clear', () {
      engine.startMatch();
      engine.selectWord(engine.state.wordChoices.first);

      expect(engine.state.strokes, isEmpty);

      engine.submitStroke(const SketchStroke(
        points: <Offset>[Offset(10, 10), Offset(20, 20)],
        color: Colors.cyan,
        strokeWidth: 4.0,
      ));
      expect(engine.state.strokes.length, equals(1));

      engine.submitStroke(const SketchStroke(
        points: <Offset>[Offset(30, 30), Offset(40, 40)],
        color: Colors.yellow,
        strokeWidth: 4.0,
      ));
      expect(engine.state.strokes.length, equals(2));

      engine.undoStroke();
      expect(engine.state.strokes.length, equals(1));

      engine.clearCanvas();
      expect(engine.state.strokes, isEmpty);
    });

    test('correct guess awards score to guesser and drawer', () {
      engine.startMatch();
      const SketchPartyWord testWord = SketchPartyWord(
        word: 'Guitar',
        category: 'Objects',
        difficulty: WordDifficulty.medium,
      );
      engine.selectWord(testWord);

      final String guesserId = engine.state.players[1].id;
      final String guesserName = engine.state.players[1].displayName;

      engine.submitGuess('guitar', playerId: guesserId, playerName: guesserName);

      final SketchPartyState state = engine.state;
      final SketchPartyPlayer guesser = state.getPlayer(guesserId)!;
      final SketchPartyPlayer drawer = state.getPlayer('user_sketch_001')!;

      expect(guesser.hasGuessed, isTrue);
      expect(guesser.totalScore, greaterThan(0));
      expect(drawer.totalScore, greaterThan(0));
      expect(state.correctGuessCount, equals(1));
    });
  });

  group('Sketch Party - UI & Screen Widget Tests', () {
    testWidgets('SketchPartyScreen renders lobby with room code and start match button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SketchPartyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SKETCH PARTY'), findsOneWidget);
      expect(find.text('START MATCH'), findsOneWidget);
      expect(find.text('LOBBY ROSTER'), findsOneWidget);
    });

    testWidgets('tapping start match enters wordSelect and drawing phase',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SketchPartyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap start match
      await tester.tap(find.text('START MATCH'));
      await tester.pumpAndSettle();

      // Should show the 3 word choices for the drawer
      expect(find.text('Your Turn to Draw'), findsOneWidget);
      expect(find.text('Choose one secret word'), findsOneWidget);

      // Tap the first word choice in SketchWordSelectModal
      await tester.tap(find.descendant(
        of: find.byType(SketchWordSelectModal),
        matching: find.byType(InkWell),
      ).first);
      await tester.pump(const Duration(milliseconds: 300));

      // Should be in drawing mode: toolbar is visible
      expect(find.byIcon(Icons.auto_fix_normal_rounded), findsOneWidget); // Eraser
      expect(find.byIcon(Icons.undo_rounded), findsOneWidget); // Undo
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget); // Clear
      expect(find.text('Brush Size'), findsOneWidget);
      expect(find.text('You are drawing'), findsOneWidget);

      // Verify End Turn and points card are removed per design requirement
      expect(find.text('End Turn'), findsNothing);
      expect(find.textContaining('+200'), findsNothing);
    });

    testWidgets('SketchRoundResultModal renders ROUND FINISHED card with word, scores, and continue button',
        (WidgetTester tester) async {
      bool nextTurnCalled = false;
      const SketchPartyWord testWord = SketchPartyWord(
        word: 'Guitar',
        category: 'Objects',
        difficulty: WordDifficulty.medium,
      );

      final List<SketchPartyPlayer> testPlayers = <SketchPartyPlayer>[
        const SketchPartyPlayer(
          id: 'user_1',
          displayName: 'You',
          avatarId: 'bunny_pink',
          totalScore: 150,
          roundScore: 0,
          hasGuessed: false,
        ),
        const SketchPartyPlayer(
          id: 'bot_1',
          displayName: 'Pixel',
          avatarId: 'bot_blue',
          totalScore: 320,
          roundScore: 50,
          hasGuessed: false,
          isBot: true,
        ),
        const SketchPartyPlayer(
          id: 'bot_2',
          displayName: 'Nova',
          avatarId: 'bot_purple',
          totalScore: 481,
          roundScore: 270,
          hasGuessed: true,
          isBot: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SketchRoundResultModal(
              word: testWord,
              players: testPlayers,
              drawerName: 'Pixel',
              onNextTurn: () => nextTurnCalled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ROUND FINISHED'), findsOneWidget);
      expect(find.text('GUITAR'), findsOneWidget);
      expect(find.text('Sketched by Pixel'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('Pixel'), findsOneWidget);
      expect(find.text('Nova'), findsOneWidget);
      expect(find.text('+50'), findsOneWidget);
      expect(find.text('+270'), findsOneWidget);
      expect(find.text('150 pts'), findsOneWidget);
      expect(find.text('320 pts'), findsOneWidget);
      expect(find.text('481 pts'), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);

      await tester.tap(find.text('CONTINUE'));
      expect(nextTurnCalled, isTrue);
    });

    testWidgets('SketchScoreboard renders podium, final scores, stats, and rematch button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool rematchCalled = false;
      bool exitCalled = false;

      final List<SketchPartyPlayer> testPlayers = <SketchPartyPlayer>[
        const SketchPartyPlayer(
          id: 'user_1',
          displayName: 'You',
          avatarId: 'bunny_pink',
          totalScore: 420,
        ),
        const SketchPartyPlayer(
          id: 'bot_1',
          displayName: 'Sam',
          avatarId: 'bot_blue',
          totalScore: 380,
          isBot: true,
        ),
        const SketchPartyPlayer(
          id: 'bot_2',
          displayName: 'Mia',
          avatarId: 'bot_purple',
          totalScore: 310,
          isBot: true,
        ),
        const SketchPartyPlayer(
          id: 'bot_3',
          displayName: 'Leo',
          avatarId: 'bot_cyan',
          totalScore: 260,
          isBot: true,
        ),
        const SketchPartyPlayer(
          id: 'bot_4',
          displayName: 'Cooper',
          avatarId: 'bot_green',
          totalScore: 180,
          isBot: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SketchScoreboard(
            players: testPlayers,
            onPlayAgain: () => rematchCalled = true,
            onExit: () => exitCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Match Complete'), findsOneWidget);
      expect(find.text('Great game, everyone!'), findsOneWidget);
      expect(find.text('1st'), findsOneWidget);
      expect(find.text('2nd'), findsOneWidget);
      expect(find.text('3rd'), findsOneWidget);
      expect(find.text('FINAL SCORES'), findsOneWidget);
      expect(find.text('YOUR STATS'), findsOneWidget);
      expect(find.text('Rematch'), findsOneWidget);
      expect(find.text('Back to Hub'), findsOneWidget);
      expect(find.text('View Stats'), findsOneWidget);

      await tester.tap(find.text('Rematch'));
      expect(rematchCalled, isTrue);

      await tester.tap(find.text('Back to Hub'));
      expect(exitCalled, isTrue);
    });

    testWidgets('SketchPartyMenuScreen renders 4 action options and How to Play button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SketchPartyMenuScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Play'), findsOneWidget);
      expect(find.text('Create Room'), findsOneWidget);
      expect(find.text('Join Room'), findsOneWidget);
      expect(find.text('Solo vs Bots'), findsOneWidget);
      expect(find.text('How to Play'), findsOneWidget);
    });

    testWidgets('tapping Solo vs Bots navigates to SketchPartyLobbyScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SketchPartyMenuScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure visible in scroll view and tap Solo vs Bots
      await tester.ensureVisible(find.text('Solo vs Bots'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solo vs Bots'));
      await tester.pumpAndSettle();

      // Should open the 2nd screen (SketchPartyLobbyScreen) with 1 bot joined
      expect(find.byType(SketchPartyLobbyScreen), findsOneWidget);
      expect(find.text('ROOM CODE'), findsOneWidget);
      expect(find.text('PLAYERS (2/8)'), findsOneWidget);
      expect(find.text('Auto-fill AI Bot'), findsOneWidget);
    });

    testWidgets('tapping How to Play opens rules bottom sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SketchPartyMenuScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure visible in scroll view and tap How to Play
      await tester.ensureVisible(find.text('How to Play'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('How to Play'));
      await tester.pumpAndSettle();

      expect(find.text('HOW TO PLAY SKETCH PARTY'), findsOneWidget);
      expect(find.text('Draw Clearly'), findsOneWidget);
      expect(find.text('Dynamic Letter Hints'), findsOneWidget);
    });

    testWidgets('tapping Create Room opens SketchPartyLobbyScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SketchPartyMenuScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create Room'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Room'));
      await tester.pumpAndSettle();

      expect(find.byType(SketchPartyLobbyScreen), findsOneWidget);
      expect(find.text('ROOM CODE'), findsOneWidget);
      expect(find.textContaining('PLAYERS'), findsOneWidget);
      expect(find.text('GAME SETTINGS'), findsOneWidget);
      expect(find.text('ROOM CHAT'), findsOneWidget);
      expect(find.text('Start Match'), findsOneWidget);
    });

    testWidgets('SketchPartyLobbyScreen allows sending chat messages and starting match',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SketchPartyLobbyScreen(initialRoomCode: 'TEST-1234'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TEST-1234'), findsOneWidget);
      expect(find.text('PLAYERS (2/8)'), findsOneWidget);
      expect(find.text('Bot Sparky'), findsAtLeast(1));

      // Verify player count stepper replaces Room is open text
      expect(find.text('Room is open'), findsNothing);
      expect(find.text('2 Players'), findsOneWidget);

      // Tap + button on stepper to increase player count to 3
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('3 Players'), findsOneWidget);
      expect(find.text('PLAYERS (3/8)'), findsOneWidget);

      // Tap - button on stepper to decrease player count back to 2
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();
      expect(find.text('2 Players'), findsOneWidget);
      expect(find.text('PLAYERS (2/8)'), findsOneWidget);

      // Verify toggle button dynamically removes and adds bot without override/error
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('PLAYERS (1/8)'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('PLAYERS (2/8)'), findsOneWidget);

      // Enter a chat message and send
      await tester.enterText(find.byType(TextField), 'Hello team!');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hello team!'), findsOneWidget);

      // Tap Start Match -> launches SketchPartyScreen
      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(SketchPartyScreen), findsOneWidget);
    });
  });
}
