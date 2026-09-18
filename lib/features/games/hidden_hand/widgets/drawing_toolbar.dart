import 'package:flutter/material.dart';

class DrawingToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isInteractive;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<double> onWidthSelected;
  final VoidCallback? onDoneTurn;

  static const List<Color> palette = <Color>[
    Color(0xffefc249), // Gold
    Color(0xff08abc4), // Cyan
    Color(0xffec4899), // Pink
    Color(0xff10b981), // Green
    Color(0xffa855f7), // Purple
    Color(0xfff97316), // Orange
    Color(0xffffffff), // White
    Color(0xff64748b), // Slate Grey
  ];

  const DrawingToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isInteractive,
    required this.onColorSelected,
    required this.onWidthSelected,
    this.onDoneTurn,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInteractive) {
      return Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xff222432),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff333547)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(Icons.remove_red_eye_rounded, color: Color(0xffa1a0b0), size: 18),
            SizedBox(width: 8),
            Text(
              'Observing other artist at work...',
              style: TextStyle(
                color: Color(0xffa1a0b0),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff222432),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffefc249), width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xffefc249).withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Colors & Brush sizes
          Row(
            children: <Widget>[
              // Colors
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: palette.map((color) {
                      final bool isSelected = selectedColor.toARGB32() == color.toARGB32();
                      return GestureDetector(
                        onTap: () => onColorSelected(color),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.2,
                            ),
                            boxShadow: isSelected
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Stroke sizes
              Row(
                children: <double>[3.0, 6.0, 10.0].map((width) {
                  final bool isSelected = selectedWidth == width;
                  return GestureDetector(
                    onTap: () => onWidthSelected(width),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xff333547) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: width + 4,
                        height: width + 4,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(width: 8),

              // Done Turn Button
              ElevatedButton.icon(
                onPressed: onDoneTurn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffefc249),
                  foregroundColor: const Color(0xff1c1d2a),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text(
                  'DONE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
