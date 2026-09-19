import 'package:flutter/material.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import '../models/georush_mode.dart';
import '../widgets/georush_mode_card.dart';

class GeoRushScreen extends StatefulWidget {
  const GeoRushScreen({super.key});

  @override
  State<GeoRushScreen> createState() => _GeoRushScreenState();
}

class _GeoRushScreenState extends State<GeoRushScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _activeNavIndex = 0;
  String _displayName = 'Explorer';
  String _avatarId = 'avatar_astro';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final String? uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      final UserProfile? profile = ProfileService.instance.getProfileSync(uid);
      if (profile != null) {
        setState(() {
          _displayName = profile.displayName.isNotEmpty ? profile.displayName : 'Explorer';
          _avatarId = profile.avatarId;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectMode(GeoRushGameMode mode) {
    switch (mode) {
      case GeoRushGameMode.singlePlayer:
        _showSoloModeSheet();
        break;
      case GeoRushGameMode.multiplayer:
        _showMultiplayerMatchmakingSheet();
        break;
      case GeoRushGameMode.offline:
        _showOfflineMapsDialog();
        break;
    }
  }

  void _showSoloModeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff122030),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffe8bd42).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore_rounded, color: Color(0xffe8bd42), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Solo Expedition',
                        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Select region to begin your challenge',
                        style: TextStyle(color: Colors.white60, fontSize: 12.5),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRegionTile(ctx, 'World Landmarks', 'Eiffel Tower, Taj Mahal, Pyramids...', Icons.public_rounded, const Color(0xff38bdf8)),
              _buildRegionTile(ctx, 'Country Capitals', 'Test your speed identifying global capitals', Icons.location_city_rounded, const Color(0xff34d399)),
              _buildRegionTile(ctx, 'Hidden Wonders', 'Secret islands, deep canyons, remote places', Icons.terrain_rounded, const Color(0xfff59e0b)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegionTile(BuildContext ctx, String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xff182c40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
        onTap: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xff0e273c),
              content: Text('Starting Solo Expedition: $title! Loading world map...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showMultiplayerMatchmakingSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff122030),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: Color(0xff38bdf8),
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Searching for Explorers...',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Finding 3 opponents near your skill rank',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel Matchmaking', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOfflineMapsDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xff122030),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: <Widget>[
              Icon(Icons.download_for_offline_rounded, color: Color(0xff34d399)),
              SizedBox(width: 10),
              Text('Offline Maps', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Global Starter Pack (32 MB) is ready for offline play.',
                style: TextStyle(color: Colors.white70, fontSize: 13.5),
              ),
              SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(Icons.check_circle_rounded, color: Color(0xff34d399), size: 18),
                  SizedBox(width: 8),
                  Text('High-definition vector terrain', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Icon(Icons.check_circle_rounded, color: Color(0xff34d399), size: 18),
                  SizedBox(width: 8),
                  Text('1,200 curated global locations', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff059669),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xff059669),
                    content: Text('Starting Offline Mode... Have fun!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Play Offline'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlayerAvatar avatar = PlayerAvatar.getById(_avatarId);

    return Scaffold(
      backgroundColor: const Color(0xff0c1926),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xff0d2136),
              Color(0xff0c1825),
              Color(0xff08101a),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Top Bar (Avatar, Search Input, Mail Icon)
              _buildTopBar(avatar),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 8),

                      // GEORUSH Brand Title
                      const Text(
                        'GEORUSH',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Explorers Online Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff22c55e),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: const Color(0xff22c55e).withValues(alpha: 0.8),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            '800 Explorers Online',
                            style: TextStyle(
                              color: Color(0xffcbd5e1),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Mode Decision Cards
                      ...GeoRushModeData.modes.map((GeoRushModeData data) {
                        return GeoRushModeCard(
                          data: data,
                          onAction: () => _onSelectMode(data.mode),
                        );
                      }),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Bar
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(PlayerAvatar avatar) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: <Widget>[
          // Exit button back to PlayPal lobby
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
            tooltip: 'Return to PlayPal Lobby',
            onPressed: () => Navigator.of(context).pop(),
          ),

          // User Profile Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[avatar.primaryColor, avatar.secondaryColor],
              ),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Icon(avatar.icon, color: Colors.white, size: 20),
          ),

          const SizedBox(width: 10),

          // Search Field: "Find a game or friend..."
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xff16283d).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xff233f5d), width: 1.1),
              ),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 12),
                  const Icon(Icons.search_rounded, color: Color(0xff7a92ac), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: const InputDecoration(
                        hintText: 'Find a game or friend...',
                        hintStyle: TextStyle(color: Color(0xff7a92ac), fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
                      onPressed: () => setState(() => _searchController.clear()),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Mail / Messages Button
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xff122030),
                  content: Text('Inbox: No new game invitations.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xff16283d).withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xff233f5d), width: 1.1),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: Color(0xffcbd5e1),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff091420),
        border: Border(top: BorderSide(color: Color(0xff172c42), width: 1.2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.explore_outlined, 'Discover'),
          _buildNavItem(2, Icons.people_outline_rounded, 'Friends'),
          _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _activeNavIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() => _activeNavIndex = index);
        if (index == 3) {
          // Open profile or trigger message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xff122030),
              content: Text('Logged in as $_displayName ($_avatarId)'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color(0xff1e3a59),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xff38bdf8).withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                size: 23,
                color: isSelected ? const Color(0xff38bdf8) : const Color(0xff64748b),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xff64748b),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

