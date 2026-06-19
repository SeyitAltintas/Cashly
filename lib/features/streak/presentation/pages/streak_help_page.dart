// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import '../../data/constants/streak_badges.dart';

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
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: tier.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tier.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${tier.level}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: tier.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                            fontSize: 12,
                            color: tier.primaryColor,
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

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.content,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 10),
            Text(
              content!,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (customContent != null) ...[
            const SizedBox(height: 10),
            customContent!,
          ],
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              xp,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
