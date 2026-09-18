import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';
import 'thematic_components.dart';

class DrawingCanvasWidget extends StatefulWidget {
  final List<DrawingStroke> strokes;
  final bool isInteractive;
  final Color activeColor;
  final double strokeWidth;
  final String activePlayerId;
  final Color? glowColor;
  final String? artistName;
  final bool showStickyNotes;
  final bool showMaskWatermark;
  final ValueChanged<DrawingStroke>? onStrokeCompleted;

  const DrawingCanvasWidget({
    super.key,
    required this.strokes,
    required this.isInteractive,
    required this.activeColor,
    required this.strokeWidth,
    required this.activePlayerId,
    this.glowColor,
    this.artistName,
    this.showStickyNotes = true,
    this.showMaskWatermark = true,
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
    final Color borderColor = widget.isInteractive
        ? HiddenHandTheme.gold
        : (widget.glowColor ?? const Color(0xff3b82f6));

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff0d1020).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor.withValues(alpha: widget.isInteractive ? 0.9 : 0.45),
            width: widget.isInteractive ? 2.2 : 1.5,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: borderColor.withValues(alpha: widget.isInteractive ? 0.22 : 0.08),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            // Blueprint grid background
            Positioned.fill(
              child: CustomPaint(
                painter: BlueprintGridPainter(step: 24.0),
              ),
            ),

            // Exact Venetian mask watermark from reference assets (center behind strokes)
            if (widget.showMaskWatermark && widget.strokes.length < 15)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Image.asset(
                      'assets/images/games/canvas_mask_watermark.png',
                      width: 135,
                      height: 155,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

            // Drawing canvas and gesture detector
            GestureDetector(
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

            // Top-right status badge
            Positioned(
              top: 10,
              right: 12,
              child: IgnorePointer(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xff121526).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff10b981),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xff10b981).withValues(alpha: 0.7),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          widget.isInteractive
                              ? 'Your Brush Active'
                              : (widget.artistName != null
                                  ? '${widget.artistName} Drawing'
                                  : 'Brush Ready'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.isInteractive
                                ? HiddenHandTheme.gold
                                : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Exact Sticky Note from reference UI (Bottom-Left only, attached to border)
            if (widget.showStickyNotes)
              Positioned(
                bottom: 0,
                left: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/games/sticky_note_transparent.png',
                    width: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const StickyNoteWidget(
                      text: 'GOOD ART\nREVEALS\nEVERYTHING',
                      angle: -0.05,
                      width: 80,
                    ),
                  ),
                ),
              ),
          ],
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
