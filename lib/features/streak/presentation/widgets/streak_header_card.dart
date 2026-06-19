import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';

/// Rank sayfasının üst kartı
/// Mevcut rank, XP ve progress bar gösterir
class StreakHeaderCard extends StatefulWidget {
  final RankData streakData;

  const StreakHeaderCard({super.key, required this.streakData});

  @override
  State<StreakHeaderCard> createState() => _StreakHeaderCardState();
}

class _StreakHeaderCardState extends State<StreakHeaderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rank.primaryColor.withValues(alpha: 0.25 + glow * 0.08),
                rank.glowColor.withValues(alpha: 0.15 + glow * 0.05),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(
                rank.primaryColor.withValues(alpha: 0.4),
                rank.glowColor.withValues(alpha: 0.8),
                glow,
              )!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: rank.glowColor.withValues(alpha: 0.15 + glow * 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
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
                        fit: BoxFit.contain,
                        frameRate: const FrameRate(60),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Toplam XP
                        _XpBadge(
                          xp: widget.streakData.totalXp,
                          color: rank.primaryColor,
                          glowColor: rank.glowColor,
                          glowValue: glow,
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
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
                      Color.lerp(
                        rank.primaryColor,
                        rank.glowColor,
                        glow,
                      )!,
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
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

class _XpBadge extends StatelessWidget {
  final int xp;
  final Color color;
  final Color glowColor;
  final double glowValue;

  const _XpBadge({
    required this.xp,
    required this.color,
    required this.glowColor,
    required this.glowValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color.lerp(
            color.withValues(alpha: 0.4),
            glowColor.withValues(alpha: 0.8),
            glowValue,
          )!,
          width: 1,
        ),
      ),
      child: Text(
        '⭐ $xp XP',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color.lerp(color, glowColor, glowValue),
        ),
      ),
    );
  }
}
