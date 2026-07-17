import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';

/// Notlar listesi AppBar'ı.
///
/// İki mod destekler:
/// - **Normal mod**: Başlık + grid/list toggle
/// - **Seçim modu**: Kapatma + seçim sayısı + tümünü seç/bırak
class NotesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final bool isReady;
  final int selectedCount;
  final List<NoteModel> visibleNotes;
  final Set<String> selectedNoteIds;
  final NoteRepository repository;
  final VoidCallback onClearSelection;
  final VoidCallback onSelectAll;

  const NotesAppBar({
    super.key,
    required this.isSelectionMode,
    required this.isReady,
    required this.selectedCount,
    required this.visibleNotes,
    required this.selectedNoteIds,
    required this.repository,
    required this.onClearSelection,
    required this.onSelectAll,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isSelectionMode) {
      final allSelected =
          visibleNotes.isNotEmpty &&
          visibleNotes.every((n) => selectedNoteIds.contains(n.id));

      return AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: onClearSelection,
        ),
        title: Text(
          context.l10n.notesSelectedCount(selectedCount.toString()),
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
              allSelected
                  ? Icons.deselect_rounded
                  : Icons.select_all_rounded,
              size: 22,
            ),
            onPressed: onSelectAll,
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
        if (isReady)
          ValueListenableBuilder<Box>(
            valueListenable: repository.listenable(),
            builder: (context, box, _) {
              final isGrid = repository.isGridView;
              return IconButton(
                icon: Icon(
                  isGrid ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
                  size: 22,
                ),
                onPressed: () => repository.setGridView(!isGrid),
              );
            },
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}
