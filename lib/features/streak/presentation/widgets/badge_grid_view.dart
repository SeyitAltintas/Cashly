import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../data/constants/streak_badges.dart';
import '../controllers/streak_controller.dart';

/// Rozet grid'ini gösteren widget — const item builder ile optimize edilmiş
class BadgeGridView extends StatelessWidget {
  final StreakController controller;
  final void Function(BuildContext, StreakBadge, bool) onBadgeTap;

  const BadgeGridView({
    super.key,
    required this.controller,
    required this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: controller.allBadges.length,
      itemBuilder: (context, index) {
        final badge = controller.allBadges[index];
        final isEarned = controller.isBadgeEarned(badge);
        return _BadgeItem(
          badge: badge,
          isEarned: isEarned,
          onTap: () => onBadgeTap(context, badge, isEarned),
        );
      },
    );
  }
}

/// Tek rozet kartı — const constructor ile rebuild optimize edildi
class _BadgeItem extends StatelessWidget {
  final StreakBadge badge;
  final bool isEarned;
  final VoidCallback onTap;

  const _BadgeItem({
    required this.badge,
    required this.isEarned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEarned
              ? badge.color.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned
                ? badge.color.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.icon,
              color: isEarned
                  ? badge.color
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              badge.emoji,
              style: TextStyle(fontSize: 16, color: isEarned ? null : Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              '${badge.requiredStreak}${context.l10n.dShort}',
              style: TextStyle(
                fontSize: 10,
                color: isEarned
                    ? badge.color
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
