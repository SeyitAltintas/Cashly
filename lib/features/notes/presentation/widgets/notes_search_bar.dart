import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Notlar listesi için arama kutusu widget'ı.
///
/// [controller] ve [searchQuery] dışarıdan sağlanır.
/// Metin değiştiğinde [onChanged], temizlendiğinde [onClear] çağrılır.
class NotesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const NotesSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: context.l10n.searchNotes,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            size: 22,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: onClear,
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
        onChanged: onChanged,
      ),
    );
  }
}
