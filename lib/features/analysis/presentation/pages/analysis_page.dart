import 'package:flutter/material.dart';
import '../utils/analysis_colors.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../widgets/analysis_widgets.dart';
import 'pdf_export_page.dart';
import '../controllers/analysis_controller.dart';
import '../../../dashboard/presentation/widgets/budget_status_card.dart';
import '../../../dashboard/presentation/pages/category_budget_detail_page.dart';
import 'package:intl/intl.dart';
part '../views/expense_analysis_view.part.dart';
part '../views/income_analysis_view.part.dart';
part '../views/asset_analysis_view.part.dart';

/// Analiz ve Raporlar Sayfası
/// Harcama, Gelir ve Varlık analizlerini gösterir
class AnalysisPage extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;
  final List<Asset> assets;
  final List<Income> incomes;
  final DateTime selectedDate;
  final List<PaymentMethod> paymentMethods;
  final String userId;
  final String userName;
  final Map<String, double>? categoryBudgets; // Kategori bütçeleri
  final double totalBudget; // Genel butce limiti
  final Map<String, IconData>? expenseCategoryIcons;
  final Map<String, IconData>? incomeCategoryIcons;
  final void Function(DateTime)? onAddExpensePressed;
  final void Function(DateTime)? onAddIncomePressed;
  final void Function(DateTime)? onAddAssetPressed;

  const AnalysisPage({
    super.key,
    required this.expenses,
    required this.assets,
    required this.incomes,
    required this.selectedDate,
    required this.userId,
    required this.userName,
    this.paymentMethods = const [],
    this.categoryBudgets,
    this.totalBudget = 0.0,
    this.expenseCategoryIcons,
    this.incomeCategoryIcons,
    this.onAddExpensePressed,
    this.onAddIncomePressed,
    this.onAddAssetPressed,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

enum ChartViewType { pie, bar, line }


class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AnalysisController _controller;
  ChartViewType _chartType = ChartViewType.pie;
  bool _isCumulative = false;

  int get _touchedIndex => _controller.touchedIndex;

  // Harcamalar için birbirine zıt, okunabilir ve canlı "Sıcak" tonlar
  

  // Gelirler için birbirine zıt, tazeleyici "Doğa / Yeşil" tabanlı tonlar
  

  // Varlıklar için birbirine zıt, güven veren "Deniz / Gökyüzü" tabanlı tonlar
  

  @override
  void initState() {
    super.initState();
    // DI'dan controller al
    _controller = getIt<AnalysisController>();
    _controller.addListener(_onStateChanged);
    _tabController = TabController(length: 3, vsync: this);

    // Verileri Controller'a push et
    _controller.updateData(
      harcamalar: widget.expenses,
      gelirler: widget.incomes,
      varliklar: widget.assets,
      odemeYontemleri: widget.paymentMethods,
      secilenAy: widget.selectedDate,
    );

    // Sekme değiştiğinde touchedIndex'i sıfırla ve UI'yi (örn. AppBar) güncelle
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.resetTouchedIndex();
      }
      if (mounted) {
        setState(() {}); // appBar durumlarının güncellenmesi için
      }
    });
  }

  @override
  void didUpdateWidget(AnalysisPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenses != oldWidget.expenses ||
        widget.incomes != oldWidget.incomes ||
        widget.assets != oldWidget.assets ||
        widget.paymentMethods != oldWidget.paymentMethods ||
        widget.selectedDate != oldWidget.selectedDate) {
      // Değişen yeni verileri kontrolcüye bildir
      _controller.updateData(
        harcamalar: widget.expenses,
        gelirler: widget.incomes,
        varliklar: widget.assets,
        odemeYontemleri: widget.paymentMethods,
        secilenAy: widget.selectedDate,
      );
    }
  }

  void _onStateChanged() {
    // Removed empty setState. UI uses ListenableBuilder now.
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    // Controller singleton olduğu için dispose etmiyoruz
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildStickyHeader(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildExpenseAnalysis(),
                _buildIncomeAnalysis(),
                _buildAssetAnalysis(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  bool get _isCurrentTabEmpty {
    switch (_tabController.index) {
      case 0:
        return _controller.currentExpenses.isEmpty;
      case 1:
        return _controller.currentIncomes.isEmpty;
      case 2:
        return _controller.varliklar.where((a) => !a.isDeleted).isEmpty;
      default:
        return true;
    }
  }

  /// AppBar ve TabBar oluşturur
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(context.l10n.analysisAndReports),
      actions: [
        if (!_isCurrentTabEmpty)
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            tooltip: context.l10n.downloadReportTooltip,
            onPressed: _showExportSheet,
          ),
      ],
    );
  }

  /// Alt Bar (Ay Seçici ve TabBar)
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, child) {
                  final double animValue = _tabController.animation!.value;
                  final int currentIndex = animValue.round();
                  final (tabColor, tabColorDark) = _getTabColors(currentIndex);

                  return TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [tabColor, tabColorDark],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: tabColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(context.l10n.expenseTab),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.trending_up, size: 18),
                            const SizedBox(width: 6),
                            Text(context.l10n.incomeTab),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(context.l10n.assetTab),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sticky Header (Filtre + Toggle)
  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildTimeFilterSelector(context)),
          const SizedBox(width: 8),
          if (!_isCurrentTabEmpty &&
              _tabController.index !=
                  2) // Varlıklar sekmesinde bar/line chart anlamlı olmayabilir ama isterseniz line eklenebilir. Şimdilik harcama/gelir var.
            Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withAlpha(128),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withAlpha(25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleBtn(ChartViewType.pie, Icons.pie_chart_rounded),
                  _buildToggleBtn(ChartViewType.bar, Icons.bar_chart_rounded),
                  _buildToggleBtn(ChartViewType.line, Icons.show_chart_rounded),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(ChartViewType type, IconData icon) {
    final isSelected = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(76),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.white.withAlpha(128),
        ),
      ),
    );
  }

  /// Zaman Filtresi Seçici Widget'ı
  Widget _buildTimeFilterSelector(BuildContext context) {
    String formatMonth(DateTime date) {
      final months = [
        '',
        context.l10n.january,
        context.l10n.february,
        context.l10n.march,
        context.l10n.april,
        context.l10n.may,
        context.l10n.june,
        context.l10n.july,
        context.l10n.august,
        context.l10n.september,
        context.l10n.october,
        context.l10n.november,
        context.l10n.december,
      ];
      return '${months[date.month]} ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_controller.historyLimit == -1) // Özel ay modu ok tuşu
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () {
                final current = _controller.selectedMonth;
                _controller.setSelectedMonth(
                  DateTime(current.year, current.month - 1),
                );
              },
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _controller.historyLimit,
                  isDense: true,
                  isExpanded: true,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 7,
                      child: Text(
                        context.l10n.thisWeek,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text(
                        context.l10n.thisMonth,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 90,
                      child: Text(
                        context.l10n.last3Months,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 180,
                      child: Text(
                        context.l10n.last6Months,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 366,
                      child: Text(
                        context.l10n.thisYear,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 365,
                      child: Text(
                        context.l10n.last1Year,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: -1,
                      child: Text(
                        _controller.historyLimit == -1
                            ? formatMonth(_controller.selectedMonth)
                            : context.l10n.selectMonth,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _controller.setHistoryLimit(value);
                    }
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return [7, 30, 90, 180, 366, 365, -1].map<Widget>((
                      int item,
                    ) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item == -1
                              ? formatMonth(_controller.selectedMonth)
                              : [
                                  context.l10n.thisWeek,
                                  context.l10n.thisMonth,
                                  context.l10n.last3Months,
                                  context.l10n.last6Months,
                                  context.l10n.thisYear,
                                  context.l10n.last1Year,
                                  "",
                                ][[7, 30, 90, 180, 366, 365, -1].indexOf(item)],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),

          if (_controller.historyLimit == -1) // Özel ay modu ok tuşu
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () {
                final current = _controller.selectedMonth;
                _controller.setSelectedMonth(
                  DateTime(current.year, current.month + 1),
                );
              },
            ),
        ],
      ),
    );
  }

  /// PDF export sayfasina git
  void _showExportSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfExportPage(
          userId: widget.userId,
          userName: widget.userName,
          selectedDate: widget.selectedDate,
        ),
      ),
    );
  }

  (Color, Color) _getTabColors(int index) {
    switch (index) {
      case 0:
        return (Colors.red.shade400, Colors.red.shade700);
      case 1:
        return (Colors.green.shade400, Colors.green.shade700);
      case 2:
        return (Colors.blue.shade600, Colors.blue.shade700);
      default:
        return (Colors.red.shade400, Colors.red.shade700);
    }
  }

  /// Harcama Analizi
  

  /// Gelir Analizi
  

  /// Varlık Analizi
  

  // ========== YARDIMCI METODLAR ==========

  String _getShortMonthName(BuildContext context, int month) {
    if (month >= 1 && month <= 12) {
      try {
        final locale = Localizations.localeOf(context).languageCode;
        return DateFormat.MMM(locale).format(DateTime(2024, month, 1));
      } catch (_) {
         // Fallback works natively internally or below
      }
    }
    return '';
  }

  /// En yüksek kategoriyi bulur
  (String, double) _findTopCategory(Map<String, double> totals) {
    String topCategory = '';
    double topAmount = 0;
    totals.forEach((key, value) {
      if (value > topAmount) {
        topAmount = value;
        topCategory = key;
      }
    });
    return (topCategory, topAmount);
  }

  /// Kategori sırasına göre değerine orantılı renk üretir (Koyu -> Açık)
  Color _getColorForIndex(int index, List<Color> colors) {
    if (colors.isEmpty) return Colors.grey;
    return colors[index % colors.length];
  }

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
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      );
    }
    return sections;
  }

  /// Pasta grafiği widget'ı
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
                                  ? Colors.white
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
                            child: Text(
                              CurrencyFormatter.format(centerValue),
                              style: TextStyle(
                                color: _touchedIndex != -1
                                    ? Colors.white
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
                              style: const TextStyle(
                                color: Colors.white,
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
                        int currentIndex = _touchedIndex == -1
                            ? -1
                            : _touchedIndex;
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

  /// Ortak chart wrapper (Toggle + Chart)
  Widget _buildChartArea(
    List<PieChartSectionData> pieSections,
    Map<String, double> totals,
    double totalAmount,
    List<Color> colors,
  ) {
    if (totals.isEmpty || totalAmount <= 0) {
      return const SizedBox(height: 320);
    }

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
              : _chartType == ChartViewType.bar
              ? _buildBarChart(
                  totals,
                  totalAmount,
                  colors,
                  key: const ValueKey('bar'),
                )
              : _chartType == ChartViewType.line
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
  }

  /// Çizgi (Line) Grafik widget'ı
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
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
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
                    ? Colors.white
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                            color: Colors.orange.withValues(alpha: 0.5),
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
                                color: Colors.orange.withValues(alpha: 0.8),
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
                        ? Colors.red.shade400
                        : Colors.green.shade400,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    shadow: Shadow(
                      color:
                          (isExpense
                                  ? Colors.red.shade400
                                  : Colors.green.shade400)
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
                                  ? Colors.red.shade400
                                  : Colors.green.shade400)
                              .withValues(alpha: 0.3),
                          (isExpense
                                  ? Colors.red.shade400
                                  : Colors.green.shade400)
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
                                      ? Colors.red.shade400
                                      : Colors.green.shade400,
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
                        if (spot.spotIndex < 0 || spot.spotIndex >= sortedEntries.length) {
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
                                    ? Colors.red.shade400
                                    : Colors.green.shade400,
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
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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

  /// Çubuk (Bar) Grafik widget'ı
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
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
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
              horizontalInterval: maxVal > 0 ? (maxVal / 4).clamp(0.1, double.infinity) : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.3),
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
                      color: Colors.white.withValues(alpha: 0.1),
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

  /// Ödeme yöntemine göre dağılım
  Widget _buildPaymentMethodDistribution({bool isExpense = true}) {
    final Map<String, double> pmTotals =
        isExpense ? _controller.expensePaymentMethodTotals : _controller.incomePaymentMethodTotals;
    final double pmTotal =
        isExpense ? _controller.totalMonthlyExpense : _controller.totalMonthlyIncome;

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

  /// En yüksek 3 harcamayı gösteren widget
  Widget _buildTopExpenses(List<Map<String, dynamic>> currentExpenses, double totalMonthlyExpense) {
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
        final convertedA = curService.convert(valA, pbA, curService.currentCurrency);
        final convertedB = curService.convert(valB, pbB, curService.currentCurrency);
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
               child: Icon(Icons.warning_rounded, size: 16, color: Colors.red.shade400),
            )
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.topExpensesDescription,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: List.generate(top3.length, (index) {
              final expense = top3[index];
              final category = expense['kategori']?.toString() ?? context.l10n.notSpecified;
              final expenseName = expense['isim']?.toString() ?? context.translateDbName(category);
              final amount = (expense['tutar'] as num?)?.toDouble() ?? 0.0;
              final currency = expense['paraBirimi']?.toString() ?? 'TRY';
              final note = expense['ikinciAciklama']?.toString() ?? expense['kategoriAyrinti']?.toString() ?? '';
              
              // Orijinal tutarı base currency'e çevir
              final curService = getIt<CurrencyService>();
              final convertedAmount = curService.convert(amount, currency, curService.currentCurrency);
              
              // Tarih bilgisini al ve formatla
              final tarihStr = expense['tarih']?.toString();
              String dateText = '';
              if (tarihStr != null) {
                final date = DateTime.tryParse(tarihStr);
                if (date != null) {
                  dateText = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                }
              }

              // İkonu bul
              IconData categoryIcon = widget.expenseCategoryIcons?[category] ?? Icons.category_rounded;
              
              // Her işlem için o harcama paletindeki zıt renklerden birini seç
              final Color iconColor = AnalysisColors.expenseColors[index % AnalysisColors.expenseColors.length];

              return Column(
                children: [
                   ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (dateText.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                             children: [
                                Icon(Icons.calendar_today_outlined, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                                const SizedBox(width: 4),
                                Text(
                                  dateText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                          CurrencyFormatter.format(amount, currency: currency),
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
                               color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                             ),
                           )
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
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
  // ========== VARLIK ANALİZİ WİDGET'LARI ==========

  /// Özellik 1: Kârlılık Liderleri - ROI en yüksek 3 varlık
  Widget _buildTopPerformers(List<Asset> activeAssets) {
    if (activeAssets.isEmpty) return const SizedBox.shrink();

    final curService = getIt<CurrencyService>();

    // purchasePrice == 0 ise ROI hesaplanamaz → hariç tut
    final assetsWithRoi = activeAssets.where((a) => a.purchasePrice > 0).toList();
    if (assetsWithRoi.isEmpty) return const SizedBox.shrink();

    // ROI'ye göre sırala (en yüksek başta)
    assetsWithRoi.sort((a, b) => b.profitLossPercentage.compareTo(a.profitLossPercentage));

    // Sadece kârda olanları göster
    final profitable = assetsWithRoi.where((a) => a.profitLoss > 0).toList();

    if (profitable.isEmpty) {
      return _buildInfoCard(
        icon: Icons.trending_up_rounded,
        iconColor: Colors.blue,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showDetailBottomSheet(
                    title: context.l10n.topPerformersDetailTitle,
                    body: context.l10n.topPerformersDetailBody,
                    icon: Icons.trending_up_rounded,
                    iconColor: Colors.blue,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: List.generate(top3.length, (index) {
              final asset = top3[index];
              final roi = asset.profitLossPercentage;
              final profitAmount = curService.convert(
                asset.profitLoss, asset.paraBirimi, curService.currentCurrency,
              );
              final isProfit = profitAmount >= 0;
              final Color roiColor = isProfit ? Colors.green : Colors.red;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AnalysisColors.assetColors[index % AnalysisColors.assetColors.length].withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.show_chart_rounded,
                        color: AnalysisColors.assetColors[index % AnalysisColors.assetColors.length],
                        size: 24,
                      ),
                    ),
                    title: Text(
                      asset.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      context.translateDbName(asset.category),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roiColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${isProfit ? '+' : ''}${roi.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: roiColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${isProfit ? '+' : ''}${CurrencyFormatter.format(profitAmount)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Özellik 2: Portföy Çeşitliliği
  Widget _buildPortfolioDiversification(Map<String, double> typeTotals, double totalValue) {
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
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
    } else if (isConcentrated) {
      statusTitle = context.l10n.concentratedPortfolio;
      statusDesc = context.l10n.concentratedPortfolioDesc(
        context.translateDbName(dominantType),
        dominantPercent.toStringAsFixed(0),
      );
      statusColor = Colors.orange;
      statusIcon = Icons.pie_chart_rounded;
    } else {
      statusTitle = context.l10n.diversifiedPortfolio;
      statusDesc = context.l10n.diversifiedPortfolioDesc;
      statusColor = Colors.green;
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showDetailBottomSheet(
                title: context.l10n.portfolioDiversificationDetailTitle,
                body: context.l10n.portfolioDiversificationDetailBody,
                icon: Icons.pie_chart_rounded,
                iconColor: Colors.blue,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              // Progress bars for each type
              ...typeTotals.entries.map((entry) {
                final pct = entry.value / totalValue;
                final color = AnalysisColors.assetColors[typeTotals.keys.toList().indexOf(entry.key) % AnalysisColors.assetColors.length];
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
                              fontWeight: FontWeight.bold,
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
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
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

  /// Özellik 3: Likidite Durumu
  Widget _buildLiquidityCheck(List<Asset> activeAssets, double totalValue) {
    if (activeAssets.isEmpty || totalValue <= 0) return const SizedBox.shrink();

    final curService = getIt<CurrencyService>();

    // Yüksek likidite: Altın, Döviz, Kripto, Banka
    // Düşük likidite: Hisse Senedi, Diğer, ve kullanıcı tanımlı bilinmeyen türler
    const highLiquidityCategories = {
      'altın', 'gold',
      'döviz', 'forex', 'currency',
      'kripto', 'crypto',
      'banka', 'bank',
    };

    double highLiquidTotal = 0;
    double lowLiquidTotal = 0;

    for (var asset in activeAssets) {
      final converted = curService.convert(asset.amount, asset.paraBirimi, curService.currentCurrency);
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showDetailBottomSheet(
                title: context.l10n.liquidityDetailTitle,
                body: context.l10n.liquidityDetailBody,
                icon: Icons.water_drop_rounded,
                iconColor: Colors.cyan,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
                        const Icon(Icons.flash_on_rounded, color: Colors.cyan, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.highLiquidity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '%${highPct.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (highPct / 100).clamp(0.0, 1.0),
                            backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation(Colors.cyan),
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
                        const Icon(Icons.hourglass_bottom_rounded, color: Colors.orange, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.lowLiquidity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '%${lowPct.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (lowPct / 100).clamp(0.0, 1.0),
                            backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation(Colors.orange),
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
                icon: isHealthy ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                iconColor: isHealthy ? Colors.green : Colors.orange,
                title: isHealthy ? context.l10n.highLiquidity : context.l10n.lowLiquidity,
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

  // ========== GELİR ANALİZİ WİDGET'LARI ==========


  /// Özellik 1: En Büyük 3 Gelir (Düzenli gelirler hariç)
  /// Controller üzerinden tüm tarihsel veriye bakarak düzenli kategorileri tespit eder.
  /// Farklı aylarda 2+ kez görünen kategoriler "düzenli" sayılır.
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
        final va = curService.convert(a.amount, a.paraBirimi, curService.currentCurrency);
        final vb = curService.convert(b.amount, b.paraBirimi, curService.currentCurrency);
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
               child: Icon(Icons.emoji_events_rounded, size: 16, color: Colors.green.shade400),
            )
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.topIncomesDescription,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: List.generate(top3.length, (index) {
              final income = top3[index];
              final amount = income.amount;
              final currency = income.paraBirimi;
              final convertedAmount = curService.convert(amount, currency, curService.currentCurrency);
              final Color iconColor = AnalysisColors.incomeColors[index % AnalysisColors.incomeColors.length];
              final incomeCatIcon = widget.incomeCategoryIcons?[income.category] ?? Icons.attach_money_rounded;

              // Tarih
              final date = income.date;
              final dateText = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

              return Column(
                children: [
                   ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(incomeCatIcon, color: iconColor, size: 24),
                    ),
                    title: Text(
                      income.name.isNotEmpty ? income.name : context.translateDbName(income.category),
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
                            Icon(Icons.calendar_today_outlined, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Text(
                              dateText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                          CurrencyFormatter.format(amount, currency: currency),
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
                               color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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

  /// Özellik 2: Gelir Kararlılığı (Düzenli vs Değişken)
  Widget _buildIncomeStability(List<Income> currentIncomes, double totalIncome) {
    if (currentIncomes.isEmpty || totalIncome <= 0) return const SizedBox.shrink();

    // Controller'ın tüm geçmişe bakarak hesapladığı düzenli kategorileri al
    final regularCategories = _controller.regularIncomeCategories;
    final curService = getIt<CurrencyService>();
    final categoryAmounts = <String, double>{};

    for (var g in currentIncomes) {
      final val = curService.convert(g.amount, g.paraBirimi, curService.currentCurrency);
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
    final variablePercent = (variableTotal / totalIncome * 100).clamp(0.0, 100.0);

    // Tek kaynak uyarısı vs çeşitli gelir
    final bool isSingleSource = uniqueCategories == 1;
    final String adviceText = isSingleSource
        ? context.l10n.singleSourceWarning
        : context.l10n.stableIncomeNote;
    final Color adviceColor = isSingleSource ? Colors.orange : Colors.green;
    final IconData adviceIcon = isSingleSource ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;

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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
                        width: 10, height: 10,
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
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
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
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

  /// Özellik 3: Günlük Kazanç Hızı
  /// Her zaman dönemin TOPLAM gün sayısına böler (geçen gün sayısına değil).
  /// Böylece maaş gibi toplu ödemeler ayın 10'unda girse bile
  /// günlük oran yapay şekilde şişirilmez.
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
      final isLeap = (now.year % 4 == 0 && now.year % 100 != 0) || (now.year % 400 == 0);
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
                child: Icon(Icons.speed_rounded, color: Colors.green.shade400, size: 28),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalDays ${context.l10n.daysElapsed}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$incomeCount ${context.l10n.incomeTransactions}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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

  /// Özellik 5: Tasarruf Potansiyeli
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
      message = context.l10n.savingsPotentialPositive('%${savingsPercent.toStringAsFixed(0)}');
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

  /// Bilgi kartı (boş durumlar için yeniden kullanılabilir)
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Detaylı bilgi bottom sheet'i göster
  void _showDetailBottomSheet({
    required String title,
    required String body,
    required IconData icon,
    required Color iconColor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Body
              Text(
                body,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.close,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String pmId,
    double value,
    double total,
    Color color,
  ) {
    String pmName = context.l10n.notSpecified;
    IconData pmIcon = Icons.help_outline;

    if (pmId != 'unknown') {
      final pm = widget.paymentMethods.where((p) => p.id == pmId).firstOrNull;
      if (pm != null) {
        pmName = pm.lastFourDigits != null
            ? '${pm.name} ****${pm.lastFourDigits}'
            : pm.name;
        pmIcon = pm.type == 'nakit'
            ? Icons.wallet
            : pm.type == 'kredi'
            ? Icons.credit_card
            : Icons.account_balance;
      }
    }

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(pmIcon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pmName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            CurrencyFormatter.format(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            total > 0 ? '${(value / total * 100).toStringAsFixed(1)}%' : '0.0%',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
