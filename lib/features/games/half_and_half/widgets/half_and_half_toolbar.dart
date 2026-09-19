import 'package:flutter/material.dart';

class HalfAndHalfToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final VoidCallback onSelectPencil;
  final VoidCallback onSelectEraser;
  final Function(Color) onSelectColor;
  final Function(double) onSelectWidth;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  static const List<Color> palette = <Color>[
    Color(0xff1e1b2e), // Deep ink black
    Color(0xff6d28d9), // Royal Purple (matching creature theme)
    Color(0xff2563eb), // Blue
    Color(0xff059669), // Emerald
    Color(0xffe11d48), // Crimson
    Color(0xffd97706), // Amber
  ];

  const HalfAndHalfToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isEraser,
    required this.onSelectPencil,
    required this.onSelectEraser,
    required this.onSelectColor,
    required this.onSelectWidth,
    required this.onUndo,
    required this.onClear,
    required this.onSubmit,
  });

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff18122d),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Select Ink Color', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: palette.map((Color c) {
                  final bool isCurrent = selectedColor == c && !isEraser;
                  return GestureDetector(
                    onTap: () {
                      onSelectColor(c);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent ? Colors.white : Colors.white24,
                          width: isCurrent ? 3 : 1.5,
                        ),
                        boxShadow: isCurrent
                            ? <BoxShadow>[
                                BoxShadow(color: c.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWidthPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff18122d),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Stroke Thickness: ${selectedWidth.toStringAsFixed(1)}px',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selectedWidth,
                    min: 2.0,
                    max: 14.0,
                    activeColor: const Color(0xffa78bfa),
                    inactiveColor: Colors.white24,
                    onChanged: (double val) {
                      setModalState(() {});
                      onSelectWidth(val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff161129),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xff39285f), width: 1.4),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Pencil Tool
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: !isEraser ? const Color(0xffa78bfa) : Colors.white54,
              size: 24,
            ),
            tooltip: 'Pencil',
            onPressed: onSelectPencil,
          ),

          // Eraser Tool
          IconButton(
            icon: Icon(
              Icons.auto_fix_normal_rounded,
              color: isEraser ? const Color(0xfff43f5e) : Colors.white54,
              size: 24,
            ),
            tooltip: 'Eraser',
            onPressed: onSelectEraser,
          ),

          // Stroke Width Tool
          IconButton(
            icon: const Icon(Icons.line_weight_rounded, color: Colors.white70, size: 24),
            tooltip: 'Stroke Width',
            onPressed: () => _showWidthPicker(context),
          ),

          // Color Palette Wheel
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEraser ? Colors.white : selectedColor,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (isEraser ? Colors.white : selectedColor).withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Undo
          IconButton(
            icon: const Icon(Icons.undo_rounded, color: Colors.white70, size: 22),
            tooltip: 'Undo',
            onPressed: onUndo,
          ),

          // Done / Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff7c3aed),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: onSubmit,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.check_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

