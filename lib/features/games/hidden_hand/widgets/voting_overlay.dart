import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/drawing_stroke.dart';
import '../models/hidden_hand_player.dart';
import '../models/hidden_hand_state.dart';
import 'thematic_components.dart';

class VotingOverlay extends StatefulWidget {
  final HiddenHandState state;
  final String localPlayerId;
  final ValueChanged<String> onCastVote;
  final VoidCallback? onSkipVote;

  const VotingOverlay({
    super.key,
    required this.state,
    required this.localPlayerId,
    required this.onCastVote,
    this.onSkipVote,
  });

  @override
  State<VotingOverlay> createState() => _VotingOverlayState();
}

class _VotingOverlayState extends State<VotingOverlay> {
  String? _selectedCandidateId;

  @override
  void initState() {
    super.initState();
    final HiddenHandPlayer? local = widget.state.getPlayer(widget.localPlayerId);
    _selectedCandidateId = local?.voteTargetId;
  }

  @override
  Widget build(BuildContext context) {
    final HiddenHandPlayer? localPlayer = widget.state.getPlayer(widget.localPlayerId);
    final bool hasVoted = localPlayer?.voteTargetId != null;
    final List<HiddenHandPlayer> alivePlayers = widget.state.activePlayers;

    // Vote tally
    final Map<String, int> tally = <String, int>{};
    int skipVotes = 0;
    for (final HiddenHandPlayer p in alivePlayers) {
      if (p.voteTargetId == 'SKIP') {
        skipVotes++;
      } else if (p.voteTargetId != null) {
        tally[p.voteTargetId!] = (tally[p.voteTargetId!] ?? 0) + 1;
      }
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double minHeight = constraints.maxHeight > 24
                ? constraints.maxHeight - 24
                : 0.0;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
              // Turn Banner: ROUND 1/4 | TIME TO VOTE | Timer Ring
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xeb121528),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HiddenHandTheme.cardBorder),
                ),
                child: Row(
                  children: <Widget>[
                    RoundDotIndicator(
                      currentRound: widget.state.roundNumber,
                      totalRounds: 4,
                    ),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 26, color: const Color(0xff2d3148)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'TIME TO VOTE',
                            style: GoogleFonts.cinzel(
                              color: HiddenHandTheme.gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Who is the Hidden Hand drawing blindly?',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xff94a3b8),
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(width: 1, height: 26, color: const Color(0xff2d3148)),
                    const SizedBox(width: 8),
                    TimerRingWidget(
                      secondsRemaining: widget.state.turnTimeRemaining,
                      totalSeconds: 20,
                      size: 40,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Candidate Selection Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xeb101326),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xff2c314d)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Vote out the impostor or skip to keep drawing.',
                        style: GoogleFonts.cinzel(color: const Color(0xff94a3b8), fontSize: 10.5),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Candidate Cards
                    ...alivePlayers.map((candidate) {
                      final bool isSelected = _selectedCandidateId == candidate.id;
                      final int votes = tally[candidate.id] ?? 0;
                      final Color pColor = Color(candidate.assignedColorValue);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff272010)
                              : const Color(0xff15182c),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? HiddenHandTheme.gold : const Color(0xff292f49),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: HiddenHandTheme.gold.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: hasVoted
                                ? null
                                : () => setState(() => _selectedCandidateId = candidate.id),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              child: Row(
                                children: <Widget>[
                                  JewelAvatarWidget(
                                    initial: candidate.displayName.substring(0, 1),
                                    color: pColor,
                                    isHost: false,
                                    isEliminated: candidate.isEliminated,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          candidate.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cinzel(
                                            color: isSelected ? HiddenHandTheme.gold : Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        Text(
                                          isSelected
                                              ? 'Your current choice'
                                              : (candidate.voteTargetId != null
                                                  ? 'Has voted'
                                                  : 'Waiting for vote'),
                                          style: TextStyle(
                                            color: isSelected
                                                ? HiddenHandTheme.goldLight
                                                : (candidate.voteTargetId != null
                                                    ? const Color(0xff10b981)
                                                    : const Color(0xff64748b)),
                                            fontSize: 9.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (votes > 0) ...<Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xfff43f5e).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xfff43f5e)),
                                      ),
                                      child: Text(
                                        '$votes vote${votes > 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          color: Color(0xfff43f5e),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: HiddenHandTheme.gold,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const <Widget>[
                                          Icon(Icons.check_rounded, size: 12, color: Color(0xff12131c)),
                                          SizedBox(width: 2),
                                          Text(
                                            'SELECTED',
                                            style: TextStyle(
                                              color: Color(0xff12131c),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 9.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (!hasVoted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: HiddenHandTheme.gold, width: 1.2),
                                      ),
                                      child: Text(
                                        'VOTE',
                                        style: GoogleFonts.cinzel(
                                          color: HiddenHandTheme.gold,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Miniature Canvas Sketch Preview ("CURRENT CANVAS")
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xeb101326),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xff2c314d)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'CURRENT CANVAS',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xff94a3b8),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        // Miniature canvas view
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 100,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xff0d1020),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xff3b82f6), width: 1),
                            ),
                            child: CustomPaint(
                              painter: _MiniCanvasPainter(strokes: widget.state.strokes),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: const <Widget>[
                              Icon(Icons.remove_red_eye_rounded, size: 15, color: HiddenHandTheme.cyanAccent),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Study the sketch.\nFind the fake artist.',
                                  style: TextStyle(
                                    color: Color(0xff94a3b8),
                                    fontSize: 9.5,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const StickyNoteWidget(
                          text: 'SAME PICTURE\nDIFFERENT\nMINDS',
                          angle: 0.04,
                          width: 76,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Bottom Actions: [SKIP VOTE] and [CONFIRM VOTE] - Guaranteed no overflow
              Row(
                children: <Widget>[
                  // SKIP VOTE
                  Expanded(
                    child: OutlinedButton(
                      onPressed: hasVoted
                          ? null
                          : () {
                              widget.onCastVote('SKIP');
                              widget.onSkipVote?.call();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        side: const BorderSide(color: Color(0xff3f4668), width: 1.2),
                        backgroundColor: const Color(0xff181c34),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(Icons.skip_next_rounded, size: 15, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'SKIP VOTE',
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              skipVotes > 0 ? 'Keep drawing ($skipVotes)' : 'Keep drawing',
                              style: const TextStyle(color: Color(0xff94a3b8), fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // CONFIRM VOTE
                  Expanded(
                    child: GoldenCtaButton(
                      height: 44,
                      onPressed: (!hasVoted && _selectedCandidateId != null)
                          ? () => widget.onCastVote(_selectedCandidateId!)
                          : null,
                      icon: Icons.check_circle_rounded,
                      label: hasVoted ? 'VOTE RECORDED' : 'CONFIRM VOTE',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.lock_outline_rounded, size: 11, color: Color(0xff64748b)),
                  SizedBox(width: 4),
                  Text(
                    'Voting ends when all players decide.',
                    style: TextStyle(color: Color(0xff64748b), fontSize: 9.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
),
),
);
  }
}

class _MiniCanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  _MiniCanvasPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    // Background faint grid
    final Paint gridPaint = Paint()
      ..color = const Color(0xff1d243e).withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Scale strokes to fit mini preview
    const double sourceWidth = 360.0;
    const double sourceHeight = 360.0;
    final double scaleX = size.width / sourceWidth;
    final double scaleY = size.height / sourceHeight;

    for (final DrawingStroke stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final Paint paint = Paint()
        ..color = stroke.color
        ..strokeWidth = (stroke.strokeWidth * scaleX).clamp(1.0, 3.0)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          Offset(stroke.points[0].x * scaleX, stroke.points[0].y * scaleY),
          1.5,
          paint,
        );
      } else {
        final Path path = Path();
        path.moveTo(stroke.points[0].x * scaleX, stroke.points[0].y * scaleY);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].x * scaleX, stroke.points[i].y * scaleY);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniCanvasPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
