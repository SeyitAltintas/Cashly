import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../../core/theme/app_theme.dart';

/// Tüm sesli komutları detaylı listeleyen sayfa
class VoiceCommandsPage extends StatelessWidget {
  const VoiceCommandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.voiceCommandsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Açıklama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.voiceCommandsTip,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Harcama Ekleme
            _buildCommandSection(
              context,
              icon: Icons.add_circle_outline,
              title: context.l10n.voiceCmdAddExpenseTitle,
              description: context.l10n.voiceCmdAddExpenseDesc,
              examples: context.l10n.voiceCmdAddExpenseExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Harcama Silme
            _buildCommandSection(
              context,
              icon: Icons.delete_outline,
              title: context.l10n.voiceCmdDeleteExpenseTitle,
              description: context.l10n.voiceCmdDeleteExpenseDesc,
              examples: context.l10n.voiceCmdDeleteExpenseExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Harcama Düzenleme
            _buildCommandSection(
              context,
              icon: Icons.edit,
              title: context.l10n.voiceCmdEditExpenseTitle,
              description: context.l10n.voiceCmdEditExpenseDesc,
              examples: context.l10n.voiceCmdEditExpenseExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Toplam Sorgulama
            _buildCommandSection(
              context,
              icon: Icons.account_balance_wallet,
              title: context.l10n.voiceCmdTotalQueryTitle,
              description: context.l10n.voiceCmdTotalQueryDesc,
              examples: context.l10n.voiceCmdTotalQueryExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Kategori Analizi
            _buildCommandSection(
              context,
              icon: Icons.pie_chart,
              title: context.l10n.voiceCmdCategoryAnalysisTitle,
              description: context.l10n.voiceCmdCategoryAnalysisDesc,
              examples: context.l10n.voiceCmdCategoryAnalysisExamples.split(
                '|',
              ),
            ),

            const SizedBox(height: 16),

            // Kategori Bazlı Sorgulama
            _buildCommandSection(
              context,
              icon: Icons.category,
              title: context.l10n.voiceCmdCategoryQueryTitle,
              description: context.l10n.voiceCmdCategoryQueryDesc,
              examples: context.l10n.voiceCmdCategoryQueryExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Son Harcamalar
            _buildCommandSection(
              context,
              icon: Icons.list_alt,
              title: context.l10n.voiceCmdLastExpensesTitle,
              description: context.l10n.voiceCmdLastExpensesDesc,
              examples: context.l10n.voiceCmdLastExpensesExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Bütçe Durumu
            _buildCommandSection(
              context,
              icon: Icons.warning_amber,
              title: context.l10n.voiceCmdBudgetStatusTitle,
              description: context.l10n.voiceCmdBudgetStatusDesc,
              examples: context.l10n.voiceCmdBudgetStatusExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Kalan Bütçe
            _buildCommandSection(
              context,
              icon: Icons.account_balance_wallet,
              title: context.l10n.voiceCmdRemainingBudgetTitle,
              description: context.l10n.voiceCmdRemainingBudgetDesc,
              examples: context.l10n.voiceCmdRemainingBudgetExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Limit Belirleme
            _buildCommandSection(
              context,
              icon: Icons.edit_note,
              title: context.l10n.voiceCmdSetLimitTitle,
              description: context.l10n.voiceCmdSetLimitDesc,
              examples: context.l10n.voiceCmdSetLimitExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Tasarruf Hesaplama
            _buildCommandSection(
              context,
              icon: Icons.savings,
              title: context.l10n.voiceCmdSavingsTitle,
              description: context.l10n.voiceCmdSavingsDesc,
              examples: context.l10n.voiceCmdSavingsExamples.split('|'),
            ),

            const SizedBox(height: 16),

            // Sabit Giderleri Ekle
            _buildCommandSection(
              context,
              icon: Icons.repeat,
              title: context.l10n.voiceCmdAddFixedTitle,
              description: context.l10n.voiceCmdAddFixedDesc,
              examples: context.l10n.voiceCmdAddFixedExamples.split('|'),
            ),

            const SizedBox(height: 32),

            // İpucu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.voiceCommandsTip,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<String> examples,
  }) {
    // Get icon index for color
    final iconIndex = [
      Icons.add_circle_outline,
      Icons.delete_outline,
      Icons.edit,
      Icons.account_balance_wallet,
      Icons.pie_chart,
      Icons.category,
      Icons.list_alt,
      Icons.warning_amber,
      Icons.account_balance_wallet,
      Icons.edit_note,
      Icons.savings,
      Icons.repeat,
    ].indexOf(icon);

    final iconColor = iconIndex >= 0
        ? PageThemeColors.getIconColor(iconIndex)
        : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Açıklama
          Text(
            description,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          // Örnekler
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: examples
                .map(
                  (example) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '"$example"',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
