import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/extensions/l10n_extensions.dart';

/// Bütçe Durumu Kartı Widget'ı
/// Bütçe limiti, kullanım oranını ve kategori bazlı limitleri gösterir
/// Tıklandığında detay sayfasına yönlendirir
class BudgetStatusCard extends StatelessWidget {
  final double monthlyExpense;
  final double butceLimiti;
  final Map<String, double>? categoryBudgets;
  final Map<String, double>? categoryExpenses;
  final VoidCallback? onTap;

  const BudgetStatusCard({
    super.key,
    required this.monthlyExpense,
    required this.butceLimiti,
    this.categoryBudgets,
    this.categoryExpenses,
    this.onTap,
    this.isObscured = false,
  });

  final bool isObscured;

  @override
  Widget build(BuildContext context) {
    final budgetUsed = butceLimiti > 0 ? (monthlyExpense / butceLimiti) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedCard(
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
              // Global bütçe durumu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.budgetStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ],
                    ],
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
                    context.l10n.spentAmount(
                      CurrencyFormatter.format(
                        monthlyExpense,
                        isObscured: isObscured,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    context.l10n.limitAmount(
                      CurrencyFormatter.format(
                        butceLimiti,
                        isObscured: isObscured,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              // Kategori limitleri kaldırıldı - detaylar için karta tıklayın
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double budgetUsed) {
    if (budgetUsed > 0.8) return Colors.red.shade400;
    if (budgetUsed > 0.5) return Colors.orange.shade400;
    return Colors.green.shade400;
  }
}
