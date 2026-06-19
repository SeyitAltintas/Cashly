import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/constants/streak_badges.dart';
import '../controllers/streak_controller.dart';

/// 9 rank kademesini gösteren grid
/// Kilitli ranklar bulanık/gri görünür, kazanılan ranklar parlak
class BadgeGridView extends StatelessWidget {
  final StreakController controller;
  final void Function(BuildContext, RankTier, bool) onBadgeTap;

  const BadgeGridView({
    super.key,
    required this.controller,
    required this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    const tiers = RankTiers.allTiers;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: tiers.length,
      itemBuilder: (context, index) {
        final tier = tiers[index];
        final isUnlocked = controller.isTierUnlocked(tier);
        final isCurrent = controller.currentRank.level == tier.level;

        return _RankTierCard(
          tier: tier,
          isUnlocked: isUnlocked,
          isCurrent: isCurrent,
          onTap: () => onBadgeTap(context, tier, isUnlocked),
        );
      },
    );
  }
}

class _RankTierCard extends StatelessWidget {
  final RankTier tier;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback onTap;

  const _RankTierCard({
    required this.tier,
    required this.isUnlocked,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isUnlocked
              ? tier.primaryColor.withValues(alpha: 0.1)
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? tier.primaryColor
                : isUnlocked
                    ? tier.primaryColor.withValues(alpha: 0.35)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: tier.glowColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie veya kilitli icon
            if (isUnlocked)
              SizedBox(
                width: 60,
                height: 60,
                child: RepaintBoundary(
                  child: Lottie.asset(
                    tier.lottieAsset,
                    fit: BoxFit.contain,
                    frameRate: const FrameRate(60),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock_outline,
                  size: 28,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.25),
                ),
              ),
            const SizedBox(height: 6),
            // Rank adı
            Text(
              tier.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isUnlocked
                    ? (isCurrent ? tier.primaryColor : Theme.of(context).colorScheme.onSurface)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
              ),
            ),
            // Mevcut rank etiketi
            if (isCurrent) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tier.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Mevcut',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
