part of '../pages/analysis_page.dart';

extension _IncomeAnalysisExtension on _AnalysisPageState {
  Widget _buildIncomeAnalysis() {
    final currentIncomes = _controller.currentIncomes;

    if (currentIncomes.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: AnalysisEmptyState(
              message: context.l10n.noIncomeDataForThisMonth,
              actionText: context.l10n.addIncome,
              icon: Icons.account_balance_wallet_outlined,
              buttonColor: Colors.green.shade400,
              onActionPressed: widget.onAddIncomePressed != null
                  ? () => widget.onAddIncomePressed!(_controller.selectedMonth)
                  : () => Navigator.pop(context),
            ),
          ),
        ],
      );
    }

    final totals = _controller.incomeCategoryTotals;
    final totalIncome = _controller.totalMonthlyIncome;
    final topEntry = _controller.topIncomeCategory;
    final topCategory = topEntry?.key ?? '';
    final topAmount = topEntry?.value ?? 0.0;

    final sections = _buildPieChartSections(totals, totalIncome, AnalysisColors.incomeColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            [
                  TrendInsightCard(
                    title: context.l10n.monthlyInsight,
                    currentAmount: totalIncome,
                    previousAmount: _controller.previousMonthTotalIncome,
                    isExpense: false,
                    increaseText: context.l10n.earnedMoreThanLastMonth(
                      '{percent}',
                    ),
                    decreaseText: context.l10n.earnedLessThanLastMonth(
                      '{percent}',
                    ),
                    noChangeText: context.l10n.earnedSameAsLastMonth,
                    topCategoryLabel: context.l10n.highestIncome,
                    topCategoryName: context.translateDbName(topCategory),
                    topCategoryAmount: CurrencyFormatter.format(topAmount),
                  ),
                  _buildChartArea(sections, totals, totalIncome, AnalysisColors.incomeColors),
                  if (currentIncomes.isNotEmpty)
                    _buildTopIncomes(currentIncomes, totalIncome),
                  if (currentIncomes.isNotEmpty && totalIncome > 0)
                    _buildIncomeStability(currentIncomes, totalIncome),
                  if (totalIncome > 0) ...[
                    _buildDailyEarningRate(totalIncome),
                    _buildSavingsPotential(totalIncome, _controller.totalMonthlyExpense),
                  ],
                  if (widget.paymentMethods.isNotEmpty)
                    _buildPaymentMethodDistribution(isExpense: false),
                ]
                .animate(interval: 50.ms)
                .fade(duration: 400.ms)
                .slideY(
                  begin: 0.1,
                  duration: 400.ms,
                  curve: Curves.easeOutQuad,
                ),
      ),
    );
  }
}
