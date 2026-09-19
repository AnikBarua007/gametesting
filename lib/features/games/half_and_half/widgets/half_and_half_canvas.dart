import 'package:flutter/material.dart';
import '../models/half_and_half_drawing.dart';
import '../models/half_and_half_state.dart';

class HalfAndHalfCanvas extends StatefulWidget {
  final HalfAndHalfRole localRole;
  final List<DrawingStroke> currentStrokes;
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final Function(DrawingStroke) onStrokeCompleted;
  final Function(Size) onSizeDetermined;

  const HalfAndHalfCanvas({
    super.key,
    required this.localRole,
    required this.currentStrokes,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isEraser,
    required this.onStrokeCompleted,
    required this.onSizeDetermined,
  });

  @override
  State<HalfAndHalfCanvas> createState() => _HalfAndHalfCanvasState();
}

class _HalfAndHalfCanvasState extends State<HalfAndHalfCanvas> {
  List<DrawingPoint> _currentPoints = <DrawingPoint>[];

  bool _isInsideAllowedArea(Offset point, Size size) {
    final double seamY = size.height * 0.5;
    const double tolerance = 15.0; // 15px seam tolerance for natural overlap

    if (widget.localRole == HalfAndHalfRole.topHalf) {
      return point.dy <= (seamY + tolerance);
    } else {
      return point.dy >= (seamY - tolerance);
    }
  }

  void _onPanStart(DragDownDetails details, BoxConstraints constraints) {
    final Offset localPos = details.localPosition;
    final Size size = Size(constraints.maxWidth, constraints.maxHeight);

    if (!_isInsideAllowedArea(localPos, size)) return;

    setState(() {
      _currentPoints = <DrawingPoint>[
        DrawingPoint(
          offset: localPos,
          color: widget.selectedColor,
          strokeWidth: widget.selectedWidth,
          isEraser: widget.isEraser,
        ),
      ];
    });
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_currentPoints.isEmpty) return;

    final Offset localPos = details.localPosition;
    final Size size = Size(constraints.maxWidth, constraints.maxHeight);

    if (!_isInsideAllowedArea(localPos, size)) return;

    setState(() {
      _currentPoints.add(
        DrawingPoint(
          offset: localPos,
          color: widget.selectedColor,
          strokeWidth: widget.selectedWidth,
          isEraser: widget.isEraser,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPoints.isNotEmpty) {
      final DrawingStroke stroke = DrawingStroke(
        points: List<DrawingPoint>.from(_currentPoints),
        color: widget.selectedColor,
        strokeWidth: widget.selectedWidth,
        isEraser: widget.isEraser,
      );
      widget.onStrokeCompleted(stroke);
      setState(() {
        _currentPoints = <DrawingPoint>[];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTop = widget.localRole == HalfAndHalfRole.topHalf;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSizeDetermined(canvasSize);
        });

        final double seamY = canvasSize.height * 0.5;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xff7052be), width: 2.2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: <Widget>[
                // Drawing Canvas Area
                GestureDetector(
                  onPanDown: (DragDownDetails d) => _onPanStart(d, constraints),
                  onPanUpdate: (DragUpdateDetails d) => _onPanUpdate(d, constraints),
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    size: canvasSize,
                    painter: _StrokesPainter(
                      strokes: widget.currentStrokes,
                      activePoints: _currentPoints,
                      activeColor: widget.selectedColor,
                      activeWidth: widget.selectedWidth,
                      isEraser: widget.isEraser,
                    ),
                  ),
                ),

                // Mask for the Hidden Half (matching Phone 2 & 3 mockup)
                Positioned(
                  left: 0,
                  right: 0,
                  top: isTop ? seamY : 0,
                  height: seamY,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff090714),
                        border: Border(
                          top: isTop ? const BorderSide(color: Color(0xff553c98), width: 1.5) : BorderSide.none,
                          bottom: !isTop ? const BorderSide(color: Color(0xff553c98), width: 1.5) : BorderSide.none,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xff8b5cf6).withValues(alpha: 0.18),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.visibility_off_rounded,
                            color: const Color(0xffa78bfa).withValues(alpha: 0.6),
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isTop ? 'Bottom Half Hidden' : 'Top Half Hidden',
                            style: const TextStyle(
                              color: Color(0xffc4b5fd),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Dashed Center Guideline Line
                Positioned(
                  left: 0,
                  right: 0,
                  top: seamY - 1,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DashedLinePainter(),
                      child: Container(
                        height: 2,
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xff7052be), width: 1),
                          ),
                          child: Text(
                            isTop ? 'Bottom Edge Guideline' : 'Top Edge Guideline',
                            style: const TextStyle(
                              color: Color(0xff583b9b),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StrokesPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<DrawingPoint> activePoints;
  final Color activeColor;
  final double activeWidth;
  final bool isEraser;

  _StrokesPainter({
    required this.strokes,
    required this.activePoints,
    required this.activeColor,
    required this.activeWidth,
    required this.isEraser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final DrawingStroke stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final Paint paint = Paint()
        ..color = stroke.isEraser ? Colors.white : stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first.offset, stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      } else {
        final Path path = Path()..moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].offset.dx, stroke.points[i].offset.dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Draw active live stroke
    if (activePoints.isNotEmpty) {
      final Paint activePaint = Paint()
        ..color = isEraser ? Colors.white : activeColor
        ..strokeWidth = activeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (activePoints.length == 1) {
        canvas.drawCircle(activePoints.first.offset, activeWidth / 2, activePaint..style = PaintingStyle.fill);
      } else {
        final Path path = Path()..moveTo(activePoints.first.offset.dx, activePoints.first.offset.dy);
        for (int i = 1; i < activePoints.length; i++) {
          path.lineTo(activePoints[i].offset.dx, activePoints[i].offset.dy);
        }
        canvas.drawPath(path, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) => true;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xff7052be)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6.0;
    const double dashSpace = 4.0;
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

