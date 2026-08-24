import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/notes/presentation/controllers/trash_notes_controller.dart';
import '../widgets/note_card.dart';

class TrashNotesPage extends StatelessWidget {
  const TrashNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<TrashNotesController>()..init(),
      child: const _TrashNotesView(),
    );
  }
}

class _TrashNotesView extends StatefulWidget {
  const _TrashNotesView();

  @override
  State<_TrashNotesView> createState() => _TrashNotesViewState();
}

class _TrashNotesViewState extends State<_TrashNotesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TrashNotesController>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<TrashNotesController>();
    final notes = controller.trashNotes;
    final isSelectionMode = controller.isSelectionMode;

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isSelectionMode) {
          controller.clearSelection();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(context, controller, colorScheme),
        body: notes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.trashEmpty,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        context.l10n.trashEmptyHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final isSelected = controller.selectedNoteIds.contains(
                      note.id,
                    );

                    // Kalan gün hesabı
                    final daysLeft =
                        30 -
                        DateTime.now()
                            .difference(note.deletedAt ?? DateTime.now())
                            .inDays;

                    return NoteCard(
                      note: note,
                      isGrid: true,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelectionMode) {
                          controller.toggleSelection(note.id);
                        } else {
                          AppSnackBar.info(context, context.l10n.restoreToView);
                        }
                      },
                      onLongPress: () {
                        controller.toggleSelection(note.id);
                      },
                      bottomTrailing: !isSelected
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.l10n.daysLeft(
                                  daysLeft > 0 ? daysLeft : 0,
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onErrorContainer,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
        bottomNavigationBar: isSelectionMode
            ? _buildBottomBar(context, controller, colorScheme)
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    TrashNotesController controller,
    ColorScheme colorScheme,
  ) {
    if (controller.isSelectionMode) {
      final allSelected =
          controller.trashNotes.isNotEmpty &&
          controller.trashNotes.every(
            (n) => controller.selectedNoteIds.contains(n.id),
          );

      return AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: controller.clearSelection,
        ),
        title: Text(
          context.l10n.notesSelectedCount(
            controller.selectedNoteIds.length.toString(),
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
              size: 22,
            ),
            onPressed: controller.selectAll,
          ),
          const SizedBox(width: 4),
        ],
      );
    }

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        tooltip: context.l10n.back,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        context.l10n.trashBin,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: 'Inter',
        ),
      ),
      centerTitle: false,
      actions: [
        if (controller.trashNotes.isNotEmpty)
          TextButton(
            onPressed: () => _confirmEmptyTrash(context, controller),
            child: Text(
              context.l10n.emptyTrash,
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    TrashNotesController controller,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 12,
        top: 12,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.restore_rounded,
            label: context.l10n.restore,
            color: colorScheme.primary,
            onTap: () async {
              await controller.restoreSelected();
              if (context.mounted) {
                AppSnackBar.success(context, context.l10n.notesRestored);
              }
            },
          ),
          _ActionButton(
            icon: Icons.delete_forever_rounded,
            label: context.l10n.permanentlyDelete,
            color: colorScheme.error,
            onTap: () => _confirmDeleteSelected(context, controller),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    TrashNotesController controller,
  ) async {
    // Dialog açılmadan önce count'u sabitle — async gap'te clearSelection çağrılırsa 0 olabilir
    final count = controller.selectedNoteIds.length;
    if (count == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.warning),
        content: Text(ctx.l10n.permanentlyDeleteConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.permanentlyDeleteSelected();
      if (context.mounted) {
        AppSnackBar.success(context, context.l10n.notesPermanentlyDeleted);
      }
    }
  }

  Future<void> _confirmEmptyTrash(
    BuildContext context,
    TrashNotesController controller,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.warning),
        content: Text(ctx.l10n.emptyTrashConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(ctx.l10n.emptyTrash),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.emptyTrash();
      if (context.mounted) {
        AppSnackBar.success(context, context.l10n.trashEmptied);
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
