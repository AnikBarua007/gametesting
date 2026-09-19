import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/profile_service.dart';
import '../models/sketch_party_player.dart';
import '../models/sketch_party_state.dart';
import '../models/sketch_party_word.dart';
import '../models/sketch_stroke.dart';
import 'sketch_bot_ai.dart';
import 'sketch_word_catalog.dart';

class SketchPartyEngine {
  late SketchPartyState _state;
  final StreamController<SketchPartyState> _stateController =
      StreamController<SketchPartyState>.broadcast();

  Timer? _gameTimer;
  Timer? _botDrawTimer;
  final Random _random = Random();
  final SketchBotAI _botAI = SketchBotAI();

  List<SketchStroke> _botTargetStrokes = <SketchStroke>[];
  int _botStrokeIndex = 0;

  Stream<SketchPartyState> get stateStream => _stateController.stream;
  SketchPartyState get state => _state;

  SketchPartyEngine() {
    _initDefaultState();
  }

  void _initDefaultState() {
    _state = SketchPartyState(
      roomCode: 'PARTY-${1000 + _random.nextInt(9000)}',
      phase: SketchPartyPhase.lobby,
      players: const <SketchPartyPlayer>[],
      activeDrawerId: '',
      statusMessage: 'Waiting in lobby',
    );
  }

