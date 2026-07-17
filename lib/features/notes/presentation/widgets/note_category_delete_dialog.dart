import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';

/// Belirli bir kategoriyi silme onayı isteyen dialog.
///
/// Silme işlemi onaylanırsa [onConfirmDelete] callback'i çağrılır.
/// Notlar silinmez, sadece kategorisiz kalır.
class NoteCategoryDeleteDialog extends StatelessWidget {
  final NoteCategoryModel category;
  final VoidCallback onConfirmDelete;

  const NoteCategoryDeleteDialog({
    super.key,
    required this.category,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      title: const Text(
        'Kategoriyi Sil',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        '"${category.name}" kategorisini silmek istediğinize emin misiniz?\n\nBu kategoriye ait notlar silinmeyecek, sadece kategorisiz kalacaktır.',
        style: TextStyle(
          fontFamily: 'Inter',
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 15,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            context.l10n.cancel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmDelete();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            context.l10n.delete,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
