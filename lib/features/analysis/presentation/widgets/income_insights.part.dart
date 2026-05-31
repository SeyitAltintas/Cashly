part of '../pages/analysis_page.dart';

extension IncomeInsightsExtension on _AnalysisPageState {
  Widget _buildTopIncomes(List<Income> currentIncomes, double totalIncome) {
    if (currentIncomes.isEmpty) return const SizedBox.shrink();

    // Controller'dan tüm geçmişe bakarak düzenli kategorileri al
    final regularCategories = _controller.regularIncomeCategories;

    final filtered = currentIncomes.where((g) {
      return !regularCategories.contains(g.category);
    }).toList();

    // Eğer filtreleme sonrası boşsa (tüm gelirler düzenli) özel mesaj göster
    if (filtered.isEmpty) {
      return _buildInfoCard(
        icon: Icons.emoji_events_outlined,
        iconColor: Colors.amber,
        title: context.l10n.topIncomes,
        message: context.l10n.topIncomesAllSalary,
      );
    }

    final curService = getIt<CurrencyService>();
    final sorted = List<Income>.from(filtered)
      ..sort((a, b) {
        final va = curService.convert(
          a.amount,
          a.paraBirimi,
          curService.currentCurrency,
        );
        final vb = curService.convert(
          b.amount,
          b.paraBirimi,
          curService.currentCurrency,
        );
        return vb.compareTo(va);
      });

    final top3 = sorted.take(3).toList();
    if (top3.isEmpty || top3.every((e) => e.amount == 0.0)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.topIncomes,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showDetailBottomSheet(
                      title: context.l10n.topIncomesDetailTitle,
                      body: context.l10n.topIncomesDetailBody,
                      icon: Icons.emoji_events_rounded,
                      iconColor: Colors.amber,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 16,
                  color: Colors.green.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.topIncomesDescription,
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
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
                final income = top3[index];
                final amount = income.amount;
                final currency = income.paraBirimi;
                final convertedAmount = curService.convert(
                  amount,
                  currency,
                  curService.currentCurrency,
                );
                final Color iconColor = AnalysisColors
                    .incomeColors[index % AnalysisColors.incomeColors.length];
                final incomeCatIcon =
                    widget.incomeCategoryIcons?[income.category] ??
                    Icons.attach_money_rounded;

                // Tarih
                final date = income.date;
                final dateText =
                    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

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
                          color: iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(incomeCatIcon, color: iconColor, size: 24),
                      ),
                      title: Text(
                        income.name.isNotEmpty
                            ? income.name
                            : context.translateDbName(income.category),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(
                              amount,
                              currency: currency,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade600,
                            ),
                          ),
                          if (currency != curService.currentCurrency)
                            Text(
                              '~${CurrencyFormatter.format(convertedAmount)}',
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
      ),
    );
  }

