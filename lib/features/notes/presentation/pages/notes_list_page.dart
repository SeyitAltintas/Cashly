import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/repositories/note_category_repository.dart';
import 'package:cashly/features/notes/presentation/widgets/note_card.dart';
import 'package:cashly/features/notes/presentation/widgets/notes_empty_state.dart';
import 'package:cashly/features/notes/presentation/widgets/notes_search_bar.dart';
import 'package:cashly/features/notes/presentation/widgets/note_create_category_dialog.dart';
import 'package:cashly/features/notes/presentation/widgets/note_category_delete_dialog.dart';
import 'package:cashly/features/notes/presentation/widgets/note_bulk_assign_dialog.dart';
import 'package:cashly/features/notes/presentation/widgets/notes_filter_chips.dart';
import 'package:cashly/features/notes/presentation/widgets/notes_bottom_action_bar.dart';
import 'package:cashly/features/notes/presentation/widgets/notes_app_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'note_editor_page.dart';

/// Kayıtlı notların listelendiği sayfa.
///
/// Hive box listenable'ı ile reaktif olarak güncellenir —
/// editor'dan dönüldüğünde ekstra fetch gerekmez.
class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final NoteRepository _repository = NoteRepository();
  final NoteCategoryRepository _categoryRepository = NoteCategoryRepository();
  bool _isReady = false;
  List<NoteCategoryModel> _allCategories = [];

  String? _selectedFilterId;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _selectedNoteIds = {};
  bool get _isSelectionMode => _selectedNoteIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNoteIds.contains(id)) {
        _selectedNoteIds.remove(id);
      } else {
        _selectedNoteIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
    });
  }

  void _selectAll(List<NoteModel> notes) {
    if (notes.isEmpty) return;
    setState(() {
      final allSelected = notes.every((n) => _selectedNoteIds.contains(n.id));
      if (allSelected) {
        // Görünür notların tümü seçiliyse, sadece onları seçimden çıkar
        for (final n in notes) {
          _selectedNoteIds.remove(n.id);
        }
      } else {
        // Tüm görünür notları seçime ekle
        _selectedNoteIds.addAll(notes.map((n) => n.id));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  String _toTurkishLowerCase(String value) {
    return value.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
  }

  String _extractPlainText(String deltaJson) {
    try {
      final list = jsonDecode(deltaJson) as List;
      final buffer = StringBuffer();
      for (final item in list) {
        if (item is Map && item['insert'] is String) {
          buffer.write(item['insert']);
        }
      }
      return _toTurkishLowerCase(buffer.toString());
    } catch (e) {
      return _toTurkishLowerCase(deltaJson);
    }
  }

  /// Mevcut arama ve filtre durumuna göre görünen notları döndürür.
  /// [_selectAll] ve [_buildAppBar] bununla çalışmalı — yoksa arama
  /// modundayken görünmeyen notlar da seçilir (EC-SELECT-FILTER).
  List<NoteModel> _getVisibleNotes() {
    List<NoteModel> notes = _repository.getAllNotes();
    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final titleMatch = _toTurkishLowerCase(
          note.title,
        ).contains(_searchQuery);
        final contentMatch = _extractPlainText(
          note.deltaJson,
        ).contains(_searchQuery);
        return titleMatch || contentMatch;
      }).toList();
    }
    if (_selectedFilterId == 'pinned') {
      notes = notes.where((note) => note.isPinned).toList();
    } else if (_selectedFilterId != null) {
      notes = notes
          .where((note) => note.categoryId == _selectedFilterId)
          .toList();
    }
    return notes;
  }

  Future<void> _initRepository() async {
    await _repository.init();
    await _categoryRepository.init();
    if (mounted) {
      setState(() {
        _allCategories = _categoryRepository.getAllCategories();
        _isReady = true;
      });
    }
  }

  // ─── Navigasyon ─────────────────────────────────────────────────────────

  Future<void> _openNote(String? noteId) async {
    final tag = noteId != null ? 'note_hero_$noteId' : 'note_hero_new';
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(noteId: noteId, heroTag: tag),
      ),
    );
    // Editörden döndükten sonra kategori listesini ve notları yenile.
    if (mounted) {
      setState(() {
        _allCategories = _categoryRepository.getAllCategories();
      });
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  // ─── Build ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    bool allPinned = false;
    if (_isSelectionMode) {
      final selectedNotes = _repository.getAllNotes().where(
        (n) => _selectedNoteIds.contains(n.id),
      );
      allPinned =
          selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: NotesAppBar(
          isSelectionMode: _isSelectionMode,
          isReady: _isReady,
          selectedCount: _selectedNoteIds.length,
          visibleNotes: _getVisibleNotes(),
          selectedNoteIds: _selectedNoteIds,
          repository: _repository,
          onClearSelection: _clearSelection,
          onSelectAll: () => _selectAll(_getVisibleNotes()),
        ),
        body: _isReady
            ? Stack(
                children: [
                  Column(
                    children: [
                      if (!_isSelectionMode)
                        NotesSearchBar(
                          controller: _searchController,
                          searchQuery: _searchQuery,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = _toTurkishLowerCase(value);
                            });
                          },
                          onClear: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                      if (!_isSelectionMode)
                        NotesFilterChips(
                          selectedFilterId: _selectedFilterId,
                          categories: _allCategories,
                          onFilterSelected: (id) =>
                              setState(() => _selectedFilterId = id),
                          onCategoryLongPressed: _showDeleteCategoryDialog,
                          onAddCategory: _showCreateCategoryDialog,
                        ),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                  NotesBottomActionBar(
                    isVisible: _isSelectionMode,
                    allPinned: allPinned,
                    onHide: _clearSelection,
                    onTogglePin: () async {
                      final ids = _selectedNoteIds.toList();
                      await _repository.setPinStateForNotes(ids, !allPinned);
                      if (mounted) setState(() {});
                    },
                    onMoveTag: () => _showBulkAssignTagDialog(colorScheme),
                    onDelete: () => _confirmAndDeleteSelected(),
                  ),
                ],
              )
            : _buildLoading(),
        floatingActionButton: _isSelectionMode ? null : _buildFab(colorScheme),
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<Box>(
      valueListenable: _repository.listenable(),
      builder: (context, box, _) {
        final notes = _getVisibleNotes();

        final isGrid = _repository.isGridView;

        if (notes.isEmpty) {
          return NotesEmptyState(
            isSearching: _searchQuery.isNotEmpty,
            isFiltering: _selectedFilterId != null,
            searchQuery: _searchQuery,
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
              isSelected: _selectedNoteIds.contains(notes[index].id),
              isSelectionMode: _isSelectionMode,
              searchQuery: _searchQuery,
              onTap: () {
                if (_isSelectionMode) {
                  _toggleSelection(notes[index].id);
                } else {
                  _openNote(notes[index].id);
                }
              },
              onLongPress: () => _toggleSelection(notes[index].id),
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
            isSelected: _selectedNoteIds.contains(notes[index].id),
            isSelectionMode: _isSelectionMode,
            searchQuery: _searchQuery,
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(notes[index].id);
              } else {
                _openNote(notes[index].id);
              }
            },
            onLongPress: () => _toggleSelection(notes[index].id),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildFab(ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      heroTag: 'note_hero_new',
      onPressed: () => _openNote(null),
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

  Future<void> _confirmAndDeleteSelected() async {
    final ids = _selectedNoteIds.toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.warning),
        content: Text('${ids.length} notu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _clearSelection();
      await _repository.deleteNotes(ids);
      if (mounted) {
        AppSnackBar.success(context, context.l10n.noteDeleteConfirm);
      }
    }
  }

  void _showDeleteCategoryDialog(NoteCategoryModel cat) {
    showDialog(
      context: context,
      builder: (_) => NoteCategoryDeleteDialog(
        category: cat,
        onConfirmDelete: () async {
          await _categoryRepository.deleteCategory(cat.id);
          await _repository.removeCategoryFromNotes(cat.id);
          if (!mounted) return;
          setState(() {
            if (_selectedFilterId == cat.id) _selectedFilterId = null;
            _allCategories = _categoryRepository.getAllCategories();
          });
          if (!mounted) return;
          AppSnackBar.success(context, 'Kategori silindi');
        },
      ),
    );
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => NoteCreateCategoryDialog(
        onCategoryCreated: (newCat) async {
          await _categoryRepository.saveCategory(newCat);
          if (mounted) {
            setState(() {
              _allCategories = _categoryRepository.getAllCategories();
            });
          }
        },
      ),
    );
  }

  void _showBulkAssignTagDialog(ColorScheme colorScheme) {
    final bool hasAnyTagAssigned = _selectedNoteIds.any(
      (id) => _repository.getNoteById(id)?.categoryId != null,
    );

    if (_allCategories.isEmpty && !hasAnyTagAssigned) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Henüz bir etiketiniz bulunmamaktadır.');
      }
      return;
    }

    String? commonCategoryId;
    if (_selectedNoteIds.isNotEmpty) {
      final firstCat = _repository
          .getNoteById(_selectedNoteIds.first)
          ?.categoryId;
      final allSame = _selectedNoteIds.every(
        (id) => _repository.getNoteById(id)?.categoryId == firstCat,
      );
      if (allSame) commonCategoryId = firstCat;
    }

    showDialog(
      context: context,
      builder: (_) => NoteBulkAssignDialog(
        selectedNoteIds: _selectedNoteIds.toList(),
        allCategories: _allCategories,
        repository: _repository,
        commonCategoryId: commonCategoryId,
        hasAnyTagAssigned: hasAnyTagAssigned,
        onDone: _clearSelection,
      ),
    );
  }
}
