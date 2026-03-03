import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../widgets/analysis_widgets.dart';
import 'pdf_export_page.dart';
import '../controllers/analysis_controller.dart';

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
  final Map<String, IconData>? expenseCategoryIcons;
  final Map<String, IconData>? incomeCategoryIcons;
  final VoidCallback? onAddExpensePressed;
  final VoidCallback? onAddIncomePressed;
  final VoidCallback? onAddAssetPressed;

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
    this.expenseCategoryIcons,
    this.incomeCategoryIcons,
    this.onAddExpensePressed,
    this.onAddIncomePressed,
    this.onAddAssetPressed,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AnalysisController _controller;
  bool _isBarChart = false;

  int get _touchedIndex => _controller.touchedIndex;

  // Harcama için kırmızı tonları renk paleti
  static const List<Color> expenseColors = [
    Color(0xFFEF5350), // red.shade400
    Color(0xFFE53935), // red.shade600
    Color(0xFFE57373), // red.shade300
    Color(0xFFD32F2F), // red.shade700
    Color(0xFFFF8A80), // redAccent.shade200
    Color(0xFFF44336), // red.shade500
    Color(0xFFFF5252), // redAccent.shade400
    Color(0xFFC62828), // red.shade800
    Color(0xFFEF9A9A), // red.shade200
    Color(0xFFFF8A80), // redAccent.shade100
  ];

  // Gelir için yeşil tonları renk paleti
  static const List<Color> incomeColors = [
    Color(0xFF66BB6A), // green.shade400
    Color(0xFF43A047), // green.shade600
    Color(0xFF81C784), // green.shade300
    Color(0xFF388E3C), // green.shade700
    Color(0xFF69F0AE), // greenAccent.shade400
    Color(0xFF4CAF50), // green.shade500
    Color(0xFF26A69A), // teal.shade400
    Color(0xFF2E7D32), // green.shade800
  ];

  // Varlık için mavi tonları renk paleti (koyu mavi)
  static const List<Color> assetColors = [
    Color(0xFF1E88E5), // blue.shade600
    Color(0xFF1976D2), // blue.shade700
    Color(0xFF42A5F5), // blue.shade400
    Color(0xFF1565C0), // blue.shade800
    Color(0xFF0D47A1), // blue.shade900
    Color(0xFF2196F3), // blue.shade500
    Color(0xFF1976D2), // blue.shade700
    Color(0xFF0D47A1), // blue.shade900
  ];

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
    if (mounted) setState(() {});
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseAnalysis(),
          _buildIncomeAnalysis(),
          _buildAssetAnalysis(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  bool get _isCurrentTabEmpty {
    switch (_tabController.index) {
      case 0:
        return _controller.monthlyExpenses.isEmpty;
      case 1:
        return _controller.monthlyIncomes.isEmpty;
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
            _buildMonthSelector(context),
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

  /// Ay Değiştirici Widget'ı
  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              final current = _controller.secilenAy;
              _controller.setSecilenAy(
                DateTime(current.year, current.month - 1),
              );
            },
          ),
          Text(
            _formatMonthYear(_controller.secilenAy),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              final current = _controller.secilenAy;
              final next = DateTime(current.year, current.month + 1);
              _controller.setSecilenAy(next);
            },
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    // Sadece ay ve yıl döndürelim
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
  Widget _buildExpenseAnalysis() {
    final monthlyExpenses = _controller.monthlyExpenses;

    if (monthlyExpenses.isEmpty) {
      return AnalysisEmptyState(
        message: context.l10n.noExpenseDataForThisMonth,
        actionText: context.l10n.addExpense,
        icon: Icons.receipt_long_outlined,
        buttonColor: Colors.red.shade400,
        onActionPressed:
            widget.onAddExpensePressed ?? () => Navigator.pop(context),
      );
    }

    final totals = _controller.expenseCategoryTotals;
    final totalAmount = _controller.totalMonthlyExpense;
    final topEntry = _controller.topExpenseCategory;
    final topCategory = topEntry?.key ?? '';
    final topAmount = topEntry?.value ?? 0.0;

    final sections = _buildPieChartSections(totals, totalAmount, expenseColors);

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
                  _buildChartArea(sections, totals, totalAmount, expenseColors),
                  const SizedBox(height: 24),
                  _buildCategoryList(
                    context.l10n.categoryDistribution,
                    totals,
                    totalAmount,
                    expenseColors,
                    isExpense: true,
                    categoryBudgets: widget.categoryBudgets,
                    categoryIcons: widget.expenseCategoryIcons,
                  ),
                  if (widget.paymentMethods.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildPaymentMethodDistribution(),
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

  /// Gelir Analizi
  Widget _buildIncomeAnalysis() {
    final monthlyIncomes = _controller.monthlyIncomes;

    if (monthlyIncomes.isEmpty) {
      return AnalysisEmptyState(
        message: context.l10n.noIncomeDataForThisMonth,
        actionText: context.l10n.addIncome,
        icon: Icons.account_balance_wallet_outlined,
        buttonColor: Colors.green.shade400,
        onActionPressed:
            widget.onAddIncomePressed ?? () => Navigator.pop(context),
      );
    }

    final totals = _controller.incomeCategoryTotals;
    final totalIncome = _controller.totalMonthlyIncome;
    final topEntry = _controller.topIncomeCategory;
    final topCategory = topEntry?.key ?? '';
    final topAmount = topEntry?.value ?? 0.0;

    final sections = _buildPieChartSections(totals, totalIncome, incomeColors);

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
                  _buildChartArea(sections, totals, totalIncome, incomeColors),
                  const SizedBox(height: 24),
                  _buildCategoryList(
                    context.l10n.incomeCategories,
                    totals,
                    totalIncome,
                    incomeColors,
                    isExpense: false,
                    categoryIcons: widget.incomeCategoryIcons,
                  ),
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

  /// Varlık Analizi
  Widget _buildAssetAnalysis() {
    final activeAssets = _controller.activeAssets;

    if (activeAssets.isEmpty) {
      return AnalysisEmptyState(
        message: context.l10n.noAssetsAddedYet,
        actionText: context.l10n.addAsset,
        icon: Icons.diamond_outlined,
        buttonColor: Colors.blue.shade500,
        onActionPressed:
            widget.onAddAssetPressed ?? () => Navigator.pop(context),
      );
    }

    final totals = _controller.assetTypeTotals;
    final totalValue = _controller.totalAssetValue;
    final (topType, topAmount) = _findTopCategory(totals);

    final sections = _buildPieChartSections(totals, totalValue, assetColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            [
                  // Varlıklar için önceki ay hesabımız yok. Fakat sağa kaydırılaablir kart gösterimi için boş veriyle destekleyebiliriz:
                  TrendInsightCard(
                    title: context.l10n.monthlyInsight,
                    currentAmount: totalValue,
                    previousAmount: 0, // Varlık kıyaslaması yapılmıyor
                    isExpense: false,
                    increaseText: '',
                    decreaseText: '',
                    noChangeText: '',
                    topCategoryLabel: context.l10n.mostValuableType,
                    topCategoryName: context.translateDbName(topType),
                    topCategoryAmount: CurrencyFormatter.format(topAmount),
                  ),
                  const SizedBox(height: 24),
                  _buildChartArea(sections, totals, totalValue, assetColors),
                  const SizedBox(height: 24),
                  _buildCategoryList(
                    context.l10n.assetTypes,
                    totals,
                    totalValue,
                    assetColors,
                    isExpense:
                        false, // Varlıklar harcama değildir, detaya girmeyeceğiz fakat parametre gerekli.
                  ),
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

  // ========== YARDIMCI METODLAR ==========

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

  /// Kategori adına göre sabit bir renk üretir
  Color _getColorForCategory(String categoryName, List<Color> colors) {
    if (colors.isEmpty) return Colors.grey;
    int hash = categoryName.hashCode.abs();
    return colors[hash % colors.length];
  }

  /// Pasta grafiği için sections oluşturur
  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> totals,
    double total,
    List<Color> colors,
  ) {
    List<PieChartSectionData> sections = [];
    int index = 0;
    totals.forEach((key, value) {
      final isTouched = index == _touchedIndex;
      final color = _getColorForCategory(key, colors);
      final percentage = (value / total * 100);
      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
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
      index++;
    });
    return sections;
  }

  /// Pasta grafiği widget'ı
  Widget _buildPieChart(
    List<PieChartSectionData> sections,
    double totalAmount, {
    Key? key,
  }) {
    return Center(
      key: key,
      child: SizedBox(
        height: 320,
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
                  Text(
                    context.l10n.total,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.format(totalAmount),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _controller.setTouchedIndex(-1);
                      return;
                    }
                    _controller.setTouchedIndex(
                      pieTouchResponse.touchedSection!.touchedSectionIndex,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 4,
                centerSpaceRadius: 100,
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
    );
  }

  /// Ortak chart wrapper (Toggle + Chart)
  Widget _buildChartArea(
    List<PieChartSectionData> pieSections,
    Map<String, double> totals,
    double totalAmount,
    List<Color> colors,
  ) {
    if (totals.isEmpty || totalAmount == 0) {
      return const SizedBox(height: 320);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(18),
                constraints: const BoxConstraints(minHeight: 36, minWidth: 46),
                renderBorder: false,
                fillColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                selectedColor: Theme.of(context).colorScheme.primary,
                color: Colors.white70,
                isSelected: [!_isBarChart, _isBarChart],
                onPressed: (index) {
                  setState(() {
                    _isBarChart = index == 1;
                  });
                },
                children: const [
                  Icon(Icons.pie_chart_outline, size: 20),
                  Icon(Icons.bar_chart, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _isBarChart
              ? _buildBarChart(
                  totals,
                  totalAmount,
                  colors,
                  key: const ValueKey('bar'),
                )
              : _buildPieChart(
                  pieSections,
                  totalAmount,
                  key: const ValueKey('pie'),
                ),
        ),
      ],
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
            maxY: maxVal * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Theme.of(context).colorScheme.surface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${context.translateDbName(topData[groupIndex].key)}\n',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: CurrencyFormatter.format(rod.toY),
                        style: TextStyle(
                          color: _getColorForCategory(
                            topData[groupIndex].key,
                            colors,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                    // Kırpma işlemi uzun kelimeler için
                    String shortTitle = translated.length > 6
                        ? '${translated.substring(0, 6)}.'
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
              horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.1),
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
                barRods: [
                  BarChartRodData(
                    toY: entryData.value,
                    color: _getColorForCategory(entryData.key, colors),
                    width: 26, // Bar kalınlığını artırdık
                    borderRadius: BorderRadius.circular(
                      6,
                    ), // Tüm kenarları yuvarlak
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal * 1.2, // Track yığını tepeye kadar çıksın
                      color: Theme.of(
                        context,
                      ).colorScheme.surface, // Arkaplanla bütünleşik olsun
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

  /// Kategori Detaylarını Bottom Sheet ile Gösterir
  void _showCategoryDetails(
    BuildContext context,
    String categoryKey,
    bool isExpense,
  ) {
    // Sadece Harcama ve Gelirler için detay gösterebiliriz
    final items = isExpense
        ? _controller.monthlyExpenses
              .where(
                (e) => (e['kategori']?.toString() ?? 'Diğer') == categoryKey,
              )
              .toList()
        : _controller.monthlyIncomes
              .where(
                (g) =>
                    (g.category.isEmpty ? 'Diğer' : g.category) == categoryKey,
              )
              .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.75, // Yüksekliği ekrana göre ayarladık
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Çekme çubuğu
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Başlık
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.translateDbName(categoryKey),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // İçerik Listesi
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.noDetailsFound,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          dynamic item = items[index];
                          String title = '';
                          if (isExpense) {
                            title = item['aciklama']?.toString() ?? '';
                          } else {
                            title = item.name ?? '';
                          }
                          double amount = isExpense
                              ? ((item['tutar'] as num?)?.toDouble() ?? 0.0)
                              : item.amount;
                          String currency = isExpense
                              ? (item['paraBirimi']?.toString() ?? 'TRY')
                              : item.paraBirimi;

                          // Tarih formatı için
                          DateTime date = isExpense
                              ? (DateTime.tryParse(item['tarih'].toString()) ??
                                    DateTime.now())
                              : item.date;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        (isExpense ? Colors.red : Colors.green)
                                            .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isExpense
                                        ? Icons.shopping_bag_outlined
                                        : Icons.account_balance_wallet_outlined,
                                    color: isExpense
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title.isNotEmpty
                                            ? title
                                            : context.translateDbName(
                                                categoryKey,
                                              ), // Açıklama yoksa kategori adını yaz
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${date.day}.${date.month}.${date.year}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${isExpense ? '-' : '+'}${CurrencyFormatter.format(amount, currency: currency)}",
                                  style: TextStyle(
                                    color: isExpense
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Kategori listesi widget'ı
  Widget _buildCategoryList(
    String title,
    Map<String, double> totals,
    double total,
    List<Color> colors, {
    required bool isExpense,
    Map<String, double>? categoryBudgets,
    Map<String, IconData>? categoryIcons,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...totals.entries.toList().map((e) {
          final color = _getColorForCategory(e.key, colors);
          return LegendItem(
            title: context.translateDbName(e.key),
            value: e.value,
            color: color,
            total: total,
            budgetLimit: categoryBudgets?[e.key],
            icon: categoryIcons?[e.key],
            onTap: () {
              if (title != context.l10n.assetTypes) {
                // Varlıklarda detay yok (opsiyonel)
                _showCategoryDetails(context, e.key, isExpense);
              }
            },
          );
        }),
      ],
    );
  }

  /// Ödeme yöntemine göre dağılım
  Widget _buildPaymentMethodDistribution() {
    final Map<String, double> pmTotals = _controller.expensePaymentMethodTotals;
    final double pmTotal = _controller.totalMonthlyExpense;

    if (pmTotals.isEmpty || pmTotal == 0) return const SizedBox.shrink();

    final List<Color> pmColors = [
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.amber.shade400,
      Colors.cyan.shade400,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.distributionByPaymentMethod,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...pmTotals.entries.toList().asMap().entries.map((entry) {
          int idx = entry.key;
          var e = entry.value;
          final color = pmColors[idx % pmColors.length];
          return _buildPaymentMethodItem(e.key, e.value, pmTotal, color);
        }),
      ],
    );
  }

  Widget _buildPaymentMethodItem(
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(pmIcon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pmName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(value / total * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(value),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
