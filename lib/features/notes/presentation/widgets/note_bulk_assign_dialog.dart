import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';

/// Seçili notlara toplu etiket/kategori atama dialog'u.
///
/// [selectedNoteIds]: Seçili not ID'leri
/// [allCategories]: Mevcut tüm kategoriler
/// [repository]: Not güncelleme işlemleri için
/// [commonCategoryId]: Seçili notların ortak kategorisi (varsa)
/// [hasAnyTagAssigned]: Seçili notlardan en az birinin kategorisi var mı
/// [onDone]: İşlem tamamlandığında çağrılır (seçimi temizlemek için)
class NoteBulkAssignDialog extends StatefulWidget {
  final List<String> selectedNoteIds;
  final List<NoteCategoryModel> allCategories;
  final NoteRepository repository;
  final String? commonCategoryId;
  final bool hasAnyTagAssigned;
  final VoidCallback onDone;

  const NoteBulkAssignDialog({
    super.key,
    required this.selectedNoteIds,
    required this.allCategories,
    required this.repository,
    this.commonCategoryId,
    required this.hasAnyTagAssigned,
    required this.onDone,
  });

  @override
  State<NoteBulkAssignDialog> createState() => _NoteBulkAssignDialogState();
}

class _NoteBulkAssignDialogState extends State<NoteBulkAssignDialog> {
  late String? _localSelectedId;

  @override
  void initState() {
    super.initState();
    _localSelectedId = widget.commonCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      title: Text(
        context.l10n.assignTag,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.allCategories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final cat = widget.allCategories[index];
                  final isSelected = _localSelectedId == cat.id;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      isSelected
                          ? Icons.label_rounded
                          : Icons.label_outline_rounded,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 22,
                    ),
                    title: Text(
                      cat.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: colorScheme.primary,
                            size: 22,
                          )
                        : null,
                    onTap: () => setState(() => _localSelectedId = cat.id),
                  );
                },
              ),
            ),
            if (widget.allCategories.isNotEmpty) const Divider(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(
                Icons.layers_clear_rounded,
                color: widget.hasAnyTagAssigned
                    ? colorScheme.error
                    : colorScheme.onSurface.withValues(alpha: 0.3),
                size: 22,
              ),
              title: Text(
                'Seçimi Temizle (Kaldır)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: _localSelectedId == 'REMOVE'
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.hasAnyTagAssigned
                      ? colorScheme.error
                      : colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              trailing: _localSelectedId == 'REMOVE'
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.error,
                      size: 22,
                    )
                  : null,
              onTap: widget.hasAnyTagAssigned
                  ? () => setState(() => _localSelectedId = 'REMOVE')
                  : null,
            ),
          ],
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
          onPressed: _localSelectedId == null
              ? () => Navigator.pop(context)
              : _onConfirm,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Tamam',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _onConfirm() async {
    final categoryId = _localSelectedId == 'REMOVE' ? null : _localSelectedId;
    await widget.repository.setCategoryForNotes(widget.selectedNoteIds, categoryId);

    if (!mounted) return;
    widget.onDone();
    AppSnackBar.success(context, context.l10n.tagAssignedSuccess);
    Navigator.pop(context);
  }
}
