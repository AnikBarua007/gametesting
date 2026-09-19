import 'package:flutter/material.dart';
import '../models/sketch_stroke.dart';

/// Zero-latency, dual-layer interactive drawing canvas for Sketch Party.
/// Uses raw [Listener] and dedicated [ValueNotifier] painters to achieve
/// instantaneous response times with zero widget tree rebuild overhead.
class SketchCanvas extends StatefulWidget {
  final List<SketchStroke> strokes;
  final ValueChanged<SketchStroke>? onStrokeComplete;
  final Color currentColor;
  final double currentStrokeWidth;
  final bool isEraser;
  final bool isInteractive;
  final Color canvasBackgroundColor;

  const SketchCanvas({
    super.key,
    required this.strokes,
    this.onStrokeComplete,
    this.currentColor = const Color(0xff08abc4),
    this.currentStrokeWidth = 4.0,
    this.isEraser = false,
    this.isInteractive = true,
    this.canvasBackgroundColor = const Color(0xff121829),
  });

  @override
  State<SketchCanvas> createState() => _SketchCanvasState();
}

class _SketchCanvasState extends State<SketchCanvas> {
  final ValueNotifier<SketchStroke?> _activeStrokeNotifier =
      ValueNotifier<SketchStroke?>(null);
  List<Offset> _currentPoints = <Offset>[];

  @override
  void dispose() {
    _activeStrokeNotifier.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.isInteractive) return;

    final Offset local = event.localPosition;
    _currentPoints = <Offset>[local];

    _activeStrokeNotifier.value = SketchStroke(
      points: List<Offset>.from(_currentPoints),
      color: widget.isEraser ? widget.canvasBackgroundColor : widget.currentColor,
      strokeWidth: widget.isEraser ? widget.currentStrokeWidth * 2.5 : widget.currentStrokeWidth,
      isEraser: widget.isEraser,
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.isInteractive || _currentPoints.isEmpty) return;

    final Offset local = event.localPosition;
    final Offset last = _currentPoints.last;

    // Point deduplication threshold (skips jitter sub-pixels to maintain high FPS)
    final double distSq = (local.dx - last.dx) * (local.dx - last.dx) +
        (local.dy - last.dy) * (local.dy - last.dy);
    if (distSq < 3.0) return;

    _currentPoints.add(local);

    _activeStrokeNotifier.value = SketchStroke(
      points: List<Offset>.from(_currentPoints),
      color: widget.isEraser ? widget.canvasBackgroundColor : widget.currentColor,
      strokeWidth: widget.isEraser ? widget.currentStrokeWidth * 2.5 : widget.currentStrokeWidth,
      isEraser: widget.isEraser,
    );
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!widget.isInteractive || _currentPoints.isEmpty) return;

    final SketchStroke? finishedStroke = _activeStrokeNotifier.value;
    _currentPoints = <Offset>[];
    _activeStrokeNotifier.value = null;

    if (finishedStroke != null && finishedStroke.points.isNotEmpty) {
      widget.onStrokeComplete?.call(finishedStroke);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _currentPoints = <Offset>[];
    _activeStrokeNotifier.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: widget.canvasBackgroundColor,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Layer 1: Completed static strokes
              RepaintBoundary(
                child: CustomPaint(
                  painter: _StaticStrokesPainter(
                    strokes: widget.strokes,
                    backgroundColor: widget.canvasBackgroundColor,
                  ),
                ),
              ),

              // Layer 2: In-flight active stroke (repainted via ValueNotifier, 0 widget rebuilds)
              CustomPaint(
                painter: _ActiveStrokePainter(
                  strokeNotifier: _activeStrokeNotifier,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fast CustomPainter for all completed strokes with quadratic Bezier smoothing.
class _StaticStrokesPainter extends CustomPainter {
  final List<SketchStroke> strokes;
  final Color backgroundColor;

  const _StaticStrokesPainter({
    required this.strokes,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final SketchStroke stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final Paint paint = Paint()
        ..color = stroke.isEraser ? backgroundColor : stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      if (stroke.points.length == 1) {
        // Single tap point: draw a solid dot
        canvas.drawCircle(
          stroke.points.first,
          stroke.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }

      final Path path = Path();
      path.moveTo(stroke.points[0].dx, stroke.points[0].dy);

      for (int i = 1; i < stroke.points.length - 1; i++) {
        final Offset p0 = stroke.points[i];
        final Offset p1 = stroke.points[i + 1];
        final Offset mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }

      final Offset last = stroke.points.last;
      path.lineTo(last.dx, last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StaticStrokesPainter oldDelegate) {
    return oldDelegate.strokes.length != strokes.length ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Zero-latency painter for the currently active stroke that listens directly
/// to [strokeNotifier] with zero widget tree overhead.
class _ActiveStrokePainter extends CustomPainter {
  final ValueNotifier<SketchStroke?> strokeNotifier;

  _ActiveStrokePainter({required this.strokeNotifier})
      : super(repaint: strokeNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    final SketchStroke? stroke = strokeNotifier.value;
    if (stroke == null || stroke.points.isEmpty) return;

    final Paint paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final Path path = Path();
    path.moveTo(stroke.points[0].dx, stroke.points[0].dy);

    for (int i = 1; i < stroke.points.length - 1; i++) {
      final Offset p0 = stroke.points[i];
      final Offset p1 = stroke.points[i + 1];
      final Offset mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }

    final Offset last = stroke.points.last;
    path.lineTo(last.dx, last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ActiveStrokePainter oldDelegate) => true;
}
