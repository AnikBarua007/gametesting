import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';

class DrawingCanvasWidget extends StatefulWidget {
  final List<DrawingStroke> strokes;
  final bool isInteractive;
  final Color activeColor;
  final double strokeWidth;
  final String activePlayerId;
  final ValueChanged<DrawingStroke>? onStrokeCompleted;

  const DrawingCanvasWidget({
    super.key,
    required this.strokes,
    required this.isInteractive,
    required this.activeColor,
    required this.strokeWidth,
    required this.activePlayerId,
    this.onStrokeCompleted,
  });

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  final List<DrawingPoint> _currentPoints = <DrawingPoint>[];

  void _onPanStart(DragStartDetails details) {
    if (!widget.isInteractive) return;
    setState(() {
      _currentPoints.clear();
      _currentPoints.add(DrawingPoint(
        details.localPosition.dx,
        details.localPosition.dy,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isInteractive) return;
    setState(() {
      _currentPoints.add(DrawingPoint(
        details.localPosition.dx,
        details.localPosition.dy,
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isInteractive || _currentPoints.isEmpty) return;

    final DrawingStroke stroke = DrawingStroke(
      playerId: widget.activePlayerId,
      points: List<DrawingPoint>.from(_currentPoints),
      colorValue: widget.activeColor.toARGB32(),
      strokeWidth: widget.strokeWidth,
    );

    widget.onStrokeCompleted?.call(stroke);

    setState(() {
      _currentPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff12131c),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isInteractive
                ? const Color(0xffefc249)
                : const Color(0xff333446),
            width: widget.isInteractive ? 2.5 : 1.5,
          ),
          boxShadow: <BoxShadow>[
            if (widget.isInteractive)
              BoxShadow(
                color: const Color(0xffefc249).withValues(alpha: 0.18),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            painter: _CanvasPainter(
              strokes: widget.strokes,
              currentPoints: _currentPoints,
              currentColor: widget.activeColor,
              currentStrokeWidth: widget.strokeWidth,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<DrawingPoint> currentPoints;
  final Color currentColor;
  final double currentStrokeWidth;

  const _CanvasPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle background grid
    final Paint gridPaint = Paint()
      ..color = const Color(0xff1e202e)
      ..strokeWidth = 0.8;

    const double step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Render historical strokes
    for (final DrawingStroke stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final Paint paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points[0].toOffset(), stroke.strokeWidth / 2, paint);
      } else {
        final Path path = Path();
        path.moveTo(stroke.points[0].x, stroke.points[0].y);

        for (int i = 1; i < stroke.points.length; i++) {
          final DrawingPoint p0 = stroke.points[i - 1];
          final DrawingPoint p1 = stroke.points[i];
          final double midX = (p0.x + p1.x) / 2;
          final double midY = (p0.y + p1.y) / 2;
          path.quadraticBezierTo(p0.x, p0.y, midX, midY);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Render active in-progress stroke
    if (currentPoints.isNotEmpty) {
      final Paint livePaint = Paint()
        ..color = currentColor
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (currentPoints.length == 1) {
        canvas.drawCircle(currentPoints[0].toOffset(), currentStrokeWidth / 2, livePaint);
      } else {
        final Path path = Path();
        path.moveTo(currentPoints[0].x, currentPoints[0].y);
        for (int i = 1; i < currentPoints.length; i++) {
          final DrawingPoint p0 = currentPoints[i - 1];
          final DrawingPoint p1 = currentPoints[i];
          final double midX = (p0.x + p1.x) / 2;
          final double midY = (p0.y + p1.y) / 2;
          path.quadraticBezierTo(p0.x, p0.y, midX, midY);
        }
        canvas.drawPath(path, livePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentPoints != currentPoints ||
        oldDelegate.currentColor != currentColor ||
        oldDelegate.currentStrokeWidth != currentStrokeWidth;
  }
}
