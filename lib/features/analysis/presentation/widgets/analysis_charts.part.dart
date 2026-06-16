// ignore_for_file: library_private_types_in_public_api
part of '../pages/analysis_page.dart';

extension AnalysisChartsExtension on _AnalysisPageState {
  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> totals,
    double total,
    List<Color> colors,
  ) {
    List<PieChartSectionData> sections = [];
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (int index = 0; index < sortedEntries.length; index++) {
      final value = sortedEntries[index].value;
      // fl_chart crashes if value is negative. Safety net:
      final safeValue = value > 0 ? value : 0.0;
      final isTouched = index == _touchedIndex;
      final color = _getColorForIndex(index, colors);
      final percentage = total > 0 ? (safeValue / total * 100) : 0.0;
      sections.add(
        PieChartSectionData(
          color: color,
          value: safeValue,
          title: '${percentage.toStringAsFixed(0)}%',
          showTitle: percentage >= 5.0 || isTouched,
          radius: isTouched ? 50.0 : 40.0,
          titlePositionPercentageOffset: 0.55,
          titleStyle: TextStyle(
            fontSize: isTouched ? 14.0 : 12.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            shadows: [Shadow(color: Theme.of(context).colorScheme.onSurface, blurRadius: 2)],
          ),
        ),
      );
    }
    return sections;
  }

  Widget _buildPieChart(
    List<PieChartSectionData> sections,
    Map<String, double> totals,
    double totalAmount, {
    Key? key,
  }) {
    String centerTitle = context.l10n.total;
    double centerValue = totalAmount;
    String? centerPercentage;

    int safeIndex = _touchedIndex;
    if (safeIndex >= totals.length || safeIndex < 0) {
      safeIndex = -1;
    }

    if (safeIndex != -1) {
      final entries = totals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final entry = entries[safeIndex];
      centerTitle = context.translateDbName(entry.key);
      centerValue = entry.value;
      centerPercentage = totalAmount > 0
          ? '${(centerValue / totalAmount * 100).toStringAsFixed(1)}%'
          : '0.0%';
    }
    return Center(
      key: key,
      child: SizedBox(
        height: 320,
        child: Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ortadaki yazıyı grafiğin içine taşırmamak için width ile sınırlandırıyoruz
                  SizedBox(
                    width: 170, // centerSpaceRadius * 2 den biraz küçük
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            centerTitle,
                            key: ValueKey<String>(centerTitle),
                            style: TextStyle(
                              color: _touchedIndex != -1
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: _touchedIndex != -1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: FittedBox(
                            key: ValueKey<double>(centerValue),
                            fit: BoxFit.scaleDown,
                            child: AmountText(
                              CurrencyFormatter.format(centerValue),
                              style: TextStyle(
                                color: _touchedIndex != -1
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (centerPercentage != null) ...[
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              centerPercentage,
                              key: ValueKey<String>(centerPercentage),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // ANR Çözümü: Yalnızca tıkladıktan sonra parmak kalktığında işlemi algıla.
                          // Ekranda gezinme (Pan/Move) saniyede yüzlerce duruma (setState) yol açıp ana thread'i çökertir.
                          final type = event.runtimeType.toString();
                          if (!type.contains('TapUp') &&
                              !type.contains('TapDown')) {
                            return; // İlgili olmayan eylemleri (scroll, pan) yok say
                          }

                          if (pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _controller.setTouchedIndex(
                              -1,
                            ); // Boşluğa tıklanırsa sıfırla
                            return;
                          }

                          HapticFeedback.lightImpact();

                          int idx = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                          if (idx < 0 || idx >= sections.length) {
                            _controller.setTouchedIndex(-1);
                            return;
                          }

                          _controller.setTouchedIndex(idx);
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                      centerSpaceRadius:
                          100, // oklar için biraz daha küçültebiliriz ya da böyle kalabilir. Oklara yer açmak için.
                      sections: sections,
                    ),
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                    delay: 100.ms,
                  ),
                ],
              ),
            ),
            if (sections.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        int currentIndex = _touchedIndex <= 0
                            ? sections.length
                            : _touchedIndex;
                        int newIndex = currentIndex - 1;
                        if (newIndex < 0) newIndex = sections.length - 1;
                        _controller.setTouchedIndex(newIndex);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 44,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(Icons.keyboard_arrow_up, size: 28),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        int currentIndex = _touchedIndex;
                        if (currentIndex == -1) currentIndex = -1;
                        int newIndex = currentIndex + 1;
                        if (newIndex >= sections.length) newIndex = 0;
                        _controller.setTouchedIndex(newIndex);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 44,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(Icons.keyboard_arrow_down, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartArea(
    List<PieChartSectionData> pieSections,
    Map<String, double> totals,
    double totalAmount,
    List<Color> colors,
  ) {
    if (totals.isEmpty || totalAmount <= 0) {
      return const SizedBox(height: 320);
    }

    return ValueListenableBuilder<ChartViewType>(
      valueListenable: _chartTypeNotifier,
      builder: (context, currentType, _) {
        return Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: _tabController.index == 2
                  ? _buildPieChart(
                      pieSections,
                      totals,
                      totalAmount,
                      key: const ValueKey('pie'),
                    )
                  : currentType == ChartViewType.bar
                  ? _buildBarChart(
                      totals,
                      totalAmount,
                      colors,
                      key: const ValueKey('bar'),
                    )
                  : currentType == ChartViewType.line
                  ? _buildLineChart(key: const ValueKey('line'))
                  : _buildPieChart(
                      pieSections,
                      totals,
                      totalAmount,
                      key: const ValueKey('pie'),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineChart({Key? key}) {
    final isExpense = _tabController.index == 0;
    final dailyData = isExpense
        ? _controller.dailyExpenseTotals
        : _controller.dailyIncomeTotals;

    if (dailyData.isEmpty) {
      return SizedBox(key: key, height: 320);
    }

    // Sort by date
    final sortedEntries = dailyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    double maxY = 0;
    List<FlSpot> spots = [];
    double cumulativeTotal = 0.0;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      cumulativeTotal += entry.value;

      final yValue = _isCumulative ? cumulativeTotal : entry.value;
      if (yValue > maxY) maxY = yValue;
      spots.add(FlSpot(i.toDouble(), yValue));
    }

    // Eğer birikimli (cumulative) ve Gider sekmesinde ise limit çizgisi tüm bütçeyi göstersin
    // Ancak sadece "Bu Ay" (30) veya "Özel Ay" (-1) filtresi seçiliyken aktif olsun.
    final bool isMonthlyView =
        _controller.historyLimit == 30 || _controller.historyLimit == -1;
    final showLimit =
        isExpense && _isCumulative && widget.totalBudget > 0 && isMonthlyView;
    if (showLimit && widget.totalBudget > maxY) {
      maxY = widget.totalBudget * 1.2;
    }

    Widget buildCumulativeToggle(
      bool isCumulativeMode,
      String label,
      IconData icon,
    ) {
      final isSelected = _isCumulative == isCumulativeMode;
      return GestureDetector(
        onTap: () {
          if (_isCumulative != isCumulativeMode) {
            // ignore: invalid_use_of_protected_member
            setState(() {
              _isCumulative = isCumulativeMode;
            });
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      key: key,
      child: Stack(
        children: [
          SizedBox(
            height: 320,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0
                      ? (maxY / 4).clamp(0.1, double.infinity)
                      : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: showLimit
                      ? [
                          HorizontalLine(
                            y: widget.totalBudget,
                            color: ColorConstants.turuncuVurgu.withValues(alpha: 0.5),
                            strokeWidth: 2,
                            dashArray: [8, 4],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.only(
                                right: 5,
                                bottom: 5,
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.turuncuVurgu.withValues(alpha: 0.8),
                              ),
                              labelResolver: (line) =>
                                  'Limit: ${CurrencyFormatter.format(widget.totalBudget)}',
                            ),
                          ),
                        ]
                      : [],
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: (sortedEntries.length / 5).ceilToDouble().clamp(
                        1.0,
                        31.0,
                      ),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedEntries.length) {
                          return const SizedBox.shrink();
                        }

                        // X ekseninde çakışan tarihleri engellemek için sadece meta'nın önerdiği grid hizalarında metni göster
                        if (value != meta.min &&
                            value != meta.max &&
                            value % (sortedEntries.length / 5).ceil() != 0) {
                          return const SizedBox.shrink();
                        }

                        final date = sortedEntries[index].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: sortedEntries.length > 1
                    ? (sortedEntries.length - 1).toDouble()
                    : 1.0,
                minY: 0,
                maxY: maxY > 0 ? maxY * 1.2 : 1.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: isExpense
                        ? ColorConstants.kirmiziVurgu
                        : ColorConstants.yesil,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    shadow: Shadow(
                      color:
                          (isExpense
                                  ? ColorConstants.kirmiziVurgu
                                  : ColorConstants.yesil)
                              .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (isExpense
                                  ? ColorConstants.kirmiziVurgu
                                  : ColorConstants.yesil)
                              .withValues(alpha: 0.3),
                          (isExpense
                                  ? ColorConstants.kirmiziVurgu
                                  : ColorConstants.yesil)
                              .withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.2),
                              strokeWidth: 2,
                              dashArray: [4, 4],
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: isExpense
                                      ? ColorConstants.kirmiziVurgu
                                      : ColorConstants.yesil,
                                  strokeWidth: 3,
                                  strokeColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Theme.of(context).colorScheme.surface,
                    tooltipRoundedRadius: 16,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        // Bounds check to prevent RangeError
                        if (spot.spotIndex < 0 ||
                            spot.spotIndex >= sortedEntries.length) {
                          return null;
                        }
                        final date = sortedEntries[spot.spotIndex].key;

                        return LineTooltipItem(
                          '${date.day} ${_getShortMonthName(context, date.month)}\n',
                          TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            TextSpan(
                              text: CurrencyFormatter.format(spot.y),
                              style: TextStyle(
                                color: isExpense
                                    ? ColorConstants.kirmiziVurgu
                                    : ColorConstants.yesil,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCumulativeToggle(
                    false,
                    context.l10n.daily,
                    Icons.bar_chart_rounded,
                  ),
                  buildCumulativeToggle(
                    true,
                    context.l10n.cumulativeLabel,
                    Icons.show_chart_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    Map<String, double> totals,
    double totalAmount,
    List<Color> colors, {
    Key? key,
  }) {
    final data = totals.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      ); // büyükten küçüğe sıralayalım

    // Çok fazla bar varsa biraz kırpalım (ilk 7 yeterli geri kalanı ufak kalır)
    final topData = data.take(7).toList();

    double maxVal = topData.isNotEmpty ? topData.first.value : 0;

    return Center(
      key: key,
      child: SizedBox(
        height: 320,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal > 0 ? maxVal * 1.2 : 1.0,
            barTouchData: BarTouchData(
              enabled: false, // Dokunma kapatıldı, tooltip sürekliliği sağlandı
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent, // Arkaplan siliyoruz
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 2,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  // split(',') was causing bugs in English locales (e.g. "1,000.00 $" -> "1")
                  String formattedText = CurrencyFormatter.format(rod.toY);
                  // Optionally remove decimal trailing zeros if possible, but safely.
                  formattedText = formattedText.replaceAll(
                    RegExp(r'[,.]00(?=\D*$)'),
                    '',
                  );

                  return BarTooltipItem(
                    formattedText,
                    TextStyle(
                      color: _getColorForIndex(groupIndex, colors),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 32,
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() < 0 || value.toInt() >= topData.length) {
                      return const SizedBox.shrink();
                    }
                    String rawTitle = topData[value.toInt()].key;
                    String translated = context.translateDbName(rawTitle);
                    // Kırpma işlemi uzun kelimeler ve emojiler için (surrogate pair çökmesini önler)
                    String shortTitle = translated.runes.length > 6
                        ? '${String.fromCharCodes(translated.runes.take(6))}.'
                        : translated;

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        shortTitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxVal > 0
                  ? (maxVal / 4).clamp(0.1, double.infinity)
                  : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: topData.asMap().entries.map((entry) {
              final index = entry.key;
              final entryData = entry.value;
              return BarChartGroupData(
                x: index,
                showingTooltipIndicators: [
                  0,
                ], // Her zaman ilk rod (tek rod var zaten) tooltipi gösterilecek
                barRods: [
                  BarChartRodData(
                    toY: entryData.value,
                    color: _getColorForIndex(index, colors),
                    width: 26, // Bar kalınlığını artırdık
                    borderRadius: BorderRadius.circular(
                      6,
                    ), // Tüm kenarları yuvarlak
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal * 1.2, // Track yığını tepeye kadar çıksın
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
