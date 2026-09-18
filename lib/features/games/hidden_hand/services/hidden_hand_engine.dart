import 'dart:async';
import 'dart:math';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import '../models/drawing_stroke.dart';
import '../models/game_words.dart';
import '../models/hidden_hand_player.dart';
import '../models/hidden_hand_state.dart';

class HiddenHandEngine {
  late HiddenHandState _state;
  final StreamController<HiddenHandState> _stateController =
      StreamController<HiddenHandState>.broadcast();

  Timer? _turnTimer;
  Timer? _botActionTimer;
  final Random _random = Random();

  Stream<HiddenHandState> get stateStream => _stateController.stream;
  HiddenHandState get state => _state;

  static const List<int> _playerPalette = <int>[
    0xffefc249, // Golden Amber
    0xff08abc4, // Cyan
    0xffec4899, // Hot Pink
    0xff10b981, // Emerald Green
    0xffa855f7, // Purple
    0xfff97316, // Orange
    0xff3b82f6, // Royal Blue
    0xffe2e8f0, // Silver White
  ];

  HiddenHandEngine() {
    _initDefaultState();
  }

  void _initDefaultState() {
    final DrawingWordPrompt prompt = GameWordDatabase.getRandomPrompt(_random);
    _state = HiddenHandState(
      roomCode: 'HAND-${1000 + _random.nextInt(9000)}',
      phase: GamePhase.lobby,
      players: const <HiddenHandPlayer>[],
      currentTurnPlayerId: '',
      secretPrompt: prompt,
      statusMessage: 'Ready in lobby',
    );
  }

