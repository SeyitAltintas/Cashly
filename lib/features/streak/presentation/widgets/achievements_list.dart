import 'package:flutter/material.dart';
import '../controllers/streak_controller.dart';
import 'package:cashly/core/constants/color_constants.dart';

/// Başarılar listesini gösteren widget
class AchievementsList extends StatelessWidget {
  final StreakController controller;

  const AchievementsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final achievements = controller.getAchievements(context);

    return Column(
      children: achievements.map((achievement) {
        final isEarned = achievement['earned'] == true;
        return _AchievementItem(achievement: achievement, isEarned: isEarned);
      }).toList(),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Map<String, dynamic> achievement;
  final bool isEarned;

  const _AchievementItem({required this.achievement, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned
              ? ColorConstants.yesil.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEarned
                  ? ColorConstants.yesil.withValues(alpha: 0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: isEarned
                  ? ColorConstants.yesil
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isEarned)
            const Icon(Icons.check_circle, color: ColorConstants.yesil, size: 24)
          else
            Icon(
              Icons.circle_outlined,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              size: 24,
            ),
        ],
      ),
    );
  }
}
