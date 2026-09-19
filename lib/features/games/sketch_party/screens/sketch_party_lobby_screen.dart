import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import 'sketch_party_screen.dart';

class SketchPartyLobbyScreen extends StatefulWidget {
  final String? initialRoomCode;
  final bool isHost;
  final bool isSoloVsBot;

  const SketchPartyLobbyScreen({
    super.key,
    this.initialRoomCode,
    this.isHost = true,
    this.isSoloVsBot = false,
  });

  @override
  State<SketchPartyLobbyScreen> createState() => _SketchPartyLobbyScreenState();
}

class _LobbyParticipant {
  final String id;
  final String name;
  final PlayerAvatar avatar;
  final bool isHost;
  final bool isBot;
  final bool isReady;

  const _LobbyParticipant({
    required this.id,
    required this.name,
    required this.avatar,
    this.isHost = false,
    this.isBot = false,
    this.isReady = true,
  });
}

class _LobbyChatMessage {
  final String sender;
  final String text;
  final String time;
  final PlayerAvatar? avatar;
  final bool isMe;
  final bool isBot;

  const _LobbyChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.avatar,
    this.isMe = false,
    this.isBot = false,
  });
}

class _SketchPartyLobbyScreenState extends State<SketchPartyLobbyScreen> {
  static const List<({String name, PlayerAvatar avatar})> _botPool = <({String name, PlayerAvatar avatar})>[
    (
      name: 'Bot Sparky',
      avatar: PlayerAvatar(
        id: 'avatar_cyber',
        name: 'Sparky',
        icon: Icons.smart_toy_rounded,
        primaryColor: Color(0xff06b6d4),
        secondaryColor: Color(0xff3b82f6),
      ),
    ),
    (
      name: 'Bot Luna',
      avatar: PlayerAvatar(
        id: 'avatar_ninja',
        name: 'Luna',
        icon: Icons.visibility_off_rounded,
        primaryColor: Color(0xff6366f1),
        secondaryColor: Color(0xffa855f7),
      ),
    ),
    (
      name: 'Bot Blaze',
      avatar: PlayerAvatar(
        id: 'avatar_phoenix',
        name: 'Blaze',
        icon: Icons.local_fire_department_rounded,
        primaryColor: Color(0xffef4444),
        secondaryColor: Color(0xfff59e0b),
      ),
    ),
    (
      name: 'Bot Astro',
      avatar: PlayerAvatar(
        id: 'avatar_astro',
        name: 'Astro',
        icon: Icons.rocket_launch_rounded,
        primaryColor: Color(0xff10b981),
        secondaryColor: Color(0xff14b8a6),
      ),
    ),
    (
      name: 'Bot Rex',
      avatar: PlayerAvatar(
        id: 'avatar_crown',
        name: 'Rex',
        icon: Icons.military_tech_rounded,
        primaryColor: Color(0xffeab308),
        secondaryColor: Color(0xfff97316),
      ),
    ),
    (
      name: 'Bot Pixel',
      avatar: PlayerAvatar(
        id: 'avatar_ghost',
        name: 'Pixel',
        icon: Icons.cruelty_free_rounded,
        primaryColor: Color(0xffec4899),
        secondaryColor: Color(0xff8b5cf6),
      ),
    ),
    (
      name: 'Bot Nova',
      avatar: PlayerAvatar(
        id: 'avatar_nova',
        name: 'Nova',
        icon: Icons.auto_awesome_rounded,
        primaryColor: Color(0xff8b5cf6),
        secondaryColor: Color(0xffec4899),
      ),
    ),
  ];

  late final String _roomCode;
  int _rounds = 3;
  int _turnTimer = 60;
  String _difficulty = 'Mix';
  bool _autoFillBots = true;

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  late final PlayerAvatar _myAvatar;
  late final String _myName;

  final List<_LobbyParticipant> _participants = <_LobbyParticipant>[];
  late final List<_LobbyChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _roomCode = widget.initialRoomCode ??
        (widget.isSoloVsBot
            ? 'BOT-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}'
            : 'PARTY-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}');

    // 1. Resolve local user identity & profile avatar from app's user profile system
    final AuthUser? user = AuthService.instance.currentUser;
    final UserProfile? profile = ProfileService.instance.getProfileSync(user?.uid ?? '');
    _myAvatar = profile?.avatar ?? PlayerAvatar.getById('avatar_cyber');
    _myName = (profile?.displayName.isNotEmpty == true) ? profile!.displayName : 'You';

