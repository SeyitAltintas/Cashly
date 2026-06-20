import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_container.dart';

/// Rank sayfasının üst kartı
/// Mevcut rank, XP ve progress bar gösterir
class StreakHeaderCard extends StatefulWidget {
  final RankData streakData;

  const StreakHeaderCard({super.key, required this.streakData});

  @override
  State<StreakHeaderCard> createState() => _StreakHeaderCardState();
}

class _StreakHeaderCardState extends State<StreakHeaderCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rank = RankTiers.fromXp(widget.streakData.totalXp);
    final nextRank = RankTiers.nextTierFrom(widget.streakData.totalXp);
    final progress = RankTiers.progressToNext(widget.streakData.totalXp);
    final xpToNext = RankTiers.xpToNextTier(widget.streakData.totalXp);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;

        return DashboardCardContainer(
          padding: const EdgeInsets.all(24),
          borderWidth: 1.5,
          child: Column(
            children: [
              // Rank Lottie animasyonu + bilgileri
              Row(
                children: [
                  // Büyük Lottie animasyonu
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: RepaintBoundary(
                      child: Lottie.asset(
                        rank.lottieAsset,
                        controller: _lottieController,
                        fit: BoxFit.contain,
                        frameRate: const FrameRate(60),
                        onLoaded: (composition) {
                          _lottieController.duration = composition.duration;
                          _lottieController.forward();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 32), // Bilgileri sağa kaydırmak için 16'dan 32'ye çıkarıldı
                  // Rank bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rank.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color.lerp(
                              rank.primaryColor,
                              rank.glowColor,
                              glow,
                            ),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rank.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '⭐ ${widget.streakData.totalXp} XP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color.lerp(
                                  rank.primaryColor,
                                  rank.glowColor,
                                  glow,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '🔥 ${widget.streakData.currentStreak} Gün Seri',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress bar
              if (nextRank != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rank.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: rank.primaryColor,
                      ),
                    ),
                    Text(
                      nextRank.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: rank.primaryColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(rank.primaryColor, rank.glowColor, glow)!,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$xpToNext XP kaldı',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ] else ...[
                // Max rank mesajı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        rank.primaryColor.withValues(alpha: 0.3),
                        rank.glowColor.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🏆 En Yüksek Rank • Cashly Efsanesi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

