import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/half_and_half_prompt.dart';

class HalfAndHalfPromptsCatalog {
  static final List<HalfAndHalfPrompt> prompts = <HalfAndHalfPrompt>[
    // 1. Three-Eyed Horned Monster (Exact creature from user mockup)
    HalfAndHalfPrompt(
      id: 'monster_three_eyes',
      title: 'Three-Eyed Sprout Monster',
      subtitle: 'Horns, 3 curious eyes, wide grin & clawed feet',
      category: 'Monsters',
      seamYRatio: 0.5,
      painterBuilder: ({
        required Color strokeColor,
        required double strokeWidth,
        Color? fillColor,
      }) {
        return _ThreeEyedMonsterPainter(
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          fillColor: fillColor,
        );
      },
    ),

    // 2. Cybernetic Robo-Cat
    HalfAndHalfPrompt(
      id: 'cyber_robo_cat',
      title: 'Cyber Mecha-Kitten',
      subtitle: 'Antenna ears, visor eyes & jet-powered paws',
      category: 'Sci-Fi',
      seamYRatio: 0.5,
      painterBuilder: ({
        required Color strokeColor,
        required double strokeWidth,
        Color? fillColor,
      }) {
        return _RoboCatPainter(
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          fillColor: fillColor,
        );
      },
    ),

    // 3. Chubby Space Dragon
    HalfAndHalfPrompt(
      id: 'chubby_dragon',
      title: 'Chubby Cosmic Dragon',
      subtitle: 'Little wings, playful snout & curled spiked tail',
      category: 'Fantasy',
      seamYRatio: 0.5,
      painterBuilder: ({
        required Color strokeColor,
        required double strokeWidth,
        Color? fillColor,
      }) {
        return _ChubbyDragonPainter(
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          fillColor: fillColor,
        );
      },
    ),
  ];

  static HalfAndHalfPrompt getRandom() {
    final int index = math.Random().nextInt(prompts.length);
    return prompts[index];
  }
}

