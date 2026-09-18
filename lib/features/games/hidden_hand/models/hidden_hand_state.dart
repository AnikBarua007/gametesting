import 'drawing_stroke.dart';
import 'game_words.dart';
import 'hidden_hand_player.dart';

enum GamePhase {
  lobby,
  roleReveal,
  drawing,
  voting,
  impostorGuess,
  gameOver,
}

class HiddenHandState {
  final String roomCode;
  final GamePhase phase;
  final List<HiddenHandPlayer> players;
  final String currentTurnPlayerId;
  final DrawingWordPrompt secretPrompt;
  final List<DrawingStroke> strokes;
  final int roundNumber;
  final int turnTimeRemaining;
  final HiddenHandPlayer? eliminatedPlayer;
  final PlayerRole? winningRole;
  final bool? impostorGuessCorrect;
  final String? impostorSubmittedGuess;
  final String statusMessage;

  const HiddenHandState({
    required this.roomCode,
    required this.phase,
    required this.players,
    required this.currentTurnPlayerId,
    required this.secretPrompt,
    this.strokes = const <DrawingStroke>[],
    this.roundNumber = 1,
    this.turnTimeRemaining = 15,
    this.eliminatedPlayer,
    this.winningRole,
    this.impostorGuessCorrect,
    this.impostorSubmittedGuess,
    this.statusMessage = 'Waiting in lobby...',
  });

  List<HiddenHandPlayer> get activePlayers =>
      players.where((p) => !p.isEliminated).toList();

  List<HiddenHandPlayer> get impostors =>
      players.where((p) => p.isImpostor).toList();

  List<HiddenHandPlayer> get activeArtists =>
      players.where((p) => !p.isEliminated && p.isArtist).toList();

  List<HiddenHandPlayer> get activeImpostors =>
      players.where((p) => !p.isEliminated && p.isImpostor).toList();

  HiddenHandPlayer? get currentTurnPlayer {
    for (final HiddenHandPlayer player in players) {
      if (player.id == currentTurnPlayerId) return player;
    }
    return null;
  }

  HiddenHandPlayer? getPlayer(String id) {
    for (final HiddenHandPlayer player in players) {
      if (player.id == id) return player;
    }
    return null;
  }

  HiddenHandState copyWith({
    String? roomCode,
    GamePhase? phase,
    List<HiddenHandPlayer>? players,
    String? currentTurnPlayerId,
    DrawingWordPrompt? secretPrompt,
    List<DrawingStroke>? strokes,
    int? roundNumber,
    int? turnTimeRemaining,
    HiddenHandPlayer? eliminatedPlayer,
    bool clearEliminatedPlayer = false,
    PlayerRole? winningRole,
    bool? impostorGuessCorrect,
    String? impostorSubmittedGuess,
    String? statusMessage,
  }) {
    return HiddenHandState(
      roomCode: roomCode ?? this.roomCode,
      phase: phase ?? this.phase,
      players: players ?? this.players,
      currentTurnPlayerId: currentTurnPlayerId ?? this.currentTurnPlayerId,
      secretPrompt: secretPrompt ?? this.secretPrompt,
      strokes: strokes ?? this.strokes,
      roundNumber: roundNumber ?? this.roundNumber,
      turnTimeRemaining: turnTimeRemaining ?? this.turnTimeRemaining,
      eliminatedPlayer: clearEliminatedPlayer
          ? null
          : (eliminatedPlayer ?? this.eliminatedPlayer),
      winningRole: winningRole ?? this.winningRole,
      impostorGuessCorrect: impostorGuessCorrect ?? this.impostorGuessCorrect,
      impostorSubmittedGuess:
          impostorSubmittedGuess ?? this.impostorSubmittedGuess,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

