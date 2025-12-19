import 'package:flutter/material.dart';
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.arrow_downward,
                    iconColor: Colors.red.shade400,
                    label: "Harcama",
                    value: "${monthlyExpense.toStringAsFixed(2)} ₺",
                    valueColor: Colors.red.shade300,
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
                    value: "${monthlyIncome.toStringAsFixed(2)} ₺",
                    valueColor: Colors.green.shade300,
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
                    value:
                        "${netDiff >= 0 ? '+' : ''}${netDiff.toStringAsFixed(2)} ₺",
                    valueColor: netDiff >= 0
                        ? Colors.green.shade300
                        : Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
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
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
