import 'package:flutter/material.dart';
import '../models/half_and_half_prompt.dart';
import '../models/half_and_half_state.dart';
import 'half_and_half_theme.dart';

class MemorizePhaseWidget extends StatelessWidget {
  final HalfAndHalfPrompt prompt;
  final HalfAndHalfRole localRole;
  final int secondsRemaining;

  const MemorizePhaseWidget({
    super.key,
    required this.prompt,
    required this.localRole,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTop = localRole == HalfAndHalfRole.topHalf;
    final String roleTitle = isTop ? 'Memorize the Top Half!' : 'Memorize the Bottom Half!';
    final String formattedTime = '00:${secondsRemaining.toString().padLeft(2, '0')}';

    return Column(
      children: <Widget>[
        const SizedBox(height: 8),

        // Phase Title
        Text(
          roleTitle,
          style: HalfAndHalfTheme.title(
            fontSize: 22,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 14),

        // Reference Illustration Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: <Color>[Color(0xff2a1f4a), Color(0xff18122d), Color(0xff100c20)],
              ),
              border: Border.all(color: const Color(0xff6b4fbb).withValues(alpha: 0.6), width: 1.8),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xff6b4fbb).withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  // Vector Reference Painting
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: CustomPaint(
                      painter: prompt.painterBuilder(
                        strokeColor: const Color(0xffd4bbfc),
                        strokeWidth: 2.8,
                        fillColor: const Color(0xff9d71e8).withValues(alpha: 0.12),
                      ),
                    ),
                  ),

                  // Divider Guideline at Seam (50%)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final double seamY = constraints.maxHeight * prompt.seamYRatio;
                        return Stack(
                          children: <Widget>[
                            // Darkened dim overlay on the OTHER player's half
                            Positioned(
                              left: 0,
                              right: 0,
                              top: isTop ? seamY : 0,
                              height: constraints.maxHeight * 0.5,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.72),
                                alignment: Alignment.center,
                                child: Text(
                                  isTop ? 'Partner will draw this half' : 'Partner will draw this half',
                                  style: HalfAndHalfTheme.body(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                            // Guideline Line & Label
                            Positioned(
                              top: seamY - 1,
                              left: 0,
                              right: 0,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: HalfAndHalfTheme.accentGold.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff22143d),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: HalfAndHalfTheme.accentGold, width: 1),
                                    ),
                                    child: Text(
                                      'Seam Guideline',
                                      style: HalfAndHalfTheme.badge(
                                        color: HalfAndHalfTheme.accentGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: HalfAndHalfTheme.accentGold.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Countdown Timer Block
        Column(
          children: <Widget>[
            Text(
              'MEMORIZE IN:',
              style: HalfAndHalfTheme.badge(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: HalfAndHalfTheme.title(
                fontSize: 38,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Subtitle indicator matching mockup
        Text(
          '1. MEMORIZE REFERENCE (${isTop ? "Player A" : "Player B"})',
          style: HalfAndHalfTheme.body(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 14),
      ],
    );
  }
}

