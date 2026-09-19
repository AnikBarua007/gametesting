import 'package:flutter/material.dart';
import '../models/half_and_half_drawing.dart';
import '../models/half_and_half_prompt.dart';
import '../models/half_and_half_state.dart';

class MergedRevealWidget extends StatefulWidget {
  final HalfAndHalfPrompt prompt;
  final HalfAndHalfState state;
  final Function(String) onAddReaction;
  final VoidCallback onToggleLike;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturnToLobby;

  const MergedRevealWidget({
    super.key,
    required this.prompt,
    required this.state,
    required this.onAddReaction,
    required this.onToggleLike,
    required this.onPlayAgain,
    required this.onReturnToLobby,
  });

  @override
  State<MergedRevealWidget> createState() => _MergedRevealWidgetState();
}

class _MergedRevealWidgetState extends State<MergedRevealWidget> {
  bool _showOriginalOverlay = false;

  @override
  Widget build(BuildContext context) {
    final List<DrawingStroke> allMergedStrokes = <DrawingStroke>[
      ...widget.state.topStrokes,
      ...widget.state.bottomStrokes,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Header Title
          const Text(
            'MERGED RESULT & COMPARISON',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 12),

          // Accuracy Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff2e1065),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffa78bfa), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.auto_awesome_rounded, color: Color(0xffe8bd42), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${widget.state.matchScore}% Match Rating! +${widget.state.matchScore * 2} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Main Merged Artwork Card
          Container(
            height: 340,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff140e26),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xff6b4fbb), width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xff6b4fbb).withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  // Merged Canvas or Original Overlay
                  if (_showOriginalOverlay)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: CustomPaint(
                        painter: widget.prompt.painterBuilder(
                          strokeColor: const Color(0xffd4bbfc),
                          strokeWidth: 3.0,
                          fillColor: const Color(0xff9d71e8).withValues(alpha: 0.15),
                        ),
                      ),
                    )
                  else
                    CustomPaint(
                      painter: _CombinedStrokesPainter(strokes: allMergedStrokes),
                    ),

                  // Player Half Labels on Canvas Border
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Top: ${widget.state.playerA.displayName} | Bottom: ${widget.state.playerB.displayName}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Inset Reference Thumbnail (Bottom-Left)
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: GestureDetector(
                      onTap: () => setState(() => _showOriginalOverlay = !_showOriginalOverlay),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xff22143d),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _showOriginalOverlay ? const Color(0xffe8bd42) : Colors.white38,
                            width: 1.8,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: CustomPaint(
                                painter: widget.prompt.painterBuilder(
                                  strokeColor: const Color(0xffc4b5fd),
                                  strokeWidth: 1.4,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              left: 2,
                              right: 2,
                              child: Container(
                                color: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 1),
                                child: Text(
                                  _showOriginalOverlay ? 'Drawing' : 'Reference',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Emoji Reactions Row: 😂 🤯 🤮 ❤️
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <String>['😂', '🤯', '🤮', '❤️'].map((String emoji) {
              final int count = widget.state.reactions[emoji] ?? 0;
              return GestureDetector(
                onTap: () => widget.onAddReaction(emoji),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xff201538),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: count > 0 ? const Color(0xffa78bfa) : const Color(0xff39285f),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      if (count > 0) ...<Widget>[
                        const SizedBox(width: 6),
                        Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Share Button matching mockup
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xff553c98), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: const Color(0xff18122d).withValues(alpha: 0.8),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xff2e1065),
                    content: Text('🎉 Masterpiece saved & copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.share_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('SHARE', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Community Likes Counter
          GestureDetector(
            onTap: widget.onToggleLike,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.favorite_rounded, color: Color(0xfff43f5e), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Community Likes: ${widget.state.communityLikes}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Play Again & Lobby Buttons
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: widget.onReturnToLobby,
                  child: const Text('Back to Lobby', style: TextStyle(color: Colors.white60)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7c3aed),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: widget.onPlayAgain,
                  child: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CombinedStrokesPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  _CombinedStrokesPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final DrawingStroke stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final Paint paint = Paint()
        ..color = stroke.isEraser ? const Color(0xff140e26) : stroke.color
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
  }

  @override
  bool shouldRepaint(covariant _CombinedStrokesPainter oldDelegate) => true;
}

