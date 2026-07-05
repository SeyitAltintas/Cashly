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

  @override
  void initState() {
    super.initState();
    _initRepository();
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

  // ─── Silme ve Seçenekler ────────────────────────────────────────────────

  Future<void> _deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      if (mounted) AppSnackBar.success(context, context.l10n.noteDeleteConfirm);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.l10n.saveFailed);
    }
  }

  void _showNoteOptions(NoteModel note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined),
                title: Text(note.isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  await _repository.togglePin(note.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                title: Text(context.l10n.delete, style: TextStyle(color: colorScheme.error, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteNote(note.id);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: _isReady ? _buildBody(colorScheme) : _buildLoading(),
      floatingActionButton: _buildFab(colorScheme),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
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
        final notes = _repository.getAllNotes();

        final isGrid = _repository.isGridView;

        if (notes.isEmpty) return _buildEmptyState(colorScheme);

        if (isGrid) {
          return MasonryGridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: notes.length,
            itemBuilder: (context, index) => _NoteCard(
              note: notes[index],
              isGrid: true,
              onTap: () => _openNote(notes[index].id),
              onLongPress: () => _showNoteOptions(notes[index]),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: notes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _NoteCard(
            note: notes[index],
            isGrid: false,
            onTap: () => _openNote(notes[index].id),
            onLongPress: () => _showNoteOptions(notes[index]),
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
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NoteCard({
    required this.note,
    this.isGrid = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              border: isDark ? Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ) : null,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: isGrid 
                ? _buildContent(context, colorScheme)
                : Row(
                    children: [
                      Expanded(child: _buildContent(context, colorScheme)),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
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
