import 'package:flutter/material.dart';
import '../models/half_and_half_state.dart';

class HalfLobbyDialog extends StatefulWidget {
  final Function({required HalfAndHalfRole role, required bool isSoloWithBot, String? roomCode}) onStartMatch;

  const HalfLobbyDialog({super.key, required this.onStartMatch});

  @override
  State<HalfLobbyDialog> createState() => _HalfLobbyDialogState();
}

class _HalfLobbyDialogState extends State<HalfLobbyDialog> {
  HalfAndHalfRole _selectedRole = HalfAndHalfRole.topHalf;
  final TextEditingController _codeController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _triggerQuickMatch() {
    setState(() => _isSearching = true);
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onStartMatch(
          role: _selectedRole,
          isSoloWithBot: false,
          roomCode: 'ONLINE-101',
        );
      }
    });
  }

  void _triggerSoloBot() {
    Navigator.pop(context);
    widget.onStartMatch(
      role: _selectedRole,
      isSoloWithBot: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff18122d),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xff553c98), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff7c3aed).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.handshake_rounded, color: Color(0xffc4b5fd), size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'HALF & HALF',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
                    Text(
                      '1.1k Collaborating right now',
                      style: TextStyle(color: Color(0xff34d399), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Role Selector: Top Half vs Bottom Half
            const Text(
              'CHOOSE YOUR HALF:',
              style: TextStyle(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildRoleButton(
                    role: HalfAndHalfRole.topHalf,
                    label: 'Top Half (A)',
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRoleButton(
                    role: HalfAndHalfRole.bottomHalf,
                    label: 'Bottom Half (B)',
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Searching indicator or Options
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(color: Color(0xffa78bfa)),
                    SizedBox(height: 14),
                    Text(
                      'Searching for online partner...',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else ...<Widget>[
              // Quick Match Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7c3aed),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
                icon: const Icon(Icons.flash_on_rounded),
                label: const Text('Quick Match (1 vs 1 Online)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                onPressed: _triggerQuickMatch,
              ),

              const SizedBox(height: 10),

              // Practice Solo with Bot
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xffc4b5fd),
                  side: const BorderSide(color: Color(0xff6d28d9)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.smart_toy_rounded),
                label: const Text('Practice Solo (with Bot Partner)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                onPressed: _triggerSoloBot,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required HalfAndHalfRole role,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff5b21b6) : const Color(0xff22143d),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xffa78bfa) : const Color(0xff4c337a),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white60),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

