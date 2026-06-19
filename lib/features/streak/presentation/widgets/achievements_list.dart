import 'package:flutter/material.dart';
import '../controllers/streak_controller.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_container.dart';

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
        'icon': Icons.star,
        'title': 'Haftalık Seri',
        'description': '7 gün üst üste giriş yaptın.',
        'earned': data.longestStreak >= 7,
      },
      {
        'icon': Icons.school,
        'title': 'Finansal Çırak',
        'description': '100 XP toplayarak Çırak kademesine yükseldin.',
        'earned': data.totalXp >= 100,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Aylık Seri',
        'description': '30 gün üst üste giriş yaptın.',
        'earned': data.longestStreak >= 30,
      },
      {
        'icon': Icons.military_tech,
        'title': 'Finansal Uzman',
        'description': '900 XP toplayarak Uzman kademesine ulaştın.',
        'earned': data.totalXp >= 900,
      },
      {
        'icon': Icons.all_inclusive,
        'title': '100 Günlük Serüven',
        'description': 'Toplam 100 gün uygulamaya giriş yaptın.',
        'earned': data.totalLoginDays >= 100,
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Cashly Efsanesi',
        'description': '3600 XP toplayarak Efsane kademesine yükseldin.',
        'earned': data.totalXp >= 3600,
      },
      {
        'icon': Icons.calendar_month,
        'title': 'Yılın Seri Ustası',
        'description': 'Toplam 365 gün uygulamaya giriş yaptın.',
        'earned': data.totalLoginDays >= 365,
      },
      {
        'icon': Icons.diamond,
        'title': 'Grandmaster',
        'description': '6000 XP ile en yüksek kademeye ulaştın!',
        'earned': data.totalXp >= 6000,
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
      child: DashboardCardContainer(
        padding: const EdgeInsets.all(14),
        borderWidth: 1.5,
        backgroundColor: isEarned
            ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
            : null,
        borderColor: isEarned
            ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
            : null,
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
