import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';

/// Aylık Özet Kartı Widget'ı
/// Harcama, gelir ve net durumu gösterir
class MonthlySummaryCard extends StatelessWidget {
  final double monthlyExpense;
  final double monthlyIncome;
  final double netDiff;

  const MonthlySummaryCard({
    super.key,
    required this.monthlyExpense,
    required this.monthlyIncome,
    required this.netDiff,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      delay: 200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive degerler hesapla
          final cardWidth = constraints.maxWidth;
          final titleFontSize = (cardWidth * 0.042).clamp(14.0, 18.0);
          final labelFontSize = (cardWidth * 0.028).clamp(9.0, 11.0);
          final valueFontSize = (cardWidth * 0.032).clamp(10.0, 14.0);
          final padding = (cardWidth * 0.05).clamp(14.0, 20.0);
          final iconSize = (cardWidth * 0.052).clamp(16.0, 22.0);

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bu Ay Özeti",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: padding * 0.8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        icon: Icons.arrow_downward,
                        iconColor: Colors.red.shade400,
                        label: "Harcama",
                        value: CurrencyFormatter.format(monthlyExpense),
                        valueColor: Colors.red.shade300,
                        labelFontSize: labelFontSize,
                        valueFontSize: valueFontSize,
                        iconSize: iconSize,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        icon: Icons.arrow_upward,
                        iconColor: Colors.green.shade400,
                        label: "Gelir",
                        value: CurrencyFormatter.format(monthlyIncome),
                        valueColor: Colors.green.shade300,
                        labelFontSize: labelFontSize,
                        valueFontSize: valueFontSize,
                        iconSize: iconSize,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        icon: netDiff >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        iconColor: netDiff >= 0
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        label: "Net",
                        value: CurrencyFormatter.formatSigned(
                          netDiff,
                          showPlus: true,
                        ),
                        valueColor: netDiff >= 0
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                        labelFontSize: labelFontSize,
                        valueFontSize: valueFontSize,
                        iconSize: iconSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required double labelFontSize,
    required double valueFontSize,
    required double iconSize,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
