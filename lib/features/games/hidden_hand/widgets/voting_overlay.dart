import 'package:flutter/material.dart';
import '../models/hidden_hand_player.dart';
import '../models/hidden_hand_state.dart';

class VotingOverlay extends StatelessWidget {
  final HiddenHandState state;
  final String localPlayerId;
  final ValueChanged<String> onCastVote;

  const VotingOverlay({
    super.key,
    required this.state,
    required this.localPlayerId,
    required this.onCastVote,
  });

  @override
  Widget build(BuildContext context) {
    final HiddenHandPlayer? localPlayer = state.getPlayer(localPlayerId);
    final bool hasVoted = localPlayer?.voteTargetId != null;
    final List<HiddenHandPlayer> alivePlayers = state.activePlayers;

    // Count votes for each candidate
    final Map<String, int> tally = <String, int>{};
    int skipVotes = 0;
    for (final HiddenHandPlayer p in alivePlayers) {
      if (p.voteTargetId == 'SKIP') {
        skipVotes++;
      } else if (p.voteTargetId != null) {
        tally[p.voteTargetId!] = (tally[p.voteTargetId!] ?? 0) + 1;
      }
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xff1d1f2e),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xffefc249), width: 1.8),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xffefc249).withValues(alpha: 0.2),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.how_to_vote_rounded, color: Color(0xffefc249), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'EMERGENCY VOTE',
                    style: TextStyle(
                      color: Color(0xffefc249),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Who is the Hidden Hand drawing blindly? Vote out the impostor or skip.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xff94a3b8), fontSize: 12),
              ),
              const SizedBox(height: 18),

              // Player Candidate Grid
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: alivePlayers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final HiddenHandPlayer candidate = alivePlayers[index];
                    final bool isSelf = candidate.id == localPlayerId;
                    final bool isSelected = localPlayer?.voteTargetId == candidate.id;
                    final int votes = tally[candidate.id] ?? 0;

                    return InkWell(
                      onTap: hasVoted || isSelf ? null : () => onCastVote(candidate.id),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff4c1d34)
                              : const Color(0xff26283b),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xfff43f5e)
                                : const Color(0xff3f415c),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(candidate.assignedColorValue),
                              child: Text(
                                candidate.displayName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xff12131c),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    candidate.displayName + (isSelf ? ' (You)' : ''),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelf ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (candidate.voteTargetId != null)
                                    const Text(
                                      'Voted',
                                      style: TextStyle(color: Color(0xff10b981), fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                            if (votes > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff43f5e),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$votes vote${votes > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            if (!isSelf && !hasVoted) ...<Widget>[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white38, size: 14),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Skip Vote Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: hasVoted ? null : () => onCastVote('SKIP'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff94a3b8),
                    side: BorderSide(
                      color: localPlayer?.voteTargetId == 'SKIP'
                          ? const Color(0xffefc249)
                          : const Color(0xff444760),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: Text(
                    localPlayer?.voteTargetId == 'SKIP'
                        ? 'YOU SKIPPED ($skipVotes votes)'
                        : 'SKIP VOTE (Keep Drawing)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: localPlayer?.voteTargetId == 'SKIP'
                          ? const Color(0xffefc249)
                          : Colors.white70,
                    ),
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