  Widget _buildIncomeStability(
    List<Income> currentIncomes,
    double totalIncome,
  ) {
    if (currentIncomes.isEmpty || totalIncome <= 0) {
      return const SizedBox.shrink();
    }

    // Controller'ın tüm geçmişe bakarak hesapladığı düzenli kategorileri al
    final regularCategories = _controller.regularIncomeCategories;
    final curService = getIt<CurrencyService>();
    final categoryAmounts = <String, double>{};

    for (var g in currentIncomes) {
      final val = curService.convert(
        g.amount,
        g.paraBirimi,
        curService.currentCurrency,
      );
      categoryAmounts[g.category] = (categoryAmounts[g.category] ?? 0) + val;
    }

    double regularTotal = 0;
    double variableTotal = 0;

    for (var entry in categoryAmounts.entries) {
      if (regularCategories.contains(entry.key)) {
        regularTotal += entry.value;
      } else {
        variableTotal += entry.value;
      }
    }
    final uniqueCategories = categoryAmounts.length;

    final regularPercent = (regularTotal / totalIncome * 100).clamp(0.0, 100.0);
    final variablePercent = (variableTotal / totalIncome * 100).clamp(
      0.0,
      100.0,
    );

    // Tek kaynak uyarısı vs çeşitli gelir
    final bool isSingleSource = uniqueCategories == 1;
    final String adviceText = isSingleSource
        ? context.l10n.singleSourceWarning
        : context.l10n.stableIncomeNote;
    final Color adviceColor = isSingleSource ? Colors.orange : Colors.green;
    final IconData adviceIcon = isSingleSource
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline_rounded;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.incomeStability,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showDetailBottomSheet(
                  title: context.l10n.incomeStabilityDetailTitle,
                  body: context.l10n.incomeStabilityDetailBody,
                  icon: Icons.balance_rounded,
                  iconColor: Colors.blue,
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 12,
                    child: Row(
                      children: [
                        if (regularPercent > 0)
                          Expanded(
                            flex: (regularPercent * 100).ceil(),
                            child: Container(color: Colors.green.shade400),
                          ),
                        if (variablePercent > 0)
                          Expanded(
                            flex: (variablePercent * 100).ceil(),
                            child: Container(color: Colors.orange.shade400),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${context.l10n.regularIncome} %${regularPercent.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${context.l10n.variableIncome} %${variablePercent.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tavsiye notu
                Row(
                  children: [
                    Icon(adviceIcon, size: 16, color: adviceColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        adviceText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyEarningRate(double totalIncome) {
    if (totalIncome <= 0) return const SizedBox.shrink();

    final now = DateTime.now();
    final selected = _controller.selectedMonth;
    final limit = _controller.historyLimit;

    // Dönemin toplam gün sayısını hesapla (geçen gün sayısı DEĞİL)
    int totalDays;
    if (limit == -1) {
      // Belirli bir ay seçildi → o ayın toplam gün sayısı
      totalDays = DateTime(selected.year, selected.month + 1, 0).day;
    } else if (limit == 30) {
      // Bu Ay (This Calendar Month) → bu ayın toplam gün sayısı
      totalDays = DateTime(now.year, now.month + 1, 0).day;
    } else if (limit == 366) {
      // Bu Yıl (This Calendar Year) → yılın toplam gün sayısı
      final isLeap =
          (now.year % 4 == 0 && now.year % 100 != 0) || (now.year % 400 == 0);
      totalDays = isLeap ? 366 : 365;
    } else {
      // 7, 90, 180, 365 → doğrudan kullan
      totalDays = limit;
    }
    if (totalDays <= 0) totalDays = 1;

    final dailyAvg = totalIncome / totalDays;
    final incomeCount = _controller.currentIncomes.length;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.dailyEarningRate,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showDetailBottomSheet(
                  title: context.l10n.dailyEarningRateDetailTitle,
                  body: context.l10n.dailyEarningRateDetailBody,
                  icon: Icons.speed_rounded,
                  iconColor: Colors.green,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.speed_rounded,
                    color: Colors.green.shade400,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.format(dailyAvg),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.dailyAverage,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$totalDays ${context.l10n.daysElapsed}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$incomeCount ${context.l10n.incomeTransactions}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsPotential(double totalIncome, double totalExpense) {
    if (totalIncome <= 0) return const SizedBox.shrink();

    final savings = totalIncome - totalExpense;
    final savingsPercent = (savings / totalIncome * 100).clamp(-999.0, 100.0);

    String message;
    Color statusColor;
    IconData statusIcon;

    if (totalExpense <= 0) {
      // Hiç harcama yok
      message = context.l10n.savingsPotentialNoExpense;
      statusColor = Colors.green;
      statusIcon = Icons.celebration_rounded;
    } else if (savings >= 0) {
      // Pozitif tasarruf
      message = context.l10n.savingsPotentialPositive(
        '%${savingsPercent.toStringAsFixed(0)}',
      );
      statusColor = Colors.green;
      statusIcon = Icons.savings_rounded;
    } else {
      // Negatif (açık)
      message = context.l10n.savingsPotentialNegative;
      statusColor = Colors.red;
      statusIcon = Icons.warning_rounded;
    }

    // Progress bar: 0-1 arası (ne kadar tasarruf?)
    final progressValue = savingsPercent > 0 ? savingsPercent / 100.0 : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.savingsPotential,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showDetailBottomSheet(
                  title: context.l10n.savingsPotentialDetailTitle,
                  body: context.l10n.savingsPotentialDetailBody,
                  icon: Icons.savings_rounded,
                  iconColor: Colors.green,
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(savings.abs()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
