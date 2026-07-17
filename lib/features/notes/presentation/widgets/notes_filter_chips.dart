import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';

/// Notlar listesi için yatay kaydırılabilir filtre chip'leri.
///
/// "Tümü", "Sabitlenmiş" ve kullanıcı kategorileri chip'lerini gösterir.
/// Kategori chip'lerine long-press ile silme dialog'u tetiklenir.
class NotesFilterChips extends StatelessWidget {
  final String? selectedFilterId;
  final List<NoteCategoryModel> categories;
  final ValueChanged<String?> onFilterSelected;
  final ValueChanged<NoteCategoryModel> onCategoryLongPressed;
  final VoidCallback onAddCategory;

  const NotesFilterChips({
    super.key,
    required this.selectedFilterId,
    required this.categories,
    required this.onFilterSelected,
    required this.onCategoryLongPressed,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            context: context,
            label: context.l10n.allNotesFilter,
            isSelected: selectedFilterId == null,
            onSelected: (_) => onFilterSelected(null),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: context.l10n.pinnedNotesFilter,
            isSelected: selectedFilterId == 'pinned',
            onSelected: (_) => onFilterSelected('pinned'),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          for (final cat in categories) ...[
            GestureDetector(
              onLongPress: () => onCategoryLongPressed(cat),
              child: _buildChip(
                context: context,
                label: cat.name,
                isSelected: selectedFilterId == cat.id,
                onSelected: (_) => onFilterSelected(cat.id),
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 8),
          ],
          ActionChip(
            label: Text(
              '+ ${context.l10n.newNoteTag}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
            onPressed: onAddCategory,
            backgroundColor: colorScheme.surface,
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    required ColorScheme colorScheme,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color:
              isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primaryContainer,
      side: isSelected
          ? BorderSide.none
          : BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
    );
  }
}