  void emitState(SketchPartyState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Sets up room with local human player and configured bot participants.
  void initializeRoom({
    required String localUserId,
    required String localDisplayName,
    required String localAvatarId,
    int totalPlayers = 4,
  }) {
    _cancelTimers();

    final int count = totalPlayers.clamp(2, 8);
    final List<SketchPartyPlayer> players = <SketchPartyPlayer>[
      SketchPartyPlayer(
        id: localUserId,
        displayName: localDisplayName,
        avatarId: localAvatarId,
        isHost: true,
        isBot: false,
      ),
    ];

    final List<String> botNames = <String>[
      'Pixel',
      'Nova',
      'Maya',
      'Atlas',
      'Viper',
      'Echo',
      'Blaze',
    ];
    final List<String> botAvatars = <String>[
      'avatar_cyber',
      'avatar_ninja',
      'avatar_astro',
      'avatar_specter',
      'avatar_monarch',
      'avatar_phoenix',
      'avatar_default',
    ];

    for (int i = 1; i < count; i++) {
      final int botIdx = (i - 1) % botNames.length;
      players.add(SketchPartyPlayer(
        id: 'bot_party_$i',
        displayName: botNames[botIdx],
        avatarId: botAvatars[botIdx],
        isHost: false,
        isBot: true,
      ));
    }

    emitState(_state.copyWith(
      players: players,
      activeDrawerId: players.first.id,
      phase: SketchPartyPhase.lobby,
      statusMessage: 'Ready to start match',
    ));
  }

  /// Begins the match and starts the first turn.
  void startMatch() {
    if (_state.players.isEmpty) return;

    final List<SketchPartyPlayer> resetPlayers = _state.players
        .map((p) => p.copyWith(
              totalScore: 0,
              roundScore: 0,
              hasGuessed: false,
              guessTimeRemaining: null,
            ))
        .toList();

    emitState(_state.copyWith(
      players: resetPlayers,
      currentRound: 1,
      turnIndex: 0,
      activeDrawerId: resetPlayers.first.id,
      strokes: const <SketchStroke>[],
      chatMessages: const <SketchChatMessage>[],
    ));

    _startTurn();
  }

  void _startTurn() {
    _cancelTimers();

    // Reset round scores & guessed flags for all players
    final List<SketchPartyPlayer> updatedPlayers = _state.players
        .map((p) => p.copyWith(
              roundScore: 0,
              hasGuessed: false,
              guessTimeRemaining: null,
            ))
        .toList();

    final SketchPartyPlayer currentDrawer =
        updatedPlayers[_state.turnIndex % updatedPlayers.length];
    final List<SketchPartyWord> choices =
        SketchWordCatalog.getWordChoices(_random);

    emitState(_state.copyWith(
      players: updatedPlayers,
      activeDrawerId: currentDrawer.id,
      wordChoices: choices,
      strokes: const <SketchStroke>[],
      correctGuessCount: 0,
      phase: SketchPartyPhase.wordSelect,
      statusMessage: '${currentDrawer.displayName} is choosing a word...',
    ));

    // If active drawer is a bot, pick a word automatically after 1.5 seconds
    if (currentDrawer.isBot) {
      Timer(const Duration(milliseconds: 1500), () {
        if (_state.phase == SketchPartyPhase.wordSelect) {
          // Bot picks medium or easy
          final SketchPartyWord botPick = choices[_random.nextInt(2)];
          selectWord(botPick);
        }
      });
    }
  }

  /// Drawer picks a word and 60-second drawing phase begins.
  void selectWord(SketchPartyWord word) {
    _cancelTimers();

    final String initialMask =
        SketchWordCatalog.generateMaskedHint(word.word, 0.0);

    emitState(_state.copyWith(
      currentWord: word,
      maskedHint: initialMask,
      phase: SketchPartyPhase.drawing,
      timeRemaining: 60,
      turnDuration: 60,
      strokes: const <SketchStroke>[],
      statusMessage: '${_state.activeDrawer?.displayName ?? 'Drawer'} is sketching!',
    ));

    // If bot is drawer, prepare procedural strokes
    if (_state.activeDrawer?.isBot ?? false) {
      _botTargetStrokes = _botAI.generateProceduralStrokes(
        word,
        canvasSize: const Size(380, 420),
      );
      _botStrokeIndex = 0;
      _startBotDrawingTimer();
    }

    _startGameTimer();
  }

  void _startBotDrawingTimer() {
    _botDrawTimer?.cancel();
    _botDrawTimer = Timer.periodic(const Duration(milliseconds: 1200), (Timer t) {
      if (_state.phase != SketchPartyPhase.drawing) {
        t.cancel();
        return;
      }
      if (_botStrokeIndex < _botTargetStrokes.length) {
        final List<SketchStroke> current = List<SketchStroke>.from(_state.strokes);
        current.add(_botTargetStrokes[_botStrokeIndex]);
        _botStrokeIndex++;
        emitState(_state.copyWith(strokes: current));
      } else {
        t.cancel();
      }
    });
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_state.phase != SketchPartyPhase.drawing) {
        t.cancel();
        return;
      }

      final int newTime = _state.timeRemaining - 1;

      if (newTime <= 0) {
        t.cancel();
        _endTurn();
        return;
      }

      // Update masked hint as time passes
      final double progress = 1.0 - (newTime / _state.turnDuration);
      final String updatedHint = SketchWordCatalog.generateMaskedHint(
        _state.currentWord?.word ?? '',
        progress,
      );

      // Simulate bot guesses
      _processBotGuesses(newTime);

      emitState(_state.copyWith(
        timeRemaining: newTime,
        maskedHint: updatedHint,
      ));
    });
  }

  void _processBotGuesses(int timeRemaining) {
    final SketchPartyWord? word = _state.currentWord;
    if (word == null) return;

    for (final SketchPartyPlayer player in _state.players) {
      if (!player.isBot || player.id == _state.activeDrawerId || player.hasGuessed) {
        continue;
      }

      final ({String text, bool isCorrect})? botGuess = _botAI.generateBotGuess(
        bot: player,
        currentWord: word,
        timeRemaining: timeRemaining,
        totalDuration: _state.turnDuration,
      );

      if (botGuess != null) {
        submitGuess(
          botGuess.text,
          playerId: player.id,
          playerName: player.displayName,
        );
      }
    }
  }

  /// Submit a drawn stroke (called from local drawer canvas).
  void submitStroke(SketchStroke stroke) {
    if (_state.phase != SketchPartyPhase.drawing) return;
    final List<SketchStroke> updated = List<SketchStroke>.from(_state.strokes)
      ..add(stroke);
    emitState(_state.copyWith(strokes: updated));
  }

  /// Undo the last drawn stroke.
  void undoStroke() {
    if (_state.strokes.isEmpty) return;
    final List<SketchStroke> updated = List<SketchStroke>.from(_state.strokes)
      ..removeLast();
    emitState(_state.copyWith(strokes: updated));
  }

  /// Clear the entire canvas.
  void clearCanvas() {
    if (_state.strokes.isEmpty) return;
    emitState(_state.copyWith(strokes: const <SketchStroke>[]));
  }

  /// Submits a guess from a player.
  void submitGuess(
    String rawGuess, {
    required String playerId,
    required String playerName,
  }) {
    if (_state.phase != SketchPartyPhase.drawing) return;
    final String guess = rawGuess.trim();
    if (guess.isEmpty) return;

    final SketchPartyWord? targetWord = _state.currentWord;
    if (targetWord == null) return;

    final SketchPartyPlayer? player = _state.getPlayer(playerId);
    if (player == null || player.hasGuessed || playerId == _state.activeDrawerId) {
      return;
    }

    final List<SketchChatMessage> messages =
        List<SketchChatMessage>.from(_state.chatMessages);

    if (targetWord.matches(guess)) {
      // Correct guess!
      final bool isFirstGuesser = _state.correctGuessCount == 0;
      final int difficultyBase = targetWord.difficulty.basePoints;
      final int timeBonus = _state.timeRemaining * 3;
      final int speedBonus = isFirstGuesser ? 50 : 0;
      final int earnedGuesserPoints = difficultyBase + timeBonus + speedBonus;

      final int newCorrectCount = _state.correctGuessCount + 1;

      // Update player scores
      final List<SketchPartyPlayer> updatedPlayers = _state.players.map((p) {
        if (p.id == playerId) {
          return p.copyWith(
            hasGuessed: true,
            guessTimeRemaining: _state.timeRemaining,
            roundScore: earnedGuesserPoints,
            totalScore: p.totalScore + earnedGuesserPoints,
          );
        }
        return p;
      }).toList();

      // Drawer also earns 50 points per correct guesser
      const int drawerBonusPerGuess = 50;
      final List<SketchPartyPlayer> withDrawerBonus = updatedPlayers.map((p) {
        if (p.id == _state.activeDrawerId) {
          return p.copyWith(
            roundScore: p.roundScore + drawerBonusPerGuess,
            totalScore: p.totalScore + drawerBonusPerGuess,
          );
        }
        return p;
      }).toList();

      messages.add(SketchChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: playerId,
        senderName: playerName,
        text: '🎉 $playerName guessed the word! (+${earnedGuesserPoints}pts)',
        type: ChatMessageType.correctGuess,
        timestamp: DateTime.now(),
      ));

      emitState(_state.copyWith(
        players: withDrawerBonus,
        chatMessages: messages,
        correctGuessCount: newCorrectCount,
      ));

      // Check if all guessers have guessed!
      final int totalGuessers = _state.players.length - 1;
      if (newCorrectCount >= totalGuessers) {
        // Bonus 50 points to drawer for 100% completion!
        final List<SketchPartyPlayer> finalPlayers = _state.players.map((p) {
          if (p.id == _state.activeDrawerId) {
            return p.copyWith(
              roundScore: p.roundScore + 50,
              totalScore: p.totalScore + 50,
            );
          }
          return p;
        }).toList();

        emitState(_state.copyWith(players: finalPlayers));
        _endTurn(allGuessed: true);
      }
    } else if (targetWord.isClose(guess)) {
      // Close guess feedback
      messages.add(SketchChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: playerId,
        senderName: playerName,
        text: guess,
        type: ChatMessageType.normal,
        timestamp: DateTime.now(),
      ));
      messages.add(SketchChatMessage(
        id: 'hint_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'System',
        text: '⚡ "$guess" is so close! (off by 1 letter)',
        type: ChatMessageType.closeGuess,
        timestamp: DateTime.now(),
      ));
      emitState(_state.copyWith(chatMessages: messages));
    } else {
      // Normal chat guess
      messages.add(SketchChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: playerId,
        senderName: playerName,
        text: guess,
        type: ChatMessageType.normal,
        timestamp: DateTime.now(),
      ));
      emitState(_state.copyWith(chatMessages: messages));
    }
  }

  void _endTurn({bool allGuessed = false}) {
    _cancelTimers();

    final String wordName = _state.currentWord?.word.toUpperCase() ?? '';
    final String status = allGuessed
        ? 'Everyone guessed "$wordName"!'
        : 'Time\'s up! The word was "$wordName"';

    emitState(_state.copyWith(
      phase: SketchPartyPhase.roundResult,
      statusMessage: status,
    ));
  }

  /// Advances to the next turn or ends the game if rounds complete.
  void nextTurn() {
    _cancelTimers();

    final int nextTurnIndex = _state.turnIndex + 1;
    final int playerCount = _state.players.length;

    if (nextTurnIndex >= playerCount * _state.totalRounds) {
      // All rounds complete! Finalize match & update profile
      _finishGame();
      return;
    }

    final int newRound = (nextTurnIndex ~/ playerCount) + 1;

    emitState(_state.copyWith(
      turnIndex: nextTurnIndex,
      currentRound: newRound,
    ));

    _startTurn();
  }

  void _finishGame() {
    _cancelTimers();

    // Calculate final player rankings by score
    final List<SketchPartyPlayer> sorted = List<SketchPartyPlayer>.from(_state.players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    final List<SketchPartyPlayer> ranked = <SketchPartyPlayer>[];
    for (int i = 0; i < sorted.length; i++) {
      ranked.add(sorted[i].copyWith(rank: i + 1));
    }

    emitState(_state.copyWith(
      phase: SketchPartyPhase.gameOver,
      players: ranked,
      statusMessage: 'Game Over! Congratulations ${ranked.first.displayName}!',
    ));

    _syncProfileStats(ranked);
  }

  Future<void> _syncProfileStats(List<SketchPartyPlayer> ranked) async {
    try {
      final SketchPartyPlayer? localPlayer =
          ranked.where((p) => !p.isBot).firstOrNull;
      if (localPlayer == null) return;

      final bool isWinner = localPlayer.rank == 1;
      final UserProfile? profile =
          await ProfileService.instance.getProfile(localPlayer.id);
      if (profile != null) {
        final PlayerStats currentStats = profile.stats;
        final PlayerStats newStats = currentStats.copyWith(
          gamesPlayed: currentStats.gamesPlayed + 1,
          wins: currentStats.wins + (isWinner ? 1 : 0),
          favoriteGame: 'sketch-party',
        );
        final UserProfile updatedProfile = profile.copyWith(
          stats: newStats,
          lastActive: DateTime.now(),
        );
        await ProfileService.instance.saveProfile(updatedProfile);
      }
    } catch (e) {
      debugPrint('[SketchParty] Profile stats sync: $e');
    }
  }

  void _cancelTimers() {
    _gameTimer?.cancel();
    _gameTimer = null;
    _botDrawTimer?.cancel();
    _botDrawTimer = null;
  }

  void dispose() {
    _cancelTimers();
    _stateController.close();
  }
}
