import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';
import '../controllers/dashboard_controller.dart';

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
    final isObscured = context.select((DashboardController c) => c.isObscured);

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
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFF8F9FA)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                  context.l10n.monthSummary,
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
                        iconColor: ColorConstants.kirmiziVurgu,
                        label: context.l10n.expense,
                        value: CurrencyFormatter.formatInteger(monthlyExpense),
                        isObscured: isObscured,
                        valueColor: ColorConstants.kirmiziVurgu,
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
                        iconColor: ColorConstants.yesil,
                        label: context.l10n.income,
                        value: CurrencyFormatter.formatInteger(monthlyIncome),
                        isObscured: isObscured,
                        valueColor: ColorConstants.yesil,
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
    required bool isObscured,
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
        ObscuredAmountText(
          value,
          isObscured: isObscured,
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
