import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';

/// Tek bir notu gösteren kart widget'ı.
///
/// Liste (list) ve ızgara (grid) görünümlerini destekler.
/// Arama sorgusunu vurgular (highlight), pin ikonunu gösterir.
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isGrid;
  final bool isSelected;
  final bool isSelectionMode;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    this.isGrid = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.searchQuery = '',
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
                          : Colors.black.withValues(alpha: 0.08)),
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
    final snippet = note.snippet;

    final noteColor = note.color != null ? Color(note.color!) : null;
    final isDarkBackground =
        noteColor != null && noteColor.computeLuminance() < 0.5;

    final Color textColor = noteColor != null
        ? (isDarkBackground ? Colors.white : Colors.black87)
        : colorScheme.onSurface;

    final Color subtitleColor = noteColor != null
        ? (isDarkBackground
              ? Colors.white70
              : Colors.black87.withValues(alpha: 0.7))
        : colorScheme.onSurface.withValues(alpha: 0.7);

    final Color dateColor = noteColor != null
        ? (isDarkBackground ? Colors.white70 : Colors.black54)
        : colorScheme.onSurface.withValues(alpha: 0.45);

    final Color dividerColor = noteColor != null
        ? (isDarkBackground
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.08))
        : colorScheme.onSurface.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildHighlightedText(
                title,
                searchQuery,
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
                colorScheme,
                maxLines: isGrid ? 2 : 1,
              ),
            ),
            if (note.isPinned) ...[
              const SizedBox(width: 8),
              Icon(Icons.push_pin_rounded, size: 16, color: subtitleColor),
            ],
          ],
        ),
        if (snippet.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 24,
            decoration: BoxDecoration(
              color: dividerColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 8),
          _buildHighlightedText(
            snippet,
            searchQuery,
            TextStyle(
              fontSize: 14,
              height: 1.5,
              color: subtitleColor,
              fontFamily: 'Inter',
            ),
            colorScheme,
            maxLines: isGrid ? 8 : 2,
          ),
        ],
        if (isGrid) const SizedBox(height: 14),
        if (!isGrid) const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.schedule_rounded, size: 13, color: dateColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                context.l10n.noteLastEdited(dateStr),
                style: TextStyle(
                  fontSize: 12,
                  color: dateColor,
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

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle style,
    ColorScheme colorScheme, {
    required int maxLines,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final lowerText = text
        .replaceAll('I', 'ı')
        .replaceAll('İ', 'i')
        .toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final spans = <TextSpan>[];
    int start = 0;
    int index;

    final noteColor = note.color != null ? Color(note.color!) : null;
    final isDarkBackground =
        noteColor != null && noteColor.computeLuminance() < 0.5;

    final highlightStyle = style.copyWith(
      backgroundColor: Colors.yellow.withValues(alpha: 0.4),
      fontWeight: FontWeight.w800,
      color: isDarkBackground
          ? Colors.black87
          : (note.color != null ? Colors.black : colorScheme.primary),
    );

    while ((index = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: highlightStyle,
        ),
      );
      start = index + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }



  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(local.year, local.month, local.day);
    final diff = today.difference(noteDay).inDays;

    if (diff <= 0) {
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
