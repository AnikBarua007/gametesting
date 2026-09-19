import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  const DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'x': offset.dx,
        'y': offset.dy,
        'color': color.toARGB32(),
        'width': strokeWidth,
        'isEraser': isEraser,
      };

  factory DrawingPoint.fromMap(Map<String, dynamic> map) => DrawingPoint(
        offset: Offset((map['x'] as num).toDouble(), (map['y'] as num).toDouble()),
        color: Color(map['color'] as int),
        strokeWidth: (map['width'] as num).toDouble(),
        isEraser: map['isEraser'] as bool? ?? false,
      );
}

class DrawingStroke {
  final List<DrawingPoint> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  const DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });

  DrawingStroke copyWith({
    List<DrawingPoint>? points,
    Color? color,
    double? strokeWidth,
    bool? isEraser,
  }) =>
      DrawingStroke(
        points: points ?? this.points,
        color: color ?? this.color,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        isEraser: isEraser ?? this.isEraser,
      );
}
