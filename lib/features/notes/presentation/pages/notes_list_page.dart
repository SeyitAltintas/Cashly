import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/repositories/note_category_repository.dart';
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
    setState(() {
      if (_selectedNoteIds.length == notes.length) {
        _selectedNoteIds.clear();
      } else {
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
    // Hive listenable otomatik günceller — setState gerekmez.
  }

  // ─── Bottom Action Bar (Toplu İşlem) ────────────────────────────────────

  Widget _buildBottomActionBar(ColorScheme colorScheme) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final barHeight = 72.0 + bottomPadding;

    bool allPinned = false;
    if (_isSelectionMode) {
      final selectedNotes = _repository.getAllNotes().where(
        (n) => _selectedNoteIds.contains(n.id),
      );
      allPinned =
          selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      bottom: _isSelectionMode ? 0 : -barHeight,
      left: 0,
      right: 0,
      height: barHeight,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomAction(
              icon: Icons.lock_outline_rounded,
              label: 'Gizle',
              color: iconColor,
              onTap: () {},
            ),
            _buildBottomAction(
              icon: allPinned
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              label: allPinned ? context.l10n.unpinNote : context.l10n.pinNote,
              color: iconColor,
              onTap: () async {
                final ids = _selectedNoteIds.toList();
                final newState = !allPinned;
                await _repository.setPinStateForNotes(ids, newState);
              },
            ),
            _buildBottomAction(
              icon: Icons.drive_file_move_outline,
              label: 'Şuraya taşı',
              color: iconColor,
              onTap: () {
                _showBulkAssignTagDialog(colorScheme);
              },
            ),
            _buildBottomAction(
              icon: Icons.delete_outline_rounded,
              label: context.l10n.delete,
              color: iconColor,
              onTap: () async {
                final ids = _selectedNoteIds.toList();

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.l10n.warning),
                    content: Text(
                      '${ids.length} notu silmek istediğinize emin misiniz?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(context.l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(context.l10n.delete),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  _clearSelection();
                  await _repository.deleteNotes(ids);
                  if (mounted) {
                    AppSnackBar.success(
                      context,
                      context.l10n.noteDeleteConfirm,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                  color: color,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar(ColorScheme colorScheme) {
    if (_isSelectionMode) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.l10n.searchNotes,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          fontFamily: 'Inter',
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = _toTurkishLowerCase(value);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(colorScheme),
        body: _isReady
            ? Stack(
                children: [
                  Column(
                    children: [
                      _buildSearchBar(colorScheme),
                      _buildFilterChips(colorScheme),
                      Expanded(child: _buildBody(colorScheme)),
                    ],
                  ),
                  _buildBottomActionBar(colorScheme),
                ],
              )
            : _buildLoading(),
        floatingActionButton: _isSelectionMode ? null : _buildFab(colorScheme),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    if (_isSelectionMode) {
      // EC-SELECT-FILTER: Filtrelenmiş/aranmış notları kullan;
      // tüm notları değil sadece görünenleri seç.
      final visibleNotes = _getVisibleNotes();
      final allSelected =
          visibleNotes.isNotEmpty &&
          visibleNotes.every((n) => _selectedNoteIds.contains(n.id));
      return AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: _clearSelection,
        ),
        title: Text(
          context.l10n.notesSelectedCount(_selectedNoteIds.length.toString()),
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
            onPressed: () => _selectAll(visibleNotes),
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
        context.l10n.notesList,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: 'Inter',
        ),
      ),
      centerTitle: false,
      actions: [
        if (_isReady)
          ValueListenableBuilder<Box>(
            valueListenable: _repository.listenable(),
            builder: (context, box, _) {
              final isGrid = _repository.isGridView;
              return IconButton(
                icon: Icon(
                  isGrid ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
                  size: 22,
                ),
                onPressed: () => _repository.setGridView(!isGrid),
              );
            },
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    return ValueListenableBuilder<Box>(
      valueListenable: _repository.listenable(),
      builder: (context, box, _) {
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

        final isGrid = _repository.isGridView;

        if (notes.isEmpty) return _buildEmptyState(colorScheme);

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
            itemBuilder: (context, index) => _NoteCard(
              note: notes[index],
              isGrid: true,
              isSelected: _selectedNoteIds.contains(notes[index].id),
              isSelectionMode: _isSelectionMode,
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
          itemBuilder: (context, index) => _NoteCard(
            note: notes[index],
            isGrid: false,
            isSelected: _selectedNoteIds.contains(notes[index].id),
            isSelectionMode: _isSelectionMode,
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

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.notesEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
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

  Widget _buildFilterChips(ColorScheme colorScheme) {
    if (_isSelectionMode) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: context.l10n.allNotesFilter,
            isSelected: _selectedFilterId == null,
            onSelected: (_) {
              setState(() {
                _selectedFilterId = null;
              });
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: context.l10n.pinnedNotesFilter,
            isSelected: _selectedFilterId == 'pinned',
            onSelected: (_) {
              setState(() {
                _selectedFilterId = 'pinned';
              });
            },
            colorScheme: colorScheme,
          ),

          const SizedBox(width: 8),
          for (final cat in _allCategories) ...[
            GestureDetector(
              onLongPress: () => _showDeleteCategoryDialog(cat),
              child: _buildChip(
                label: cat.name,
                isSelected: _selectedFilterId == cat.id,
                onSelected: (_) {
                  setState(() {
                    _selectedFilterId = cat.id;
                  });
                },
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 8),
          ],
          ActionChip(
            label: Text(
              '+ ${context.l10n.newNoteTag}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            ),
            onPressed: _showCreateCategoryDialog,
            backgroundColor: colorScheme.surface,
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
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

  void _showDeleteCategoryDialog(NoteCategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
            '"${cat.name}" kategorisini silmek istediğinize emin misiniz?\n\nBu kategoriye ait notlar silinmeyecek, sadece kategorisiz kalacaktır.',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
              onPressed: () async {
                Navigator.pop(ctx);
                await _categoryRepository.deleteCategory(cat.id);
                await _repository.removeCategoryFromNotes(cat.id);
                if (!mounted) return;
                setState(() {
                  if (_selectedFilterId == cat.id) _selectedFilterId = null;
                  _allCategories = _categoryRepository.getAllCategories();
                });
                AppSnackBar.success(context, 'Kategori silindi');
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
      },
    );
  }

  void _showCreateCategoryDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                  controller: nameController,
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
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
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
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      final newCat = NoteCategoryModel.create(
                        name: nameController.text.trim(),
                      );
                      await _categoryRepository.saveCategory(newCat);
                      setState(() {
                        _allCategories = _categoryRepository.getAllCategories();
                      });
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.createNoteTag,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
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

    // Basit bir tag seçim dialogu
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              title: Text(
                context.l10n.assignTag,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _allCategories.length,
                        itemBuilder: (context, index) {
                          final cat = _allCategories[index];
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  cat.name,
                                  style: const TextStyle(fontFamily: 'Inter'),
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              final ids = _selectedNoteIds.toList();
                              for (final id in ids) {
                                final note = _repository.getNoteById(id);
                                if (note != null) {
                                  if (note.categoryId != cat.id) {
                                    await _repository.updateNote(
                                      id: note.id,
                                      deltaJson: note.deltaJson,
                                      title: note.title,
                                      color: note.color,
                                      clearColor: note.color == null,
                                      categoryId: cat.id,
                                      originalCreatedAt: note.createdAt,
                                    );
                                  }
                                }
                              }
                              if (!context.mounted) return;
                              _clearSelection();
                              AppSnackBar.success(
                                context,
                                context.l10n.tagAssignedSuccess,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (_selectedNoteIds.any(
                      (id) => _repository.getNoteById(id)?.categoryId != null,
                    )) ...[
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.layers_clear,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          context.l10n.removeCategory,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: colorScheme.error,
                          ),
                        ),
                        onTap: () async {
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          final ids = _selectedNoteIds.toList();
                          for (final id in ids) {
                            final note = _repository.getNoteById(id);
                            if (note != null && note.categoryId != null) {
                              await _repository.updateNote(
                                id: note.id,
                                deltaJson: note.deltaJson,
                                title: note.title,
                                color: note.color,
                                clearColor: note.color == null,
                                categoryId: null,
                                clearCategory: true,
                                originalCreatedAt: note.createdAt,
                              );
                            }
                          }
                          if (!context.mounted) return;
                          _clearSelection();
                          AppSnackBar.success(
                            context,
                            context.l10n.tagAssignedSuccess,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    context.l10n.cancel,
                    style: const TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Not Kartı ──────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isGrid;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NoteCard({
    required this.note,
    this.isGrid = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double borderWidth = isSelected ? 2.0 : 1.0;
    final double horizontalPadding = 16.0 - borderWidth;
    final double verticalPadding = 14.0 - borderWidth;
    final double checkmarkOffset = 12.0 - borderWidth;

    return Hero(
      tag: 'note_hero_${note.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: note.color != null
                  ? Color(note.color!)
                  : (isDark
                        ? colorScheme.surfaceContainerHigh
                        : colorScheme.surfaceContainerLowest),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : (isDark
                          ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                          : Colors.black.withValues(
                              alpha: 0.08,
                            )), // Pastel renklerde belli olması için ince ve saydam bir siyah
                width: borderWidth,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: note.color != null
                        ? Color(note.color!).withValues(alpha: 0.35)
                        : colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: isGrid
                      ? _buildContent(context, colorScheme)
                      : Row(
                          children: [
                            Expanded(
                              child: _buildContent(context, colorScheme),
                            ),
                            if (!isSelectionMode)
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                          ],
                        ),
                ),
                if (isSelectionMode)
                  Positioned(
                    bottom: checkmarkOffset,
                    right: checkmarkOffset,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final title = note.title.isEmpty ? context.l10n.noteUntitled : note.title;

    final dateStr = _formatDate(context, note.updatedAt);

    final snippet = _extractPlainText(note.deltaJson);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: isGrid ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: note.color != null
                      ? Colors.black87
                      : colorScheme.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (note.isPinned) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.push_pin_rounded,
                size: 16,
                color: note.color != null
                    ? Colors.black87.withValues(alpha: 0.7)
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
        if (snippet.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Zarif ayırıcı çizgi
          Container(
            height: 2,
            width: 24,
            decoration: BoxDecoration(
              color: note.color != null
                  ? Colors.black.withValues(alpha: 0.08)
                  : colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            snippet,
            maxLines: isGrid ? 8 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: note.color != null
                  ? Colors.black87.withValues(alpha: 0.7)
                  : colorScheme.onSurface.withValues(alpha: 0.7),
              fontFamily: 'Inter',
            ),
          ),
        ],
        if (isGrid) const SizedBox(height: 14),
        if (!isGrid) const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 13,
              color: note.color != null
                  ? Colors.black45
                  : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                context.l10n.noteLastEdited(dateStr),
                style: TextStyle(
                  fontSize: 12,
                  color: note.color != null
                      ? Colors.black54
                      : colorScheme.onSurface.withValues(alpha: 0.45),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _extractPlainText(String deltaJson) {
    if (deltaJson.isEmpty || deltaJson == '[]') return '';
    try {
      final List<dynamic> ops = jsonDecode(deltaJson);
      final buffer = StringBuffer();
      for (final op in ops) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            buffer.write(insert);
          }
        }
      }
      return buffer.toString().trim();
    } catch (_) {
      return '';
    }
  }

  // Dismissible background removed

  String _formatDate(BuildContext context, DateTime date) {
    // EC-1: toLocal() ile UTC → yerel saat dönüşümü; takvim günü bazlı fark.
    final now = DateTime.now();
    final local = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(local.year, local.month, local.day);
    final diff = today.difference(noteDay).inDays;

    if (diff <= 0) {
      // Bugün veya gelecek tarih (saat farkı düzeltmesi)
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (diff == 1) {
      return context.l10n.yesterday;
    } else if (diff < 7) {
      return context.l10n.daysAgo(diff);
    } else {
      return '${local.day}.${local.month}.${local.year}';
    }
  }
}
