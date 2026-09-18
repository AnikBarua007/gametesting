import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_words.dart';
import '../models/hidden_hand_player.dart';
import 'thematic_components.dart';

class RoleRevealModal extends StatelessWidget {
  final HiddenHandPlayer localPlayer;
  final DrawingWordPrompt prompt;
  final List<HiddenHandPlayer> players;
  final VoidCallback onDismiss;

  const RoleRevealModal({
    super.key,
    required this.localPlayer,
    required this.prompt,
    required this.players,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImpostor = localPlayer.isImpostor;

    return Container(
      color: Colors.black.withValues(alpha: 0.84),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Subtitle
              Text(
                'ROLE DISTRIBUTION',
                style: GoogleFonts.cinzel(
                  color: HiddenHandTheme.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 10),

              // Center Card: "YOUR ROLE"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xeb101326),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                    width: 1.8,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold)
                          .withValues(alpha: 0.25),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Top stars decoration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.star_rate_rounded,
                          size: 13,
                          color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'YOUR ROLE',
                          style: GoogleFonts.cinzel(
                            color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.star_rate_rounded,
                          size: 13,
                          color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      isImpostor ? 'YOU ARE THE' : 'YOU ARE AN',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xff94a3b8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Role Name
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isImpostor ? 'HIDDEN HAND' : 'ARTIST',
                        style: GoogleFonts.cinzel(
                          color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mystery Object Graphic Container
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: isImpostor
                              ? <Color>[
                                  const Color(0xff7f1d1d),
                                  const Color(0xff180816),
                                ]
                              : <Color>[
                                  const Color(0xff78350f),
                                  const Color(0xff1f1508),
                                ],
                        ),
                        border: Border.all(
                          color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                          width: 2.0,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: (isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold)
                                .withValues(alpha: 0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildMedallionContent(isImpostor, prompt),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secret Object Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff181c34),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isImpostor
                              ? HiddenHandTheme.redAccent.withValues(alpha: 0.4)
                              : HiddenHandTheme.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        isImpostor ? 'SECRET OBJECT UNKNOWN' : 'SECRET OBJECT',
                        style: GoogleFonts.cinzel(
                          color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Word
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isImpostor ? 'Blend in & fake your sketch!' : prompt.word,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: isImpostor ? 15 : 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      isImpostor
                          ? 'You do not know the secret word. Watch other artists and mimic their strokes without getting caught!'
                          : 'Roles are assigned. Memorize your role before the round begins.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xff94a3b8),
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Ready Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xeb101326),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xff2c314d)),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'ALL PLAYERS ARE READY',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xffcbd5e1),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: players.take(4).map((p) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            JewelAvatarWidget(
                              icon: _getPlayerIcon(p, players.indexOf(p)),
                              color: Color(p.assignedColorValue),
                              isHost: p.isHost,
                              size: 26,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle_rounded, color: Color(0xff10b981), size: 14),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Start Round CTA
              GoldenCtaButton(
                height: 46,
                onPressed: onDismiss,
                icon: Icons.play_arrow_rounded,
                label: 'START ROUND',
                subtitle: 'Everyone is ready',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedallionContent(bool isImpostor, DrawingWordPrompt prompt) {
    if (isImpostor) {
      return const Center(
        child: Icon(
          Icons.visibility_off_rounded,
          size: 48,
          color: HiddenHandTheme.redAccent,
        ),
      );
    }

    final String cleanWord = prompt.word.trim().toLowerCase();

    // Dedicated high-resolution artwork for wristwatch
    if (cleanWord == 'wristwatch' || cleanWord == 'watch') {
      return Image.asset(
        'assets/images/games/wristwatch_artwork.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.watch_rounded,
            size: 48,
            color: HiddenHandTheme.gold,
          ),
        ),
      );
    }

    // Dynamic prompt icon with gold specular glow
    final IconData icon = _getPromptIcon(cleanWord, prompt.category);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              HiddenHandTheme.gold.withValues(alpha: 0.22),
              Colors.transparent,
            ],
          ),
        ),
        child: Icon(
          icon,
          size: 52,
          color: HiddenHandTheme.gold,
          shadows: <Shadow>[
            Shadow(
              color: HiddenHandTheme.gold.withValues(alpha: 0.55),
              blurRadius: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPromptIcon(String cleanWord, String category) {
    switch (cleanWord) {
      // Vehicles
      case 'helicopter':
        return Icons.flight_takeoff_rounded;
      case 'airplane':
        return Icons.flight_rounded;
      case 'bicycle':
        return Icons.pedal_bike_rounded;
      case 'submarine':
        return Icons.waves_rounded;
      case 'rocket':
        return Icons.rocket_launch_rounded;
      case 'sailboat':
        return Icons.sailing_rounded;

      // Animals
      case 'elephant':
      case 'giraffe':
      case 'dinosaur':
      case 'kangaroo':
        return Icons.cruelty_free_rounded;
      case 'penguin':
        return Icons.egg_rounded;
      case 'octopus':
      case 'sushi':
        return Icons.set_meal_rounded;
      case 'butterfly':
        return Icons.emoji_nature_rounded;

      // Food
      case 'pizza':
        return Icons.local_pizza_rounded;
      case 'burger':
        return Icons.lunch_dining_rounded;
      case 'ice cream':
        return Icons.icecream_rounded;
      case 'pineapple':
        return Icons.emoji_nature_rounded;
      case 'cupcake':
        return Icons.cake_rounded;

      // Everyday Objects
      case 'guitar':
        return Icons.music_note_rounded;
      case 'umbrella':
        return Icons.umbrella_rounded;
      case 'eyeglasses':
        return Icons.visibility_rounded;
      case 'wristwatch':
        return Icons.watch_rounded;
      case 'microscope':
        return Icons.biotech_rounded;
      case 'telescope':
        return Icons.search_rounded;
      case 'hourglass':
        return Icons.hourglass_full_rounded;
      case 'crown':
        return Icons.workspace_premium_rounded;

      // Landmarks & Nature
      case 'eiffel tower':
        return Icons.terrain_rounded;
      case 'pyramid':
        return Icons.change_history_rounded;
      case 'volcano':
        return Icons.whatshot_rounded;
      case 'lighthouse':
        return Icons.lightbulb_rounded;
      case 'windmill':
        return Icons.toys_rounded;
      case 'campfire':
        return Icons.local_fire_department_rounded;

      default:
        switch (category.toLowerCase()) {
          case 'vehicles':
            return Icons.directions_car_rounded;
          case 'animals':
            return Icons.pets_rounded;
          case 'food':
            return Icons.restaurant_rounded;
          case 'landmarks':
            return Icons.castle_rounded;
          case 'nature':
            return Icons.forest_rounded;
          default:
            return Icons.category_rounded;
        }
    }
  }

  IconData _getPlayerIcon(HiddenHandPlayer p, int index) {
    if (p.isHost) return Icons.shield_rounded;
    const List<IconData> icons = <IconData>[
      Icons.memory_rounded,
      Icons.auto_awesome_rounded,
      Icons.dark_mode_rounded,
      Icons.palette_rounded,
      Icons.psychology_rounded,
      Icons.bolt_rounded,
      Icons.token_rounded,
    ];
    return icons[index % icons.length];
  }
}
