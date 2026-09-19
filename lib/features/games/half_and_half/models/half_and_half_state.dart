import 'package:flutter/material.dart';
import 'half_and_half_drawing.dart';
import 'half_and_half_prompt.dart';

enum HalfAndHalfRole {
  topHalf,
  bottomHalf;

  String get displayName => this == HalfAndHalfRole.topHalf ? 'Top Half' : 'Bottom Half';
  String get playerLabel => this == HalfAndHalfRole.topHalf ? 'Player A' : 'Player B';
}

enum HalfAndHalfPhase {
  lobby,
  memorize,
  drawing,
  reveal,
}

class HalfAndHalfPlayer {
  final String id;
  final String displayName;
  final String avatarId;
  final HalfAndHalfRole role;
  final bool isBot;
  final bool hasSubmitted;

  const HalfAndHalfPlayer({
    required this.id,
    required this.displayName,
    required this.avatarId,
    required this.role,
    this.isBot = false,
    this.hasSubmitted = false,
  });

  HalfAndHalfPlayer copyWith({
    String? id,
    String? displayName,
    String? avatarId,
    HalfAndHalfRole? role,
    bool? isBot,
    bool? hasSubmitted,
  }) =>
      HalfAndHalfPlayer(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        avatarId: avatarId ?? this.avatarId,
        role: role ?? this.role,
        isBot: isBot ?? this.isBot,
        hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      );
}

class HalfAndHalfState {
  final String roomCode;
  final HalfAndHalfPhase phase;
  final HalfAndHalfPrompt prompt;
  final HalfAndHalfRole localRole;
  final HalfAndHalfPlayer playerA; // Top half
  final HalfAndHalfPlayer playerB; // Bottom half
  final List<DrawingStroke> topStrokes;
  final List<DrawingStroke> bottomStrokes;
  final int memorizeSecondsRemaining;
  final int drawSecondsRemaining;
  final Map<String, int> reactions;
  final int matchScore; // 0 - 100
  final int communityLikes;
  final Size canvasSize;

  const HalfAndHalfState({
    required this.roomCode,
    required this.phase,
    required this.prompt,
    required this.localRole,
    required this.playerA,
    required this.playerB,
    this.topStrokes = const <DrawingStroke>[],
    this.bottomStrokes = const <DrawingStroke>[],
    this.memorizeSecondsRemaining = 10,
    this.drawSecondsRemaining = 60,
    this.reactions = const <String, int>{
      '😂': 0,
      '🤯': 0,
      '🤮': 0,
      '❤️': 0,
    },
    this.matchScore = 85,
    this.communityLikes = 0,
    this.canvasSize = const Size(360, 480),
  });

  HalfAndHalfState copyWith({
    String? roomCode,
    HalfAndHalfPhase? phase,
    HalfAndHalfPrompt? prompt,
    HalfAndHalfRole? localRole,
    HalfAndHalfPlayer? playerA,
    HalfAndHalfPlayer? playerB,
    List<DrawingStroke>? topStrokes,
    List<DrawingStroke>? bottomStrokes,
    int? memorizeSecondsRemaining,
    int? drawSecondsRemaining,
    Map<String, int>? reactions,
    int? matchScore,
    int? communityLikes,
    Size? canvasSize,
  }) =>
      HalfAndHalfState(
        roomCode: roomCode ?? this.roomCode,
        phase: phase ?? this.phase,
        prompt: prompt ?? this.prompt,
        localRole: localRole ?? this.localRole,
        playerA: playerA ?? this.playerA,
        playerB: playerB ?? this.playerB,
        topStrokes: topStrokes ?? this.topStrokes,
        bottomStrokes: bottomStrokes ?? this.bottomStrokes,
        memorizeSecondsRemaining: memorizeSecondsRemaining ?? this.memorizeSecondsRemaining,
        drawSecondsRemaining: drawSecondsRemaining ?? this.drawSecondsRemaining,
        reactions: reactions ?? this.reactions,
        matchScore: matchScore ?? this.matchScore,
        communityLikes: communityLikes ?? this.communityLikes,
        canvasSize: canvasSize ?? this.canvasSize,
      );
}

