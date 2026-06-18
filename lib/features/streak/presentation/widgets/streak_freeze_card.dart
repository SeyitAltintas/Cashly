import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/constants/color_constants.dart';
import '../../data/constants/streak_badges.dart';
import '../../data/models/streak_model.dart';
import '../controllers/streak_controller.dart';

/// Dondurucu (Freeze) yönetim kartı
class StreakFreezeCard extends StatelessWidget {
  final StreakData streakData;
  final int nextFreezeIn;

  const StreakFreezeCard({
    super.key,
    required this.streakData,
    required this.nextFreezeIn,
  });

  @override
  Widget build(BuildContext context) {
    const freezeColor = Color(0xFF00BCD4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: freezeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: freezeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.ac_unit, color: freezeColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.streakFreeze,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.protectsStreakEvenIfSkipped,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: freezeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ac_unit, color: freezeColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${streakData.freezeCount}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: freezeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (streakData.usedFreezeToday)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorConstants.yesil.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.yesil.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: ColorConstants.yesil, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.streakFreezeUsedToday,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.yesil,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.nextFreezeIn(nextFreezeIn),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Sonraki rozet ilerleme bölümü
class StreakNextBadgeSection extends StatelessWidget {
  final StreakController controller;

  const StreakNextBadgeSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final badge = controller.nextBadge!;
    final remaining = controller.daysToNextBadge;
    final progress = controller.nextBadgeProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badge.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(badge.icon, color: badge.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.nextBadgeIs(badge.localizedName(context)),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.daysRemainingForBadge(remaining),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: badge.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(badge.color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
