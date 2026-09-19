import 'package:flutter/material.dart';
import '../models/sketch_party_state.dart';

class SketchChatOverlay extends StatefulWidget {
  final List<SketchChatMessage> messages;
  final ValueChanged<String> onSendGuess;
  final bool isDrawer;
  final bool hasGuessed;

  const SketchChatOverlay({
    super.key,
    required this.messages,
    required this.onSendGuess,
    required this.isDrawer,
    required this.hasGuessed,
  });

  @override
  State<SketchChatOverlay> createState() => _SketchChatOverlayState();
}

class _SketchChatOverlayState extends State<SketchChatOverlay> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    final String text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendGuess(text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant SketchChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length != widget.messages.length) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff121829),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          // Chat Stream
          Expanded(
            child: widget.messages.isEmpty
                ? const Center(
                    child: Text(
                      'Guesses will appear here...',
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    itemCount: widget.messages.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      final SketchChatMessage msg = widget.messages[index];
                      return _buildMessageItem(msg);
                    },
                  ),
          ),

          // Bottom Input Field
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(SketchChatMessage msg) {
    switch (msg.type) {
      case ChatMessageType.correctGuess:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xff10b981).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xff10b981).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Color(0xff34d399),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

      case ChatMessageType.closeGuess:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xfff4d935).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xfff4d935).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Color(0xfffde047),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

      case ChatMessageType.system:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        );

      case ChatMessageType.normal:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '${msg.senderName}: ',
                  style: const TextStyle(
                    color: Color(0xff08abc4),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: msg.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildInputBar() {
    if (widget.isDrawer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xff161e36),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: const Center(
          child: Text(
            '✏️ You are drawing! Draw clearly so players can guess.',
            style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    if (widget.hasGuessed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xff10b981).withValues(alpha: 0.15),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: const Center(
          child: Text(
            '🎉 You guessed the word! Waiting for others...',
            style: TextStyle(color: Color(0xff34d399), fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color(0xff161e36),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Type your guess here...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                isDense: true,
                filled: true,
                fillColor: const Color(0xff0d1222),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.send_rounded),
            color: const Color(0xff08abc4),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

