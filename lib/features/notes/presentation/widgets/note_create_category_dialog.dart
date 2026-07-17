import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';

/// Yeni kategori/etiket oluşturma dialog'u.
///
/// Kategori adını alır, [onCategoryCreated] callback'i ile üst katmana iletir.
class NoteCreateCategoryDialog extends StatefulWidget {
  final Future<void> Function(NoteCategoryModel) onCategoryCreated;
  final List<NoteCategoryModel> existingCategories;

  const NoteCreateCategoryDialog({
    super.key, 
    required this.onCategoryCreated,
    required this.existingCategories,
  });

  @override
  State<NoteCreateCategoryDialog> createState() =>
      _NoteCreateCategoryDialogState();
}

class _NoteCreateCategoryDialogState extends State<NoteCreateCategoryDialog> {
  late final TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
      title: Text(
        context.l10n.newNoteTag,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: context.l10n.tagName,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
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
          onPressed: _isLoading
              ? null
              : () async {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    // Türkçe karakter duyarlı kontrol (Turkish Case-Insensitivity Duplicate Category Bug Fix)
                    String toTrLower(String text) => text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

                    final isDuplicate = widget.existingCategories.any(
                      (cat) => toTrLower(cat.name) == toTrLower(name)
                    );
                    
                    if (isDuplicate) {
                      AppSnackBar.error(context, context.l10n.errDbAlreadyExists);
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                      final newCat = NoteCategoryModel.create(name: name);
                      await widget.onCategoryCreated(newCat);
                      if (mounted) Navigator.pop(this.context);
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  context.l10n.createNoteTag,
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
