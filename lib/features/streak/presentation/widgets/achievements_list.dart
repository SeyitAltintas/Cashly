import 'package:flutter/material.dart';
import '../controllers/streak_controller.dart';

/// Rank sistemi başarımları listesi
class AchievementsList extends StatelessWidget {
  final StreakController controller;

  const AchievementsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final achievements = _buildAchievements(context);

    return Column(
      children: achievements.map((achievement) {
        return _AchievementTile(
          icon: achievement['icon'] as IconData,
          title: achievement['title'] as String,
          description: achievement['description'] as String,
          isEarned: achievement['earned'] as bool,
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _buildAchievements(BuildContext context) {
    final data = controller.streakData;
    return [
      {
        'icon': Icons.play_arrow,
        'title': 'İlk Adım',
        'description': 'İlk kez uygulamaya giriş yaptın.',
        'earned': data.totalLoginDays >= 1,
      },
      {
        'icon': Icons.local_fire_department,
        'title': 'Seri Başlangıcı',
        'description': '3 gün üst üste giriş yaptın.',
        'earned': data.longestStreak >= 3,
      },
      {
        'icon': Icons.calendar_month,
        'title': 'Düzenli Kullanıcı',
        'description': '10 gün uygulamayı kullandın.',
        'earned': data.totalLoginDays >= 10,
      },
      {
        'icon': Icons.star,
        'title': 'Haftalık Seri',
        'description': '7 gün üst üste giriş yaptın.',
        'earned': data.longestStreak >= 7,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Süreklilik Ustası',
        'description': '30 gün üst üste giriş yaptın.',
        'earned': data.longestStreak >= 30,
      },
      {
        'icon': Icons.all_inclusive,
        'title': 'Cashly Bağımlısı',
        'description': '100 gün uygulamayı kullandın.',
        'earned': data.totalLoginDays >= 100,
      },
      {
        'icon': Icons.workspace_premium,
        'title': 'Büyük Başarı',
        'description': '1000 XP\'ye ulaştın.',
        'earned': data.totalXp >= 1000,
      },
      {
        'icon': Icons.emoji_events,
        'title': 'XP Koleksiyoncusu',
        'description': '10.000 XP\'ye ulaştın.',
        'earned': data.totalXp >= 10000,
      },
    ];
  }
}

class _AchievementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isEarned;

  const _AchievementTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEarned
              ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEarned
                ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isEarned
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isEarned
                    ? const Color(0xFF4CAF50)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isEarned
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isEarned)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 22,
              )
            else
              Icon(
                Icons.lock_outline,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.25),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
