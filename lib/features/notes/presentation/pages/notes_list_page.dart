import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/presentation/controllers/notes_list_controller.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:collection/collection.dart';

import 'note_editor_page.dart';
import 'trash_notes_page.dart';
import 'secure_notes_page.dart';
import '../widgets/note_card.dart';
import '../widgets/notes_empty_state.dart';
import '../widgets/notes_search_bar.dart';
import '../widgets/note_create_category_dialog.dart';
import '../widgets/note_category_delete_dialog.dart';
import '../widgets/note_bulk_assign_dialog.dart';
import '../widgets/notes_filter_chips.dart';
import '../widgets/notes_bottom_action_bar.dart';
import '../widgets/notes_app_bar.dart';
import '../widgets/pin_input_dialog.dart';

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
  double _overscroll = 0.0;
  bool _hasTriggered = false;

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

  Future<void> _openTrash(BuildContext context) async {
    final controller = context.read<NotesListController>();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TrashNotesPage()));
    // Çöp kutusundan not geri yüklenmiş veya silinmiş olabilir
    if (mounted) {
      // _fetchAndCacheAllNotes() already called via _boxListener but let's notify listeners if needed
      controller.refreshCategories();
    }
  }

  Future<void> _openSecureNotes(BuildContext context) async {
    final controller = context.read<NotesListController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SecureNotesPage(),
      ),
    );
    if (mounted) {
      controller.refreshCategories();
    }
  }

  Future<void> _onSecureSelectedPressed(BuildContext context) async {
    final controller = context.read<NotesListController>();
    if (controller.hasSecurePin) {
      final pin = await showDialog<String>(
        context: context,
        builder: (ctx) => PinInputDialog(
          onVerify: (enteredPin) async {
            final isCorrect = await controller.repository.unlockSecureNotes(enteredPin);
            if (isCorrect) {
              await controller.repository.closeSecureNotes();
            }
            return isCorrect;
          },
        ),
      );
      if (pin != null && context.mounted) {
        final success = await controller.secureSelected(pin);
        if (success && context.mounted) {
          AppSnackBar.success(context, 'Seçilen notlar başarıyla gizlendi.');
        }
      }
    } else {
      final newPin = await showDialog<String>(
        context: context,
        builder: (ctx) => const PinInputDialog(
          isCreating: true,
          title: 'Yeni PIN Oluştur',
        ),
      );
      if (newPin != null && context.mounted) {
        await controller.createSecurePinAndSecureSelected(newPin);
        if (context.mounted) {
          AppSnackBar.success(context, 'Güvenlik PIN\'i oluşturuldu ve notlar gizlendi.');
        }
      }
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    final pixels = notification.metrics.pixels;
    if (pixels < 0) {
      final currentOverscroll = -pixels;
      setState(() {
        _overscroll = currentOverscroll;
      });
      // Only change trigger state if the user is actively dragging
      if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
        if (currentOverscroll >= 100.0) {
          if (!_hasTriggered) {
            HapticFeedback.heavyImpact();
            _hasTriggered = true;
          }
        } else if (currentOverscroll < 30.0) {
          _hasTriggered = false;
        }
      }
    } else {
      if (_overscroll != 0.0) {
        setState(() {
          _overscroll = 0.0;
        });
      }
      // If user drags list back to normal scrolling area, cancel trigger
      if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
        _hasTriggered = false;
      }
    }

    if (notification is ScrollEndNotification) {
      if (_hasTriggered) {
        _hasTriggered = false;
        _overscroll = 0.0;
        _openSecureNotes(context);
      }
    }

    return false;
  }

  Widget _buildLockIndicator() {
    const threshold = 100.0;
    final progress = (_overscroll / threshold).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: Opacity(
        opacity: progress,
        child: Container(
          height: _overscroll.clamp(0.0, 120.0),
          alignment: Alignment.center,
          child: OverflowBox(
            minHeight: 0,
            maxHeight: 120,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  progress >= 1.0 ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  color: progress >= 1.0 ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 28 + (progress * 8),
                ),
                const SizedBox(height: 6),
                Text(
                  progress >= 1.0 ? 'Gizli Notları Açmak İçin Bırakın' : 'Güvenli Kilit İçin Çekin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: progress >= 1.0 ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              if (!isReady) {
                return const Center(child: CircularProgressIndicator());
              }
              return Stack(
                children: [
                  Column(
                    children: [
                      if (!selMode)
                        _SearchBarSection(searchController: _searchController),
                      if (!selMode)
                        _FilterChipsSection(
                          onShowDeleteDialog: (cat) =>
                              _showDeleteCategoryDialog(context, cat),
                          onShowCreateDialog: () =>
                              _showCreateCategoryDialog(context),
                        ),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NotificationListener<ScrollNotification>(
                              onNotification: _handleScrollNotification,
                              child: _NotesBodySection(
                                onOpenNote: (id) => _openNote(context, id),
                              ),
                            ),
                            if (_overscroll > 0)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: _buildLockIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _BottomBarSection(
                    colorScheme: colorScheme,
                    onShowBulkAssign: () =>
                        _showBulkAssignTagDialog(context, colorScheme),
                    onConfirmDelete: () => _confirmAndDeleteSelected(context),
                    onSecure: () => _onSecureSelectedPressed(context),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: isSelectionMode
              ? null
              : _buildFab(context, colorScheme),
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
            onOpenTrash: () => _openTrash(context),
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
    if (count == 0) return;

    final selectedIds = controller.selectedNoteIds.toList();
    await controller.deleteSelected();

    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      AppSnackBar.deleted(
        context,
        '$count adet not çöp kutusuna taşındı',
        onUndo: () async {
          await controller.repository.restoreNotes(selectedIds);
          AppSnackBar.successWithMessenger(messenger, 'Geri alındı');
        },
      );
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
  const _NotesBodySection({required this.onOpenNote});

  final void Function(String? id) onOpenNote;

  @override
  Widget build(BuildContext context) {
    return Selector<
      NotesListController,
      (List<NoteModel>, bool, String, bool, Set<String>)
    >(
      // Referans eşitsizliği sorununu çözmek için SetEquality ile özel shouldRebuild tanımlanmıştır.
      selector: (_, c) => (
        c.visibleNotes,
        c.isGridView,
        c.searchQuery,
        c.isSelectionMode,
        c.selectedNoteIds,
      ),
      shouldRebuild: (prev, next) {
        return prev.$1 != next.$1 ||
            prev.$2 != next.$2 ||
            prev.$3 != next.$3 ||
            prev.$4 != next.$4 ||
            !const SetEquality().equals(prev.$5, next.$5);
      },
      builder: (context, data, _) {
        final notes = data.$1;
        final isGrid = data.$2;
        final searchQuery = data.$3;
        final isSelectionMode = data.$4;
        final selectedIds = data.$5;
        final c = context.read<NotesListController>();

        if (notes.isEmpty) {
          return NotesEmptyState(
            isSearching: searchQuery.isNotEmpty,
            isFiltering: c.selectedFilterId != null,
            searchQuery: searchQuery,
          );
        }

        Widget child;
        if (isGrid) {
          child = MasonryGridView.builder(
            key: const ValueKey('grid_view'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
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
        } else {
          child = ListView.separated(
            key: const ValueKey('list_view'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: child,
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
    required this.onSecure,
  });

  final ColorScheme colorScheme;
  final VoidCallback onShowBulkAssign;
  final VoidCallback onConfirmDelete;
  final VoidCallback onSecure;

  @override
  Widget build(BuildContext context) {
    return Selector<NotesListController, (bool, bool)>(
      selector: (_, c) => (c.isSelectionMode, c.selectedNotesAreAllPinned),
      builder: (context, data, _) {
        final c = context.read<NotesListController>();
        return NotesBottomActionBar(
          isVisible: data.$1,
          allPinned: data.$2,
          onHide: onSecure,
          onTogglePin: c.togglePinSelected,
          onMoveTag: onShowBulkAssign,
          onDelete: onConfirmDelete,
        );
      },
    );
  }
}
