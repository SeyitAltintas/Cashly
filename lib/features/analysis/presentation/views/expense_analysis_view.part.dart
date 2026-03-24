part of '../pages/analysis_page.dart';

extension _ExpenseAnalysisExtension on _AnalysisPageState {
  Widget _buildExpenseAnalysis() {
    final currentExpenses = _controller.currentExpenses;

    if (currentExpenses.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: AnalysisEmptyState(
              message: context.l10n.noExpenseDataForThisMonth,
              actionText: context.l10n.addExpense,
              icon: Icons.receipt_long_outlined,
              buttonColor: Colors.red.shade400,
              onActionPressed: widget.onAddExpensePressed != null
                  ? () => widget.onAddExpensePressed!(_controller.selectedMonth)
                  : () => Navigator.pop(context),
            ),
          ),
        ],
      );
    }

    final totals = _controller.expenseCategoryTotals;
    final totalAmount = _controller.totalMonthlyExpense;
    final topEntry = _controller.topExpenseCategory;
    final topCategory = topEntry?.key ?? '';
    final topAmount = topEntry?.value ?? 0.0;

    final sections = _buildPieChartSections(totals, totalAmount, AnalysisColors.expenseColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            [
                  TrendInsightCard(
                    title: context.l10n.monthlyInsight,
                    currentAmount: totalAmount,
                    previousAmount: _controller.previousMonthTotalExpense,
                    isExpense: true,
                    increaseText: context.l10n.spentMoreThanLastMonth(
                      '{percent}',
                    ),
                    decreaseText: context.l10n.spentLessThanLastMonth(
                      '{percent}',
                    ),
                    noChangeText: context.l10n.spentSameAsLastMonth,
                    topCategoryLabel: context.l10n.highestExpense,
                    topCategoryName: context.translateDbName(topCategory),
                    topCategoryAmount: CurrencyFormatter.format(topAmount),
                  ),
                  _buildChartArea(sections, totals, totalAmount, AnalysisColors.expenseColors),
                  if (_controller.historyLimit == 30 ||
                      _controller.historyLimit == -1) ...[
                    const SizedBox(height: 24),
                    BudgetStatusCard(
                      monthlyExpense: totalAmount,
                      butceLimiti: widget.totalBudget,
                      categoryBudgets: widget.categoryBudgets,
                      categoryExpenses: totals,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryBudgetDetailPage(
                              categoryBudgets: widget.categoryBudgets ?? {},
                              categoryExpenses: totals,
                              totalBudget: widget.totalBudget,
                              totalExpense: totalAmount,
                              rawExpenses: _controller.currentExpenses.toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (currentExpenses.isNotEmpty)
                    _buildTopExpenses(currentExpenses, _controller.totalMonthlyExpense),
                  if (widget.paymentMethods.isNotEmpty)
                    _buildPaymentMethodDistribution(),
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
