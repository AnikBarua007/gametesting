import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design/features/games/hidden_hand/models/drawing_stroke.dart';
import 'package:design/features/games/hidden_hand/models/game_words.dart';
import 'package:design/features/games/hidden_hand/models/hidden_hand_player.dart';
import 'package:design/features/games/hidden_hand/models/hidden_hand_state.dart';
import 'package:design/features/games/hidden_hand/screens/hidden_hand_screen.dart';
import 'package:design/features/games/hidden_hand/services/hidden_hand_engine.dart';
import 'package:design/features/games/hidden_hand/widgets/drawing_canvas_widget.dart';
import 'package:design/features/games/hidden_hand/widgets/drawing_toolbar.dart';

void main() {
  group('Hidden Hand - Prompt & Synonym Matching Tests', () {
    test('matches exact word case-insensitively and synonyms', () {
      const DrawingWordPrompt prompt = DrawingWordPrompt(
        word: 'Bicycle',
        category: 'Vehicles',
        synonyms: <String>['bike', 'cycle'],
      );

      expect(prompt.matchesGuess('Bicycle'), isTrue);
      expect(prompt.matchesGuess('bicycle'), isTrue);
      expect(prompt.matchesGuess('BIKE'), isTrue);
      expect(prompt.matchesGuess('cycle'), isTrue);
      expect(prompt.matchesGuess('airplane'), isFalse);
      expect(prompt.matchesGuess(''), isFalse);
    });
  });

  group('Hidden Hand - Engine & Role Balancing Rules', () {
    late HiddenHandEngine engine;

    setUp(() {
      engine = HiddenHandEngine();
    });

    tearDown(() {
      engine.dispose();
    });

    test('3-5 players assigns exactly 1 impostor', () {
      for (int count = 3; count <= 5; count++) {
        engine.initializeRoom(
          localUserId: 'user_1',
          localDisplayName: 'Player1',
          localAvatarId: 'avatar_phoenix',
          playerCount: count,
        );
        engine.startMatch();

        final List<HiddenHandPlayer> impostors = engine.state.impostors;
        final List<HiddenHandPlayer> artists =
            engine.state.players.where((p) => p.isArtist).toList();

        expect(impostors.length, 1, reason: 'Count $count should have 1 impostor');
        expect(artists.length, count - 1, reason: 'Count $count should have ${count - 1} artists');
      }
    });

    test('6-8 players assigns exactly 2 impostors', () {
      for (int count = 6; count <= 8; count++) {
        engine.initializeRoom(
          localUserId: 'user_1',
          localDisplayName: 'Player1',
          localAvatarId: 'avatar_phoenix',
          playerCount: count,
        );
        engine.startMatch();

        final List<HiddenHandPlayer> impostors = engine.state.impostors;
        final List<HiddenHandPlayer> artists =
            engine.state.players.where((p) => p.isArtist).toList();

        expect(impostors.length, 2, reason: 'Count $count should have 2 impostors');
        expect(artists.length, count - 2, reason: 'Count $count should have ${count - 2} artists');
      }
    });

    test('drawing stroke adds to engine state when active', () {
      engine.initializeRoom(
        localUserId: 'user_1',
        localDisplayName: 'Player1',
        localAvatarId: 'avatar_phoenix',
        playerCount: 4,
      );
      engine.startMatch();
      engine.beginDrawingPhase();

      final String activePlayerId = engine.state.currentTurnPlayerId;
      const DrawingStroke stroke = DrawingStroke(
        playerId: 'user_1',
        points: <DrawingPoint>[DrawingPoint(10, 20), DrawingPoint(15, 25)],
        colorValue: 0xffefc249,
      );

      if (activePlayerId == 'user_1') {
        engine.addStroke(stroke);
        expect(engine.state.strokes.length, 1);
        expect(engine.state.strokes.first.points.length, 2);
      }
    });

    test('impostor guess correctly gives victory to Impostor', () {
      engine.initializeRoom(
        localUserId: 'user_1',
        localDisplayName: 'Player1',
        localAvatarId: 'avatar_phoenix',
        playerCount: 4,
      );
      engine.startMatch();

      // Force state into impostorGuess phase with known prompt
      const DrawingWordPrompt testPrompt = DrawingWordPrompt(
        word: 'Pizza',
        category: 'Food',
        synonyms: <String>['pie'],
      );

      engine.emitState(engine.state.copyWith(
        phase: GamePhase.impostorGuess,
        secretPrompt: testPrompt,
        eliminatedPlayer: const HiddenHandPlayer(
          id: 'user_1',
          displayName: 'Player1',
          avatarId: 'avatar_phoenix',
          role: PlayerRole.impostor,
        ),
      ));

      engine.submitImpostorGuess('pizza');

      expect(engine.state.phase, GamePhase.gameOver);
      expect(engine.state.winningRole, PlayerRole.impostor);
      expect(engine.state.impostorGuessCorrect, isTrue);
    });

    test('impostor guess wrong gives victory to Artists', () {
      engine.initializeRoom(
        localUserId: 'user_1',
        localDisplayName: 'Player1',
        localAvatarId: 'avatar_phoenix',
        playerCount: 4,
      );
      engine.startMatch();

      const DrawingWordPrompt testPrompt = DrawingWordPrompt(
        word: 'Pizza',
        category: 'Food',
      );

      engine.emitState(engine.state.copyWith(
        phase: GamePhase.impostorGuess,
        secretPrompt: testPrompt,
        eliminatedPlayer: const HiddenHandPlayer(
          id: 'user_1',
          displayName: 'Player1',
          avatarId: 'avatar_phoenix',
          role: PlayerRole.impostor,
        ),
      ));

      engine.submitImpostorGuess('spaceship');

      expect(engine.state.phase, GamePhase.gameOver);
      expect(engine.state.winningRole, PlayerRole.artist);
      expect(engine.state.impostorGuessCorrect, isFalse);
    });
  });

  group('Hidden Hand - UI & Widget Tests', () {
    testWidgets('HiddenHandScreen initializes in lobby with player options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HiddenHandScreen()),
      );

      expect(find.text('HIDDEN HAND'), findsOneWidget);
      expect(find.text('ROOM SIZE:'), findsOneWidget);
      expect(find.text('START ROUND'), findsOneWidget);
      expect(find.byType(DrawingCanvasWidget), findsOneWidget);
    });

    testWidgets('DrawingToolbar renders colors and done button when interactive', (tester) async {
      bool doneTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingToolbar(
              selectedColor: const Color(0xffefc249),
              selectedWidth: 4.0,
              isInteractive: true,
              onColorSelected: (_) {},
              onWidthSelected: (_) {},
              onDoneTurn: () => doneTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('DONE'), findsOneWidget);
      await tester.tap(find.text('DONE'));
      expect(doneTapped, isTrue);
    });
  });
}
