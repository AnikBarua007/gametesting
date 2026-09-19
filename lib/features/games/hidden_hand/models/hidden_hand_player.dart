enum PlayerRole {
  artist,
  impostor,
}

class HiddenHandPlayer {
  final String id;
  final String displayName;
  final String avatarId;
  final PlayerRole role;
  final bool isBot;
  final bool isHost;
  final bool isEliminated;
  final String? voteTargetId; // null = hasn't voted, 'SKIP' = skipped, else target player id
  final bool hasDrawnThisTurn;
  final int assignedColorValue;

  const HiddenHandPlayer({
    required this.id,
    required this.displayName,
    required this.avatarId,
    this.role = PlayerRole.artist,
    this.isBot = false,
    this.isHost = false,
    this.isEliminated = false,
    this.voteTargetId,
    this.hasDrawnThisTurn = false,
    this.assignedColorValue = 0xffefc249,
  });

  bool get isImpostor => role == PlayerRole.impostor;
  bool get isArtist => role == PlayerRole.artist;

  HiddenHandPlayer copyWith({
    String? id,
    String? displayName,
    String? avatarId,
    PlayerRole? role,
    bool? isBot,
    bool? isHost,
    bool? isEliminated,
    String? voteTargetId,
    bool clearVote = false,
    bool? hasDrawnThisTurn,
    int? assignedColorValue,
  }) {
    return HiddenHandPlayer(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarId: avatarId ?? this.avatarId,
      role: role ?? this.role,
      isBot: isBot ?? this.isBot,
      isHost: isHost ?? this.isHost,
      isEliminated: isEliminated ?? this.isEliminated,
      voteTargetId: clearVote ? null : (voteTargetId ?? this.voteTargetId),
      hasDrawnThisTurn: hasDrawnThisTurn ?? this.hasDrawnThisTurn,
      assignedColorValue: assignedColorValue ?? this.assignedColorValue,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'displayName': displayName,
        'avatarId': avatarId,
        'role': role.name,
        'isBot': isBot,
        'isHost': isHost,
        'isEliminated': isEliminated,
        'voteTargetId': voteTargetId,
        'hasDrawnThisTurn': hasDrawnThisTurn,
        'assignedColorValue': assignedColorValue,
      };

  factory HiddenHandPlayer.fromMap(Map<String, dynamic> map) {
    return HiddenHandPlayer(
      id: map['id'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Player',
      avatarId: map['avatarId'] as String? ?? 'avatar_phoenix',
      role: (map['role'] as String?) == 'impostor'
          ? PlayerRole.impostor
          : PlayerRole.artist,
      isBot: map['isBot'] as bool? ?? false,
      isHost: map['isHost'] as bool? ?? false,
      isEliminated: map['isEliminated'] as bool? ?? false,
      voteTargetId: map['voteTargetId'] as String?,
      hasDrawnThisTurn: map['hasDrawnThisTurn'] as bool? ?? false,
      assignedColorValue: map['assignedColorValue'] as int? ?? 0xffefc249,
    );
  }
}

