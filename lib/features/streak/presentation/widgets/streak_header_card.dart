import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../data/models/streak_model.dart';

/// Mevcut seri sayısını gösteren ana kart (ateş animasyonu + seri bilgisi)
class StreakHeaderCard extends StatelessWidget {
  final StreakData streakData;

  const StreakHeaderCard({super.key, required this.streakData});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Sol: Lottie Animasyonlu Ateş Maskotu
                SizedBox(
                  width: 80,
                  height: 80,
                  child: RepaintBoundary(
                    child: Lottie.asset(
                      'assets/lottie/money_flame.json',
                      fit: BoxFit.contain,
                      frameRate: const FrameRate(60),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Sağ: Seri bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${streakData.currentStreak}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              context.l10n.daysText,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.dailyStreak,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (streakData.usedFreezeToday) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.ac_unit,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.freezeUsed,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
