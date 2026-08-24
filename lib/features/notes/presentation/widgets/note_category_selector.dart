import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';

class NoteCategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final List<NoteCategoryModel> categories;
  final ColorScheme colorScheme;
  final Color fgColor;
  final void Function(String?) onCategorySelected;
  final Future<void> Function(NoteCategoryModel) onCategoryCreated;

  const NoteCategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.categories,
    required this.colorScheme,
    required this.fgColor,
    required this.onCategorySelected,
    required this.onCategoryCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _showCategoryPicker(context);
          },
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.label_outline,
                size: 18,
                color: fgColor.withValues(alpha: 0.6),
              ),
              if (selectedCategoryId == null)
                Text(
                  context.l10n.addNoteTag,
                  style: TextStyle(
                    fontSize: 14,
                    color: fgColor.withValues(alpha: 0.6),
                    fontFamily: 'Inter',
                  ),
                )
              else if (categories.any((c) => c.id == selectedCategoryId))
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 60,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: fgColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    categories
                        .firstWhere((c) => c.id == selectedCategoryId)
                        .name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: fgColor,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    String? localSelectedId = selectedCategoryId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              title: Text(
                context.l10n.noteTags,
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
                    if (categories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          context.l10n.noTagsYet,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = localSelectedId == cat.id;
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
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                                size: 22,
                              ),
                              title: Text(
                                cat.name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
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
                              onTap: () {
                                final newVal = localSelectedId == cat.id
                                    ? null
                                    : cat.id;
                                setDialogState(() {
                                  localSelectedId = newVal;
                                });
                                onCategorySelected(newVal);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    if (localSelectedId != null) ...[
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
                          color: Theme.of(context).colorScheme.error,
                          size: 22,
                        ),
                        title: Text(
                          context.l10n.removeCategory,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () {
                          setDialogState(() {
                            localSelectedId = null;
                          });
                          onCategorySelected(null);
                          Navigator.pop(ctx);
                        },
                      ),
                      const SizedBox(height: 4),
                    ],
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        Icons.add_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      title: Text(
                        context.l10n.createNoteTag,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCreateCategoryDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.done,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _CreateCategoryDialog(onCategoryCreated: onCategoryCreated),
    );
  }
}

class _CreateCategoryDialog extends StatefulWidget {
  final Future<void> Function(NoteCategoryModel) onCategoryCreated;

  const _CreateCategoryDialog({required this.onCategoryCreated});

  @override
  State<_CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<_CreateCategoryDialog> {
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
    return AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        FilledButton(
          onPressed: _isLoading
              ? null
              : () async {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    setState(() => _isLoading = true);
                    final newCat = NoteCategoryModel.create(name: name);
                    try {
                      await widget.onCategoryCreated(newCat);
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    } catch (_) {
                      // BUG 32 FIX: onCategoryCreated exception fırlatırsa
                      // _isLoading = true kalır ve buton sonsuz loading'e girer.
                      // finally bloğu ile her koşulda reset garanti edilir.
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
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