/// CustomPainter for the Three-Eyed Monster matching the user mockup
class _ThreeEyedMonsterPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final Color? fillColor;

  _ThreeEyedMonsterPainter({
    required this.strokeColor,
    required this.strokeWidth,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = fillColor ?? strokeColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // --- TOP HALF (y: 0 to h * 0.5) ---

    // 1. Horns
    // Left Horn
    final Path leftHorn = Path()
      ..moveTo(w * 0.28, h * 0.24)
      ..cubicTo(w * 0.12, h * 0.20, w * 0.10, h * 0.08, w * 0.22, h * 0.05)
      ..cubicTo(w * 0.24, h * 0.11, w * 0.26, h * 0.17, w * 0.36, h * 0.20);
    canvas.drawPath(leftHorn, fillPaint);
    canvas.drawPath(leftHorn, strokePaint);

    // Right Horn
    final Path rightHorn = Path()
      ..moveTo(w * 0.72, h * 0.24)
      ..cubicTo(w * 0.88, h * 0.20, w * 0.90, h * 0.08, w * 0.78, h * 0.05)
      ..cubicTo(w * 0.76, h * 0.11, w * 0.74, h * 0.17, w * 0.64, h * 0.20);
    canvas.drawPath(rightHorn, fillPaint);
    canvas.drawPath(rightHorn, strokePaint);

    // 2. Head contour (furry oval)
    final Rect headRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.36),
      width: w * 0.56,
      height: h * 0.36,
    );
    canvas.drawOval(headRect, fillPaint);
    canvas.drawOval(headRect, strokePaint);

    // 3. Three Eyes
    // Center eye (slightly higher)
    final Offset centerEye = Offset(w * 0.5, h * 0.25);
    canvas.drawCircle(centerEye, w * 0.055, strokePaint);
    canvas.drawCircle(centerEye, w * 0.024, Paint()..color = strokeColor);

    // Left eye
    final Offset leftEye = Offset(w * 0.38, h * 0.28);
    canvas.drawCircle(leftEye, w * 0.048, strokePaint);
    canvas.drawCircle(leftEye, w * 0.020, Paint()..color = strokeColor);

    // Right eye
    final Offset rightEye = Offset(w * 0.62, h * 0.28);
    canvas.drawCircle(rightEye, w * 0.048, strokePaint);
    canvas.drawCircle(rightEye, w * 0.020, Paint()..color = strokeColor);

    // 4. Big Wide Smiling Mouth (crosses near seam)
    final Path mouthPath = Path()
      ..moveTo(w * 0.30, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.70, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.44, w * 0.30, h * 0.38);
    canvas.drawPath(mouthPath, fillPaint);
    canvas.drawPath(mouthPath, strokePaint);

    // Upper little fang / teeth
    final Path fang1 = Path()
      ..moveTo(w * 0.44, h * 0.41)
      ..lineTo(w * 0.46, h * 0.44)
      ..lineTo(w * 0.48, h * 0.41);
    final Path fang2 = Path()
      ..moveTo(w * 0.52, h * 0.41)
      ..lineTo(w * 0.54, h * 0.44)
      ..lineTo(w * 0.56, h * 0.41);
    canvas.drawPath(fang1, strokePaint);
    canvas.drawPath(fang2, strokePaint);

    // --- SEAM CONNECTING LINES (at h * 0.5) ---
    // Body contour continues through seam
    final Path bodyOutline = Path()
      ..moveTo(w * 0.34, h * 0.48)
      ..cubicTo(w * 0.26, h * 0.60, w * 0.28, h * 0.78, w * 0.42, h * 0.82)
      ..lineTo(w * 0.58, h * 0.82)
      ..cubicTo(w * 0.72, h * 0.78, w * 0.74, h * 0.60, w * 0.66, h * 0.48);
    canvas.drawPath(bodyOutline, strokePaint);

    // --- BOTTOM HALF (y: h * 0.5 to h) ---

    // 5. Belly texture arcs
    final Path bellyArc1 = Path()
      ..moveTo(w * 0.42, h * 0.62)
      ..quadraticBezierTo(w * 0.50, h * 0.66, w * 0.58, h * 0.62);
    final Path bellyArc2 = Path()
      ..moveTo(w * 0.40, h * 0.70)
      ..quadraticBezierTo(w * 0.50, h * 0.74, w * 0.60, h * 0.70);
    canvas.drawPath(bellyArc1, strokePaint);
    canvas.drawPath(bellyArc2, strokePaint);

    // 6. Curled Tail (right side)
    final Path tail = Path()
      ..moveTo(w * 0.68, h * 0.70)
      ..cubicTo(w * 0.86, h * 0.66, w * 0.90, h * 0.56, w * 0.80, h * 0.52)
      ..cubicTo(w * 0.72, h * 0.50, w * 0.76, h * 0.60, w * 0.82, h * 0.60);
    canvas.drawPath(tail, strokePaint);

    // 7. Left Clawed Foot
    final Path leftFoot = Path()
      ..moveTo(w * 0.40, h * 0.82)
      ..lineTo(w * 0.36, h * 0.93)
      ..lineTo(w * 0.32, h * 0.96)
      ..moveTo(w * 0.36, h * 0.93)
      ..lineTo(w * 0.38, h * 0.97)
      ..moveTo(w * 0.36, h * 0.93)
      ..lineTo(w * 0.43, h * 0.95);
    canvas.drawPath(leftFoot, strokePaint);

    // 8. Right Clawed Foot
    final Path rightFoot = Path()
      ..moveTo(w * 0.60, h * 0.82)
      ..lineTo(w * 0.64, h * 0.93)
      ..lineTo(w * 0.60, h * 0.96)
      ..moveTo(w * 0.64, h * 0.93)
      ..lineTo(w * 0.66, h * 0.97)
      ..moveTo(w * 0.64, h * 0.93)
      ..lineTo(w * 0.71, h * 0.95);
    canvas.drawPath(rightFoot, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// CustomPainter for the Robo-Cat
class _RoboCatPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final Color? fillColor;

  _RoboCatPainter({
    required this.strokeColor,
    required this.strokeWidth,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = fillColor ?? strokeColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // --- TOP HALF ---
    // Ears
    final Path leftEar = Path()
      ..moveTo(w * 0.28, h * 0.22)
      ..lineTo(w * 0.20, h * 0.06)
      ..lineTo(w * 0.40, h * 0.16);
    final Path rightEar = Path()
      ..moveTo(w * 0.72, h * 0.22)
      ..lineTo(w * 0.80, h * 0.06)
      ..lineTo(w * 0.60, h * 0.16);
    canvas.drawPath(leftEar, strokePaint);
    canvas.drawPath(rightEar, strokePaint);

    // Center Antenna
    canvas.drawLine(Offset(w * 0.5, h * 0.16), Offset(w * 0.5, h * 0.06), strokePaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.05), w * 0.025, strokePaint);

    // Angular Head Box
    final RRect head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.32), width: w * 0.52, height: h * 0.28),
      const Radius.circular(16),
    );
    canvas.drawRRect(head, fillPaint);
    canvas.drawRRect(head, strokePaint);

    // Visor Eyepiece
    final RRect visor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.30), width: w * 0.38, height: h * 0.10),
      const Radius.circular(8),
    );
    canvas.drawRRect(visor, strokePaint);
    canvas.drawCircle(Offset(w * 0.42, h * 0.30), w * 0.024, strokePaint);
    canvas.drawCircle(Offset(w * 0.58, h * 0.30), w * 0.024, strokePaint);

    // Whiskers
    canvas.drawLine(Offset(w * 0.22, h * 0.38), Offset(w * 0.12, h * 0.36), strokePaint);
    canvas.drawLine(Offset(w * 0.22, h * 0.41), Offset(w * 0.12, h * 0.43), strokePaint);
    canvas.drawLine(Offset(w * 0.78, h * 0.38), Offset(w * 0.88, h * 0.36), strokePaint);
    canvas.drawLine(Offset(w * 0.78, h * 0.41), Offset(w * 0.88, h * 0.43), strokePaint);

    // --- BOTTOM HALF ---
    // Torso Box
    final RRect torso = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.65), width: w * 0.46, height: h * 0.32),
      const Radius.circular(12),
    );
    canvas.drawRRect(torso, fillPaint);
    canvas.drawRRect(torso, strokePaint);

    // Battery / Power Core on Belly
    final Rect core = Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.16, height: h * 0.10);
    canvas.drawRect(core, strokePaint);
    final Path bolt = Path()
      ..moveTo(w * 0.51, h * 0.60)
      ..lineTo(w * 0.47, h * 0.64)
      ..lineTo(w * 0.50, h * 0.64)
      ..lineTo(w * 0.49, h * 0.68);
    canvas.drawPath(bolt, strokePaint);

    // Wheels / Paws
    canvas.drawCircle(Offset(w * 0.36, h * 0.87), w * 0.065, strokePaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.87), w * 0.065, strokePaint);

    // Antenna tail
    final Path tail = Path()
      ..moveTo(w * 0.73, h * 0.70)
      ..lineTo(w * 0.86, h * 0.62)
      ..lineTo(w * 0.82, h * 0.54);
    canvas.drawPath(tail, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// CustomPainter for the Chubby Space Dragon
class _ChubbyDragonPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final Color? fillColor;

  _ChubbyDragonPainter({
    required this.strokeColor,
    required this.strokeWidth,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = fillColor ?? strokeColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // --- TOP HALF ---
    // Little Horns
    canvas.drawLine(Offset(w * 0.42, h * 0.16), Offset(w * 0.38, h * 0.08), strokePaint);
    canvas.drawLine(Offset(w * 0.58, h * 0.16), Offset(w * 0.62, h * 0.08), strokePaint);

    // Head
    final Rect head = Rect.fromCenter(center: Offset(w * 0.5, h * 0.28), width: w * 0.44, height: h * 0.24);
    canvas.drawOval(head, fillPaint);
    canvas.drawOval(head, strokePaint);

    // Big Cute Eyes
    canvas.drawCircle(Offset(w * 0.42, h * 0.26), w * 0.038, strokePaint);
    canvas.drawCircle(Offset(w * 0.58, h * 0.26), w * 0.038, strokePaint);

    // Snout and Nostrils
    canvas.drawCircle(Offset(w * 0.47, h * 0.34), w * 0.012, strokePaint);
    canvas.drawCircle(Offset(w * 0.53, h * 0.34), w * 0.012, strokePaint);

    // Little Wings (Left & Right)
    final Path leftWing = Path()
      ..moveTo(w * 0.30, h * 0.36)
      ..lineTo(w * 0.10, h * 0.28)
      ..lineTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.26, h * 0.44);
    final Path rightWing = Path()
      ..moveTo(w * 0.70, h * 0.36)
      ..lineTo(w * 0.90, h * 0.28)
      ..lineTo(w * 0.82, h * 0.42)
      ..lineTo(w * 0.74, h * 0.44);
    canvas.drawPath(leftWing, strokePaint);
    canvas.drawPath(rightWing, strokePaint);

    // --- BOTTOM HALF ---
    // Round Belly
    final Rect belly = Rect.fromCenter(center: Offset(w * 0.5, h * 0.65), width: w * 0.52, height: h * 0.38);
    canvas.drawOval(belly, fillPaint);
    canvas.drawOval(belly, strokePaint);

    // Belly Scales
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.2, height: h * 0.06), 0, math.pi, false, strokePaint);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.2, height: h * 0.06), 0, math.pi, false, strokePaint);

    // Stubby Dragon Feet
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.38, h * 0.85), width: w * 0.14, height: h * 0.08), strokePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.62, h * 0.85), width: w * 0.14, height: h * 0.08), strokePaint);

    // Spiky Tail
    final Path tail = Path()
      ..moveTo(w * 0.72, h * 0.72)
      ..quadraticBezierTo(w * 0.92, h * 0.74, w * 0.88, h * 0.58)
      ..lineTo(w * 0.95, h * 0.56)
      ..lineTo(w * 0.86, h * 0.52);
    canvas.drawPath(tail, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

