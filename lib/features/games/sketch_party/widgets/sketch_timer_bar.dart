import 'package:flutter/material.dart';

class SketchTimerBar extends StatelessWidget {
  final int timeRemaining;
  final int totalDuration;

  const SketchTimerBar({
    super.key,
    required this.timeRemaining,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = totalDuration > 0
        ? (timeRemaining / totalDuration).clamp(0.0, 1.0)
        : 0.0;

    final Color timerColor = timeRemaining > 25
        ? const Color(0xff08abc4)
        : (timeRemaining > 10 ? const Color(0xfff4d935) : const Color(0xffef4444));

    final bool isUrgent = timeRemaining <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff161e36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: timerColor.withValues(alpha: isUrgent ? 0.8 : 0.3),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.hourglass_bottom_rounded,
            size: 16,
            color: timerColor,
          ),
          const SizedBox(width: 6),
          Text(
            '${timeRemaining}s',
            style: TextStyle(
              color: timerColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