    // 2. Set up dynamic participants: Host (You)
    _participants.add(_LobbyParticipant(
      id: 'player_host',
      name: _myName,
      avatar: _myAvatar,
      isHost: true,
      isBot: false,
      isReady: true,
    ));

    // Exactly 1 bot joins initially
    if (_autoFillBots) {
      final ({String name, PlayerAvatar avatar}) firstBot = _botPool.first;
      _participants.add(_LobbyParticipant(
        id: 'bot_1',
        name: firstBot.name,
        avatar: firstBot.avatar,
        isHost: false,
        isBot: true,
        isReady: true,
      ));
    }

    // 3. Pre-populated chat with bot banter
    _messages = <_LobbyChatMessage>[
      _LobbyChatMessage(
        sender: _botPool.first.name,
        text: 'Ready to sketch! Let\'s do this 🎨',
        time: 'Just now',
        avatar: _botPool.first.avatar,
        isBot: true,
      ),
    ];
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _incrementPlayers() {
    if (_participants.length >= 8) return;
    setState(() {
      final int botCount = _participants.where((p) => p.isBot).length;
      final ({String name, PlayerAvatar avatar}) bot = _botPool[botCount % _botPool.length];
      _participants.add(_LobbyParticipant(
        id: 'bot_${_participants.length}',
        name: bot.name,
        avatar: bot.avatar,
        isHost: false,
        isBot: true,
        isReady: true,
      ));
      _autoFillBots = true;
      _messages.add(_LobbyChatMessage(
        sender: bot.name,
        text: 'Joined the lobby! 🎨',
        time: 'Just now',
        avatar: bot.avatar,
        isBot: true,
      ));
    });
  }

  void _decrementPlayers() {
    if (_participants.length <= 2) return;
    setState(() {
      final int lastBotIndex = _participants.lastIndexWhere((p) => p.isBot);
      if (lastBotIndex != -1) {
        _participants.removeAt(lastBotIndex);
      } else {
        _participants.removeLast();
      }
    });
  }

  void _toggleBots(bool val) {
    setState(() {
      _autoFillBots = val;
      if (val) {
        if (!_participants.any((p) => p.isBot)) {
          final ({String name, PlayerAvatar avatar}) bot = _botPool.first;
          _participants.add(_LobbyParticipant(
            id: 'bot_1',
            name: bot.name,
            avatar: bot.avatar,
            isHost: false,
            isBot: true,
            isReady: true,
          ));
          _messages.add(_LobbyChatMessage(
            sender: bot.name,
            text: 'I\'m back and ready to draw! 🤖',
            time: 'Just now',
            avatar: bot.avatar,
            isBot: true,
          ));
        }
      } else {
        _participants.removeWhere((p) => p.isBot);
      }
    });
  }

