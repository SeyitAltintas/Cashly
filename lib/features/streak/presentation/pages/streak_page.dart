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
import '../../../../core/services/haptic_service.dart';
import '../widgets/rank_timeline.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.updateStreakData(widget.streakData);
    });
  }

  @override
  void didUpdateWidget(StreakPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakData != widget.streakData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.updateStreakData(widget.streakData);
      });
    }
  }

  void _showTierDetails(BuildContext context, RankTier tier, bool isUnlocked) {
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
            body: Stack(
              children: [
                // Arka plan: Rank Yolculuğu
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.white],
                        stops: [
                          0.0,
                          0.35,
                        ], // Üst kartların bittiği yere kadar kaybolur
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: RankTimeline(
                      controller: _controller,
                      onTierTap: _showTierDetails,
                    ),
                  ),
                ),

                // Ön plan: Üst Kartlar (Sabit)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rank Header Kartı (Lottie + XP + Progress)
                        StreakHeaderCard(streakData: rankData),
                        const SizedBox(height: 20),
                        // Seri İstatistikleri
                        StreakStatsRow(streakData: rankData),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF18181B)
            : Theme.of(context).colorScheme.surface,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
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
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.tier.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),

          // Durum badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              widget.isCurrent
                  ? '✨ Mevcut Rank'
                  : widget.isUnlocked
                  ? '✅ Kazanıldı'
                  : '🔒 ${widget.tier.requiredXp} XP gerekli',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.isCurrent
                    ? widget.tier.primaryColor
                    : widget.isUnlocked
                    ? const Color(0xFF4CAF50)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
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
