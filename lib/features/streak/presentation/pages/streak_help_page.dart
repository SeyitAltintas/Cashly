import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Seri özelliği hakkında bilgi sayfası
/// Accordion menü ile tüm özellikleri açıklar
class StreakHelpPage extends StatelessWidget {
  const StreakHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.howStreakWorks),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kartı
            _buildHeaderCard(context),
            const SizedBox(height: 24),

            // Accordion menüler
            _buildExpansionTile(
              context,
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFF6B35),
              title: context.l10n.streakWhatIsIt,
              content: context.l10n.streakDescription,
            ),

            _buildExpansionTile(
              context,
              icon: Icons.ac_unit,
              iconColor: const Color(0xFF00BCD4),
              title: context.l10n.streakFreezeWhatIsIt,
              content: context.l10n.streakFreezeDescription,
            ),

            _buildExpansionTile(
              context,
              icon: Icons.military_tech,
              iconColor: const Color(0xFFFFD700),
              title: context.l10n.badges,
              content: context.l10n.badgesDescription,
            ),

            _buildExpansionTile(
              context,
              icon: Icons.emoji_events,
              iconColor: const Color(0xFF9C27B0),
              title: context.l10n.achievements,
              content: context.l10n.achievementsDescription,
            ),

            _buildExpansionTile(
              context,
              icon: Icons.bar_chart,
              iconColor: const Color(0xFF4CAF50),
              title: context.l10n.statisticsTitle,
              content: context.l10n.statisticsDescription,
            ),

            _buildExpansionTile(
              context,
              icon: Icons.tips_and_updates,
              iconColor: const Color(0xFFFF9800),
              title: context.l10n.tipsTitle,
              content: context.l10n.tipsDescription,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withValues(alpha: 0.2),
            const Color(0xFFFF8C00).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 48,
            color: Color(0xFFFF6B35),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.streakSystem,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.streakSystemSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          iconColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.5),
          collapsedIconColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
