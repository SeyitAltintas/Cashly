import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/streak_model.dart';
import '../pages/streak_page.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Dashboard'da gösterilecek seri widget'ı
/// Animasyonlu ateş maskotu ve seri sayısını gösterir
class StreakWidget extends StatefulWidget {
  final StreakData streakData;

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
    final streak = widget.streakData.currentStreak;
    final hasStreak = streak > 0;

    return GestureDetector(
      onTap: () => _navigateToStreakPage(context),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowValue = _glowController.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              // Cam efekti (glassmorphism)
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFFFF6B35).withValues(alpha: 0.4),
                  const Color(0xFFFFD700).withValues(alpha: 0.8),
                  glowValue,
                )!,
                width: 1.5,
              ),
              boxShadow: hasStreak
                  ? [
                      // Dış parıldama
                      BoxShadow(
                        color: const Color(
                          0xFFFF6B35,
                        ).withValues(alpha: 0.2 + glowValue * 0.2),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                      // İç gölge
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie animasyonlu ateş maskotu
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Lottie.asset(
                    'assets/lottie/money_flame.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 6),
                // Seri sayısı ve gün etiketi
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seri sayısı - büyük ve kalın
                    Text(
                      _formatStreak(streak),
                      style: TextStyle(
                        fontSize: streak >= 1000 ? 16 : 20,
                        fontWeight: FontWeight.w900,
                        color: Color.lerp(
                          const Color(0xFFFF6B35),
                          const Color(0xFFFFD700),
                          glowValue,
                        ),
                        height: 1,
                        shadows: [
                          Shadow(
                            color: const Color(
                              0xFFFF6B35,
                            ).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    // Gün etiketi - küçük
                    Text(
                      context.l10n.day,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Büyük sayıları kısaltır: 1000 → 1K, 10000 → 10K
  String _formatStreak(int streak) {
    if (streak >= 1000000) {
      return '${(streak / 1000000).toStringAsFixed(1)}M';
    } else if (streak >= 10000) {
      return '${(streak / 1000).toStringAsFixed(0)}K';
    } else if (streak >= 1000) {
      return '${(streak / 1000).toStringAsFixed(1)}K';
    }
    return '$streak';
  }

  void _navigateToStreakPage(BuildContext context) {
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
