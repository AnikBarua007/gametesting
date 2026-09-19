import 'package:flutter/material.dart';
import 'sketch_party_lobby_screen.dart';
import 'sketch_party_screen.dart';

class SketchPartyMenuScreen extends StatefulWidget {
  const SketchPartyMenuScreen({super.key});

  @override
  State<SketchPartyMenuScreen> createState() => _SketchPartyMenuScreenState();
}

class _SketchPartyMenuScreenState extends State<SketchPartyMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090e1c),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Ambient background gradient glow
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.3),
                    radius: 1.2,
                    colors: <Color>[
                      Color(0xff132142),
                      Color(0xff0b1226),
                      Color(0xff070b17),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Column(
              children: <Widget>[
                // Top Action Bar (Back button + PlayPal online pill)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Back Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Top Right PlayPal 12 Online Badge
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showOnlinePlayersSheet(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xff121d33).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xff08abc4).withValues(alpha: 0.4),
                                width: 1,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.people_alt_rounded,
                                  size: 16,
                                  color: Color(0xff22c55e),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const <Widget>[
                                    Text(
                                      'PlayPal',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '12 online',
                                      style: TextStyle(
                                        color: Color(0xff22c55e),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Menu Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                    child: Column(
                      children: <Widget>[
                        // Hero Illustration
                        _buildHeroHeader(),

                        const SizedBox(height: 14),

                        // Active Friends Avatars Row
                        _buildFriendsRow(context),

                        const SizedBox(height: 18),

                        // 1. QUICK PLAY
                        _buildMenuPill(
                          title: 'Quick Play',
                          subtitle: 'Jump in and play now',
                          icon: Icons.bolt_rounded,
                          gradientColors: const <Color>[
                            Color(0xfff8df40),
                            Color(0xfff1bf1c),
                          ],
                          glowColor: const Color(0xfff4c925),
                          textColor: const Color(0xff131728),
                          iconBgColor: const Color(0xffdfa80a),
                          iconColor: const Color(0xff131728),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SketchPartyScreen(autoStart: true),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // 2. CREATE ROOM
                        _buildMenuPill(
                          title: 'Create Room',
                          subtitle: 'Invite friends and play together',
                          icon: Icons.groups_rounded,
                          gradientColors: const <Color>[
                            Color(0xff2d7eed),
                            Color(0xff1a5ec4),
                          ],
                          glowColor: const Color(0xff2677dd),
                          textColor: Colors.white,
                          iconBgColor: const Color(0xff104494),
                          iconColor: Colors.white,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SketchPartyLobbyScreen(isHost: true),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // 3. JOIN ROOM
                        _buildMenuPill(
                          title: 'Join Room',
                          subtitle: 'Enter a room code',
                          icon: Icons.link_rounded,
                          gradientColors: const <Color>[
                            Color(0xff09b8d2),
                            Color(0xff058ea3),
                          ],
                          glowColor: const Color(0xff08abc4),
                          textColor: Colors.white,
                          iconBgColor: const Color(0xff046170),
                          iconColor: Colors.white,
                          onTap: () => _showJoinRoomModal(context),
                        ),

                        const SizedBox(height: 14),

                        // 4. SOLO VS BOTS (Navigates to Lobby Screen)
                        _buildMenuPill(
                          title: 'Solo vs Bots',
                          subtitle: 'Sharpen your skills',
                          icon: Icons.smart_toy_rounded,
                          gradientColors: const <Color>[
                            Color(0xffee5858),
                            Color(0xffd73434),
                          ],
                          glowColor: const Color(0xffee5858),
                          textColor: Colors.white,
                          iconBgColor: const Color(0xff9e1e1e),
                          iconColor: Colors.white,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SketchPartyLobbyScreen(
                                  isSoloVsBot: true,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Bottom "How to Play" section (as requested: "just keep how to play from the bottom here")
                        _buildHowToPlayBottomAction(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/games/sketch_party_hero.jpg',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              SizedBox(height: 10),
              Icon(Icons.gesture_rounded, color: Color(0xff08abc4), size: 55),
              SizedBox(height: 6),
              Text(
                'SKETCH PARTY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Draw, guess, and race the clock.',
                style: TextStyle(
                  color: Color(0xfff4d935),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsRow(BuildContext context) {
    final List<({String emoji, Color bg, String name})> avatars = <({String emoji, Color bg, String name})>[
      (emoji: '🐶', bg: const Color(0xffd97706), name: 'Scout'),
      (emoji: '🎧', bg: const Color(0xff3b82f6), name: 'Maya'),
      (emoji: '👓', bg: const Color(0xff8b5cf6), name: 'Leo'),
      (emoji: '🐱', bg: const Color(0xff10b981), name: 'Shadow'),
      (emoji: '🌸', bg: const Color(0xffec4899), name: 'Chloe'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xff121b30).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Avatars with green online dot
          ...avatars.map((av) {
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: av.bg.withValues(alpha: 0.3),
                  child: Text(av.emoji, style: const TextStyle(fontSize: 18)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xff10b981),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xff121b30), width: 1.5),
                    ),
                  ),
                ),
              ],
            );
          }),

          // Plus Button (Add Friends)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showInviteFriendsModal(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white70, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPill({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color glowColor,
    required Color textColor,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: glowColor.withValues(alpha: 0.38),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              children: <Widget>[
                // Leading Circular Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),

                const SizedBox(width: 14),

                // Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: textColor.withValues(alpha: 0.75),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHowToPlayBottomAction(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Subtle divider line
        Row(
          children: <Widget>[
            const Expanded(child: Divider(color: Colors.white12, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xff08abc4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white12, thickness: 1)),
          ],
        ),

        const SizedBox(height: 12),

        // Centered How to Play Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showHowToPlaySheet(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xff08abc4).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  Icon(
                    Icons.menu_book_rounded,
                    size: 20,
                    color: Color(0xff08abc4),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'How to Play',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showHowToPlaySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff121829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Pill notch
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.menu_book_rounded, color: Color(0xff08abc4), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'HOW TO PLAY SKETCH PARTY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _ruleItem(
                icon: Icons.draw_rounded,
                color: const Color(0xff08abc4),
                title: 'Draw Clearly',
                desc: 'When it is your turn, pick 1 of 3 words (Easy, Medium, or Hard) and sketch it on the live canvas.',
              ),
              const SizedBox(height: 12),
              _ruleItem(
                icon: Icons.chat_bubble_rounded,
                color: const Color(0xfff4d935),
                title: 'Guess in Real Time',
                desc: 'Type your guesses in the chat stream. The faster you guess, the more points you earn!',
              ),
              const SizedBox(height: 12),
              _ruleItem(
                icon: Icons.lightbulb_rounded,
                color: const Color(0xff22c55e),
                title: 'Dynamic Letter Hints',
                desc: 'Letters automatically unlock as the 60s timer ticks down to help everyone out.',
              ),
              const SizedBox(height: 12),
              _ruleItem(
                icon: Icons.emoji_events_rounded,
                color: const Color(0xffee5858),
                title: 'Drawer Sweep Rewards',
                desc: 'Drawers earn bonus points for every player who solves their drawing. No scribbles allowed!',
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff08abc4),
                    foregroundColor: const Color(0xff091124),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('GOT IT!', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ruleItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }


  void _showJoinRoomModal(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xff161e36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Join Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Enter the room code shared by your friend:', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 14),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'e.g. PARTY-4821',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xff0e1424),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff08abc4)),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff08abc4),
              foregroundColor: const Color(0xff091124),
            ),
            onPressed: () {
              final String code = codeController.text.trim().toUpperCase();
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SketchPartyLobbyScreen(
                    initialRoomCode: code.isNotEmpty ? code : null,
                    isHost: false,
                  ),
                ),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showInviteFriendsModal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Party invite link copied to clipboard!'),
        backgroundColor: Color(0xff08abc4),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showOnlinePlayersSheet(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🟢 12 PlayPal players online and ready to sketch!'),
        backgroundColor: Color(0xff10b981),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
