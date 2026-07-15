import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class NoteColorPickerSheet {
  static const List<Color> _lightNoteColors = [
    Color(0xFFFDFBF7), // Pamuk
    Color(0xFFF0F7F4), // Nane
    Color(0xFFF0F4F8), // Buz
    Color(0xFFFFF0F0), // Gül
    Color(0xFFF4F0F7), // Lavanta
  ];

  static const List<Color> _darkNoteColors = [
    Color(0xFF242424), // Koyu Gri
    Color(0xFF142C23), // Koyu Nane
    Color(0xFF122236), // Koyu Mavi
    Color(0xFF33161A), // Koyu Gül
    Color(0xFF261933), // Koyu Lavanta
  ];

  static List<String> _getColorLabels(BuildContext context) => [
        context.l10n.colorCotton,
        context.l10n.colorMint,
        'Buz',
        'Gül',
        context.l10n.colorLavender,
      ];

  static void show(BuildContext context, int? selectedColor, ValueChanged<int?> onColorSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final cs = Theme.of(sheetContext).colorScheme;

        final allColors = [..._lightNoteColors, ..._darkNoteColors];
        final allLabels = [
          ..._getColorLabels(sheetContext),
          sheetContext.l10n.darkCotton,
          sheetContext.l10n.darkMint,
          sheetContext.l10n.darkBlue,
          sheetContext.l10n.darkRose,
          sheetContext.l10n.darkLavender,
        ];

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        sheetContext.l10n.themeColor,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          fontFamily: 'Inter',
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          onColorSelected(null);
                          Navigator.pop(sheetContext);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selectedColor == null
                                ? cs.primary.withValues(alpha: 0.15)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedColor == null
                                  ? cs.primary
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            sheetContext.l10n.defaultColor,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selectedColor == null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: selectedColor == null
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: 0.6),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 20,
                            children: [
                              for (int i = 0; i < allColors.length; i++)
                                _ColorOption(
                                  color: allColors[i],
                                  isSelected: selectedColor != null &&
                                      allColors[i].toARGB32() == selectedColor,
                                  label: allLabels[i],
                                  onTap: () {
                                    onColorSelected(allColors[i].toARGB32());
                                    Navigator.pop(sheetContext);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;
  final String? label;

  const _ColorOption({
    this.color,
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : cs.outlineVariant.withValues(alpha: 0.5),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 28,
                      color: color == null
                          ? cs.onSurface
                          : (color!.computeLuminance() < 0.5
                                ? Colors.white
                                : Colors.black87),
                    )
                  : (color == null
                        ? Icon(
                            Icons.format_color_reset_outlined,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          )
                        : null),
            ),
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(
                label!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? primaryColor
                      : cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
