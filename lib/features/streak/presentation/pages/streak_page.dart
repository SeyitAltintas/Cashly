import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';
import 'streak_help_page.dart';
import '../controllers/streak_controller.dart';
import '../widgets/streak_header_card.dart';
import '../widgets/streak_stats_row.dart';
import '../widgets/streak_freeze_card.dart';
import '../widgets/badge_grid_view.dart';
import '../widgets/achievements_list.dart';
import 'package:cashly/core/constants/color_constants.dart';

/// Seri detay sayfası
/// Mevcut seri, rozetler ve başarıları gösterir
/// Widget'lara bölünerek refactor edilmiştir (811 satır → compose pattern)
class StreakPage extends StatefulWidget {
  final StreakData streakData;

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

  void _showBadgeDetails(
    BuildContext context,
    StreakBadge badge,
    bool isEarned,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isEarned
                    ? badge.color.withValues(alpha: 0.2)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                color: isEarned
                    ? badge.color
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${badge.emoji} ${badge.localizedName(context)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.localizedDescription(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isEarned
                    ? ColorConstants.yesil.withValues(alpha: 0.2)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isEarned
                    ? context.l10n.earned
                    : context.l10n.requiredStreakDays(badge.requiredStreak),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isEarned
                      ? ColorConstants.yesil
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Builder(
        builder: (context) {
          final controller = context.read<StreakController>();
          context.select((StreakController c) => c.streakData);
          context.select((StreakController c) => c.nextBadge);

          final streakData = controller.streakData;

          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.streakInfo),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.onSurface),
                  tooltip: context.l10n.howStreakWorks,
                  onPressed: () {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mevcut Seri Kartı
                  StreakHeaderCard(streakData: streakData),
                  const SizedBox(height: 24),

                  // İstatistikler
                  StreakStatsRow(streakData: streakData),
                  const SizedBox(height: 16),

                  // Dondurucu Kartı
                  StreakFreezeCard(
                    streakData: streakData,
                    nextFreezeIn: controller.nextFreezeIn,
                  ),
                  const SizedBox(height: 32),

                  // Sonraki Rozet
                  if (controller.nextBadge != null) ...[
                    StreakNextBadgeSection(controller: controller),
                    const SizedBox(height: 32),
                  ],

                  // Rozetler Başlığı
                  _SectionTitle(title: context.l10n.badges),
                  const SizedBox(height: 16),

                  // Rozet Grid
                  BadgeGridView(
                    controller: controller,
                    onBadgeTap: _showBadgeDetails,
                  ),
                  const SizedBox(height: 32),

                  // Başarılar
                  _SectionTitle(title: context.l10n.achievements),
                  const SizedBox(height: 16),
                  AchievementsList(controller: controller),
                ],
              ),
            ),
          );
        },
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
