import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
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
    // Sadece isSelectionMode için dinle (PopScope ve FAB için yeterli)
    final isSelectionMode = context.select<NotesListController, bool>(
      (c) => c.isSelectionMode,
    );

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isSelectionMode) {
          context.read<NotesListController>().clearSelection();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: _buildAppBar(),
          body: Selector<NotesListController, (bool, bool)>(
            // isReady VE isSelectionMode her ikisi body rebuild'ini tetiklemeli;
            // aksi takdirde SearchBar/FilterChips göster-gizle mantığı çalışmaz.
            selector: (_, c) => (c.isReady, c.isSelectionMode),
            builder: (context, data, _) {
              final isReady = data.$1;
              final selMode = data.$2;
              if (!isReady) return const Center(child: CircularProgressIndicator());
              return Stack(
                children: [
                  Column(
                    children: [
                      if (!selMode) _SearchBarSection(
                        searchController: _searchController,
                      ),
                      if (!selMode) _FilterChipsSection(
                        onShowDeleteDialog: (cat) =>
                            _showDeleteCategoryDialog(context, cat),
                        onShowCreateDialog: () =>
                            _showCreateCategoryDialog(context),
                      ),
                      Expanded(
                        child: _NotesBodySection(
                          onOpenNote: (id) => _openNote(context, id),
                        ),
                      ),
                    ],
                  ),
                  _BottomBarSection(
                    colorScheme: colorScheme,
                    onShowBulkAssign: () =>
                        _showBulkAssignTagDialog(context, colorScheme),
                    onConfirmDelete: () =>
                        _confirmAndDeleteSelected(context),
                  ),
                ],
              );
            },
          ),
          floatingActionButton:
              isSelectionMode ? null : _buildFab(context, colorScheme),
        ),
      ),
    );
  }


  // AppBar: selection + grid toggle + seçim sayısı değişince rebuild eder
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Selector<NotesListController, (bool, bool, bool, int)>(
        selector: (_, c) => (
          c.isSelectionMode,
          c.isReady,
          c.isGridView,
          c.selectedNoteIds.length, // seçim sayısı değişince AppBar güncellenir
        ),
        builder: (context, data, _) {
          final c = context.read<NotesListController>();
          return NotesAppBar(
            isSelectionMode: data.$1,
            isReady: data.$2,
            isGridView: data.$3,
            selectedCount: data.$4,
            visibleNotes: c.visibleNotes,
            selectedNoteIds: c.selectedNoteIds,
            onClearSelection: c.clearSelection,
            onSelectAll: c.selectAll,
            onToggleGridView: c.toggleGridView,
          );
        },
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
        existingCategories: controller.allCategories,
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

// ─── Granular Selector Widget'ları ──────────────────────────────────────────────────────
//
// Her widget kendi slice'na abone olur; diğer slice değiştiğinde rebuild etmez.

/// Arama kutusu: Sadece [searchQuery] değişince rebuild eder.
class _SearchBarSection extends StatelessWidget {
  const _SearchBarSection({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Selector<NotesListController, String>(
      selector: (_, c) => c.searchQuery,
      builder: (context, query, _) {
        final c = context.read<NotesListController>();
        return NotesSearchBar(
          controller: searchController,
          searchQuery: query,
          onChanged: c.setSearchQuery,
          onClear: () {
            searchController.clear();
            c.setSearchQuery('');
          },
        );
      },
    );
  }
}

/// Filtre chip'leri: Sadece [selectedFilterId] veya [allCategories] değişince rebuild eder.
class _FilterChipsSection extends StatelessWidget {
  const _FilterChipsSection({
    required this.onShowDeleteDialog,
    required this.onShowCreateDialog,
  });

  final void Function(NoteCategoryModel) onShowDeleteDialog;
  final VoidCallback onShowCreateDialog;

  @override
  Widget build(BuildContext context) {
    return Selector<NotesListController, (String?, List<NoteCategoryModel>)>(
      // List referansını doğrudan al; unmodifiable() her çağrıda yeni nesne üretir
      // ve Selector'daki == karşılaştırmasını her zaman false yapar.
      selector: (_, c) => (c.selectedFilterId, c.allCategories),
      builder: (context, data, _) {
        final c = context.read<NotesListController>();
        return NotesFilterChips(
          selectedFilterId: data.$1,
          categories: data.$2,
          onFilterSelected: c.setFilter,
          onCategoryLongPressed: onShowDeleteDialog,
          onAddCategory: onShowCreateDialog,
        );
      },
    );
  }
}

/// Not listesi/grid: Sadece [visibleNotes], [isGridView], [searchQuery],
/// [isSelectionMode] ve [selectedNoteIds] değişince rebuild eder.
class _NotesBodySection extends StatelessWidget {
  const _NotesBodySection({
    required this.onOpenNote,
  });

  final void Function(String? id) onOpenNote;

  @override
  Widget build(BuildContext context) {
    return Selector<NotesListController,
        (List<NoteModel>, bool, String, bool, int)>(
      // Set<String> equality her zaman false döner (referans); bunun yerine
      // count (int) kullanılır. Gerçek set, builder içinde context.read ile alınır.
      selector: (_, c) => (
        c.visibleNotes,
        c.isGridView,
        c.searchQuery,
        c.isSelectionMode,
        c.selectedNoteIds.length,
      ),
      builder: (context, data, _) {
        final notes = data.$1;
        final isGrid = data.$2;
        final searchQuery = data.$3;
        final isSelectionMode = data.$4;
        // Count değişince rebuild tetiklendi; gerçek set'i builder'da al.
        final c = context.read<NotesListController>();
        final selectedIds = c.selectedNoteIds;

        if (notes.isEmpty) {
          return NotesEmptyState(
            isSearching: searchQuery.isNotEmpty,
            isFiltering: c.selectedFilterId != null,
            searchQuery: searchQuery,
          );
        }

        if (isGrid) {
          return MasonryGridView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            gridDelegate:
                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: notes.length,
            itemBuilder: (context, index) => RepaintBoundary(
              child: NoteCard(
                note: notes[index],
                isGrid: true,
                isSelected: selectedIds.contains(notes[index].id),
                isSelectionMode: isSelectionMode,
                searchQuery: searchQuery,
                onTap: () {
                  if (isSelectionMode) {
                    c.toggleSelection(notes[index].id);
                  } else {
                    onOpenNote(notes[index].id);
                  }
                },
                onLongPress: () => c.toggleSelection(notes[index].id),
              ),
            ),
          );
        }

        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: notes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => RepaintBoundary(
            child: NoteCard(
              note: notes[index],
              isGrid: false,
              isSelected: selectedIds.contains(notes[index].id),
              isSelectionMode: isSelectionMode,
              searchQuery: searchQuery,
              onTap: () {
                if (isSelectionMode) {
                  c.toggleSelection(notes[index].id);
                } else {
                  onOpenNote(notes[index].id);
                }
              },
              onLongPress: () => c.toggleSelection(notes[index].id),
            ),
          ),
        );
      },
    );
  }
}

/// Alt action bar: Sadece selection state değişince rebuild eder.
class _BottomBarSection extends StatelessWidget {
  const _BottomBarSection({
    required this.colorScheme,
    required this.onShowBulkAssign,
    required this.onConfirmDelete,
  });

  final ColorScheme colorScheme;
  final VoidCallback onShowBulkAssign;
  final VoidCallback onConfirmDelete;

  @override
  Widget build(BuildContext context) {
    return Selector<NotesListController, (bool, bool)>(
      selector: (_, c) => (c.isSelectionMode, c.selectedNotesAreAllPinned),
      builder: (context, data, _) {
        final c = context.read<NotesListController>();
        return NotesBottomActionBar(
          isVisible: data.$1,
          allPinned: data.$2,
          onHide: c.clearSelection,
          onTogglePin: c.togglePinSelected,
          onMoveTag: onShowBulkAssign,
          onDelete: onConfirmDelete,
        );
      },
    );
  }
}
