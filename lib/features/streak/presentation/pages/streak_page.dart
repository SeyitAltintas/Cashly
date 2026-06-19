// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';
import '../controllers/streak_controller.dart';
import '../widgets/streak_header_card.dart';
import '../widgets/streak_stats_row.dart';
import '../widgets/badge_grid_view.dart';
import '../../../../core/services/haptic_service.dart';
import '../widgets/achievements_list.dart';
import 'streak_help_page.dart';

/// Rank Detay Sayfası
/// Mevcut rank, XP geçmişi, tüm rank kademeleri ve başarımları gösterir
class StreakPage extends StatefulWidget {
  final RankData streakData;

  const StreakPage({super.key, required this.streakData});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  late final StreakController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<StreakController>();
    _controller.updateStreakData(widget.streakData);
  }

  @override
  void didUpdateWidget(StreakPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakData != widget.streakData) {
      _controller.updateStreakData(widget.streakData);
    }
  }

  void _showTierDetails(
    BuildContext context,
    RankTier tier,
    bool isUnlocked,
  ) {
    HapticService.lightImpact();
    final isCurrent = _controller.currentRank.level == tier.level;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RankTierDetailsSheet(
        tier: tier,
        isUnlocked: isUnlocked,
        isCurrent: isCurrent,
        currentXp: widget.streakData.totalXp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Builder(
        builder: (context) {
          context.select((StreakController c) => c.streakData);

          final rankData = _controller.streakData;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Rank Bilgileri'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip: 'Rank Sistemi Nasıl Çalışır?',
                  onPressed: () {
                    HapticService.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StreakHelpPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank Header Kartı (Lottie + XP + Progress)
                  StreakHeaderCard(streakData: rankData),
                  const SizedBox(height: 20),

                  // Seri İstatistikleri
                  StreakStatsRow(streakData: rankData),
                  const SizedBox(height: 28),

                  // XP Kazanma Rehberi
                  _XpGuideCard(),
                  const SizedBox(height: 28),

                  // Tüm Rank Kademeleri
                  const _SectionTitle(title: 'Rank Kademeleri'),
                  const SizedBox(height: 14),
                  BadgeGridView(
                    controller: _controller,
                    onBadgeTap: _showTierDetails,
                  ),
                  const SizedBox(height: 28),

                  // Başarımlar
                  const _SectionTitle(title: 'Başarımlar'),
                  const SizedBox(height: 14),
                  AchievementsList(controller: _controller),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// XP Kazanma Rehberi Kartı
class _XpGuideCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF42A5F5).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF42A5F5).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Color(0xFF42A5F5), size: 18),
              SizedBox(width: 8),
              Text(
                'XP Nasıl Kazanılır?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF42A5F5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _XpRow(
            icon: Icons.login,
            label: 'Günlük giriş',
            xp: '+${RankTiers.dailyLoginXp} XP',
          ),
          _XpRow(
            icon: Icons.local_fire_department,
            label: '7 günlük seri bonusu',
            xp: '+${RankTiers.weeklyStreakBonusXp} XP',
          ),
          _XpRow(
            icon: Icons.emoji_events,
            label: '30 günlük seri bonusu',
            xp: '+${RankTiers.monthlyStreakBonusXp} XP',
          ),
          const SizedBox(height: 8),
          Text(
            '⚡ XP her yıl sıfırlanır.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _XpRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String xp;

  const _XpRow({
    required this.icon,
    required this.label,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF42A5F5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              xp,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF42A5F5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bölüm başlığı widget'ı
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Rank Kademesi Detay Bottom Sheet
class _RankTierDetailsSheet extends StatefulWidget {
  final RankTier tier;
  final bool isUnlocked;
  final bool isCurrent;
  final int currentXp;

  const _RankTierDetailsSheet({
    required this.tier,
    required this.isUnlocked,
    required this.isCurrent,
    required this.currentXp,
  });

  @override
  State<_RankTierDetailsSheet> createState() => _RankTierDetailsSheetState();
}

class _RankTierDetailsSheetState extends State<_RankTierDetailsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Sürekli tekrar eden detay lottie animasyonu
          SizedBox(
            width: 120,
            height: 120,
            child: RepaintBoundary(
              child: Lottie.asset(
                widget.tier.lottieAsset,
                controller: _lottieController,
                fit: BoxFit.contain,
                frameRate: const FrameRate(60),
                onLoaded: (composition) {
                  _lottieController.duration = composition.duration;
                  // Baştan sona oynar, sondan başa sarar ve döngüye girer
                  _lottieController.repeat(reverse: true);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Rank adı ve seviyesi
          Text(
            'Seviye ${widget.tier.level}',
            style: TextStyle(
              fontSize: 13,
              color: widget.tier.primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.tier.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: widget.isUnlocked
                  ? widget.tier.primaryColor
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.tier.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),

          // Durum badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isCurrent
                  ? widget.tier.primaryColor.withValues(alpha: 0.15)
                  : widget.isUnlocked
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isCurrent
                    ? widget.tier.primaryColor.withValues(alpha: 0.4)
                    : widget.isUnlocked
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              widget.isCurrent
                  ? '✨ Mevcut Rank'
                  : widget.isUnlocked
                      ? '✅ Kazanıldı'
                      : '🔒 ${widget.tier.requiredXp} XP gerekli',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isCurrent
                    ? widget.tier.primaryColor
                    : widget.isUnlocked
                        ? const Color(0xFF4CAF50)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// StreakNextBadgeSection artık kullanılmıyor ancak import uyumluluğu için stub bırakıldı
class StreakNextBadgeSection extends StatelessWidget {
  final StreakController controller;
  const StreakNextBadgeSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
