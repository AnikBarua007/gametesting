import 'package:flutter/material.dart';

/// Represents a single point in a drawing stroke with high-precision offset.
class SketchPoint {
  final Offset offset;
  final double pressure;

  const SketchPoint(this.offset, [this.pressure = 1.0]);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'dx': offset.dx,
        'dy': offset.dy,
        'p': pressure,
      };

  factory SketchPoint.fromMap(Map<String, dynamic> map) => SketchPoint(
        Offset(
          (map['dx'] as num).toDouble(),
          (map['dy'] as num).toDouble(),
        ),
        (map['p'] as num?)?.toDouble() ?? 1.0,
      );
}

/// A complete continuous stroke on the drawing canvas.
class SketchStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  const SketchStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });

  SketchStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    bool? isEraser,
  }) {
    return SketchStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isEraser: isEraser ?? this.isEraser,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'points': points
            .map((p) => <String, double>{'dx': p.dx, 'dy': p.dy})
            .toList(),
        'color': color.toARGB32(),
        'strokeWidth': strokeWidth,
        'isEraser': isEraser,
      };

  factory SketchStroke.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawPoints = map['points'] as List<dynamic>? ?? <dynamic>[];
    return SketchStroke(
      points: rawPoints
          .map((p) => Offset(
                (p['dx'] as num).toDouble(),
                (p['dy'] as num).toDouble(),
              ))
          .toList(),
      color: Color((map['color'] as num).toInt()),
      strokeWidth: (map['strokeWidth'] as num).toDouble(),
      isEraser: map['isEraser'] as bool? ?? false,
    );
  }
}

