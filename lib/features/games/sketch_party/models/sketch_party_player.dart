class SketchPartyPlayer {
  final String id;
  final String displayName;
  final String avatarId;
  final bool isHost;
  final bool isBot;
  final int totalScore;
  final int roundScore;
  final bool hasGuessed;
  final int? guessTimeRemaining; // Seconds remaining when guessed
  final int rank;

  const SketchPartyPlayer({
    required this.id,
    required this.displayName,
    required this.avatarId,
    this.isHost = false,
    this.isBot = false,
    this.totalScore = 0,
    this.roundScore = 0,
    this.hasGuessed = false,
    this.guessTimeRemaining,
    this.rank = 1,
  });

  SketchPartyPlayer copyWith({
    String? id,
    String? displayName,
    String? avatarId,
    bool? isHost,
    bool? isBot,
    int? totalScore,
    int? roundScore,
    bool? hasGuessed,
    int? guessTimeRemaining,
    int? rank,
  }) {
    return SketchPartyPlayer(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarId: avatarId ?? this.avatarId,
      isHost: isHost ?? this.isHost,
      isBot: isBot ?? this.isBot,
      totalScore: totalScore ?? this.totalScore,
      roundScore: roundScore ?? this.roundScore,
      hasGuessed: hasGuessed ?? this.hasGuessed,
      guessTimeRemaining: guessTimeRemaining ?? this.guessTimeRemaining,
      rank: rank ?? this.rank,
    );
  }
}

