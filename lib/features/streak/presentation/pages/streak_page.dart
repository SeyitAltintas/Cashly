import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';
import 'streak_help_page.dart';
import '../controllers/streak_controller.dart';

/// Seri detay sayfası
/// Mevcut seri, rozetler ve başarıları gösterir
/// StreakController ile entegre edilmiştir
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
    // DI'dan controller al
    _controller = getIt<StreakController>();
    // Controller'ı güncelle
    _controller.updateStreakData(widget.streakData);
  }

  @override
  void didUpdateWidget(StreakPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Props değiştiğinde controller'ı güncelle
    if (oldWidget.streakData != widget.streakData) {
      _controller.updateStreakData(widget.streakData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<StreakController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.streakInfo),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
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
                  _buildCurrentStreakCard(context, controller),
                  const SizedBox(height: 24),

                  // İstatistikler
                  _buildStatsRow(context, controller),
                  const SizedBox(height: 16),

                  // Dondurucu Kartı
                  _buildFreezeCard(context, controller),
                  const SizedBox(height: 32),

                  // Sonraki Rozet
                  if (controller.nextBadge != null) ...[
                    _buildNextBadgeSection(context, controller),
                    const SizedBox(height: 32),
                  ],

                  // Rozetler Başlığı
                  _buildSectionTitle(context, context.l10n.badges),
                  const SizedBox(height: 16),

                  // Rozet Grid
                  _buildBadgeGrid(context, controller),
                  const SizedBox(height: 32),

                  // Başarılar
                  _buildSectionTitle(context, context.l10n.achievements),
                  const SizedBox(height: 16),
                  _buildAchievementsList(context, controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStreakCard(
    BuildContext context,
    StreakController controller,
  ) {
    final streakData = controller.streakData;

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
                  child: Lottie.asset(
                    'assets/lottie/money_flame.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                // Sağ: Seri bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seri sayısı ve etiket
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${streakData.currentStreak}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              context.l10n.daysText,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.dailyStreak,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Dondurucu kullanıldıysa göster
                      if (streakData.usedFreezeToday) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.ac_unit,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.freezeUsed,
                                style: const TextStyle(
                                  color: Colors.white,
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

  Widget _buildStatsRow(BuildContext context, StreakController controller) {
    final streakData = controller.streakData;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.emoji_events,
            value: '${streakData.longestStreak}',
            label: context.l10n.longestStreak,
            color: const Color(0xFFFFD700),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.calendar_today,
            value: '${streakData.totalLoginDays}',
            label: context.l10n.totalLogins,
            color: const Color(0xFF4FC3F7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Dondurucu (Freeze) kartı
  Widget _buildFreezeCard(BuildContext context, StreakController controller) {
    const freezeColor = Color(0xFF00BCD4); // Cyan
    final streakData = controller.streakData;
    final nextFreezeIn = controller.nextFreezeIn;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: freezeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Dondurucu ikonu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: freezeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.ac_unit, color: freezeColor, size: 28),
              ),
              const SizedBox(width: 16),
              // Bilgi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.streakFreeze,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.protectsStreakEvenIfSkipped,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Sayı
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: freezeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ac_unit, color: freezeColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${streakData.freezeCount}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: freezeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bugün kullanıldı mı bilgisi
          if (streakData.usedFreezeToday)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.streakFreezeUsedToday,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            )
          else
            // Sonraki dondurucu bilgisi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.nextFreezeIn(nextFreezeIn),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNextBadgeSection(
    BuildContext context,
    StreakController controller,
  ) {
    final badge = controller.nextBadge!;
    final remaining = controller.daysToNextBadge;
    final progress = controller.nextBadgeProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badge.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(badge.icon, color: badge.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.nextBadgeIs(badge.localizedName(context)),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.daysRemainingForBadge(remaining),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // İlerleme çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: badge.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(badge.color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(BuildContext context, StreakController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: controller.allBadges.length,
      itemBuilder: (context, index) {
        final badge = controller.allBadges[index];
        final isEarned = controller.isBadgeEarned(badge);

        return _buildBadgeItem(context, badge, isEarned);
      },
    );
  }

  Widget _buildBadgeItem(
    BuildContext context,
    StreakBadge badge,
    bool isEarned,
  ) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge, isEarned),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEarned
              ? badge.color.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned
                ? badge.color.withValues(alpha: 0.5)
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.icon,
              color: isEarned
                  ? badge.color
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              badge.emoji,
              style: TextStyle(
                fontSize: 16,
                color: isEarned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${badge.requiredStreak}${context.l10n.dShort}',
              style: TextStyle(
                fontSize: 10,
                color: isEarned
                    ? badge.color
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
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
                fontWeight: FontWeight.bold,
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
                    ? Colors.green.withValues(alpha: 0.2)
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
                  fontWeight: FontWeight.w600,
                  color: isEarned
                      ? Colors.green
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

  Widget _buildAchievementsList(
    BuildContext context,
    StreakController controller,
  ) {
    final achievements = controller.getAchievements(context);

    return Column(
      children: achievements.map((achievement) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: achievement['earned'] == true
                  ? Colors.green.withValues(alpha: 0.3)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: achievement['earned'] == true
                      ? Colors.green.withValues(alpha: 0.2)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  achievement['icon'] as IconData,
                  color: achievement['earned'] == true
                      ? Colors.green
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (achievement['earned'] == true)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else
                Icon(
                  Icons.circle_outlined,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 24,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