  void _sendMessage() {
    final String text = _chatController.text.trim();
    if (text.isEmpty) return;

    final DateTime now = DateTime.now();
    final String hour = now.hour > 12 ? '${now.hour - 12}' : '${now.hour == 0 ? 12 : now.hour}';
    final String minute = now.minute.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? 'PM' : 'AM';

    setState(() {
      _messages.add(_LobbyChatMessage(
        sender: _myName,
        text: text,
        time: '$hour:$minute $period',
        avatar: _myAvatar,
        isMe: true,
      ));
      _chatController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: _roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📋 Room code "$_roomCode" copied to clipboard!',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xff08abc4),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareRoomCode() {
    Clipboard.setData(ClipboardData(
      text: 'Join my Sketch Party game! Room Code: $_roomCode',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔗 Invite link copied to clipboard! Share it with friends.',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xff22c55e),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090e1c),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top App Bar
            _buildTopBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Column(
                  children: <Widget>[
                    // 1. Room Code Banner
                    _buildRoomCodeCard(),

                    const SizedBox(height: 14),

                    // 2. Middle Card: Dynamic Players Roster with player count selector button
                    _buildPlayersCard(),

                    const SizedBox(height: 14),

                    // 3. Game Settings Card (Formatted properly with horizontally centered text & quantities)
                    _buildSettingsCard(),

                    const SizedBox(height: 14),

                    // 4. Room Chat Card
                    _buildRoomChatCard(),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Actions
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Back Circle Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xff121d33),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xff08abc4).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Transparent Centered Logo (Blends seamlessly into background)
          Image.asset(
            'assets/images/games/sketch_party_logo.png',
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(
              'SKETCH PARTY',
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Invisible balance spacing
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildRoomCodeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.4),
          width: 1.4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xff08abc4).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            'ROOM CODE',
            style: GoogleFonts.fredoka(
              color: const Color(0xff75a3dc),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: <Widget>[
              // Big Neon Room Code Pill
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xff12244a),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xff08abc4),
                      width: 1.6,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xff08abc4).withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _roomCode,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Copy & Share Action Buttons
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    _roomActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onTap: _copyRoomCode,
                    ),
                    const SizedBox(height: 6),
                    _roomActionButton(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: _shareRoomCode,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.isSoloVsBot
                ? 'Solo Practice Room with AI Bot'
                : 'Share this code with your friends to join',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _roomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xff16284d),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xff08abc4).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 14, color: const Color(0xff08abc4)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Middle Card: Dynamic participants roster with player count selector button replacing "Room is open"
  Widget _buildPlayersCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: PLAYERS (X/8) & Interactive Player Count Stepper Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'PLAYERS (${_participants.length}/8)',
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              // Player Count Stepper Button (replaces static "Room is open" text)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff142240),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xff08abc4).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Decrease Player Count Button (-)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _participants.length > 2 ? _decrementPlayers : null,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          child: Icon(
                            Icons.remove_rounded,
                            size: 15,
                            color: _participants.length > 2
                                ? const Color(0xff08abc4)
                                : Colors.white24,
                          ),
                        ),
                      ),
                    ),

                    // Current Player Count Pill Text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      child: Text(
                        '${_participants.length} Players',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Increase Player Count Button (+)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _participants.length < 8 ? _incrementPlayers : null,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          child: Icon(
                            Icons.add_rounded,
                            size: 15,
                            color: _participants.length < 8
                                ? const Color(0xff08abc4)
                                : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8-Slot Grid (2 rows of 4 slots)
          Column(
            children: <Widget>[
              // Row 1: Slots 0 to 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List<Widget>.generate(4, (int index) {
                  if (index < _participants.length) {
                    return _buildParticipantTile(_participants[index]);
                  } else {
                    return _buildEmptySlotTile(index);
                  }
                }),
              ),

              const SizedBox(height: 12),

              // Row 2: Slots 4 to 7
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List<Widget>.generate(4, (int col) {
                  final int index = col + 4;
                  if (index < _participants.length) {
                    return _buildParticipantTile(_participants[index]);
                  } else {
                    return _buildEmptySlotTile(index);
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(_LobbyParticipant p) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Avatar circle with jewel profile icon and glowing status ring
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.25, -0.35),
                  radius: 0.9,
                  colors: <Color>[
                    p.avatar.secondaryColor.withValues(alpha: 0.95),
                    p.avatar.primaryColor,
                  ],
                ),
                border: Border.all(
                  color: p.isHost ? const Color(0xfff4d935) : p.avatar.primaryColor,
                  width: 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (p.isHost ? const Color(0xfff4d935) : p.avatar.primaryColor)
                        .withValues(alpha: 0.45),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  p.avatar.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            // Badge (Host or Bot)
            if (p.isHost)
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xfff4d935),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '👑 Host',
                    style: GoogleFonts.fredoka(
                      color: const Color(0xff121626),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            else if (p.isBot)
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xff06b6d4),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '🤖 Bot',
                    style: GoogleFonts.fredoka(
                      color: const Color(0xff121626),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 7),

        // Name
        SizedBox(
          width: 65,
          child: Text(
            p.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 3),

        // Ready status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xff22c55e).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xff22c55e).withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: Text(
            '● Ready',
            style: GoogleFonts.outfit(
              color: const Color(0xff22c55e),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlotTile(int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _incrementPlayers,
        borderRadius: BorderRadius.circular(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff10172b),
                border: Border.all(
                  color: const Color(0xff08abc4).withValues(alpha: 0.35),
                  width: 1.4,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: Color(0xff08abc4),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: 65,
              child: Text(
                'Add Bot',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Open',
              style: GoogleFonts.outfit(
                color: Colors.white24,
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Game Settings Card: Formatted with clean 3-chip top row and dedicated AI Bot full-width toggle row
  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'GAME SETTINGS',
            style: GoogleFonts.fredoka(
              color: const Color(0xff75a3dc),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          // Top Row: 3 Setting Chips (Rounds, Timer, Difficulty) - Horizontally Centered
          Row(
            children: <Widget>[
              // Rounds
              Expanded(
                child: _settingTile(
                  icon: Icons.layers_rounded,
                  label: 'Rounds',
                  value: '$_rounds',
                  onTap: () {
                    setState(() {
                      if (_rounds == 2) {
                        _rounds = 3;
                      } else if (_rounds == 3) {
                        _rounds = 5;
                      } else {
                        _rounds = 2;
                      }
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Turn Timer
              Expanded(
                child: _settingTile(
                  icon: Icons.timer_outlined,
                  label: 'Draw Time',
                  value: '${_turnTimer}s',
                  onTap: () {
                    setState(() {
                      if (_turnTimer == 45) {
                        _turnTimer = 60;
                      } else if (_turnTimer == 60) {
                        _turnTimer = 80;
                      } else {
                        _turnTimer = 45;
                      }
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Difficulty
              Expanded(
                child: _settingTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'Difficulty',
                  value: _difficulty,
                  onTap: () {
                    setState(() {
                      if (_difficulty == 'Mix') {
                        _difficulty = 'Easy';
                      } else if (_difficulty == 'Easy') {
                        _difficulty = 'Hard';
                      } else {
                        _difficulty = 'Mix';
                      }
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Dedicated AI Bot Setting Row (Proper layout, no override / overflow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xff12203d),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _autoFillBots
                    ? const Color(0xff08abc4).withValues(alpha: 0.4)
                    : Colors.white12,
                width: 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                // Robot Icon Pill
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xff08abc4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    size: 18,
                    color: Color(0xff08abc4),
                  ),
                ),
                const SizedBox(width: 10),

                // Label & Status Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Auto-fill AI Bot',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _autoFillBots
                            ? '${_participants.where((p) => p.isBot).length} Bot(s) in room ready to sketch'
                            : 'Bots disabled (Play with friends)',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Clean Toggle Switch with proper spacing
                Switch(
                  value: _autoFillBots,
                  activeThumbColor: const Color(0xff08abc4),
                  activeTrackColor: const Color(0xff08abc4).withValues(alpha: 0.35),
                  inactiveThumbColor: Colors.white38,
                  inactiveTrackColor: Colors.white12,
                  onChanged: _toggleBots,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Setting Tile: Horizontally Centered Content and Quantity
  Widget _settingTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xff12203d),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Horizontally Centered Icon & Label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 13, color: const Color(0xff08abc4)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Horizontally Centered Quantity Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xff1a2d54),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xff08abc4).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomChatCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: ROOM CHAT & count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'ROOM CHAT',
                style: GoogleFonts.fredoka(
                  color: const Color(0xff75a3dc),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xff1a2d54),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_messages.length} messages',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Scrollable Chat Messages
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff090f20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: ListView.separated(
              controller: _chatScrollController,
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (BuildContext ctx, int index) {
                final _LobbyChatMessage msg = _messages[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Sender avatar icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.25, -0.35),
                          radius: 0.9,
                          colors: <Color>[
                            (msg.avatar?.secondaryColor ?? const Color(0xff3b82f6))
                                .withValues(alpha: 0.9),
                            msg.avatar?.primaryColor ?? const Color(0xff06b6d4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          msg.avatar?.icon ??
                              (msg.isBot
                                  ? Icons.smart_toy_rounded
                                  : Icons.person_rounded),
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sender & message bubble
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                msg.sender,
                                style: GoogleFonts.fredoka(
                                  color: msg.isMe
                                      ? const Color(0xfff8df40)
                                      : (msg.isBot
                                          ? const Color(0xff06b6d4)
                                          : Colors.white),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                msg.time,
                                style: GoogleFonts.outfit(
                                  color: Colors.white38,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            msg.text,
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 12,
                              height: 1.25,
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

          const SizedBox(height: 10),

          // Message Input Field & Send Button
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xff121d38),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: const Color(0xff08abc4).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 15,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: GoogleFonts.outfit(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(19),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xff08abc4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Color(0xff0b1328),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xff0a1122),
        border: const Border(top: BorderSide(color: Colors.white10, width: 1)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Big Start Match Button (Yellow Pill)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xfff8df40).withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SketchPartyScreen(
                          autoStart: true,
                          totalPlayers: _participants.length,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[Color(0xfff8df40), Color(0xfff1bf1c)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xfffff066), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xff121626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xfff8df40),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Start Match',
                          style: GoogleFonts.fredoka(
                            color: const Color(0xff121626),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xff121626),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Invite Friends Button (Blue Pill)
          Expanded(
            flex: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _shareRoomCode,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xff2d7eed), Color(0xff1a5ec4)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xff579dff).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.groups_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Invite',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
