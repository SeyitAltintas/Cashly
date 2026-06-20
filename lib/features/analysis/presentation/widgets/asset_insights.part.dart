// ignore_for_file: library_private_types_in_public_api
part of '../pages/analysis_page.dart';

extension AssetInsightsExtension on _AnalysisPageState {
  Widget _buildTopPerformers(List<Asset> activeAssets) {
    if (activeAssets.isEmpty) return const SizedBox.shrink();

    final curService = getIt<CurrencyService>();

    // purchasePrice == 0 ise ROI hesaplanamaz → hariç tut
    final assetsWithRoi = activeAssets
        .where((a) => a.purchasePrice > 0)
        .toList();
    if (assetsWithRoi.isEmpty) return const SizedBox.shrink();

    // ROI'ye göre sırala (en yüksek başta)
    assetsWithRoi.sort(
      (a, b) => b.profitLossPercentage.compareTo(a.profitLossPercentage),
    );

    // Sadece kârda olanları göster
    final profitable = assetsWithRoi.where((a) => a.profitLoss > 0).toList();

    if (profitable.isEmpty) {
      return _buildInfoCard(
        icon: Icons.trending_up_rounded,
        iconColor: ColorConstants.maviVurgu,
        title: context.l10n.topPerformers,
        message: context.l10n.topPerformersAllLoss,
      );
    }

    final top3 = profitable.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.topPerformers,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showDetailBottomSheet(
                    title: context.l10n.topPerformersDetailTitle,
                    body: context.l10n.topPerformersDetailBody,
                    icon: Icons.trending_up_rounded,
                    iconColor: ColorConstants.maviVurgu,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.topPerformersDesc,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: List.generate(top3.length, (index) {
              final asset = top3[index];
              final roi = asset.profitLossPercentage;
              final profitAmount = curService.convert(
                asset.profitLoss,
                asset.paraBirimi,
                curService.currentCurrency,
              );
              final isProfit = profitAmount >= 0;
              final Color roiColor = isProfit ? ColorConstants.yesil : ColorConstants.kirmiziVurgu;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AnalysisColors
                            .assetColors[index %
                                AnalysisColors.assetColors.length]
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.show_chart_rounded,
                        color:
                            AnalysisColors.assetColors[index %
                                AnalysisColors.assetColors.length],
                        size: 24,
                      ),
                    ),
                    title: Text(
                      asset.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      context.translateDbName(asset.category),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roiColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${isProfit ? '+' : ''}${roi.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: roiColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AmountText(
                          '${isProfit ? '+' : ''}${CurrencyFormatter.format(profitAmount)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != top3.length - 1)
                    Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioDiversification(
    Map<String, double> typeTotals,
    double totalValue,
  ) {
    if (typeTotals.isEmpty || totalValue <= 0) return const SizedBox.shrink();

    final typeCount = typeTotals.length;

    // En büyük dilimi bul
    String dominantType = '';
    double dominantPercent = 0;
    for (var entry in typeTotals.entries) {
      final pct = entry.value / totalValue * 100;
      if (pct > dominantPercent) {
        dominantPercent = pct;
        dominantType = entry.key;
      }
    }

    // Durum tespiti
    final bool isSingleType = typeCount == 1;
    final bool isConcentrated = !isSingleType && dominantPercent >= 70;

    final String statusTitle;
    final String statusDesc;
    final Color statusColor;
    final IconData statusIcon;

    if (isSingleType) {
      statusTitle = context.l10n.singleAssetType;
      statusDesc = context.l10n.singleAssetTypeDesc;
      statusColor = ColorConstants.turuncuVurgu;
      statusIcon = Icons.warning_amber_rounded;
    } else if (isConcentrated) {
      statusTitle = context.l10n.concentratedPortfolio;
      statusDesc = context.l10n.concentratedPortfolioDesc(
        context.translateDbName(dominantType),
        dominantPercent.toStringAsFixed(0),
      );
      statusColor = ColorConstants.turuncuVurgu;
      statusIcon = Icons.pie_chart_rounded;
    } else {
      statusTitle = context.l10n.diversifiedPortfolio;
      statusDesc = context.l10n.diversifiedPortfolioDesc;
      statusColor = ColorConstants.yesil;
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.portfolioDiversification,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showDetailBottomSheet(
                title: context.l10n.portfolioDiversificationDetailTitle,
                body: context.l10n.portfolioDiversificationDetailBody,
                icon: Icons.pie_chart_rounded,
                iconColor: ColorConstants.maviVurgu,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              // Progress bars for each type
              ...typeTotals.entries.map((entry) {
                final pct = entry.value / totalValue;
                final color =
                    AnalysisColors.assetColors[typeTotals.keys.toList().indexOf(
                          entry.key,
                        ) %
                        AnalysisColors.assetColors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.translateDbName(entry.key),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '%${(pct * 100).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              // Status message
              _buildInfoCard(
                icon: statusIcon,
                iconColor: statusColor,
                title: statusTitle,
                message: statusDesc,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidityCheck(List<Asset> activeAssets, double totalValue) {
    if (activeAssets.isEmpty || totalValue <= 0) return const SizedBox.shrink();

    final curService = getIt<CurrencyService>();

    // Yüksek likidite: Altın, Döviz, Kripto, Banka
    // Düşük likidite: Hisse Senedi, Diğer, ve kullanıcı tanımlı bilinmeyen türler
    const highLiquidityCategories = {
      'altın',
      'gold',
      'döviz',
      'forex',
      'currency',
      'kripto',
      'crypto',
      'banka',
      'bank',
    };

    double highLiquidTotal = 0;
    double lowLiquidTotal = 0;

    for (var asset in activeAssets) {
      final converted = curService.convert(
        asset.amount,
        asset.paraBirimi,
        curService.currentCurrency,
      );
      if (highLiquidityCategories.contains(asset.category.toLowerCase())) {
        highLiquidTotal += converted;
      } else {
        lowLiquidTotal += converted;
      }
    }

    final highPct = (highLiquidTotal / totalValue * 100).clamp(0.0, 100.0);
    final lowPct = (lowLiquidTotal / totalValue * 100).clamp(0.0, 100.0);
    final isHealthy = highPct >= 30; // %30+ likit = sağlıklı

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.liquidityCheck,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showDetailBottomSheet(
                title: context.l10n.liquidityDetailTitle,
                body: context.l10n.liquidityDetailBody,
                icon: Icons.water_drop_rounded,
                iconColor: ColorConstants.camgobegiVurgu,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              // Two bars side by side
              Row(
                children: [
                  // High Liquidity
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          color: ColorConstants.camgobegiVurgu,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.highLiquidity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '%${highPct.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.camgobegiVurgu,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (highPct / 100).clamp(0.0, 1.0),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation(
                              ColorConstants.camgobegiVurgu,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Low Liquidity
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.hourglass_bottom_rounded,
                          color: ColorConstants.turuncuVurgu,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.lowLiquidity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '%${lowPct.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.turuncuVurgu,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (lowPct / 100).clamp(0.0, 1.0),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation(
                              ColorConstants.turuncuVurgu,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status message
              _buildInfoCard(
                icon: isHealthy
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                iconColor: isHealthy ? ColorConstants.yesil : ColorConstants.turuncuVurgu,
                title: isHealthy
                    ? context.l10n.highLiquidity
                    : context.l10n.lowLiquidity,
                message: isHealthy
                    ? context.l10n.liquidityHealthy(highPct.toStringAsFixed(0))
                    : context.l10n.liquidityWarning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
