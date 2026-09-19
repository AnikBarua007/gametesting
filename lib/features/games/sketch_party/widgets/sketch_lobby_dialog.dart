import 'package:flutter/material.dart';
import '../models/sketch_party_player.dart';

class SketchLobbyDialog extends StatefulWidget {
  final String roomCode;
  final List<SketchPartyPlayer> players;
  final ValueChanged<int> onPlayerCountChanged;
  final VoidCallback onStartMatch;
  final VoidCallback onExit;

  const SketchLobbyDialog({
    super.key,
    required this.roomCode,
    required this.players,
    required this.onPlayerCountChanged,
    required this.onStartMatch,
    required this.onExit,
  });

  @override
  State<SketchLobbyDialog> createState() => _SketchLobbyDialogState();
}

class _SketchLobbyDialogState extends State<SketchLobbyDialog> {
  late int _playerCount;

  @override
  void initState() {
    super.initState();
    _playerCount = widget.players.length.clamp(2, 8);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xff161e36),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xff08abc4).withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xff08abc4).withValues(alpha: 0.25),
              blurRadius: 26,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Title Header
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff08abc4).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gesture_rounded, color: Color(0xff08abc4), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'SKETCH PARTY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Room: ${widget.roomCode}',
                        style: const TextStyle(
                          color: Color(0xfff4d935),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onExit,
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Player Count Slider
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xff0e1424),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('Total Players:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(
                        '$_playerCount Players',
                        style: const TextStyle(color: Color(0xff08abc4), fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xff08abc4),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: const Color(0xfff4d935),
                      overlayColor: const Color(0xfff4d935).withValues(alpha: 0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _playerCount.toDouble(),
                      min: 2,
                      max: 8,
                      divisions: 6,
                      onChanged: (double val) {
                        setState(() {
                          _playerCount = val.toInt();
                        });
                        widget.onPlayerCountChanged(_playerCount);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Players Roster Preview
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LOBBY ROSTER',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.players.length,
                itemBuilder: (BuildContext ctx, int index) {
                  final SketchPartyPlayer p = widget.players[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xff0e1424),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: p.isHost
                            ? const Color(0xfff4d935).withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xff08abc4).withValues(alpha: 0.25),
                          child: Text(
                            p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Color(0xff08abc4), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.displayName,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (p.isHost)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xfff4d935).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('YOU / HOST', style: TextStyle(color: Color(0xfff4d935), fontSize: 9, fontWeight: FontWeight.w800)),
                          )
                        else if (p.isBot)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('AI BOT', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Start Match CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff08abc4),
                  foregroundColor: const Color(0xff0b1329),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                ),
                onPressed: widget.onStartMatch,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.play_arrow_rounded, size: 20),
                    SizedBox(width: 6),
                    Text('START MATCH', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

