import 'dart:ui';

class DrawingPoint {
  final double x;
  final double y;

  const DrawingPoint(this.x, this.y);

  Offset toOffset() => Offset(x, y);

  Map<String, dynamic> toMap() => <String, dynamic>{'x': x, 'y': y};

  factory DrawingPoint.fromMap(Map<String, dynamic> map) {
    return DrawingPoint(
      (map['x'] as num).toDouble(),
      (map['y'] as num).toDouble(),
    );
  }
}

class DrawingStroke {
  final String playerId;
  final List<DrawingPoint> points;
  final int colorValue;
  final double strokeWidth;

  const DrawingStroke({
    required this.playerId,
    required this.points,
    required this.colorValue,
    this.strokeWidth = 4.0,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'playerId': playerId,
        'points': points.map((p) => p.toMap()).toList(),
        'colorValue': colorValue,
        'strokeWidth': strokeWidth,
      };

  factory DrawingStroke.fromMap(Map<String, dynamic> map) {
    return DrawingStroke(
      playerId: map['playerId'] as String? ?? '',
      points: (map['points'] as List<dynamic>?)
              ?.map((p) => DrawingPoint.fromMap(p as Map<String, dynamic>))
              .toList() ??
          <DrawingPoint>[],
      colorValue: map['colorValue'] as int? ?? 0xffefc249,
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 4.0,
    );
  }
}

