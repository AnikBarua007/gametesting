import 'sketch_party_player.dart';
import 'sketch_party_word.dart';
import 'sketch_stroke.dart';

enum SketchPartyPhase {
  lobby,
  wordSelect,
  drawing,
  roundResult,
  gameOver,
}

enum ChatMessageType {
  normal,
  closeGuess,
  correctGuess,
  system,
}

class SketchChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final ChatMessageType type;
  final DateTime timestamp;

  const SketchChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.timestamp,
  });
}

class SketchPartyState {
  final String roomCode;
  final SketchPartyPhase phase;
  final List<SketchPartyPlayer> players;
  final String activeDrawerId;
  final int currentRound;
  final int totalRounds;
  final int turnIndex;
  final SketchPartyWord? currentWord;
  final List<SketchPartyWord> wordChoices;
  final String maskedHint;
  final int timeRemaining;
  final int turnDuration;
  final List<SketchStroke> strokes;
  final List<SketchChatMessage> chatMessages;
  final String statusMessage;
  final int correctGuessCount;

  const SketchPartyState({
    required this.roomCode,
    required this.phase,
    required this.players,
    required this.activeDrawerId,
    this.currentRound = 1,
    this.totalRounds = 3,
    this.turnIndex = 0,
    this.currentWord,
    this.wordChoices = const <SketchPartyWord>[],
    this.maskedHint = '',
    this.timeRemaining = 60,
    this.turnDuration = 60,
    this.strokes = const <SketchStroke>[],
    this.chatMessages = const <SketchChatMessage>[],
    this.statusMessage = '',
    this.correctGuessCount = 0,
  });

  bool isDrawer(String userId) => activeDrawerId == userId;

  SketchPartyPlayer? get activeDrawer {
    try {
      return players.firstWhere((p) => p.id == activeDrawerId);
    } catch (_) {
      return null;
    }
  }

  SketchPartyPlayer? getPlayer(String userId) {
    try {
      return players.firstWhere((p) => p.id == userId);
    } catch (_) {
      return null;
    }
  }

  SketchPartyState copyWith({
    String? roomCode,
    SketchPartyPhase? phase,
    List<SketchPartyPlayer>? players,
    String? activeDrawerId,
    int? currentRound,
    int? totalRounds,
    int? turnIndex,
    SketchPartyWord? currentWord,
    List<SketchPartyWord>? wordChoices,
    String? maskedHint,
    int? timeRemaining,
    int? turnDuration,
    List<SketchStroke>? strokes,
    List<SketchChatMessage>? chatMessages,
    String? statusMessage,
    int? correctGuessCount,
  }) {
    return SketchPartyState(
      roomCode: roomCode ?? this.roomCode,
      phase: phase ?? this.phase,
      players: players ?? this.players,
      activeDrawerId: activeDrawerId ?? this.activeDrawerId,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      turnIndex: turnIndex ?? this.turnIndex,
      currentWord: currentWord ?? this.currentWord,
      wordChoices: wordChoices ?? this.wordChoices,
      maskedHint: maskedHint ?? this.maskedHint,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      turnDuration: turnDuration ?? this.turnDuration,
      strokes: strokes ?? this.strokes,
      chatMessages: chatMessages ?? this.chatMessages,
      statusMessage: statusMessage ?? this.statusMessage,
      correctGuessCount: correctGuessCount ?? this.correctGuessCount,
    );
  }
}
