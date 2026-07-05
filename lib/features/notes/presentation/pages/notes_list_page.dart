import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
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
  bool _isReady = false;

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

  String _extractPlainText(String deltaJson) {
    try {
      final list = jsonDecode(deltaJson) as List;
      final buffer = StringBuffer();
      for (final item in list) {
        if (item is Map && item['insert'] is String) {
          buffer.write(item['insert']);
        }
      }
      return buffer.toString().toLowerCase();
    } catch (e) {
      return deltaJson.toLowerCase();
    }
  }

  Future<void> _initRepository() async {
    await _repository.init();
    if (mounted) setState(() => _isReady = true);
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
    final barHeight = 64.0 + bottomPadding;

    bool allPinned = false;
    if (_isSelectionMode) {
      final selectedNotes = _repository.getAllNotes().where((n) => _selectedNoteIds.contains(n.id));
      allPinned = selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      bottom: _isSelectionMode ? 0 : -barHeight,
      left: 0,
      right: 0,
      height: barHeight,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
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
            TextButton.icon(
              onPressed: () async {
                final ids = _selectedNoteIds.toList();
                final newState = !allPinned;
                _clearSelection();
                await _repository.setPinStateForNotes(ids, newState);
              },
              icon: Icon(allPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded, color: colorScheme.onSurface),
              label: Text(allPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle', style: TextStyle(color: colorScheme.onSurface, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ),
            TextButton.icon(
              onPressed: () async {
                final ids = _selectedNoteIds.toList();
                _clearSelection();
                await _repository.deleteNotes(ids);
                if (mounted) AppSnackBar.success(context, context.l10n.noteDeleteConfirm);
              },
              icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
              label: Text(context.l10n.delete, style: TextStyle(color: colorScheme.error, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ),
          ],
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
          hintText: '${context.l10n.search}...',
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurface.withValues(alpha: 0.5), size: 22),
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
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: _isReady 
          ? Stack(
              children: [
                Column(
                  children: [
                    _buildSearchBar(colorScheme),
                    Expanded(child: _buildBody(colorScheme)),
                  ],
                ),
                _buildBottomActionBar(colorScheme),
              ],
            ) 
          : _buildLoading(),
      floatingActionButton: _isSelectionMode ? null : _buildFab(colorScheme),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    if (_isSelectionMode) {
      final notes = _repository.getAllNotes();
      final allSelected = _selectedNoteIds.length == notes.length && notes.isNotEmpty;
      return AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: _clearSelection,
        ),
        title: Text(
          '${_selectedNoteIds.length} Seçildi',
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
            icon: Icon(allSelected ? Icons.deselect_rounded : Icons.select_all_rounded, size: 22),
            onPressed: () => _selectAll(notes),
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
                icon: Icon(isGrid ? Icons.view_agenda_rounded : Icons.grid_view_rounded, size: 22),
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
            final titleMatch = note.title.toLowerCase().contains(_searchQuery);
            final contentMatch = _extractPlainText(note.deltaJson).contains(_searchQuery);
            return titleMatch || contentMatch;
          }).toList();
        }

        final isGrid = _repository.isGridView;

        if (notes.isEmpty) return _buildEmptyState(colorScheme);

        if (isGrid) {
          return MasonryGridView.builder(
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
        style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
      ),
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
                        : Colors.black.withValues(alpha: 0.08)), // Pastel renklerde belli olması için ince ve saydam bir siyah
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  child: isGrid 
                    ? _buildContent(context, colorScheme)
                    : Row(
                        children: [
                          Expanded(child: _buildContent(context, colorScheme)),
                          if (!isSelectionMode)
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
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
                        color: isSelected ? colorScheme.primary : colorScheme.surface,
                        border: Border.all(
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: isSelected ? colorScheme.onPrimary : Colors.transparent,
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
    final title = note.title.isEmpty
        ? context.l10n.noteUntitled
        : note.title;

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
                  color: note.color != null ? Colors.black87 : colorScheme.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (note.isPinned) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.push_pin_rounded,
                size: 16,
                color: note.color != null ? Colors.black87.withValues(alpha: 0.7) : colorScheme.onSurface.withValues(alpha: 0.7),
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
              color: note.color != null ? Colors.black.withValues(alpha: 0.08) : colorScheme.onSurface.withValues(alpha: 0.08),
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
              color: note.color != null ? Colors.black87.withValues(alpha: 0.7) : colorScheme.onSurface.withValues(alpha: 0.7),
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
              color: note.color != null ? Colors.black45 : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                context.l10n.noteLastEdited(dateStr),
                style: TextStyle(
                  fontSize: 12,
                  color: note.color != null ? Colors.black54 : colorScheme.onSurface.withValues(alpha: 0.45),
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
