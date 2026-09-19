import 'package:flutter/material.dart';

enum GeoRushGameMode {
  singlePlayer,
  multiplayer,
  offline,
}

class GeoRushModeData {
  final GeoRushGameMode mode;
  final String title;
  final String description;
  final String actionLabel;
  final Color accentColor;

  const GeoRushModeData({
    required this.mode,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.accentColor,
  });

  static const List<GeoRushModeData> modes = <GeoRushModeData>[
    GeoRushModeData(
      mode: GeoRushGameMode.singlePlayer,
      title: 'SINGLE PLAYER',
      description: 'Guess locations on your own.\nBeat your high score!',
      actionLabel: 'PLAY SOLO',
      accentColor: Color(0xffe8bd42),
    ),
    GeoRushModeData(
      mode: GeoRushGameMode.multiplayer,
      title: 'MULTIPLAYER',
      description: 'Challenge friends or random\nplayers in real-time.',
      actionLabel: 'QUICK MATCH',
      accentColor: Color(0xff38bdf8),
    ),
    GeoRushModeData(
      mode: GeoRushGameMode.offline,
      title: 'OFFLINE',
      description: 'Download maps and play without\ninternet.',
      actionLabel: 'DOWNLOAD & PLAY',
      accentColor: Color(0xff34d399),
    ),
  ];
}

