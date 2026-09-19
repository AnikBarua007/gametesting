import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sketch_party_player.dart';
import '../models/sketch_party_word.dart';
import '../models/sketch_stroke.dart';

class SketchBotAI {
  final Random _random = Random();

  /// Realistic wrong/funny guesses for bots before they guess correctly.
  static const Map<String, List<String>> _categoryBloopers = <String, List<String>>{
    'Food': <String>['bread', 'sandwich', 'cheese', 'cookie', 'pie', 'taco', 'salad'],
    'Animals': <String>['dog', 'mouse', 'horse', 'bear', 'rabbit', 'lion', 'bird'],
    'Objects': <String>['box', 'phone', 'table', 'chair', 'lamp', 'pen', 'key'],
    'Nature': <String>['cloud', 'flower', 'leaf', 'star', 'mountain', 'river'],
    'Vehicles': <String>['bus', 'train', 'plane', 'truck', 'bike', 'boat'],
  };

  /// Decides if a bot guesser should guess at this second.
  /// Returns a tuple of (guessText, isCorrect) or null if staying quiet.
  ({String text, bool isCorrect})? generateBotGuess({
    required SketchPartyPlayer bot,
    required SketchPartyWord currentWord,
    required int timeRemaining,
    required int totalDuration,
  }) {
    if (bot.hasGuessed) return null;

    final int elapsed = totalDuration - timeRemaining;
    // Bots usually don't guess in the first 8 seconds
    if (elapsed < 8) return null;

    // Probability ramps up as more strokes are drawn & time elapses
    // Around 18-35 seconds, probability of correct guess increases
    final double chance = _random.nextDouble();

    if (elapsed > 20 && chance < 0.22) {
      // Correct guess!
      return (text: currentWord.word, isCorrect: true);
    } else if (chance < 0.12) {
      // Plausible wrong guess to make chat lively
      final List<String> list = _categoryBloopers[currentWord.category] ??
          <String>['something', 'sketch', 'doodle', 'idk', 'drawing'];
      final String wrongGuess = list[_random.nextInt(list.length)];
      if (wrongGuess.toLowerCase() != currentWord.word.toLowerCase()) {
        return (text: wrongGuess, isCorrect: false);
      }
    }
    return null;
  }

