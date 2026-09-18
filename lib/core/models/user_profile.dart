import 'dart:convert';
import 'package:flutter/material.dart';

class PlayerAvatar {
  final String id;
  final String name;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const PlayerAvatar({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  static const List<PlayerAvatar> presets = <PlayerAvatar>[
    PlayerAvatar(
      id: 'avatar_phoenix',
      name: 'Phoenix',
      icon: Icons.local_fire_department_rounded,
      primaryColor: Color(0xffef4444),
      secondaryColor: Color(0xfff59e0b),
    ),
    PlayerAvatar(
      id: 'avatar_ninja',
      name: 'Shadow',
      icon: Icons.visibility_off_rounded,
      primaryColor: Color(0xff6366f1),
      secondaryColor: Color(0xffa855f7),
    ),
    PlayerAvatar(
      id: 'avatar_cyber',
      name: 'Cyber',
      icon: Icons.sports_esports_rounded,
      primaryColor: Color(0xff06b6d4),
      secondaryColor: Color(0xff3b82f6),
    ),
    PlayerAvatar(
      id: 'avatar_astro',
      name: 'Astro',
      icon: Icons.rocket_launch_rounded,
      primaryColor: Color(0xff10b981),
      secondaryColor: Color(0xff14b8a6),
    ),
    PlayerAvatar(
      id: 'avatar_crown',
      name: 'Monarch',
      icon: Icons.military_tech_rounded,
      primaryColor: Color(0xffeab308),
      secondaryColor: Color(0xfff97316),
    ),
    PlayerAvatar(
      id: 'avatar_ghost',
      name: 'Specter',
      icon: Icons.cruelty_free_rounded,
      primaryColor: Color(0xffec4899),
      secondaryColor: Color(0xff8b5cf6),
    ),
  ];

  static PlayerAvatar getById(String? id) {
    return presets.firstWhere(
      (a) => a.id == id,
      orElse: () => presets.first,
    );
  }
}

class PlayerStats {
  final int gamesPlayed;
  final int wins;
  final String favoriteGame;

  const PlayerStats({
    this.gamesPlayed = 0,
    this.wins = 0,
    this.favoriteGame = 'hidden-hand',
  });

  double get winRate => gamesPlayed == 0 ? 0.0 : (wins / gamesPlayed);

  PlayerStats copyWith({
    int? gamesPlayed,
    int? wins,
    String? favoriteGame,
  }) {
    return PlayerStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      favoriteGame: favoriteGame ?? this.favoriteGame,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'favoriteGame': favoriteGame,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PlayerStats();
    return PlayerStats(
      gamesPlayed: (map['gamesPlayed'] as num?)?.toInt() ?? 0,
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      favoriteGame: (map['favoriteGame'] as String?) ?? 'hidden-hand',
    );
  }
}

class UserProfile {
  final String uid;
  final String displayName;
  final String? email;
  final bool isGuest;
  final String avatarId;
  final String bio;
  final String status;
  final DateTime createdAt;
  final DateTime lastActive;
  final PlayerStats stats;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.isGuest = false,
    this.avatarId = 'avatar_cyber',
    this.bio = 'Ready to play!',
    this.status = 'online',
    required this.createdAt,
    required this.lastActive,
    this.stats = const PlayerStats(),
  });

  bool get isProfileComplete => displayName.trim().isNotEmpty;

  PlayerAvatar get avatar => PlayerAvatar.getById(avatarId);

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    bool? isGuest,
    String? avatarId,
    String? bio,
    String? status,
    DateTime? createdAt,
    DateTime? lastActive,
    PlayerStats? stats,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      avatarId: avatarId ?? this.avatarId,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'isGuest': isGuest,
      'avatarId': avatarId,
      'bio': bio,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'stats': stats.toMap(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      displayName: (map['displayName'] as String?) ?? '',
      email: map['email'] as String?,
      isGuest: (map['isGuest'] as bool?) ?? false,
      avatarId: (map['avatarId'] as String?) ?? 'avatar_cyber',
      bio: (map['bio'] as String?) ?? 'Ready to play!',
      status: (map['status'] as String?) ?? 'online',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? DateTime.tryParse(map['lastActive'] as String) ?? DateTime.now()
          : DateTime.now(),
      stats: PlayerStats.fromMap(map['stats'] as Map<String, dynamic>?),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

