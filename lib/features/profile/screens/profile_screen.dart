import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _profile;
  bool _editing = false;
  late TextEditingController _tagController;
  late TextEditingController _bioController;
  late String _selectedAvatarId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _tagController = TextEditingController(text: _profile.displayName);
    _bioController = TextEditingController(text: _profile.bio);
    _selectedAvatarId = _profile.avatarId;
  }

  @override
  void dispose() {
    _tagController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final String tag = _tagController.text.trim();
    if (tag.isEmpty) return;

    setState(() => _saving = true);

    try {
      final UserProfile updated = _profile.copyWith(
        displayName: tag,
        bio: _bioController.text.trim(),
        avatarId: _selectedAvatarId,
      );
      await ProfileService.instance.saveProfile(updated);
      setState(() {
        _profile = updated;
        _editing = false;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _handleSignOut() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff262735),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        Navigator.of(context).pop(); // Close profile screen if pushed
      }
      await AuthService.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerAvatar avatar = PlayerAvatar.getById(_selectedAvatarId);

    return Scaffold(
      backgroundColor: const Color(0xff1c1d2a),
      appBar: AppBar(
        backgroundColor: const Color(0xff1c1d2a),
        foregroundColor: Colors.white,
        title: Text(
          _editing ? 'Edit Profile' : 'Player Profile',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xffefc249)),
              tooltip: 'Edit Profile',
              onPressed: () => setState(() => _editing = true),
            )
          else
            IconButton(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xffefc249)),
                    )
                  : const Icon(Icons.check_rounded, color: Color(0xffefc249)),
              tooltip: 'Save',
              onPressed: _saving ? null : _handleSave,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            // Avatar Display
            Center(
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: <Color>[avatar.primaryColor, avatar.secondaryColor],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: avatar.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Icon(avatar.icon, size: 54, color: Colors.white),
                  ),
                  if (_editing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xffefc249),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.palette_rounded,
                            size: 16, color: Color(0xff1c1d2a)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Identity Text / Editor
            if (!_editing) ...<Widget>[
              Text(
                _profile.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _profile.isGuest
                      ? const Color(0xff3f3f50)
                      : const Color(0xff2d244c),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _profile.isGuest
                        ? Colors.white24
                        : const Color(0xffefc249),
                  ),
                ),
                child: Text(
                  _profile.isGuest
                      ? 'GUEST ACCOUNT'
                      : (_profile.email ?? 'VERIFIED PLAYER'),
                  style: TextStyle(
                    color: _profile.isGuest
                        ? Colors.white70
                        : const Color(0xffefc249),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _profile.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xffc5c3d4), fontSize: 13),
              ),
            ] else ...<Widget>[
              // Avatar selector when editing
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Change Avatar Icon',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PlayerAvatar.presets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final PlayerAvatar a = PlayerAvatar.presets[index];
                    final bool isSel = a.id == _selectedAvatarId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarId = a.id),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: <Color>[a.primaryColor, a.secondaryColor]),
                          border: Border.all(
                            color: isSel ? Colors.white : Colors.transparent,
                            width: isSel ? 2.5 : 1,
                          ),
                        ),
                        child: Icon(a.icon, color: Colors.white, size: 24),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Gamertag text input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff262735),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xff444558)),
                ),
                child: TextField(
                  controller: _tagController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Gamertag',
                    labelStyle: TextStyle(color: Color(0xffefc249)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Bio text input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff262735),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xff444558)),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    labelStyle: TextStyle(color: Color(0xffefc249)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Career Stats Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xff262735),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xff3a3c4f)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.leaderboard_rounded,
                          color: Color(0xffefc249), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'CAREER STATS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildStatTile('Matches', '${_profile.stats.gamesPlayed}'),
                      _buildStatTile('Wins', '${_profile.stats.wins}'),
                      _buildStatTile(
                        'Win Rate',
                        '${(_profile.stats.winRate * 100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xff3a3c4f), height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Favorite Game',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xff37235d),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: const Color(0xffefc249), width: 1),
                        ),
                        child: Text(
                          _profile.stats.favoriteGame.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xffefc249),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            OutlinedButton.icon(
              onPressed: _handleSignOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xfff87171),
                side: const BorderSide(color: Color(0xfff87171)),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'SIGN OUT',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xff8f8e9f), fontSize: 12),
        ),
      ],
    );
  }
}

