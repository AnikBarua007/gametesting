import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sketch_party_player.dart';
import '../models/sketch_party_word.dart';

class SketchRoundResultModal extends StatelessWidget {
  final SketchPartyWord? word;
  final List<SketchPartyPlayer> players;
  final String drawerName;
  final VoidCallback onNextTurn;

  const SketchRoundResultModal({
    super.key,
    required this.word,
    required this.players,
    required this.drawerName,
    required this.onNextTurn,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = constraints.maxHeight < 390;

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Top Header: Horizontal Divider Lines + [ ROUND FINISHED ] Pill
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xff08abc4).withValues(alpha: 0.4),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xff08abc4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xff08abc4),
                      width: 1.4,
                    ),
                  ),
                  child: Text(
                    'ROUND FINISHED',
                    style: GoogleFonts.outfit(
                      color: const Color(0xff08abc4),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xff08abc4).withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),

            if (isCompact) const SizedBox(height: 10) else const Spacer(),

            // Revealed Secret Word
            Center(
              child: Text(
                word?.word.toUpperCase() ?? 'WORD',
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                'Sketched by $drawerName',
                style: GoogleFonts.outfit(
                  color: const Color(0xff94a3b8),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (isCompact) const SizedBox(height: 12) else const Spacer(),

            // Player Points Breakdown Inner Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff0a1324),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xff08abc4).withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(players.length, (int index) {
                  final SketchPartyPlayer p = players[index];
                  final bool isLast = index == players.length - 1;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            // Icon: Green check circle if guessed, person icon otherwise
                            if (p.hasGuessed)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff22c55e),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white12,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 14,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 10),

                            // Player Name
                            Expanded(
                              child: Text(
                                p.displayName,
                                style: GoogleFonts.fredoka(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            // Points gained this round (e.g. +50, +270)
                            if (p.roundScore > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff8df40).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xfff8df40).withValues(alpha: 0.8),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  '+${p.roundScore}',
                                  style: GoogleFonts.fredoka(
                                    color: const Color(0xfff8df40),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),

                            // Total Score
                            Text(
                              '${p.totalScore} pts',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          color: Colors.white.withValues(alpha: 0.08),
                          height: 10,
                        ),
                    ],
                  );
                }),
              ),
            ),

            if (isCompact) const SizedBox(height: 12) else const Spacer(),

            // Continue CTA Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff08abc4),
                  foregroundColor: const Color(0xff091222),
                  elevation: 6,
                  shadowColor: const Color(0xff08abc4).withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onNextTurn,
                child: Text(
                  'CONTINUE',
                  style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        );

        if (isCompact) {
          content = SingleChildScrollView(child: content);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xff091426),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xff08abc4),
              width: 1.8,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xff08abc4).withValues(alpha: 0.35),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: content,
        );
      },
    );
  }
}
