import 'package:flutter/material.dart';
import '../models/georush_mode.dart';
import 'georush_illustrations.dart';

class GeoRushModeCard extends StatefulWidget {
  final GeoRushModeData data;
  final VoidCallback onAction;

  const GeoRushModeCard({
    super.key,
    required this.data,
    required this.onAction,
  });

  @override
  State<GeoRushModeCard> createState() => _GeoRushModeCardState();
}

class _GeoRushModeCardState extends State<GeoRushModeCard> {
  bool _isHoveredOrPressed = false;

  Widget _buildIllustration() {
    switch (widget.data.mode) {
      case GeoRushGameMode.singlePlayer:
        return const SinglePlayerExplorerIllustration(size: 112);
      case GeoRushGameMode.multiplayer:
        return const MultiplayerGlobesIllustration(size: 112);
      case GeoRushGameMode.offline:
        return const OfflineMapIllustration(size: 112);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.data.accentColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isHoveredOrPressed = true),
      onTapUp: (_) => setState(() => _isHoveredOrPressed = false),
      onTapCancel: () => setState(() => _isHoveredOrPressed = false),
      onTap: widget.onAction,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHoveredOrPressed
                ? <Color>[
                    const Color(0xff1d354d),
                    const Color(0xff142639),
                  ]
                : <Color>[
                    const Color(0xff16283b),
                    const Color(0xff0e1d2c),
                  ],
          ),
          border: Border.all(
            color: _isHoveredOrPressed
                ? accent.withValues(alpha: 0.65)
                : const Color(0xff233e5b),
            width: _isHoveredOrPressed ? 1.6 : 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _isHoveredOrPressed
                  ? accent.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.35),
              blurRadius: _isHoveredOrPressed ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Left Illustration
            _buildIllustration(),

            const SizedBox(width: 14),

            // Right Information & Action
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Mode Title
                  Text(
                    widget.data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Mode Description
                  Text(
                    widget.data.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12.2,
                      height: 1.28,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pill Action Button
                  InkWell(
                    onTap: widget.onAction,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xff274766).withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xff3d668e).withValues(alpha: 0.75),
                          width: 1.1,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.data.actionLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

