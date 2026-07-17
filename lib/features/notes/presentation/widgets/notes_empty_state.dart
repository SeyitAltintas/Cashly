import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Notlar listesi boş olduğunda gösterilen durum widget'ı.
///
/// Üç farklı senaryo için farklı ikon, başlık ve alt başlık gösterir:
/// - Arama boş sonuç verdi
/// - Filtre boş sonuç verdi
/// - Henüz hiç not yok
class NotesEmptyState extends StatelessWidget {
  final bool isSearching;
  final bool isFiltering;
  final String searchQuery;

  const NotesEmptyState({
    super.key,
    required this.isSearching,
    required this.isFiltering,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final icon = isSearching
        ? Icons.search_off_rounded
        : (isFiltering
              ? Icons.filter_alt_off_rounded
              : Icons.note_add_outlined);

    final title = isSearching
        ? context.l10n.notesSearchEmptyTitle
        : (isFiltering
              ? context.l10n.notesFilterEmptyTitle
              : context.l10n.notesEmptyTitle);

    final subtitle = isSearching
        ? context.l10n.notesSearchEmptySubtitle(searchQuery)
        : (isFiltering
              ? context.l10n.notesFilterEmptySubtitle
              : context.l10n.notesEmptySubtitle);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
