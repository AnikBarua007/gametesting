import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'thematic_components.dart';

class DrawingToolbar extends StatefulWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isInteractive;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<double> onWidthSelected;
  final VoidCallback? onDoneTurn;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;
  final String submitLabel;

  static const List<Color> palette = <Color>[
    Color(0xffffffff), // White
    Color(0xffef4444), // Red
    Color(0xfff97316), // Orange
    Color(0xfffacc15), // Yellow
    Color(0xff10b981), // Green
    Color(0xff06b6d4), // Cyan
    Color(0xffa855f7), // Purple
    Color(0xffec4899), // Pink
  ];

  const DrawingToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isInteractive,
    required this.onColorSelected,
    required this.onWidthSelected,
    this.onDoneTurn,
    this.onUndo,
    this.onClear,
    this.submitLabel = 'DONE',
  });

  @override
  State<DrawingToolbar> createState() => _DrawingToolbarState();
}

class _DrawingToolbarState extends State<DrawingToolbar> {
  bool _isEraser = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isInteractive) {
      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xcc121528),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff2c314d)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.remove_red_eye_rounded, color: Color(0xff9ca3af), size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Observing other artist at work...',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.cinzel(
                  color: const Color(0xff9ca3af),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xeb101325),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xff2c3252), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Top Row: Colors & Brush Sizes
          Row(
            children: <Widget>[
              // COLOR PALETTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'COLOR',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xff6b7280),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: DrawingToolbar.palette.map((color) {
                          final bool isSelected =
                              !_isEraser && widget.selectedColor.toARGB32() == color.toARGB32();
                          return GestureDetector(
                            onTap: () {
                              setState(() => _isEraser = false);
                              widget.onColorSelected(color);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2.0,
                                ),
                                boxShadow: isSelected
                                    ? <BoxShadow>[
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.7),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // BRUSH SIZE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'BRUSH SIZE',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xff6b7280),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xff181c34),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xff2d3356)),
                    ),
                    child: Row(
                      children: <double>[3.0, 6.0, 10.0].map((width) {
                        final bool isSelected = widget.selectedWidth == width;
                        return GestureDetector(
                          onTap: () => widget.onWidthSelected(width),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? HiddenHandTheme.gold.withValues(alpha: 0.25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Container(
                              width: width + 2,
                              height: width + 2,
                              decoration: BoxDecoration(
                                color: isSelected ? HiddenHandTheme.gold : const Color(0xff94a3b8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Bottom Row: [Pen] [Eraser] [Undo] [Clear] + [▶ SUBMIT DRAWING]
          Row(
            children: <Widget>[
              _buildToolButton(
                icon: Icons.edit_rounded,
                label: 'Pen',
                isActive: !_isEraser,
                onTap: () {
                  setState(() => _isEraser = false);
                  widget.onColorSelected(DrawingToolbar.palette[0]);
                },
              ),
              const SizedBox(width: 4),

              _buildToolButton(
                icon: Icons.cleaning_services_rounded,
                label: 'Eraser',
                isActive: _isEraser,
                onTap: () {
                  setState(() => _isEraser = true);
                  widget.onColorSelected(const Color(0xff0d1020));
                },
              ),
              const SizedBox(width: 4),

              _buildToolButton(
                icon: Icons.undo_rounded,
                label: 'Undo',
                isActive: false,
                onTap: widget.onUndo,
              ),
              const SizedBox(width: 4),

              _buildToolButton(
                icon: Icons.delete_outline_rounded,
                label: 'Clear',
                isActive: false,
                onTap: widget.onClear,
              ),

              const SizedBox(width: 6),

              // Responsive Submit Golden Button
              Expanded(
                child: GoldenCtaButton(
                  height: 40,
                  onPressed: widget.onDoneTurn,
                  icon: Icons.play_arrow_rounded,
                  label: widget.submitLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? HiddenHandTheme.gold.withValues(alpha: 0.2) : const Color(0xff181c34),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? HiddenHandTheme.gold : const Color(0xff2d3356),
            width: isActive ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: isActive ? HiddenHandTheme.gold : const Color(0xffcbd5e1),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: isActive ? HiddenHandTheme.gold : const Color(0xff94a3b8),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