  /// Generates recognizable procedural strokes for bot drawing mode.
  /// Generates a set of normalized (0.0 to 1.0) strokes, which are mapped to canvas bounds.
  List<SketchStroke> generateProceduralStrokes(
    SketchPartyWord word, {
    required Size canvasSize,
  }) {
    final double w = canvasSize.width;
    final double h = canvasSize.height;
    final Color mainColor = const Color(0xff08abc4);
    final Color detailColor = const Color(0xfff4d935);
    final Color darkColor = const Color(0xffffffff);

    // Normalize coordinates helper
    Offset pt(double nx, double ny) => Offset(nx * w, ny * h);

    final String term = word.word.toLowerCase();
    final List<SketchStroke> strokes = <SketchStroke>[];

    if (term.contains('apple') || term.contains('fruit')) {
      // Apple body (circle with dip)
      strokes.add(SketchStroke(
        points: _circlePoints(pt(0.5, 0.52), w * 0.22),
        color: const Color(0xffef4444),
        strokeWidth: 5.0,
      ));
      // Stem
      strokes.add(SketchStroke(
        points: <Offset>[pt(0.5, 0.32), pt(0.53, 0.23)],
        color: const Color(0xff854d0e),
        strokeWidth: 4.5,
      ));
      // Leaf
      strokes.add(SketchStroke(
        points: <Offset>[pt(0.53, 0.25), pt(0.62, 0.24), pt(0.55, 0.29)],
        color: const Color(0xff22c55e),
        strokeWidth: 4.0,
      ));
    } else if (term.contains('house') || term.contains('home')) {
      // House base square
      strokes.add(SketchStroke(
        points: <Offset>[
          pt(0.25, 0.42),
          pt(0.75, 0.42),
          pt(0.75, 0.82),
          pt(0.25, 0.82),
          pt(0.25, 0.42),
        ],
        color: mainColor,
        strokeWidth: 5.0,
      ));
      // Triangle Roof
      strokes.add(SketchStroke(
        points: <Offset>[
          pt(0.20, 0.44),
          pt(0.50, 0.18),
          pt(0.80, 0.44),
        ],
        color: detailColor,
        strokeWidth: 5.5,
      ));
      // Door
      strokes.add(SketchStroke(
        points: <Offset>[
          pt(0.42, 0.82),
          pt(0.42, 0.60),
          pt(0.58, 0.60),
          pt(0.58, 0.82),
        ],
        color: darkColor,
        strokeWidth: 4.0,
      ));
    } else if (term.contains('sun') || term.contains('star')) {
      // Sun center
      strokes.add(SketchStroke(
        points: _circlePoints(pt(0.5, 0.5), w * 0.18),
        color: detailColor,
        strokeWidth: 5.5,
      ));
      // Rays
      final List<Offset> rays = <Offset>[
        pt(0.5, 0.22), pt(0.5, 0.12),
        pt(0.5, 0.78), pt(0.5, 0.88),
        pt(0.22, 0.5), pt(0.12, 0.5),
        pt(0.78, 0.5), pt(0.88, 0.5),
        pt(0.30, 0.30), pt(0.22, 0.22),
        pt(0.70, 0.70), pt(0.78, 0.78),
        pt(0.70, 0.30), pt(0.78, 0.22),
        pt(0.30, 0.70), pt(0.22, 0.78),
      ];
      for (int i = 0; i < rays.length; i += 2) {
        strokes.add(SketchStroke(
          points: <Offset>[rays[i], rays[i + 1]],
          color: detailColor,
          strokeWidth: 4.5,
        ));
      }
    } else if (term.contains('car') || term.contains('auto')) {
      // Car body
      strokes.add(SketchStroke(
        points: <Offset>[
          pt(0.15, 0.62),
          pt(0.28, 0.62),
          pt(0.38, 0.42),
          pt(0.68, 0.42),
          pt(0.78, 0.62),
          pt(0.88, 0.62),
          pt(0.88, 0.74),
          pt(0.15, 0.74),
          pt(0.15, 0.62),
        ],
        color: mainColor,
        strokeWidth: 5.0,
      ));
      // Wheels
      strokes.add(SketchStroke(
        points: _circlePoints(pt(0.30, 0.74), w * 0.07),
        color: darkColor,
        strokeWidth: 5.0,
      ));
      strokes.add(SketchStroke(
        points: _circlePoints(pt(0.72, 0.74), w * 0.07),
        color: darkColor,
        strokeWidth: 5.0,
      ));
    } else if (term.contains('rocket') || term.contains('spaceship')) {
      // Rocket fuselage
      strokes.add(SketchStroke(
        points: <Offset>[
          pt(0.5, 0.15),
          pt(0.62, 0.35),
          pt(0.62, 0.68),
          pt(0.38, 0.68),
          pt(0.38, 0.35),
          pt(0.5, 0.15),
        ],
        color: darkColor,
        strokeWidth: 5.0,
      ));
      // Window porthole
      strokes.add(SketchStroke(
        points: _circlePoints(pt(0.5, 0.42), w * 0.06),
        color: mainColor,
        strokeWidth: 4.0,
      ));
      // Thruster flame
      strokes.add(SketchStroke(
        points: <Offset>[
          pt(0.42, 0.70),
          pt(0.50, 0.88),
          pt(0.58, 0.70),
        ],
        color: detailColor,
        strokeWidth: 4.5,
      ));
    } else {
      // Generic creative doodle representation (smiling artist palette/face)
      strokes.add(SketchStroke(
        points: _circlePoints(pt(0.5, 0.48), w * 0.24),
        color: mainColor,
        strokeWidth: 5.0,
      ));
      // Smile
      strokes.add(SketchStroke(
        points: <Offset>[
          pt(0.38, 0.54),
          pt(0.50, 0.64),
          pt(0.62, 0.54),
        ],
        color: detailColor,
        strokeWidth: 4.5,
      ));
      // Eyes
      strokes.add(SketchStroke(
        points: <Offset>[pt(0.42, 0.40), pt(0.42, 0.44)],
        color: darkColor,
        strokeWidth: 6.0,
      ));
      strokes.add(SketchStroke(
        points: <Offset>[pt(0.58, 0.40), pt(0.58, 0.44)],
        color: darkColor,
        strokeWidth: 6.0,
      ));
    }

    return strokes;
  }

  List<Offset> _circlePoints(Offset center, double radius) {
    final List<Offset> pts = <Offset>[];
    const int segments = 24;
    for (int i = 0; i <= segments; i++) {
      final double angle = (i / segments) * 2 * pi;
      pts.add(Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      ));
    }
    return pts;
  }
}

