import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final AuthUser user;

  const ProfileSetupScreen({super.key, required this.user});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _gamertagController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _selectedAvatarId = PlayerAvatar.presets.first.id;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Default gamertag suggestions
    if (widget.user.isGuest) {
      _gamertagController.text = 'Player_${widget.user.uid.split('_').last}';
    } else if (widget.user.email != null) {
      final String prefix = widget.user.email!.split('@').first;
      _gamertagController.text =
          prefix.substring(0, prefix.length > 12 ? 12 : prefix.length);
    }
  }

  @override
  void dispose() {
    _gamertagController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final String tag = _gamertagController.text.trim();
    if (tag.isEmpty) {
      setState(() => _error = 'Please enter a Gamertag.');
      return;
    }
    if (tag.length < 3) {
      setState(() => _error = 'Gamertag must be at least 3 characters.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final UserProfile profile = UserProfile(
        uid: widget.user.uid,
        displayName: tag,
        email: widget.user.email,
        isGuest: widget.user.isGuest,
        avatarId: _selectedAvatarId,
        bio: _bioController.text.trim().isEmpty
            ? 'Ready to challenge anyone!'
            : _bioController.text.trim(),
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        stats: const PlayerStats(),
      );

      await ProfileService.instance.saveProfile(profile);
    } catch (e) {
      debugPrint('[ProfileSetupScreen] Save profile error: $e');
      if (mounted) {
        setState(() => _error = 'Failed to save profile: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerAvatar currentAvatar = PlayerAvatar.getById(_selectedAvatarId);

    return Scaffold(
      backgroundColor: const Color(0xff1c1d2a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'CREATE YOUR IDENTITY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Choose an avatar and gamertag seen by other players.',
                  style: TextStyle(color: Color(0xffa5a3b8), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),

              // Active Avatar Preview Card
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[
                        currentAvatar.primaryColor,
                        currentAvatar.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: currentAvatar.primaryColor.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 3,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    currentAvatar.icon,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  currentAvatar.name,
                  style: TextStyle(
                    color: currentAvatar.secondaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar Presets Picker
              const Text(
                'Select Avatar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PlayerAvatar.presets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final PlayerAvatar avatar = PlayerAvatar.presets[index];
                    final bool isSelected = avatar.id == _selectedAvatarId;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarId = avatar.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: <Color>[
                              avatar.primaryColor,
                              avatar.secondaryColor,
                            ],
                          ),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Icon(avatar.icon, color: Colors.white, size: 30),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 26),

              // Error Text
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xfff87171), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Gamertag Field
              const Text(
                'Gamertag',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff262735),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xff444558)),
                ),
                child: TextField(
                  controller: _gamertagController,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined,
                        color: Color(0xffefc249), size: 20),
                    hintText: 'e.g. PixelHero',
                    hintStyle: TextStyle(color: Color(0xff717082)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Bio Field
              const Text(
                'Player Bio (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff262735),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xff444558)),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Say something to friends and rivals...',
                    hintStyle: TextStyle(color: Color(0xff717082)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffefc249),
                  foregroundColor: const Color(0xff1c1d2a),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xff1c1d2a),
                        ),
                      )
                    : const Text(
                        'ENTER ARENA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

