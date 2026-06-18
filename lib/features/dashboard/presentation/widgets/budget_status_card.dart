import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';
import 'dashboard_card_container.dart';

class BudgetStatusCard extends StatelessWidget {
  final String? title;
  final double monthlyExpense;
  final double monthlyIncome;
  final double netDiff;
  final double butceLimiti;
  final Map<String, double>? categoryBudgets;
  final Map<String, double>? categoryExpenses;
  final VoidCallback? onTap;
  final bool isObscured;

  const BudgetStatusCard({
    super.key,
    this.title,
    required this.monthlyExpense,
    required this.monthlyIncome,
    required this.netDiff,
    required this.butceLimiti,
    this.categoryBudgets,
    this.categoryExpenses,
    this.onTap,
    this.isObscured = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedCard(
      delay: 200,
      child: DashboardCardContainer(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? context.l10n.thisMonth,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: onSurfaceColor.withValues(alpha: 0.4),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.arrow_downward,
                    iconColor: ColorConstants.kirmiziVurgu,
                    label: context.l10n.expense,
                    value: CurrencyFormatter.formatInteger(monthlyExpense),
                    isObscured: isObscured,
                    valueColor: ColorConstants.kirmiziVurgu,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: onSurfaceColor.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.arrow_upward,
                    iconColor: ColorConstants.yesil,
                    label: context.l10n.income,
                    value: CurrencyFormatter.formatInteger(monthlyIncome),
                    isObscured: isObscured,
                    valueColor: ColorConstants.yesil,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: onSurfaceColor.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: netDiff >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    iconColor: netDiff >= 0
                        ? ColorConstants.yesil
                        : ColorConstants.kirmiziVurgu,
                    label: context.l10n.net,
                    value: CurrencyFormatter.formatIntegerSigned(
                      netDiff,
                      showPlus: true,
                    ),
                    isObscured: isObscured,
                    valueColor: netDiff >= 0
                        ? ColorConstants.yesil
                        : ColorConstants.kirmiziVurgu,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildBudgetProgress(
              context,
              monthlyExpense,
              butceLimiti,
              isObscured,
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
    required bool isObscured,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ObscuredAmountText(
          value,
          isObscured: isObscured,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBudgetProgress(
    BuildContext context,
    double monthlyExpense,
    double butceLimiti,
    bool isObscured,
  ) {
    final budgetUsed = butceLimiti > 0 ? (monthlyExpense / butceLimiti) : 0.0;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.budgetStatus,
              style: TextStyle(
                fontSize: 12,
                color: onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
            Text(
              "${(budgetUsed * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(budgetUsed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: budgetUsed.clamp(0.0, 1.0),
            minHeight: 8,
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
    );
  }

  Color _getStatusColor(double budgetUsed) {
    if (budgetUsed > 0.8) return ColorConstants.kirmiziVurgu;
    if (budgetUsed > 0.5) return ColorConstants.turuncuVurgu;
    return ColorConstants.yesil;
  }
}
