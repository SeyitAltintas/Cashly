part of '../pages/analysis_page.dart';

extension _AssetAnalysisExtension on _AnalysisPageState {
  Widget _buildAssetAnalysis() {
    final activeAssets = _controller.activeAssets;

    if (activeAssets.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: AnalysisEmptyState(
              message: context.l10n.noAssetsAddedYet,
              actionText: context.l10n.addAsset,
              icon: Icons.diamond_outlined,
              buttonColor: Colors.blue.shade500,
              onActionPressed: widget.onAddAssetPressed != null
                  ? () => widget.onAddAssetPressed!(_controller.selectedMonth)
                  : () => Navigator.pop(context),
            ),
          ),
        ],
      );
    }

    final totals = _controller.assetTypeTotals;
    final totalValue = _controller.totalAssetValue;
    final (topType, topAmount) = _findTopCategory(totals);

    final sections = _buildPieChartSections(totals, totalValue, AnalysisColors.assetColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            [
                  TrendInsightCard(
                    title: context.l10n.assetInsightTitle,
                    currentAmount: totalValue,
                    previousAmount: _controller.totalAssetPurchaseValue,
                    isExpense: false,
                    increaseText: context.l10n.assetIncrease('{percent}'),
                    decreaseText: context.l10n.assetDecrease('{percent}'),
                    noChangeText: context.l10n.assetNoChange,
                    noteText: context.l10n.fxImpactNotice,
                    topCategoryLabel: context.l10n.mostValuableType,
                    topCategoryName: context.translateDbName(topType),
                    topCategoryAmount: CurrencyFormatter.format(topAmount),
                  ),
                  const SizedBox(height: 24),
                  _buildChartArea(sections, totals, totalValue, AnalysisColors.assetColors),
                  if (activeAssets.any((a) => a.purchasePrice > 0)) ...[
                    const SizedBox(height: 24),
                    _buildTopPerformers(activeAssets),
                  ],
                  if (activeAssets.isNotEmpty && totalValue > 0) ...[
                    const SizedBox(height: 24),
                    _buildPortfolioDiversification(totals, totalValue),
                    const SizedBox(height: 24),
                    _buildLiquidityCheck(activeAssets, totalValue),
                  ],
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
