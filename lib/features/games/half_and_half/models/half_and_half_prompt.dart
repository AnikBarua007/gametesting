import 'package:flutter/material.dart';

typedef PromptPainterBuilder = CustomPainter Function({
  required Color strokeColor,
  required double strokeWidth,
  Color? fillColor,
});

class HalfAndHalfPrompt {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final double seamYRatio; // Default 0.5 (middle)
  final PromptPainterBuilder painterBuilder;

  const HalfAndHalfPrompt({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.seamYRatio = 0.5,
    required this.painterBuilder,
  });
}

