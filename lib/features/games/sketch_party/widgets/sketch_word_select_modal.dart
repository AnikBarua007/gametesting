import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sketch_party_word.dart';

class SketchWordSelectModal extends StatelessWidget {
  final List<SketchPartyWord> choices;
  final ValueChanged<SketchPartyWord> onWordSelected;

  const SketchWordSelectModal({
    super.key,
    required this.choices,
    required this.onWordSelected,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'objects':
      case 'object':
        return Icons.view_in_ar_rounded;
      case 'places':
      case 'place':
        return Icons.location_on_rounded;
      case 'vehicles':
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'animals':
      case 'animal':
        return Icons.pets_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'nature':
        return Icons.park_rounded;
      case 'sports':
      case 'actions':
        return Icons.sports_soccer_rounded;
      case 'fantasy':
        return Icons.auto_awesome_rounded;
      case 'people':
        return Icons.person_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = constraints.maxHeight < 390;

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header: Circular Palette Icon + Title + Subtitle
            Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff0e203c),
                    border: Border.all(
                      color: const Color(0xff08abc4),
                      width: 1.6,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xff08abc4).withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.palette_rounded,
                      color: Color(0xfff8df40),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Your Turn to Draw',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose one secret word',
                        style: GoogleFonts.outfit(
                          color: const Color(0xff94a3b8),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isCompact) const SizedBox(height: 12) else const Spacer(),

            // 3 Word Choice Cards
            ...choices.map((SketchPartyWord word) {
              final Color diffColor;
              final String diffText;
              switch (word.difficulty) {
                case WordDifficulty.easy:
                  diffColor = const Color(0xff10b981);
                  diffText = 'Easy';
                  break;
                case WordDifficulty.medium:
                  diffColor = const Color(0xfff8df40);
                  diffText = 'Medium';
                  break;
                case WordDifficulty.hard:
                  diffColor = const Color(0xffef4444);
                  diffText = 'Hard';
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 11),
                decoration: BoxDecoration(
                  color: const Color(0xff091426),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: diffColor,
                    width: 1.5,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: diffColor.withValues(alpha: 0.22),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onWordSelected(word),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: <Widget>[
                          // Circular Category Icon Container
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff0e203c),
                              border: Border.all(
                                color: diffColor,
                                width: 1.4,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _getCategoryIcon(word.category),
                                color: diffColor,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Category & Word Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  word.category.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: diffColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  word.word,
                                  style: GoogleFonts.fredoka(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Points & Difficulty Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xff091426),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: diffColor,
                                width: 1.4,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: diffColor.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  '+${word.difficulty.basePoints}',
                                  style: GoogleFonts.fredoka(
                                    color: diffColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  diffText,
                                  style: GoogleFonts.outfit(
                                    color: diffColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Chevron Right Arrow
                          Icon(
                            Icons.chevron_right_rounded,
                            color: diffColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            if (isCompact) const SizedBox(height: 10) else const Spacer(),

            // Bottom Info Note with Dividers
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xff08abc4).withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xff94a3b8),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Harder words earn more points',
                        style: GoogleFonts.outfit(
                          color: const Color(0xff94a3b8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xff08abc4).withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ],
        );

        if (isCompact) {
          content = SingleChildScrollView(child: content);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
