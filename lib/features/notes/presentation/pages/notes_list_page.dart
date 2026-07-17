import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/presentation/controllers/notes_list_controller.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'note_editor_page.dart';
import '../widgets/note_card.dart';
import '../widgets/notes_empty_state.dart';
import '../widgets/notes_search_bar.dart';
import '../widgets/note_create_category_dialog.dart';
import '../widgets/note_category_delete_dialog.dart';
import '../widgets/note_bulk_assign_dialog.dart';
import '../widgets/notes_filter_chips.dart';
import '../widgets/notes_bottom_action_bar.dart';
import '../widgets/notes_app_bar.dart';

/// Kayıtlı notların listelendiği sayfa.
///
/// UI katmanı sadece görünüme odaklanır, 
/// tüm durum yönetimi [NotesListController] üzerinden yapılır.
class NotesListPage extends StatelessWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<NotesListController>()..init(),
      child: const _NotesListView(),
    );
  }
}

class _NotesListView extends StatefulWidget {
  const _NotesListView();

  @override
  State<_NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<_NotesListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Navigasyon
  Future<void> _openNote(BuildContext context, String? noteId) async {
    final tag = noteId != null ? 'note_hero_$noteId' : 'note_hero_new';
    final controller = context.read<NotesListController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(noteId: noteId, heroTag: tag),
      ),
    );
    if (mounted) {
      controller.refreshCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<NotesListController>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: NotesAppBar(
          isSelectionMode: controller.isSelectionMode,
          isReady: controller.isReady,
          selectedCount: controller.selectedNoteIds.length,
          visibleNotes: controller.visibleNotes,
          selectedNoteIds: controller.selectedNoteIds,
          isGridView: controller.isGridView,
          onClearSelection: controller.clearSelection,
          onSelectAll: controller.selectAll,
          onToggleGridView: controller.toggleGridView,
        ),
        body: controller.isReady
            ? Stack(
                children: [
                  Column(
                    children: [
                      if (!controller.isSelectionMode)
                        NotesSearchBar(
                          controller: _searchController,
                          searchQuery: controller.searchQuery,
                          onChanged: controller.setSearchQuery,
                          onClear: () {
                            _searchController.clear();
                            controller.setSearchQuery('');
                          },
                        ),
                      if (!controller.isSelectionMode)
                        NotesFilterChips(
                          selectedFilterId: controller.selectedFilterId,
                          categories: controller.allCategories,
                          onFilterSelected: controller.setFilter,
                          onCategoryLongPressed: (cat) =>
                              _showDeleteCategoryDialog(context, cat),
                          onAddCategory: () => _showCreateCategoryDialog(context),
                        ),
                      Expanded(child: _buildBody(context, controller)),
                    ],
                  ),
                  NotesBottomActionBar(
                    isVisible: controller.isSelectionMode,
                    allPinned: controller.selectedNotesAreAllPinned,
                    onHide: controller.clearSelection,
                    onTogglePin: controller.togglePinSelected,
                    onMoveTag: () =>
                        _showBulkAssignTagDialog(context, colorScheme),
                    onDelete: () => _confirmAndDeleteSelected(context),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
        floatingActionButton: controller.isSelectionMode
            ? null
            : _buildFab(context, colorScheme),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotesListController controller) {
    final notes = controller.visibleNotes;
    final isGrid = controller.isGridView;

    if (notes.isEmpty) {
      return NotesEmptyState(
        isSearching: controller.searchQuery.isNotEmpty,
        isFiltering: controller.selectedFilterId != null,
        searchQuery: controller.searchQuery,
      );
    }

    if (isGrid) {
      return MasonryGridView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: notes.length,
        itemBuilder: (context, index) => NoteCard(
          note: notes[index],
          isGrid: true,
          isSelected: controller.selectedNoteIds.contains(notes[index].id),
          isSelectionMode: controller.isSelectionMode,
          searchQuery: controller.searchQuery,
          onTap: () {
            if (controller.isSelectionMode) {
              controller.toggleSelection(notes[index].id);
            } else {
              _openNote(context, notes[index].id);
            }
          },
          onLongPress: () => controller.toggleSelection(notes[index].id),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: notes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => NoteCard(
        note: notes[index],
        isGrid: false,
        isSelected: controller.selectedNoteIds.contains(notes[index].id),
        isSelectionMode: controller.isSelectionMode,
        searchQuery: controller.searchQuery,
        onTap: () {
          if (controller.isSelectionMode) {
            controller.toggleSelection(notes[index].id);
          } else {
            _openNote(context, notes[index].id);
          }
        },
        onLongPress: () => controller.toggleSelection(notes[index].id),
      ),
    );
  }

  Widget _buildFab(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      heroTag: 'note_hero_new',
      onPressed: () => _openNote(context, null),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        context.l10n.newNote,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // --- Dialogs ---

  Future<void> _confirmAndDeleteSelected(BuildContext context) async {
    final controller = context.read<NotesListController>();
    final count = controller.selectedNoteIds.length;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.warning),
        content: Text('$count notu silmek istediğinize emin misiniz?'),
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
      await controller.deleteSelected();
      if (context.mounted) {
        AppSnackBar.success(context, context.l10n.noteDeleteConfirm);
      }
    }
  }

  void _showDeleteCategoryDialog(BuildContext context, NoteCategoryModel cat) {
    final controller = context.read<NotesListController>();
    showDialog(
      context: context,
      builder: (ctx) => NoteCategoryDeleteDialog(
        category: cat,
        onConfirmDelete: () async {
          await controller.categoryRepository.deleteCategory(cat.id);
          await controller.repository.removeCategoryFromNotes(cat.id);

          if (!context.mounted) return;
          if (controller.selectedFilterId == cat.id) {
            controller.setFilter(null);
          }
          controller.refreshCategories();

          AppSnackBar.success(context, 'Kategori silindi');
        },
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    final controller = context.read<NotesListController>();
    showDialog(
      context: context,
      builder: (ctx) => NoteCreateCategoryDialog(
        onCategoryCreated: (newCat) async {
          await controller.categoryRepository.saveCategory(newCat);
          if (context.mounted) {
            controller.refreshCategories();
          }
        },
      ),
    );
  }

  void _showBulkAssignTagDialog(BuildContext context, ColorScheme colorScheme) {
    final controller = context.read<NotesListController>();
    final bool hasAnyTagAssigned = controller.selectedNoteIds.any(
      (id) => controller.repository.getNoteById(id)?.categoryId != null,
    );

    if (controller.allCategories.isEmpty && !hasAnyTagAssigned) {
      AppSnackBar.error(context, 'Henüz bir etiketiniz bulunmamaktadır.');
      return;
    }

    String? commonCategoryId;
    if (controller.selectedNoteIds.isNotEmpty) {
      final firstCat = controller.repository
          .getNoteById(controller.selectedNoteIds.first)
          ?.categoryId;
      final allSame = controller.selectedNoteIds.every(
        (id) => controller.repository.getNoteById(id)?.categoryId == firstCat,
      );
      if (allSame) commonCategoryId = firstCat;
    }

    showDialog(
      context: context,
      builder: (ctx) => NoteBulkAssignDialog(
        selectedNoteIds: controller.selectedNoteIds.toList(),
        allCategories: controller.allCategories,
        repository: controller.repository,
        commonCategoryId: commonCategoryId,
        hasAnyTagAssigned: hasAnyTagAssigned,
        onDone: controller.clearSelection,
      ),
    );
  }
}
