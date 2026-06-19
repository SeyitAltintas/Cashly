// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import '../../data/constants/streak_badges.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_container.dart';

/// Rank sisteminin nasıl çalıştığını açıklayan yardım sayfası
class StreakHelpPage extends StatelessWidget {
  const StreakHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rank Sistemi Nedir?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            _InfoCard(
              isPrimary: true,
              icon: Icons.emoji_events,
              iconColor: const Color(0xFFFFB300),
              title: 'Rank Sistemi',
              content:
                  'Cashly\'de her gün giriş yaparak ve seri oluşturarak XP kazanırsın. '
                  'Yeterli XP biriktirdiğinde bir üst rank kademesine yükselirsin. '
                  'Toplam 9 rank kademesi mevcuttur.',
            ),
            const SizedBox(height: 16),

            // XP Kazanma
            _InfoCard(
              icon: Icons.star,
              iconColor: const Color(0xFF42A5F5),
              title: 'XP Nasıl Kazanılır?',
              content: null,
              customContent: Column(
                children: [
                  _XpInfoRow(
                    icon: Icons.login,
                    label: 'Her gün giriş yap',
                    xp: '+${RankTiers.dailyLoginXp} XP',
                    color: const Color(0xFF42A5F5),
                  ),
                  _XpInfoRow(
                    icon: Icons.local_fire_department,
                    label: '7 günlük seri oluştur',
                    xp: '+${RankTiers.weeklyStreakBonusXp} XP bonus',
                    color: const Color(0xFFFF6B35),
                  ),
                  _XpInfoRow(
                    icon: Icons.emoji_events,
                    label: '30 günlük seri oluştur',
                    xp: '+${RankTiers.monthlyStreakBonusXp} XP bonus',
                    color: const Color(0xFFFFB300),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Seri sistemi
            _InfoCard(
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFF6B35),
              title: 'Seri (Streak) Nedir?',
              content:
                  'Her gün uygulamaya giriş yaparak serinizi sürdürürsünüz. '
                  'Bir gün giriş yapmazsanız seri sıfırlanır. '
                  'Ancak XP\'niz korunmaya devam eder, seri kırılsa bile!',
            ),
            const SizedBox(height: 16),

            // Yıllık reset
            _InfoCard(
              icon: Icons.refresh,
              iconColor: const Color(0xFF9C27B0),
              title: 'Yıllık XP Sıfırlaması',
              content:
                  'Her yıl başında XP\'niz sıfırlanır ve en düşük rank olan '
                  '"Acemi"\'den tekrar başlarsınız. Bu, her yıl yeni bir meydan '
                  'okuma olması içindir. Seri kaydınız ve başarımlarınız korunur.',
            ),
            const SizedBox(height: 16),

            // Rank kademeleri
            _InfoCard(
              icon: Icons.layers,
              iconColor: const Color(0xFF4CAF50),
              title: 'Rank Kademeleri',
              content: null,
              customContent: Column(
                children: RankTiers.allTiers.map((tier) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 32, // non-interactive
                          height: 32, // non-interactive
                          decoration: BoxDecoration(
                            color: tier.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${tier.level}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: tier.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tier.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          tier.level == 1
                              ? 'Başlangıç'
                              : '${tier.requiredXp} XP',
                          style: TextStyle(
                            fontSize: 13,
                            color: tier.level == 1
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : tier.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? content;
  final Widget? customContent;
  final bool isPrimary;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.content,
    this.customContent,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final innerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22), // non-interactive
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (content != null) ...[
          const SizedBox(height: 14),
          Text(
            content!,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (customContent != null) ...[
          const SizedBox(height: 14),
          customContent!,
        ],
      ],
    );

    return DashboardCardContainer(
      padding: const EdgeInsets.all(20),
      borderWidth: 1.5,
      child: innerContent,
    );
  }
}

class _XpInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String xp;
  final Color color;

  const _XpInfoRow({
    required this.icon,
    required this.label,
    required this.xp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ), // non-interactive
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            xp,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
