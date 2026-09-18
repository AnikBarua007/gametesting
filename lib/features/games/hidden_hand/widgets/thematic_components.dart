import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens and visual styling for Hidden Hand's mystery detective theme.
class HiddenHandTheme {
  static const Color gold = Color(0xffefc249);
  static const Color goldLight = Color(0xfffde68a);
  static const Color goldDark = Color(0xffb45309);
  static const Color darkBg = Color(0xff0e101d);
  static const Color cardBg = Color(0xcc121528);
  static const Color cardBorder = Color(0xff2c314d);
  static const Color textMuted = Color(0xff8e93ad);
  static const Color textDim = Color(0xff5c627d);
  static const Color cyanAccent = Color(0xff06b6d4);
  static const Color pinkAccent = Color(0xffec4899);
  static const Color greenAccent = Color(0xff10b981);
  static const Color redAccent = Color(0xfff43f5e);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xfff7d768),
      Color(0xffeab308),
      Color(0xffd97706),
    ],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xcc181c33),
      Color(0xcc101324),
    ],
  );
}

/// A glowing golden marble CTA button with rich typography and auto-scaling.
class GoldenCtaButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final double height;
  final bool isLoading;

  const GoldenCtaButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.subtitle,
    this.icon,
    this.height = 50,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: enabled
            ? HiddenHandTheme.goldGradient
            : const LinearGradient(
                colors: <Color>[Color(0xff4b5563), Color(0xff374151)],
              ),
        boxShadow: enabled
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xffeab308).withValues(alpha: 0.38),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Color(0xff12131c),
                    ),
                  )
                else if (icon != null) ...<Widget>[
                  Icon(icon, color: const Color(0xff12131c), size: 18),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: GoogleFonts.cinzel(
                            color: const Color(0xff12131c),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            subtitle!,
                            style: const TextStyle(
                              color: Color(0xcc12131c),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular countdown timer ring with glowing progress.
class TimerRingWidget extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final double size;

  const TimerRingWidget({
    super.key,
    required this.secondsRemaining,
    this.totalSeconds = 15,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (secondsRemaining / math.max(1, totalSeconds)).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: Size(size, size),
            painter: _TimerRingPainter(progress: progress),
          ),
          Text(
            '${secondsRemaining}s',
            style: GoogleFonts.cinzel(
              color: HiddenHandTheme.gold,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;

  _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - 4) / 2;

    final Paint trackPaint = Paint()
      ..color = const Color(0xff2d3148)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;

    final Paint glowPaint = Paint()
      ..color = HiddenHandTheme.gold.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final Paint arcPaint = Paint()
      ..color = HiddenHandTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.2;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      final double sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Round dot indicator displaying "ROUND 1/4" with 4 dot indicators.
class RoundDotIndicator extends StatelessWidget {
  final int currentRound;
  final int totalRounds;

  const RoundDotIndicator({
    super.key,
    required this.currentRound,
    this.totalRounds = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'ROUND $currentRound/$totalRounds',
          style: GoogleFonts.cinzel(
            color: HiddenHandTheme.textMuted,
            fontWeight: FontWeight.w800,
            fontSize: 9.5,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(totalRounds, (index) {
            final bool isCurrent = index == currentRound - 1;
            final bool isPast = index < currentRound - 1;

            return Container(
              margin: const EdgeInsets.only(right: 5),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? HiddenHandTheme.gold
                    : (isPast ? HiddenHandTheme.goldDark : Colors.transparent),
                border: Border.all(
                  color: (isCurrent || isPast)
                      ? HiddenHandTheme.gold
                      : HiddenHandTheme.textDim,
                  width: 1.2,
                ),
                boxShadow: isCurrent
                    ? <BoxShadow>[
                        BoxShadow(
                          color: HiddenHandTheme.gold.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// A taped vintage post-it note pinned on the canvas or board with authentic handwriting font.
class StickyNoteWidget extends StatelessWidget {
  final String text;
  final double angle;
  final double width;

  const StickyNoteWidget({
    super.key,
    required this.text,
    this.angle = -0.06,
    this.width = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
        decoration: BoxDecoration(
          color: const Color(0xff353245).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xff4b495e), width: 0.8),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Translucent scotch tape on top edge
            Positioned(
              top: -16,
              left: (width - 12) / 2 - 16,
              child: Container(
                width: 32,
                height: 11,
                decoration: BoxDecoration(
                  color: const Color(0x66cbd5e1),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0x44ffffff), width: 0.5),
                ),
              ),
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.caveat(
                    color: const Color(0xfff1f5f9),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    height: 1.15,
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

/// Custom painter for the faint blueprint grid pattern on the canvas.
class BlueprintGridPainter extends CustomPainter {
  final double step;

  BlueprintGridPainter({this.step = 24.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xff1d243e).withValues(alpha: 0.45)
      ..strokeWidth = 0.8;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BlueprintGridPainter oldDelegate) => false;
}

/// Custom painter drawing the mysterious phantom mask watermark on the canvas.
class MaskWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint maskPaint = Paint()
      ..color = const Color(0xff222a48).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double w = size.width * 0.28;
    final double h = size.height * 0.32;

    final Path path = Path()
      ..moveTo(cx, cy - h / 2)
      ..cubicTo(cx + w / 2, cy - h / 2, cx + w / 2, cy + h / 4, cx, cy + h / 2)
      ..cubicTo(cx - w / 2, cy + h / 4, cx - w / 2, cy - h / 2, cx, cy - h / 2)
      ..close();

    canvas.drawPath(path, maskPaint);

    // Eye slits
    final Paint eyePaint = Paint()
      ..color = const Color(0xff121528)
      ..style = PaintingStyle.fill;

    final Path leftEye = Path()
      ..moveTo(cx - w * 0.25, cy - h * 0.08)
      ..quadraticBezierTo(cx - w * 0.15, cy - h * 0.16, cx - w * 0.05, cy - h * 0.08)
      ..quadraticBezierTo(cx - w * 0.15, cy - h * 0.02, cx - w * 0.25, cy - h * 0.08)
      ..close();

    final Path rightEye = Path()
      ..moveTo(cx + w * 0.05, cy - h * 0.08)
      ..quadraticBezierTo(cx + w * 0.15, cy - h * 0.16, cx + w * 0.25, cy - h * 0.08)
      ..quadraticBezierTo(cx + w * 0.15, cy - h * 0.02, cx + w * 0.05, cy - h * 0.08)
      ..close();

    canvas.drawPath(leftEye, eyePaint);
    canvas.drawPath(rightEye, eyePaint);
  }

  @override
  bool shouldRepaint(covariant MaskWatermarkPainter oldDelegate) => false;
}

/// Custom painter for the golden crown sitting above the host avatar.
class GoldenCrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = HiddenHandTheme.goldGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    final Path path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.35)
      ..lineTo(w * 0.25, h * 0.65)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.75, h * 0.65)
      ..lineTo(w, h * 0.35)
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(path, paint);

    // Crown base line
    final Paint basePaint = Paint()
      ..color = const Color(0xfffef08a)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, h - 0.5), Offset(w, h - 0.5), basePaint);

    // 3 Jewels on the 3 tips
    final Paint jewelPaint = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(0.5, h * 0.35), 1.0, jewelPaint);
    canvas.drawCircle(Offset(w * 0.5, 0.5), 1.3, jewelPaint);
    canvas.drawCircle(Offset(w - 0.5, h * 0.35), 1.0, jewelPaint);
  }

  @override
  bool shouldRepaint(covariant GoldenCrownPainter oldDelegate) => false;
}

/// A crystal jewel avatar with 3D specular glow, crown, and custom profile icon.
class JewelAvatarWidget extends StatelessWidget {
  final String? initial;
  final IconData? icon;
  final Color color;
  final bool isHost;
  final bool isEliminated;
  final double size;

  const JewelAvatarWidget({
    super.key,
    this.initial,
    this.icon,
    required this.color,
    this.isHost = false,
    this.isEliminated = false,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        // Crown above host avatar
        if (isHost)
          Positioned(
            top: -9,
            child: CustomPaint(
              size: const Size(15, 9),
              painter: GoldenCrownPainter(),
            ),
          ),

        // Faceted / glowing crystal orb
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.25, -0.35),
              radius: 0.9,
              colors: <Color>[
                Colors.white.withValues(alpha: 0.85),
                color,
                color.withValues(alpha: 0.75),
                const Color(0xff090b14),
              ],
              stops: const <double>[0.0, 0.35, 0.75, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: size * 0.54,
                    color: Colors.white,
                  )
                : Text(
                    (initial ?? '?').toUpperCase(),
                    style: GoogleFonts.cinzel(
                      color: const Color(0xff12131c),
                      fontWeight: FontWeight.w900,
                      fontSize: size * 0.44,
                    ),
                  ),
          ),
        ),

        // Green online status dot
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff10b981),
              border: Border.all(color: const Color(0xff0e101d), width: 1.2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xff10b981).withValues(alpha: 0.8),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),

        // Red X if eliminated
        if (isEliminated)
          const Icon(Icons.close_rounded, color: Colors.red, size: 26),
      ],
    );
  }
}

/// The 3-item navigation tab bar: [Draw] | [Discuss] | [Vote].
class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onTabChanged;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildNavItem(0, Icons.brush_rounded, 'Draw'),
          Container(width: 1, height: 16, color: const Color(0xff2d3148)),
          _buildNavItem(1, Icons.chat_bubble_outline_rounded, 'Discuss'),
          Container(width: 1, height: 16, color: const Color(0xff2d3148)),
          _buildNavItem(2, Icons.bar_chart_rounded, 'Vote'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = activeIndex == index;

    return GestureDetector(
      onTap: () => onTabChanged?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 15,
                  color: isActive ? HiddenHandTheme.gold : const Color(0xff6b7280),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    color: isActive ? HiddenHandTheme.gold : const Color(0xff9ca3af),
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (isActive) ...<Widget>[
              const SizedBox(height: 3),
              Container(
                width: 30,
                height: 2.2,
                decoration: BoxDecoration(
                  color: HiddenHandTheme.gold,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: HiddenHandTheme.gold.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
