import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';
import '../pages/streak_page.dart';

/// Dashboard ve profil'de gösterilecek mini rank göstergesi
/// Lottie animasyonu + rank adı + XP progress bar içerir
class StreakWidget extends StatefulWidget {
  final RankData streakData;

  const StreakWidget({super.key, required this.streakData});

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
    final progress = RankTiers.progressToNext(widget.streakData.totalXp);
    final nextRank = RankTiers.nextTierFrom(widget.streakData.totalXp);

    return GestureDetector(
      onTap: () => _navigateToRankPage(context),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowValue = _glowController.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: rank.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.lerp(
                  rank.primaryColor.withValues(alpha: 0.5),
                  rank.glowColor.withValues(alpha: 0.9),
                  glowValue,
                )!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: rank.glowColor.withValues(
                    alpha: 0.15 + glowValue * 0.15,
                  ),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini Lottie rank animasyonu
                SizedBox(
                  width: 36,
                  height: 36,
                  child: RepaintBoundary(
                    child: Lottie.asset(
                      rank.lottieAsset,
                      fit: BoxFit.contain,
                      frameRate: const FrameRate(60),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rank adı
                    Text(
                      rank.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color.lerp(
                          rank.primaryColor,
                          rank.glowColor,
                          glowValue,
                        ),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // XP Progress bar
                    if (nextRank != null) ...[
                      SizedBox(
                        width: 72,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: rank.primaryColor.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.lerp(
                                rank.primaryColor,
                                rank.glowColor,
                                glowValue,
                              )!,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Max rank
                      Text(
                        'MAX',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: rank.glowColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToRankPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StreakPage(streakData: widget.streakData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
