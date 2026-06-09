// ignore_for_file: library_private_types_in_public_api
part of '../pages/analysis_page.dart';

extension ExpenseInsightsExtension on _AnalysisPageState {
  Widget _buildTopExpenses(
    List<Map<String, dynamic>> currentExpenses,
    double totalMonthlyExpense,
  ) {
    if (currentExpenses.isEmpty) return const SizedBox.shrink();

    // "Sabit Giderler" / "Fixed Expenses" kategorisini hariç tut
    final filteredExpenses = currentExpenses.where((h) {
      final cat = h['kategori']?.toString() ?? '';
      final catLower = cat.toLowerCase();
      return catLower != 'sabit giderler' && catLower != 'fixed expenses';
    }).toList();

    // Döviz dönüştürülmüş tutara göre en yüksek 3 işlemi bul
    final curService = getIt<CurrencyService>();
    final sortedExpenses = List<Map<String, dynamic>>.from(filteredExpenses)
      ..sort((a, b) {
        final double valA = (a['tutar'] as num?)?.toDouble() ?? 0.0;
        final double valB = (b['tutar'] as num?)?.toDouble() ?? 0.0;
        final pbA = a['paraBirimi']?.toString() ?? 'TRY';
        final pbB = b['paraBirimi']?.toString() ?? 'TRY';
        final convertedA = curService.convert(
          valA,
          pbA,
          curService.currentCurrency,
        );
        final convertedB = curService.convert(
          valB,
          pbB,
          curService.currentCurrency,
        );
        return convertedB.compareTo(convertedA);
      });

    final top3 = sortedExpenses.take(3).toList();
    if (top3.isEmpty || top3.every((e) => (e['tutar'] as num? ?? 0.0) == 0.0)) {
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
              Text(
                context.l10n.topExpenses,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 16,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.topExpensesDescription,
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
                final expense = top3[index];
                final category =
                    expense['kategori']?.toString() ??
                    context.l10n.notSpecified;
                final expenseName =
                    expense['isim']?.toString() ??
                    context.translateDbName(category);
                final amount = (expense['tutar'] as num?)?.toDouble() ?? 0.0;
                final currency = expense['paraBirimi']?.toString() ?? 'TRY';
                final note =
                    expense['ikinciAciklama']?.toString() ??
                    expense['kategoriAyrinti']?.toString() ??
                    '';

                // Orijinal tutarı base currency'e çevir
                final curService = getIt<CurrencyService>();
                final convertedAmount = curService.convert(
                  amount,
                  currency,
                  curService.currentCurrency,
                );

                // Tarih bilgisini al ve formatla
                final tarihStr = expense['tarih']?.toString();
                String dateText = '';
                if (tarihStr != null) {
                  final date = DateTime.tryParse(tarihStr);
                  if (date != null) {
                    dateText =
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                  }
                }

                // İkonu bul
                IconData categoryIcon =
                    widget.expenseCategoryIcons?[category] ??
                    Icons.category_rounded;

                // Her işlem için o harcama paletindeki zıt renklerden birini seç
                final Color iconColor = AnalysisColors
                    .expenseColors[index % AnalysisColors.expenseColors.length];

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
                        child: Icon(categoryIcon, color: iconColor, size: 24),
                      ),
                      title: Text(
                        expenseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (dateText.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          if (currency != curService.currentCurrency) ...[
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
                        ],
                      ),
                    ),
                    // Son eleman değilse araya çizgi koy
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

  Widget _buildPaymentMethodDistribution({bool isExpense = true}) {
    final Map<String, double> pmTotals = isExpense
        ? _controller.expensePaymentMethodTotals
        : _controller.incomePaymentMethodTotals;
    final double pmTotal = isExpense
        ? _controller.totalMonthlyExpense
        : _controller.totalMonthlyIncome;

    if (pmTotals.isEmpty || pmTotal == 0) return const SizedBox.shrink();

    final List<Color> pmColors = [
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.amber.shade400,
      Colors.cyan.shade400,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isExpense
                ? context.l10n.distributionByPaymentMethod
                : context.l10n.distributionByAccount,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pmTotals.length,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final entry = pmTotals.entries.elementAt(index);
                final color = pmColors[index % pmColors.length];
                return _buildPaymentMethodCard(
                  entry.key,
                  entry.value,
                  pmTotal,
                  color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
