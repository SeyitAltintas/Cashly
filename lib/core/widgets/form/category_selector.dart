import 'package:flutter/material.dart';
import '../../constants/color_constants.dart';
import '../../extensions/l10n_extensions.dart';

/// Kategori seçici widget'ı
/// Harcama ve gelir kategorileri için yeniden kullanılabilir dropdown.
class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Map<String, IconData> categoryIcons;
  final Function(String?) onChanged;
  final String? labelText;
  final Color? accentColor;
  final bool isExpanded;
  final bool showLabel;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categoryIcons,
    required this.onChanged,
    this.labelText,
    this.accentColor,
    this.isExpanded = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? ColorConstants.kirmiziVurgu;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                hint: Text(
                  labelText ?? context.l10n.category,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                isExpanded: isExpanded,
                dropdownColor: theme.colorScheme.surface,
                items: categoryIcons.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value, size: 20, color: color),
                        const SizedBox(width: 8),
                        Text(context.translateDbName(entry.key)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Harcama kategorisi seçici (kırmızı tema)
  static CategorySelector expense({
    Key? key,
    required String? selectedCategory,
    required Map<String, IconData> categoryIcons,
    required Function(String?) onChanged,
  }) {
    return CategorySelector(
      key: key,
      selectedCategory: selectedCategory,
      categoryIcons: categoryIcons,
      onChanged: onChanged,
      accentColor: ColorConstants.kirmiziVurgu,
    );
  }

  /// Gelir kategorisi seçici (yeşil tema)
  static CategorySelector income({
    Key? key,
    required String? selectedCategory,
    required Map<String, IconData> categoryIcons,
    required Function(String?) onChanged,
  }) {
    return CategorySelector(
      key: key,
      selectedCategory: selectedCategory,
      categoryIcons: categoryIcons,
      onChanged: onChanged,
      accentColor: Colors.green,
    );
  }
}
