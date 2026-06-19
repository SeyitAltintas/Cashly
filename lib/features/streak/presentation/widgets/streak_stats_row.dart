import 'package:flutter/material.dart';
import '../../data/models/streak_model.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_container.dart';

/// Rank sayfası istatistik satırı
/// Günlük seri, toplam gün ve XP bilgilerini gösterir
class StreakStatsRow extends StatelessWidget {
  final RankData streakData;

  const StreakStatsRow({super.key, required this.streakData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFFF6B35),
            label: 'Güncel Seri',
            value: '${streakData.currentStreak}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today,
            iconColor: const Color(0xFF42A5F5),
            label: 'Toplam Gün',
            value: '${streakData.totalLoginDays}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFFFB300),
            label: 'En Uzun Seri',
            value: '${streakData.longestStreak}',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCardContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      borderWidth: 1.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
