import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SketchToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<bool> onEraserToggled;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final bool canUndo;

  static const List<Color> palette = <Color>[
    Color(0xffffffff), // White
    Color(0xffef4444), // Red
    Color(0xfff97316), // Orange
    Color(0xfff8df40), // Yellow
    Color(0xff08abc4), // Cyan
    Color(0xff22c55e), // Green
    Color(0xffa855f7), // Purple
    Color(0xff2563eb), // Royal Blue
  ];

  static const List<double> strokeWidths = <double>[
    2.5,  // Fine
    5.0,  // Standard
    8.5,  // Marker
    14.0, // Bold
  ];

  const SketchToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isEraser,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onEraserToggled,
    required this.onUndo,
    required this.onClear,
    this.canUndo = true,
  });

  void _stepWidth(int delta) {
    int currentIndex = strokeWidths.indexOf(selectedWidth);
    if (currentIndex == -1) currentIndex = 1;
    final int nextIndex = (currentIndex + delta).clamp(0, strokeWidths.length - 1);
    onWidthChanged(strokeWidths[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Top Row: Palette Circle Swatches (Compact & Spaced)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: palette.map((Color c) {
              final bool isSelected = !isEraser && selectedColor.toARGB32() == c.toARGB32();
              return GestureDetector(
                onTap: () {
                  onEraserToggled(false);
                  onColorChanged(c);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isSelected ? 24 : 18,
                  height: isSelected ? 24 : 18,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xff08abc4) : Colors.white24,
                      width: isSelected ? 2.2 : 1,
                    ),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xff08abc4).withValues(alpha: 0.7),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),

          // Bottom Row: Brush Size on Left, Action Tools on Right (Wrapped in FittedBox for zero overflow)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Left: Brush Size Stepper
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Brush Size',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Minus Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _stepWidth(-1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff16284d),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(Icons.remove_rounded, size: 12, color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Size Dots
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: strokeWidths.map((double w) {
                        final bool isCurrent = selectedWidth == w;
                        final double dotSize = (w * 0.5 + 3.0).clamp(3.5, 11.0);
                        return GestureDetector(
                          onTap: () => onWidthChanged(w),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: 14,
                            height: 14,
                            alignment: Alignment.center,
                            decoration: isCurrent
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xff08abc4), width: 1.2),
                                  )
                                : null,
                            child: Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent
                                    ? (isEraser ? const Color(0xfff8df40) : selectedColor)
                                    : Colors.white38,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 4),

                    // Plus Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _stepWidth(1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff16284d),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(Icons.add_rounded, size: 12, color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 18),

                // Right: Action Buttons (Eraser, Undo, Clear)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Eraser Button
                    _actionButton(
                      icon: Icons.auto_fix_normal_rounded,
                      label: 'Eraser',
                      isActive: isEraser,
                      activeColor: const Color(0xff08abc4),
                      onTap: () => onEraserToggled(!isEraser),
                    ),
                    const SizedBox(width: 6),

                    // Undo Button
                    _actionButton(
                      icon: Icons.undo_rounded,
                      label: 'Undo',
                      isEnabled: canUndo,
                      onTap: onUndo,
                    ),
                    const SizedBox(width: 6),

                    // Clear Button
                    _actionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Clear',
                      iconColor: const Color(0xfff87171),
                      onTap: () => _showClearConfirmation(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isEnabled = true,
    Color activeColor = const Color(0xff08abc4),
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.25)
                : const Color(0xff12203d),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? activeColor
                  : const Color(0xff08abc4).withValues(alpha: 0.25),
              width: isActive ? 1.2 : 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 15,
                color: !isEnabled
                    ? Colors.white24
                    : (isActive ? activeColor : (iconColor ?? Colors.white)),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.fredoka(
                  color: !isEnabled
                      ? Colors.white24
                      : (isActive ? activeColor : Colors.white70),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xff121d38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Canvas?',
          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to erase your entire drawing?',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onClear();
            },
            child: Text('Clear All', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
