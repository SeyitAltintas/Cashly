import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Seçim modunda gösterilen, toplu işlem butonlarını içeren alt aksiyon çubuğu.
///
/// [isVisible] true olduğunda animasyonla yukarı çıkar.
/// [allPinned] seçili notların tümü sabitlenmişse true.
/// Tüm aksiyonlar callback ile üst katmana iletilir.
class NotesBottomActionBar extends StatelessWidget {
  final bool isVisible;
  final bool allPinned;
  final VoidCallback onHide;
  final VoidCallback onTogglePin;
  final VoidCallback onMoveTag;
  final VoidCallback onDelete;

  const NotesBottomActionBar({
    super.key,
    required this.isVisible,
    required this.allPinned,
    required this.onHide,
    required this.onTogglePin,
    required this.onMoveTag,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    const barHeight = 72.0;
    final totalHeight = barHeight + bottomPadding;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      bottom: isVisible ? 0 : -totalHeight,
      left: 0,
      right: 0,
      height: totalHeight,
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
            _buildAction(
              icon: Icons.lock_outline_rounded,
              label: 'Gizle',
              color: iconColor,
              onTap: onHide,
            ),
            _buildAction(
              icon: allPinned
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              label: allPinned ? context.l10n.unpinNote : context.l10n.pinNote,
              color: iconColor,
              onTap: onTogglePin,
            ),
            _buildAction(
              icon: Icons.drive_file_move_outline,
              label: 'Şuraya taşı',
              color: iconColor,
              onTap: onMoveTag,
            ),
            _buildAction(
              icon: Icons.delete_outline_rounded,
              label: context.l10n.delete,
              color: iconColor,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction({
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
}
