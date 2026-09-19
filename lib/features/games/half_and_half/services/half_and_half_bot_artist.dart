import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/half_and_half_drawing.dart';
import '../models/half_and_half_prompt.dart';
import '../models/half_and_half_state.dart';

class HalfAndHalfBotArtist {
  final math.Random _random = math.Random();

  List<DrawingStroke> generatePartnerHalf({
    required HalfAndHalfPrompt prompt,
    required HalfAndHalfRole botRole,
    required Size canvasSize,
    Color color = const Color(0xff53457a),
  }) {
    final double w = canvasSize.width;
    final double h = canvasSize.height;
    final double seamY = h * prompt.seamYRatio;

    final List<DrawingStroke> strokes = <DrawingStroke>[];

    if (botRole == HalfAndHalfRole.bottomHalf) {
      // Draw bottom half (belly, feet, tail, seam connections)
      // 1. Belly contour starting at seam
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.34, seamY - 4),
        control1: Offset(w * 0.26 + _jitter(), h * 0.62 + _jitter()),
        control2: Offset(w * 0.32 + _jitter(), h * 0.80 + _jitter()),
        end: Offset(w * 0.45, h * 0.82),
        color: color,
        width: 3.5,
      ));

      strokes.add(_createCurveStroke(
        start: Offset(w * 0.45, h * 0.82),
        control1: Offset(w * 0.50, h * 0.83),
        control2: Offset(w * 0.55, h * 0.83),
        end: Offset(w * 0.66, seamY - 4),
        color: color,
        width: 3.5,
      ));

      // 2. Belly ripples / folds
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.42, h * 0.62),
        control1: Offset(w * 0.50, h * 0.67),
        control2: Offset(w * 0.52, h * 0.67),
        end: Offset(w * 0.58, h * 0.62),
        color: color,
        width: 2.8,
      ));

      // 3. Left clawed leg
      strokes.add(_createLineStroke(
        from: Offset(w * 0.40, h * 0.82),
        to: Offset(w * 0.36, h * 0.94),
        color: color,
        width: 3.5,
      ));
      strokes.add(_createLineStroke(
        from: Offset(w * 0.36, h * 0.94),
        to: Offset(w * 0.30, h * 0.97),
        color: color,
        width: 3.0,
      ));
      strokes.add(_createLineStroke(
        from: Offset(w * 0.36, h * 0.94),
        to: Offset(w * 0.38, h * 0.98),
        color: color,
        width: 3.0,
      ));

      // 4. Right clawed leg
      strokes.add(_createLineStroke(
        from: Offset(w * 0.60, h * 0.82),
        to: Offset(w * 0.64, h * 0.94),
        color: color,
        width: 3.5,
      ));
      strokes.add(_createLineStroke(
        from: Offset(w * 0.64, h * 0.94),
        to: Offset(w * 0.58, h * 0.97),
        color: color,
        width: 3.0,
      ));
      strokes.add(_createLineStroke(
        from: Offset(w * 0.64, h * 0.94),
        to: Offset(w * 0.70, h * 0.97),
        color: color,
        width: 3.0,
      ));

      // 5. Tail
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.66, h * 0.68),
        control1: Offset(w * 0.88, h * 0.64),
        control2: Offset(w * 0.92, h * 0.52),
        end: Offset(w * 0.80, h * 0.50),
        color: color,
        width: 3.5,
      ));
    } else {
      // Draw top half (horns, head, eyes, smile)
      // 1. Head dome
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.34, seamY + 4),
        control1: Offset(w * 0.22, h * 0.32),
        control2: Offset(w * 0.25, h * 0.18),
        end: Offset(w * 0.50, h * 0.16),
        color: color,
        width: 3.5,
      ));
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.50, h * 0.16),
        control1: Offset(w * 0.75, h * 0.18),
        control2: Offset(w * 0.78, h * 0.32),
        end: Offset(w * 0.66, seamY + 4),
        color: color,
        width: 3.5,
      ));

      // 2. Horns
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.28, h * 0.24),
        control1: Offset(w * 0.12, h * 0.18),
        control2: Offset(w * 0.12, h * 0.08),
        end: Offset(w * 0.22, h * 0.06),
        color: color,
        width: 3.5,
      ));
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.72, h * 0.24),
        control1: Offset(w * 0.88, h * 0.18),
        control2: Offset(w * 0.88, h * 0.08),
        end: Offset(w * 0.78, h * 0.06),
        color: color,
        width: 3.5,
      ));

      // 3. Eyes (3 circles)
      strokes.add(_createCircleStroke(center: Offset(w * 0.5, h * 0.25), radius: w * 0.055, color: color));
      strokes.add(_createCircleStroke(center: Offset(w * 0.38, h * 0.28), radius: w * 0.048, color: color));
      strokes.add(_createCircleStroke(center: Offset(w * 0.62, h * 0.28), radius: w * 0.048, color: color));

      // 4. Wide Smile reaching seam
      strokes.add(_createCurveStroke(
        start: Offset(w * 0.32, h * 0.38),
        control1: Offset(w * 0.40, seamY - 2),
        control2: Offset(w * 0.60, seamY - 2),
        end: Offset(w * 0.68, h * 0.38),
        color: color,
        width: 3.8,
      ));
    }

    return strokes;
  }

  double _jitter() => (_random.nextDouble() - 0.5) * 6.0;

  DrawingStroke _createLineStroke({
    required Offset from,
    required Offset to,
    required Color color,
    required double width,
  }) {
    final List<DrawingPoint> points = <DrawingPoint>[];
    const int steps = 8;
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      points.add(DrawingPoint(
        offset: Offset(
          from.dx + (to.dx - from.dx) * t + _jitter() * 0.3,
          from.dy + (to.dy - from.dy) * t + _jitter() * 0.3,
        ),
        color: color,
        strokeWidth: width,
      ));
    }
    return DrawingStroke(points: points, color: color, strokeWidth: width);
  }

  DrawingStroke _createCurveStroke({
    required Offset start,
    required Offset control1,
    required Offset control2,
    required Offset end,
    required Color color,
    required double width,
  }) {
    final List<DrawingPoint> points = <DrawingPoint>[];
    const int steps = 18;
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double u = 1 - t;
      final double x = u * u * u * start.dx +
          3 * u * u * t * control1.dx +
          3 * u * t * t * control2.dx +
          t * t * t * end.dx;
      final double y = u * u * u * start.dy +
          3 * u * u * t * control1.dy +
          3 * u * t * t * control2.dy +
          t * t * t * end.dy;

      points.add(DrawingPoint(
        offset: Offset(x + _jitter() * 0.3, y + _jitter() * 0.3),
        color: color,
        strokeWidth: width,
      ));
    }
    return DrawingStroke(points: points, color: color, strokeWidth: width);
  }

  DrawingStroke _createCircleStroke({
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final List<DrawingPoint> points = <DrawingPoint>[];
    const int steps = 16;
    for (int i = 0; i <= steps; i++) {
      final double theta = (i / steps) * 2 * math.pi;
      points.add(DrawingPoint(
        offset: Offset(
          center.dx + radius * math.cos(theta) + _jitter() * 0.4,
          center.dy + radius * math.sin(theta) + _jitter() * 0.4,
        ),
        color: color,
        strokeWidth: 3.0,
      ));
    }
    return DrawingStroke(points: points, color: color, strokeWidth: 3.0);
  }
}

