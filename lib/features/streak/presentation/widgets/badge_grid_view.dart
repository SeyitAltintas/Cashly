import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/constants/streak_badges.dart';
import '../controllers/streak_controller.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_container.dart';

/// 9 rank kademesini gösteren grid
/// Kilitli ranklar bulanık/gri görünür, kazanılan ranklar parlak
class BadgeGridView extends StatefulWidget {
  final StreakController controller;
  final void Function(BuildContext, RankTier, bool) onBadgeTap;

  const BadgeGridView({
    super.key,
    required this.controller,
    required this.onBadgeTap,
  });

  @override
  State<BadgeGridView> createState() => _BadgeGridViewState();
}

class _BadgeGridViewState extends State<BadgeGridView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final currentLevel = widget.controller.currentRank.level;
    final currentIndex = (currentLevel - 1).clamp(0, RankTiers.allTiers.length - 1);
    
    // Her kart 110px genişlikte ve 12px boşluğa sahip (toplam 122px).
    // Mevcut kartı ekranın biraz daha ortasına yakın göstermek için - 100px offset uyguluyoruz.
    double initialOffset = (currentIndex * 122.0) - 100.0;
    if (initialOffset < 0) initialOffset = 0.0;
    
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tiers = RankTiers.allTiers;

    return SizedBox(
      height: 110,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: tiers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tier = tiers[index];
          final isUnlocked = widget.controller.isTierUnlocked(tier);
          final isCurrent = widget.controller.currentRank.level == tier.level;

          return SizedBox(
            width: 110,
            child: _RankTierCard(
              tier: tier,
              isUnlocked: isUnlocked,
              isCurrent: isCurrent,
              onTap: () => widget.onBadgeTap(context, tier, isUnlocked),
            ),
          );
        },
      ),
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
    return DashboardCardContainer(
      padding: EdgeInsets.zero,
      onTap: onTap,
      borderWidth: isCurrent ? 2.5 : 1.5,
      borderColor: isCurrent
          ? tier.primaryColor
          : isUnlocked
          ? tier.primaryColor.withValues(alpha: 0.35)
          : null,
      backgroundColor: isUnlocked
          ? tier.primaryColor.withValues(alpha: 0.1)
          : null,
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
                    repeat: false,
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.25),
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
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isUnlocked
                    ? (isCurrent
                          ? tier.primaryColor
                          : Theme.of(context).colorScheme.onSurface)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
  }
}