  void emitState(HiddenHandState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Sets up a room with the local human player and [playerCount] total players.
  void initializeRoom({
    required String localUserId,
    required String localDisplayName,
    required String localAvatarId,
    int playerCount = 4,
  }) {
    _turnTimer?.cancel();
    _botActionTimer?.cancel();

    final int count = playerCount.clamp(3, 8);
    final List<HiddenHandPlayer> players = <HiddenHandPlayer>[
      HiddenHandPlayer(
        id: localUserId,
        displayName: localDisplayName,
        avatarId: localAvatarId,
        isHost: true,
        isBot: false,
        assignedColorValue: _playerPalette[0],
      ),
    ];

    final List<String> botNames = <String>[
      'Nova',
      'Pixel',
      'Viper',
      'Echo',
      'Blaze',
      'Atlas',
      'Cipher',
    ];
    final List<String> botAvatars = <String>[
      'avatar_cyber',
      'avatar_ninja',
      'avatar_astro',
      'avatar_specter',
      'avatar_monarch',
      'avatar_phoenix',
    ];

    for (int i = 1; i < count; i++) {
      players.add(
        HiddenHandPlayer(
          id: 'bot_$i',
          displayName: botNames[(i - 1) % botNames.length],
          avatarId: botAvatars[(i - 1) % botAvatars.length],
          isHost: false,
          isBot: true,
          assignedColorValue: _playerPalette[i % _playerPalette.length],
        ),
      );
    }

    emitState(_state.copyWith(
      phase: GamePhase.lobby,
      players: players,
      statusMessage: '$count players ready in lobby.',
    ));
  }

  /// Starts the match: assigns roles according to rules and enters Role Reveal.
  /// 3-5 players -> 1 Impostor
  /// 6-8 players -> 2 Impostors
  void startMatch() {
    _turnTimer?.cancel();
    _botActionTimer?.cancel();

    final List<HiddenHandPlayer> currentPlayers = List<HiddenHandPlayer>.from(_state.players);
    if (currentPlayers.length < 3) return;

    final DrawingWordPrompt prompt = GameWordDatabase.getRandomPrompt(_random);

    // Rule: 3-5 players = 1 Impostor, 6-8 players = 2 Impostors
    final int impostorCount = currentPlayers.length <= 5 ? 1 : 2;

    final List<int> indices = List<int>.generate(currentPlayers.length, (i) => i);
    indices.shuffle(_random);
    final Set<int> impostorIndices = indices.take(impostorCount).toSet();

    final List<HiddenHandPlayer> assignedPlayers = <HiddenHandPlayer>[];
    for (int i = 0; i < currentPlayers.length; i++) {
      final bool isImpostor = impostorIndices.contains(i);
      assignedPlayers.add(
        currentPlayers[i].copyWith(
          role: isImpostor ? PlayerRole.impostor : PlayerRole.artist,
          isEliminated: false,
          hasDrawnThisTurn: false,
          clearVote: true,
        ),
      );
    }

    emitState(_state.copyWith(
      phase: GamePhase.roleReveal,
      players: assignedPlayers,
      secretPrompt: prompt,
      strokes: <DrawingStroke>[],
      roundNumber: 1,
      clearEliminatedPlayer: true,
      winningRole: null,
      impostorGuessCorrect: null,
      impostorSubmittedGuess: null,
      statusMessage: 'Memorize your role!',
    ));

    // After 4.5 seconds of role reveal, begin drawing turn
    _botActionTimer = Timer(const Duration(milliseconds: 4500), () {
      beginDrawingPhase();
    });
  }

  /// Begins or resumes the collaborative drawing turn sequence
  void beginDrawingPhase() {
    _turnTimer?.cancel();
    _botActionTimer?.cancel();

    // Reset turn flags for active players
    final List<HiddenHandPlayer> refreshed = _state.players.map((p) {
      return p.copyWith(hasDrawnThisTurn: false, clearVote: true);
    }).toList();

    final HiddenHandPlayer firstPlayer = refreshed.firstWhere((p) => !p.isEliminated);

    emitState(_state.copyWith(
      phase: GamePhase.drawing,
      players: refreshed,
      currentTurnPlayerId: firstPlayer.id,
      turnTimeRemaining: 15,
      statusMessage: "${firstPlayer.displayName}'s turn to draw",
    ));

    _startTurnTimer();
    _checkBotTurn();
  }

  void _startTurnTimer() {
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.turnTimeRemaining <= 1) {
        timer.cancel();
        endPlayerTurn(_state.currentTurnPlayerId);
      } else {
        emitState(_state.copyWith(turnTimeRemaining: _state.turnTimeRemaining - 1));
      }
    });
  }

  void _checkBotTurn() {
    final HiddenHandPlayer? current = _state.currentTurnPlayer;
    if (current != null && current.isBot && !current.isEliminated) {
      _botActionTimer?.cancel();
      // Bot simulates drawing after 1.2 to 2.2 seconds
      final int delayMs = 1200 + _random.nextInt(1000);
      _botActionTimer = Timer(Duration(milliseconds: delayMs), () {
        _simulateBotStroke(current);
        endPlayerTurn(current.id);
      });
    }
  }

  void _simulateBotStroke(HiddenHandPlayer bot) {
    // Generate procedural stylized strokes within canvas coordinates (approx 300x300 area)
    final double cx = 100.0 + _random.nextDouble() * 150.0;
    final double cy = 100.0 + _random.nextDouble() * 150.0;
    final List<DrawingPoint> points = <DrawingPoint>[];

    final int strokeType = _random.nextInt(3);
    if (strokeType == 0) {
      // Arc / curve
      final double radius = 25.0 + _random.nextDouble() * 40.0;
      final double startAngle = _random.nextDouble() * pi;
      for (int i = 0; i <= 6; i++) {
        final double a = startAngle + (i * (pi / 5));
        points.add(DrawingPoint(cx + cos(a) * radius, cy + sin(a) * radius));
      }
    } else if (strokeType == 1) {
      // Straight feature line
      final double dx = (_random.nextDouble() - 0.5) * 70.0;
      final double dy = (_random.nextDouble() - 0.5) * 70.0;
      points.add(DrawingPoint(cx, cy));
      points.add(DrawingPoint(cx + dx * 0.5, cy + dy * 0.5));
      points.add(DrawingPoint(cx + dx, cy + dy));
    } else {
      // Zigzag / detail
      points.add(DrawingPoint(cx - 20, cy - 10));
      points.add(DrawingPoint(cx, cy + 15));
      points.add(DrawingPoint(cx + 20, cy - 10));
    }

    final DrawingStroke botStroke = DrawingStroke(
      playerId: bot.id,
      points: points,
      colorValue: bot.assignedColorValue,
      strokeWidth: 4.0,
    );

    final List<DrawingStroke> updatedStrokes = List<DrawingStroke>.from(_state.strokes)..add(botStroke);
    emitState(_state.copyWith(strokes: updatedStrokes));
  }

  /// Appends a new stroke drawn by the active player
  void addStroke(DrawingStroke stroke) {
    if (_state.phase != GamePhase.drawing) return;
    if (stroke.playerId != _state.currentTurnPlayerId) return;

    final List<DrawingStroke> updated = List<DrawingStroke>.from(_state.strokes)..add(stroke);
    emitState(_state.copyWith(strokes: updated));
  }

  /// Ends the current player's drawing turn and rotates or triggers voting
  void endPlayerTurn(String playerId) {
    _turnTimer?.cancel();
    _botActionTimer?.cancel();

    // Mark current player as having drawn
    final List<HiddenHandPlayer> updatedPlayers = _state.players.map((p) {
      if (p.id == playerId) return p.copyWith(hasDrawnThisTurn: true);
      return p;
    }).toList();

    // Find next active player who hasn't drawn this round
    final List<HiddenHandPlayer> active =
        updatedPlayers.where((p) => !p.isEliminated).toList();
    final List<HiddenHandPlayer> remainingToDraw =
        active.where((p) => !p.hasDrawnThisTurn).toList();

    if (remainingToDraw.isNotEmpty) {
      final HiddenHandPlayer nextPlayer = remainingToDraw.first;
      emitState(_state.copyWith(
        players: updatedPlayers,
        currentTurnPlayerId: nextPlayer.id,
        turnTimeRemaining: 15,
        statusMessage: "${nextPlayer.displayName}'s turn to draw",
      ));
      _startTurnTimer();
      _checkBotTurn();
    } else {
      // Every active player has drawn once this round! Trigger Emergency Voting
      emitState(_state.copyWith(
        players: updatedPlayers,
        phase: GamePhase.voting,
        statusMessage: 'Round ${_state.roundNumber} complete! Vote or Skip.',
      ));

      _handleBotVoting();
    }
  }

  /// Simulates bot votes with realistic suspicion and skips
  void _handleBotVoting() {
    _botActionTimer?.cancel();
    _botActionTimer = Timer(const Duration(milliseconds: 1400), () {
      final List<HiddenHandPlayer> alive = _state.activePlayers;
      final List<HiddenHandPlayer> updated = List<HiddenHandPlayer>.from(_state.players);

      for (int i = 0; i < updated.length; i++) {
        final HiddenHandPlayer p = updated[i];
        if (p.isBot && !p.isEliminated && p.voteTargetId == null) {
          // 35% chance bot skips, 65% chance bot votes for someone else
          if (_random.nextDouble() < 0.35) {
            updated[i] = p.copyWith(voteTargetId: 'SKIP');
          } else {
            final List<HiddenHandPlayer> targets =
                alive.where((candidate) => candidate.id != p.id).toList();
            if (targets.isNotEmpty) {
              final HiddenHandPlayer target = targets[_random.nextInt(targets.length)];
              updated[i] = p.copyWith(voteTargetId: target.id);
            }
          }
        }
      }

      emitState(_state.copyWith(players: updated));
    });
  }

  /// Casts a vote from [voterId] to [targetId] ('SKIP' or another player's id)
  void castVote(String voterId, String targetId) {
    if (_state.phase != GamePhase.voting) return;

    final List<HiddenHandPlayer> updated = _state.players.map((p) {
      if (p.id == voterId) return p.copyWith(voteTargetId: targetId);
      return p;
    }).toList();

    emitState(_state.copyWith(players: updated));

    // Check if all active players have voted
    final List<HiddenHandPlayer> alive =
        updated.where((p) => !p.isEliminated).toList();
    final bool allVoted = alive.every((p) => p.voteTargetId != null);

    if (allVoted) {
      _resolveVoting();
    }
  }

  /// Calculates vote tally and decides elimination or next round
  void _resolveVoting() {
    final List<HiddenHandPlayer> alive = _state.activePlayers;
    final Map<String, int> tally = <String, int>{};

    for (final HiddenHandPlayer p in alive) {
      if (p.voteTargetId != null) {
        tally[p.voteTargetId!] = (tally[p.voteTargetId!] ?? 0) + 1;
      }
    }

    final int majorityNeeded = (alive.length / 2).floor() + 1;
    String? mostVotedId;
    int highestCount = 0;

    tally.forEach((targetId, count) {
      if (count > highestCount) {
        highestCount = count;
        mostVotedId = targetId;
      }
    });

    // If Skip received the most votes or no target reached strict majority
    if (mostVotedId == null || mostVotedId == 'SKIP' || highestCount < majorityNeeded) {
      emitState(_state.copyWith(
        statusMessage: 'Vote skipped! Continuing to next drawing round.',
      ));

      Timer(const Duration(milliseconds: 2200), () {
        emitState(_state.copyWith(
          roundNumber: _state.roundNumber + 1,
        ));
        beginDrawingPhase();
      });
      return;
    }

    // A player reached majority!
    final HiddenHandPlayer eliminated =
        alive.firstWhere((p) => p.id == mostVotedId);

    final List<HiddenHandPlayer> postElimination = _state.players.map((p) {
      if (p.id == eliminated.id) return p.copyWith(isEliminated: true);
      return p;
    }).toList();

    // Was the eliminated player the Impostor?
    if (eliminated.isImpostor) {
      // Impostor caught! Trigger Impostor's Last Guess Climax!
      emitState(_state.copyWith(
        phase: GamePhase.impostorGuess,
        players: postElimination,
        eliminatedPlayer: eliminated,
        statusMessage: "${eliminated.displayName} was the HIDDEN HAND! Last chance to guess the object!",
      ));

      // If the caught impostor is a bot, auto-guess after delay
      if (eliminated.isBot) {
        Timer(const Duration(milliseconds: 2800), () {
          // Bot has 25% chance of guessing right
          final bool botGuessesRight = _random.nextDouble() < 0.25;
          final String guess = botGuessesRight
              ? _state.secretPrompt.word
              : '${_state.secretPrompt.category} object';
          submitImpostorGuess(guess);
        });
      }
    } else {
      // Innocent artist eliminated!
      final List<HiddenHandPlayer> remainingAlive =
          postElimination.where((p) => !p.isEliminated).toList();
      final List<HiddenHandPlayer> remainingArtists =
          remainingAlive.where((p) => p.isArtist).toList();

      // If only 2 players remain (e.g. 1 artist and 1 impostor), Impostor automatically wins!
      if (remainingAlive.length <= 2 || remainingArtists.isEmpty) {
        _concludeGame(
          winningRole: PlayerRole.impostor,
          players: postElimination,
          eliminated: eliminated,
          status: 'Only 2 players left! Impostor takes over the Arena!',
        );
      } else {
        // Game continues to next round
        emitState(_state.copyWith(
          players: postElimination,
          eliminatedPlayer: eliminated,
          statusMessage: "${eliminated.displayName} was INNOCENT! The Hidden Hand is still lurking.",
        ));

        Timer(const Duration(milliseconds: 2600), () {
          emitState(_state.copyWith(
            roundNumber: _state.roundNumber + 1,
            clearEliminatedPlayer: true,
          ));
          beginDrawingPhase();
        });
      }
    }
  }

  /// Submits the caught impostor's guess
  void submitImpostorGuess(String guess) {
    if (_state.phase != GamePhase.impostorGuess) return;

    final bool isCorrect = _state.secretPrompt.matchesGuess(guess);

    if (isCorrect) {
      // Impostor guessed correctly -> Impostor Wins!
      _concludeGame(
        winningRole: PlayerRole.impostor,
        guessCorrect: true,
        submittedGuess: guess,
        status: "CORRECT GUESS! The Hidden Hand guessed '${_state.secretPrompt.word}' and stole victory!",
      );
    } else {
      // Impostor failed guess -> Artists Win!
      _concludeGame(
        winningRole: PlayerRole.artist,
        guessCorrect: false,
        submittedGuess: guess,
        status: "WRONG GUESS! The secret was '${_state.secretPrompt.word}'. Artists Win!",
      );
    }
  }

  void _concludeGame({
    required PlayerRole winningRole,
    List<HiddenHandPlayer>? players,
    HiddenHandPlayer? eliminated,
    bool? guessCorrect,
    String? submittedGuess,
    required String status,
  }) {
    _turnTimer?.cancel();
    _botActionTimer?.cancel();

    final List<HiddenHandPlayer> finalPlayers = players ?? _state.players;

    emitState(_state.copyWith(
      phase: GamePhase.gameOver,
      players: finalPlayers,
      eliminatedPlayer: eliminated ?? _state.eliminatedPlayer,
      winningRole: winningRole,
      impostorGuessCorrect: guessCorrect,
      impostorSubmittedGuess: submittedGuess,
      statusMessage: status,
    ));

    _syncCareerStatsToFirestore(winningRole, finalPlayers);
  }

  /// Updates the local player's career statistics in Cloud Firestore
  Future<void> _syncCareerStatsToFirestore(
    PlayerRole winningRole,
    List<HiddenHandPlayer> players,
  ) async {
    final String? currentUid = AuthService.instance.currentUser?.uid;
    if (currentUid == null || currentUid.isEmpty) return;

    HiddenHandPlayer? localPlayer;
    for (final HiddenHandPlayer p in players) {
      if (p.id == currentUid) {
        localPlayer = p;
        break;
      }
    }
    if (localPlayer == null) return;

    final bool userWon = localPlayer.role == winningRole;

    try {
      final UserProfile? profile = await ProfileService.instance.getProfile(currentUid);
      if (profile != null) {
        final PlayerStats currentStats = profile.stats;
        final int updatedGames = currentStats.gamesPlayed + 1;
        final int updatedWins = currentStats.wins + (userWon ? 1 : 0);

        final PlayerStats newStats = currentStats.copyWith(
          gamesPlayed: updatedGames,
          wins: updatedWins,
          favoriteGame: 'hidden-hand',
        );

        final UserProfile updatedProfile = profile.copyWith(
          stats: newStats,
          lastActive: DateTime.now(),
        );

        await ProfileService.instance.saveProfile(updatedProfile);
      }
    } catch (_) {}
  }

  void dispose() {
    _turnTimer?.cancel();
    _botActionTimer?.cancel();
    _stateController.close();
  }
}
