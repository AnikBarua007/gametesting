import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/half_and_half_state.dart';
import 'half_and_half_theme.dart';

class HalfLobbyDialog extends StatefulWidget {
  final Function({required HalfAndHalfRole role, required bool isSoloWithBot, String? roomCode}) onStartMatch;

  const HalfLobbyDialog({super.key, required this.onStartMatch});

  @override
  State<HalfLobbyDialog> createState() => _HalfLobbyDialogState();
}

class _HalfLobbyDialogState extends State<HalfLobbyDialog> {
  HalfAndHalfRole _selectedRole = HalfAndHalfRole.topHalf;
  final TextEditingController _codeController = TextEditingController();
  late String _myRoomCode;
  bool _isSearching = false;
  String _searchingMessage = 'Searching for online partner...';

  @override
  void initState() {
    super.initState();
    _generateMyCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Generates a unique 6-digit numeric room code for this member
  void _generateMyCode() {
    final int codeNum = 100000 + math.Random().nextInt(900000);
    setState(() {
      _myRoomCode = '$codeNum';
    });
  }

  void _triggerQuickMatch() {
    setState(() {
      _isSearching = true;
      _searchingMessage = 'Searching for online partner...';
    });
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onStartMatch(
          role: _selectedRole,
          isSoloWithBot: false,
          roomCode: '${100000 + math.Random().nextInt(900000)}',
        );
      }
    });
  }

  void _triggerSoloBot() {
    Navigator.pop(context);
    widget.onStartMatch(
      role: _selectedRole,
      isSoloWithBot: true,
      roomCode: '${100000 + math.Random().nextInt(900000)}',
    );
  }

  void _triggerPlayWithFriend() {
    final String friendCode = _codeController.text.trim();
    final String activeRoom = friendCode.isNotEmpty ? friendCode : _myRoomCode;

    setState(() {
      _isSearching = true;
      if (friendCode.isNotEmpty) {
        _searchingMessage = 'Joining Friend\'s Room $activeRoom...\nConnecting to partner!';
      } else {
        _searchingMessage = 'Hosting Room $activeRoom...\nShare this code with your friend to connect!';
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onStartMatch(
          role: _selectedRole,
          isSoloWithBot: false,
          roomCode: activeRoom,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEnteredFriendCode = _codeController.text.trim().isNotEmpty;

    return Dialog(
      backgroundColor: const Color(0xff18122d),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xff553c98), width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'HALF & HALF',
                        style: HalfAndHalfTheme.title(
                          fontSize: 18,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '1.1k Collaborating right now',
                        style: HalfAndHalfTheme.body(
                          color: HalfAndHalfTheme.accentGreen,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Role Selector: Top Half vs Bottom Half
              Text(
                'CHOOSE YOUR HALF:',
                style: HalfAndHalfTheme.badge(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
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

              const SizedBox(height: 18),

              // Searching indicator or Options
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: <Widget>[
                      const CircularProgressIndicator(color: HalfAndHalfTheme.purpleAccent),
                      const SizedBox(height: 16),
                      Text(
                        _searchingMessage,
                        textAlign: TextAlign.center,
                        style: HalfAndHalfTheme.body(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xff22143d),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: HalfAndHalfTheme.purpleBorderLight),
                        ),
                        child: Text(
                          hasEnteredFriendCode ? _codeController.text.trim() : _myRoomCode,
                          style: HalfAndHalfTheme.title(
                            color: HalfAndHalfTheme.accentGold,
                            fontSize: 18,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...<Widget>[
                // 1. Quick Match Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HalfAndHalfTheme.purplePrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.flash_on_rounded),
                  label: Text(
                    'Quick Match (1 vs 1 Online)',
                    style: HalfAndHalfTheme.button(fontSize: 13.5),
                  ),
                  onPressed: _triggerQuickMatch,
                ),

                const SizedBox(height: 8),

                // 2. Practice Solo with Bot
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HalfAndHalfTheme.purpleLight,
                    side: const BorderSide(color: HalfAndHalfTheme.purpleBorderLight),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.smart_toy_rounded),
                  label: Text(
                    'Practice Solo (with Bot Partner)',
                    style: HalfAndHalfTheme.button(fontSize: 12.5, color: HalfAndHalfTheme.purpleLight),
                  ),
                  onPressed: _triggerSoloBot,
                ),

                const SizedBox(height: 14),

                // Divider
                Row(
                  children: <Widget>[
                    Expanded(child: Container(height: 1, color: HalfAndHalfTheme.purpleBorder.withValues(alpha: 0.6))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR PLAY WITH A FRIEND',
                        style: HalfAndHalfTheme.badge(
                          color: HalfAndHalfTheme.purpleLight.withValues(alpha: 0.7),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: HalfAndHalfTheme.purpleBorder.withValues(alpha: 0.6))),
                  ],
                ),

                const SizedBox(height: 12),

                // 3. Play with a Friend Box
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xff120924).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: HalfAndHalfTheme.purpleBorderLight.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Section A: Member's Own Room Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Icon(Icons.vpn_key_rounded, size: 14, color: HalfAndHalfTheme.accentGold),
                              const SizedBox(width: 5),
                              Text(
                                'YOUR ROOM CODE',
                                style: HalfAndHalfTheme.badge(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _generateMyCode,
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.refresh_rounded, size: 13, color: HalfAndHalfTheme.purpleLight),
                                const SizedBox(width: 3),
                                Text(
                                  'New Code',
                                  style: HalfAndHalfTheme.body(fontSize: 10.5, color: HalfAndHalfTheme.purpleLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Code Display Tile with Copy button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xff22143d),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: HalfAndHalfTheme.purpleBorderLight.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _myRoomCode,
                                style: HalfAndHalfTheme.title(
                                  fontSize: 18,
                                  color: HalfAndHalfTheme.accentGold,
                                  letterSpacing: 3.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _myRoomCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xff2e1065),
                                    content: Text(
                                      'Room code $_myRoomCode copied to clipboard!',
                                      style: HalfAndHalfTheme.body(color: Colors.white),
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: HalfAndHalfTheme.purplePrimary.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: HalfAndHalfTheme.purplePrimary),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text('Copy', style: HalfAndHalfTheme.button(fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Section B: Friend Code Input Box
                      Row(
                        children: <Widget>[
                          const Icon(Icons.input_rounded, size: 14, color: HalfAndHalfTheme.accentCyan),
                          const SizedBox(width: 5),
                          Text(
                            "ENTER FRIEND'S CODE (OPTIONAL)",
                            style: HalfAndHalfTheme.badge(
                              color: Colors.white70,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Clear Number Box
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xff1a0d33),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: HalfAndHalfTheme.purpleBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.dialpad_rounded, color: HalfAndHalfTheme.purpleLight, size: 17),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                style: HalfAndHalfTheme.title(
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter 6-digit code or leave blank to host",
                                  hintStyle: HalfAndHalfTheme.body(color: Colors.white30, fontSize: 11, letterSpacing: 0),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            if (_codeController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _codeController.clear();
                                  setState(() {});
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () async {
                                  final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                                  if (data?.text != null) {
                                    final String digits = data!.text!.replaceAll(RegExp(r'\D'), '');
                                    if (digits.isNotEmpty) {
                                      setState(() {
                                        _codeController.text = digits.length > 6 ? digits.substring(0, 6) : digits;
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Paste', style: HalfAndHalfTheme.body(fontSize: 10.5, color: Colors.white70)),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // "Play with a Friend" Action Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8b5cf6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.people_alt_rounded, size: 17),
                        label: Text(
                          hasEnteredFriendCode
                              ? "Join Friend's Room (${_codeController.text.trim()})"
                              : "Play with a Friend (Host: $_myRoomCode)",
                          style: HalfAndHalfTheme.button(fontSize: 13),
                        ),
                        onPressed: _triggerPlayWithFriend,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
              style: HalfAndHalfTheme.badge(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
