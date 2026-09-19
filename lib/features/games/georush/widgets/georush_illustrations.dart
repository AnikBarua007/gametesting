import 'package:flutter/material.dart';

/// Renders the Explorer with Map & Compass for Single Player mode
class SinglePlayerExplorerIllustration extends StatelessWidget {
  final double size;
  const SinglePlayerExplorerIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background ambient halo
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  const Color(0xffd4a373).withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Explorer Character Graphic
          Positioned(
            left: size * 0.08,
            top: size * 0.12,
            child: Container(
              width: size * 0.65,
              height: size * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.2),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xfffefae0), Color(0xfffaedcd)],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  // Hat band & crown
                  Positioned(
                    top: 6,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xffc58a43),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Explorer Face / Avatar
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.person_pin_rounded,
                        color: Color(0xff8c531b),
                        size: 44,
                      ),
                    ),
                  ),
                  // Backpack straps
                  Positioned(
                    left: 2,
                    top: 24,
                    child: Container(
                      width: 8,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xff583101),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Folded Map in hands
          Positioned(
            left: size * 0.22,
            bottom: size * 0.08,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: size * 0.52,
                height: size * 0.38,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xffeddcd2),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xffb08968), width: 1.5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _MiniMapPainter(),
                ),
              ),
            ),
          ),

          // Floating Brass Compass Badge
          Positioned(
            top: size * 0.05,
            right: size * 0.04,
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: <Color>[Color(0xffffe6a7), Color(0xffbb9457)],
                ),
                border: Border.all(color: const Color(0xfffff3b0), width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xffbb9457).withValues(alpha: 0.6),
                    blurRadius: 7,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.explore_rounded,
                  color: Color(0xff6f1d1b),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders Two Players Holding Earth Globes for Multiplayer mode
class MultiplayerGlobesIllustration extends StatelessWidget {
  final double size;
  const MultiplayerGlobesIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background ambient blue halo
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  const Color(0xff0284c7).withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Player 1 (Left boy)
          Positioned(
            left: size * 0.04,
            top: size * 0.20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: size * 0.32,
                  height: size * 0.32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xff38bdf8), Color(0xff0369a1)],
                    ),
                  ),
                  child: const Icon(Icons.face_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 2),
                Container(
                  width: size * 0.34,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: const Color(0xff0284c7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),

          // Player 2 (Right girl)
          Positioned(
            right: size * 0.04,
            top: size * 0.20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: size * 0.32,
                  height: size * 0.32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xfff43f5e), Color(0xffbe123c)],
                    ),
                  ),
                  child: const Icon(Icons.face_3_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 2),
                Container(
                  width: size * 0.34,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: const Color(0xffe11d48),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),

          // Main Glowing Globe in Center
          Positioned(
            bottom: size * 0.04,
            child: Container(
              width: size * 0.52,
              height: size * 0.52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.25, -0.3),
                  colors: <Color>[Color(0xff38bdf8), Color(0xff0284c7), Color(0xff0c4a6e)],
                ),
                border: Border.all(color: const Color(0xffbae6fd), width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xff0ea5e9).withValues(alpha: 0.55),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.public_rounded,
                  color: const Color(0xffa7f3d0).withValues(alpha: 0.95),
                  size: size * 0.42,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders World Map with Red Pin & No-WiFi Badge for Offline mode
class OfflineMapIllustration extends StatelessWidget {
  final double size;
  const OfflineMapIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background ambient green halo
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  const Color(0xff059669).withValues(alpha: 0.26),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Folded World Map Canvas
          Positioned(
            left: size * 0.08,
            top: size * 0.12,
            child: Container(
              width: size * 0.68,
              height: size * 0.62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xffd1fae5), Color(0xffa7f3d0)],
                ),
                border: Border.all(color: const Color(0xff34d399), width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(1, 4),
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  CustomPaint(
                    size: Size(size * 0.68, size * 0.62),
                    painter: _MiniMapPainter(
                      landColor: const Color(0xff059669).withValues(alpha: 0.5),
                    ),
                  ),
                  // Location Pin in map center
                  Positioned(
                    top: 10,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xffef4444),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prominent Crossed-out WiFi Badge (bottom-right)
          Positioned(
            right: size * 0.05,
            bottom: size * 0.08,
            child: Container(
              width: size * 0.40,
              height: size * 0.40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: <Color>[Color(0xfffee2e2), Color(0xfffecaca)],
                ),
                border: Border.all(color: const Color(0xffef4444), width: 2.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xffef4444).withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xffdc2626),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final Color? landColor;
  _MiniMapPainter({this.landColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = landColor ?? const Color(0xffb08968).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    // Mini continent silhouettes
    final Path path1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.15, size.width * 0.4, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.15, size.height * 0.5)
      ..close();

    final Path path2 = Path()
      ..moveTo(size.width * 0.55, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.2, size.width * 0.8, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.75, size.width * 0.5, size.height * 0.55)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // Map contour grid line
    final Paint linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.5),
      Offset(size.width * 0.95, size.height * 0.5),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.9),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
