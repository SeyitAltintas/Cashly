import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';
import 'dashboard_card_container.dart';

class BudgetStatusCard extends StatelessWidget {
  final double monthlyExpense;
  final double butceLimiti;
  final Map<String, double>? categoryBudgets;
  final Map<String, double>? categoryExpenses;
  final VoidCallback? onTap;
  final bool isObscured;

  const BudgetStatusCard({
    super.key,
    required this.monthlyExpense,
    required this.butceLimiti,
    this.categoryBudgets,
    this.categoryExpenses,
    this.onTap,
    this.isObscured = false,
  });

  @override
  Widget build(BuildContext context) {
    final budgetUsed = butceLimiti > 0 ? (monthlyExpense / butceLimiti) : 0.0;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedCard(
        delay: 300,
        child: DashboardCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          color: onSurfaceColor.withValues(alpha: 0.4),
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
                  backgroundColor: onSurfaceColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(budgetUsed),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ObscuredAmountText(
                    context.l10n.spentAmount(
                      CurrencyFormatter.formatInteger(monthlyExpense),
                    ),
                    isObscured: isObscured,
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                  ObscuredAmountText(
                    context.l10n.limitAmount(
                      CurrencyFormatter.formatInteger(butceLimiti),
                    ),
                    isObscured: isObscured,
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double budgetUsed) {
    if (budgetUsed > 0.8) return ColorConstants.kirmiziVurgu;
    if (budgetUsed > 0.5) return ColorConstants.turuncuVurgu;
    return ColorConstants.yesil;
  }
}
