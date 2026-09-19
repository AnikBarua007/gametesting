import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';
import 'thematic_components.dart';

/// Ultra-responsive, zero-latency drawing canvas for Hidden Hand.
///
/// Performance Optimizations:
/// 1. Uses raw [Listener] to capture hardware touch input instantaneously (bypassing gesture arena delay).
/// 2. Decoupled into two separate paint layers with [RepaintBoundary]:
///    - Historical strokes are cached in a GPU texture and NEVER repainted while drawing.
///    - Live in-progress stroke repaints only its isolated transparent layer via [ChangeNotifier].
/// 3. Zero widget rebuilds during brush movement (no `setState` called on touch move).
/// 4. Quadratic bezier curves with terminal point connection for smooth, latency-free strokes.
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

/// Lightweight notifier holding the live stroke coordinates.
/// Calling [notifyListeners] triggers repainting ONLY of the live stroke painter.
class _LiveStrokeModel extends ChangeNotifier {
  final List<DrawingPoint> points = <DrawingPoint>[];
  Color color;
  double strokeWidth;

  _LiveStrokeModel({required this.color, required this.strokeWidth});

  void start(double x, double y) {
    points.clear();
    points.add(DrawingPoint(x, y));
    notifyListeners();
  }

  void add(double x, double y) {
    if (points.isNotEmpty) {
      final DrawingPoint last = points.last;
      final double dx = x - last.x;
      final double dy = y - last.y;
      // Skip negligible micro-jitters (< 1.0 px) to prevent unnecessary math
      if (dx * dx + dy * dy < 1.0) return;
    }
    points.add(DrawingPoint(x, y));
    notifyListeners();
  }

  void clear() {
    if (points.isNotEmpty) {
      points.clear();
      notifyListeners();
    }
  }
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  late final _LiveStrokeModel _liveStroke;
  int? _activePointerId;

  @override
  void initState() {
    super.initState();
    _liveStroke = _LiveStrokeModel(
      color: widget.activeColor,
      strokeWidth: widget.strokeWidth,
    );
  }

  @override
  void didUpdateWidget(covariant DrawingCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeColor != oldWidget.activeColor) {
      _liveStroke.color = widget.activeColor;
    }
    if (widget.strokeWidth != oldWidget.strokeWidth) {
      _liveStroke.strokeWidth = widget.strokeWidth;
    }
  }

  @override
  void dispose() {
    _liveStroke.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.isInteractive) return;
    // Lock on the primary pointer
    _activePointerId = event.pointer;
    _liveStroke.start(event.localPosition.dx, event.localPosition.dy);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.isInteractive || event.pointer != _activePointerId) return;
    _liveStroke.add(event.localPosition.dx, event.localPosition.dy);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!widget.isInteractive || event.pointer != _activePointerId) return;
    _activePointerId = null;

    if (_liveStroke.points.isEmpty) return;

    final DrawingStroke stroke = DrawingStroke(
      playerId: widget.activePlayerId,
      points: List<DrawingPoint>.from(_liveStroke.points),
      colorValue: widget.activeColor.toARGB32(),
      strokeWidth: widget.strokeWidth,
    );

    _liveStroke.clear();
    widget.onStrokeCompleted?.call(stroke);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer == _activePointerId) {
      _activePointerId = null;
      _liveStroke.clear();
    }
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
            // 1. Static Blueprint Grid (Isolated RepaintBoundary)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: BlueprintGridPainter(step: 24.0),
                ),
              ),
            ),

            // 2. Venetian Mask Watermark (Static, Center)
            if (widget.showMaskWatermark && widget.strokes.length < 15)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: RepaintBoundary(
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
              ),

            // 3. Historical Completed Strokes Layer (Cached GPU texture, only repaints on stroke addition)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _HistoricalStrokesPainter(strokes: widget.strokes),
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // 4. Live In-Progress Stroke Layer + Hardware Listener (Zero latency, isolated repaint)
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _LiveStrokePainter(liveStroke: _liveStroke),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // 5. Top-right status badge
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

            // 6. Sticky Note Decorator (Bottom-Left)
            if (widget.showStickyNotes)
              Positioned(
                bottom: 0,
                left: 0,
                child: IgnorePointer(
                  child: RepaintBoundary(
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
              ),
          ],
        ),
      ),
    );
  }
}

/// Painter for historical completed strokes.
/// Repaints only when the list of completed strokes changes.
class _HistoricalStrokesPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  const _HistoricalStrokesPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final DrawingStroke stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final Paint paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

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
        path.lineTo(stroke.points.last.x, stroke.points.last.y);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HistoricalStrokesPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}

/// High-performance painter for the live in-progress stroke.
/// Bound to [_LiveStrokeModel] via [super(repaint: liveStroke)],
/// repainting instantly upon touch events without widget rebuilds.
class _LiveStrokePainter extends CustomPainter {
  final _LiveStrokeModel liveStroke;

  _LiveStrokePainter({required this.liveStroke}) : super(repaint: liveStroke);

  @override
  void paint(Canvas canvas, Size size) {
    final List<DrawingPoint> points = liveStroke.points;
    if (points.isEmpty) return;

    final Paint livePaint = Paint()
      ..color = liveStroke.color
      ..strokeWidth = liveStroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (points.length == 1) {
      canvas.drawCircle(points[0].toOffset(), liveStroke.strokeWidth / 2, livePaint);
      return;
    }

    final Path path = Path();
    path.moveTo(points[0].x, points[0].y);

    for (int i = 1; i < points.length; i++) {
      final DrawingPoint p0 = points[i - 1];
      final DrawingPoint p1 = points[i];
      final double midX = (p0.x + p1.x) / 2;
      final double midY = (p0.y + p1.y) / 2;
      path.quadraticBezierTo(p0.x, p0.y, midX, midY);
    }
    path.lineTo(points.last.x, points.last.y);
    canvas.drawPath(path, livePaint);
  }

  @override
  bool shouldRepaint(covariant _LiveStrokePainter oldDelegate) {
    return oldDelegate.liveStroke != liveStroke;
  }
}
