import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_card.dart';

/// Bütçe Durumu Kartı Widget'ı
/// Bütçe limiti ve kullanım oranını gösterir
class BudgetStatusCard extends StatelessWidget {
  final double monthlyExpense;
  final double butceLimiti;

  const BudgetStatusCard({
    super.key,
    required this.monthlyExpense,
    required this.butceLimiti,
  });

  @override
  Widget build(BuildContext context) {
    final budgetUsed = butceLimiti > 0 ? (monthlyExpense / butceLimiti) : 0.0;

    return AnimatedCard(
      delay: 300,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bütçe Durumu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  "${(budgetUsed * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(budgetUsed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: budgetUsed.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(budgetUsed),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${monthlyExpense.toStringAsFixed(2)} ₺ harcandı",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  "${butceLimiti.toStringAsFixed(2)} ₺ limit",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(double budgetUsed) {
    if (budgetUsed > 1) return Colors.red.shade400;
    if (budgetUsed > 0.8) return Colors.orange.shade400;
    return Colors.green.shade400;
  }
}
