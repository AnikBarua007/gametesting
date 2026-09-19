import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/profile_service.dart';
import '../models/sketch_party_player.dart';

class SketchScoreboard extends StatelessWidget {
  final List<SketchPartyPlayer> players;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  final VoidCallback? onViewStats;
  final String? localUserId;

  const SketchScoreboard({
    super.key,
    required this.players,
    required this.onPlayAgain,
    required this.onExit,
    this.onViewStats,
    this.localUserId,
  });

  Widget _buildAvatar(SketchPartyPlayer player, double size) {
    final PlayerAvatar avatar = PlayerAvatar.getById(player.avatarId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.25, -0.35),
          radius: 0.9,
          colors: <Color>[
            avatar.secondaryColor,
            avatar.primaryColor,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: avatar.primaryColor.withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          avatar.icon,
          size: size * 0.55,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildConfettiPiece(Color color, double angle, double width, double height) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<SketchPartyPlayer> sorted = List<SketchPartyPlayer>.from(players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    final SketchPartyPlayer? first = sorted.isNotEmpty ? sorted[0] : null;
    final SketchPartyPlayer? second = sorted.length > 1 ? sorted[1] : null;
    final SketchPartyPlayer? third = sorted.length > 2 ? sorted[2] : null;

    final UserProfile? profile = localUserId != null
        ? ProfileService.instance.getProfileSync(localUserId!)
        : null;
    final int gamesPlayed = profile?.stats.gamesPlayed ?? 12;
    final int wins = profile?.stats.wins ?? 4;
    final String favoriteGame = profile?.stats.favoriteGame == 'sketch-party'
        ? 'Rocket'
        : (profile?.stats.favoriteGame ?? 'Rocket');

    return Scaffold(
      backgroundColor: const Color(0xff060b17),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Ambient celebration background glow
            Positioned(
              top: -50,
              left: -50,
              right: -50,
              height: 350,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: <Color>[
                      const Color(0xff08abc4).withValues(alpha: 0.25),
                      const Color(0xff060b17).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: <Widget>[
                  // Logo
                  Image.asset(
                    'assets/images/games/sketch_party_logo.png',
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Text(
                      'SKETCH PARTY',
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Celebration Title with Sparkles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Left celebratory confetti accent
                      Column(
                        children: <Widget>[
                          _buildConfettiPiece(const Color(0xfff8df40), -0.4, 4, 12),
                          const SizedBox(height: 4),
                          _buildConfettiPiece(const Color(0xff38bdf8), 0.5, 5, 10),
                        ],
                      ),
                      const SizedBox(width: 14),

                      Text(
                        'Match Complete',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Right celebratory confetti accent
                      Column(
                        children: <Widget>[
                          _buildConfettiPiece(const Color(0xfff8df40), 0.4, 4, 12),
                          const SizedBox(height: 4),
                          _buildConfettiPiece(const Color(0xff38bdf8), -0.5, 5, 10),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  Text(
                    'Great game, everyone!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xff94a3b8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top 3 Podium
                  _buildPodium(first, second, third),

                  const SizedBox(height: 20),

                  // Final Scores Card
                  _buildFinalScoresCard(sorted),

                  const SizedBox(height: 14),

                  // Your Stats Card
                  _buildStatsCard(gamesPlayed, wins, favoriteGame),

                  const SizedBox(height: 20),

                  // Rematch Button
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xfffef08a),
                          Color(0xfffacc15),
                          Color(0xffeab308),
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xfffacc15).withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPlayAgain,
                        borderRadius: BorderRadius.circular(26),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff1f2937),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xfffacc15),
                                  size: 22,
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Rematch',
                                    style: GoogleFonts.fredoka(
                                      color: const Color(0xff0f172a),
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xff0f172a),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary Buttons (Back to Hub & View Stats)
                  Row(
                    children: <Widget>[
                      // Back to Hub
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onExit,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xff0c162c),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xff08abc4).withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(
                                    Icons.home_rounded,
                                    size: 19,
                                    color: Color(0xff38bdf8),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Back to Hub',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // View Stats
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onViewStats ?? onExit,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xff0c162c),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xff08abc4).withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(
                                    Icons.bar_chart_rounded,
                                    size: 19,
                                    color: Color(0xff38bdf8),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View Stats',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(SketchPartyPlayer? first, SketchPartyPlayer? second, SketchPartyPlayer? third) {
    return SizedBox(
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          // 2nd Place (Silver / Ice-Blue)
          if (second != null)
            _buildPodiumColumn(
              player: second,
              rankLabel: '2nd',
              width: 95,
              height: 105,
              avatarSize: 58,
              colors: <Color>[
                const Color(0xff38bdf8),
                const Color(0xff0284c7),
                const Color(0xff075985),
              ],
              borderColor: const Color(0xffbae6fd),
              auraColor: const Color(0xff38bdf8),
              hasCrown: false,
            )
          else
            const SizedBox(width: 95),

          const SizedBox(width: 8),

          // 1st Place (Gold / Champion)
          if (first != null)
            _buildPodiumColumn(
              player: first,
              rankLabel: '1st',
              width: 110,
              height: 132,
              avatarSize: 68,
              colors: <Color>[
                const Color(0xfffacc15),
                const Color(0xffca8a04),
                const Color(0xff854d0e),
              ],
              borderColor: const Color(0xfffef08a),
              auraColor: const Color(0xfffacc15),
              hasCrown: true,
            ),

          const SizedBox(width: 8),

          // 3rd Place (Bronze / Amber)
          if (third != null)
            _buildPodiumColumn(
              player: third,
              rankLabel: '3rd',
              width: 95,
              height: 90,
              avatarSize: 58,
              colors: <Color>[
                const Color(0xfffb923c),
                const Color(0xffea580c),
                const Color(0xff9a3412),
              ],
              borderColor: const Color(0xfffed7aa),
              auraColor: const Color(0xfffb923c),
              hasCrown: false,
            )
          else
            const SizedBox(width: 95),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required SketchPartyPlayer player,
    required String rankLabel,
    required double width,
    required double height,
    required double avatarSize,
    required List<Color> colors,
    required Color borderColor,
    required Color auraColor,
    required bool hasCrown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Avatar with Aura and optional Crown
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: auraColor, width: hasCrown ? 3.0 : 2.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: auraColor.withValues(alpha: hasCrown ? 0.6 : 0.4),
                    blurRadius: hasCrown ? 18 : 12,
                    spreadRadius: hasCrown ? 2 : 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatar(player, avatarSize),
              ),
            ),

            if (hasCrown)
              Positioned(
                top: -14,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff091122),
                  ),
                  child: const Icon(
                    Icons.military_tech_rounded,
                    color: Color(0xfffacc15),
                    size: 22,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // 3D Pedestal
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: auraColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                rankLabel,
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: hasCrown ? 21 : 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  player.displayName,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: hasCrown ? 13 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${player.totalScore}',
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: hasCrown ? 24 : 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinalScoresCard(List<SketchPartyPlayer> sorted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xff091426),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'FINAL SCORES',
            style: GoogleFonts.outfit(
              color: const Color(0xff64748b),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          ...List<Widget>.generate(sorted.length, (int index) {
            final SketchPartyPlayer p = sorted[index];
            final bool isWinner = index == 0;

            if (isWinner) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xff121d33),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xfff8df40),
                    width: 1.4,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xfff8df40).withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      '1',
                      style: GoogleFonts.fredoka(
                        color: const Color(0xfff8df40),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildAvatar(p, 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Text(
                            p.displayName,
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.military_tech_rounded,
                            color: Color(0xfff8df40),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${p.totalScore}',
                      style: GoogleFonts.fredoka(
                        color: const Color(0xfff8df40),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xff94a3b8),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildAvatar(p, 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.displayName,
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${p.totalScore}',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int gamesPlayed, int wins, String favoriteGame) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xff091426),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'YOUR STATS',
            style: GoogleFonts.outfit(
              color: const Color(0xff64748b),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Games Played
              _buildStatItem(
                icon: Icons.sports_esports_rounded,
                label: 'Games Played',
                value: '$gamesPlayed',
              ),

              // Wins
              _buildStatItem(
                icon: Icons.emoji_events_rounded,
                label: 'Wins',
                value: '$wins',
              ),

              // Favorite Game
              _buildStatItem(
                icon: Icons.rocket_launch_rounded,
                label: 'Favorite Game',
                value: favoriteGame,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xff0e203c),
            border: Border.all(
              color: const Color(0xff08abc4).withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xff08abc4),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: GoogleFonts.outfit(
                color: const Color(0xff94a3b8),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
