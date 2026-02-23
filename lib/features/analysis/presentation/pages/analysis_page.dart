import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
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
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AnalysisController _controller;

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
    // Sekme değiştiğinde touchedIndex'i sıfırla
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.resetTouchedIndex();
      }
    });
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
    );
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
        IconButton(
          icon: const Icon(Icons.file_download_outlined, color: Colors.white),
          tooltip: context.l10n.downloadReportTooltip,
          onPressed: _showExportSheet,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
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
                  gradient: LinearGradient(colors: [tabColor, tabColorDark]),
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
  Widget _buildExpenseAnalysis() {
    final monthlyExpenses = widget.expenses.where((h) {
      if (h['silindi'] == true) return false;
      DateTime date =
          DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
      return date.year == widget.selectedDate.year &&
          date.month == widget.selectedDate.month;
    }).toList();

    if (monthlyExpenses.isEmpty) {
      return AnalysisEmptyState(
        message: context.l10n.noExpenseDataForThisMonth,
      );
    }

    // Kategori toplamları
    final (totals, totalAmount) = _calculateCategoryTotals(monthlyExpenses);
    final (topCategory, topAmount) = _findTopCategory(totals);
    final sections = _buildPieChartSections(totals, totalAmount, expenseColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisHeaderCard(
            title: context.l10n.totalExpenseLabel,
            totalAmount: CurrencyFormatter.format(totalAmount),
            primaryColor: Colors.red.shade300,
            icon: Icons.trending_down,
            topCategoryLabel: context.l10n.highestExpense,
            topCategoryName: topCategory,
            topCategoryAmount: CurrencyFormatter.format(topAmount),
          ),
          const SizedBox(height: 24),
          _buildPieChart(sections),
          const SizedBox(height: 24),
          _buildCategoryList(
            context.l10n.categoryDistribution,
            totals,
            totalAmount,
            expenseColors,
            categoryBudgets: widget.categoryBudgets,
          ),
          if (widget.paymentMethods.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildPaymentMethodDistribution(monthlyExpenses),
          ],
        ],
      ),
    );
  }

  /// Gelir Analizi
  Widget _buildIncomeAnalysis() {
    final monthlyIncomes = widget.incomes.where((i) {
      if (i.isDeleted) return false;
      return i.date.year == widget.selectedDate.year &&
          i.date.month == widget.selectedDate.month;
    }).toList();

    if (monthlyIncomes.isEmpty) {
      return AnalysisEmptyState(message: context.l10n.noIncomeDataForThisMonth);
    }

    // Kategori toplamları
    Map<String, double> totals = {};
    double totalIncome = 0;
    final cur = getIt<CurrencyService>();
    for (var income in monthlyIncomes) {
      double amount = cur.convert(
        income.amount,
        income.paraBirimi,
        cur.currentCurrency,
      );
      totals[income.category] = (totals[income.category] ?? 0) + amount;
      totalIncome += amount;
    }

    final (topCategory, topAmount) = _findTopCategory(totals);
    final sections = _buildPieChartSections(totals, totalIncome, incomeColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisHeaderCard(
            title: context.l10n.totalIncomeLabel,
            totalAmount: CurrencyFormatter.format(totalIncome),
            primaryColor: Colors.green.shade300,
            icon: Icons.trending_up,
            topCategoryLabel: context.l10n.highestIncome,
            topCategoryName: topCategory,
            topCategoryAmount: CurrencyFormatter.format(topAmount),
          ),
          const SizedBox(height: 24),
          _buildPieChart(sections),
          const SizedBox(height: 24),
          _buildCategoryList(
            context.l10n.incomeCategories,
            totals,
            totalIncome,
            incomeColors,
          ),
        ],
      ),
    );
  }

  /// Varlık Analizi
  Widget _buildAssetAnalysis() {
    final activeAssets = widget.assets.where((a) => !a.isDeleted).toList();

    if (activeAssets.isEmpty) {
      return AnalysisEmptyState(message: context.l10n.noAssetsAddedYet);
    }

    Map<String, double> totals = {};
    double totalValue = 0;
    final cur = getIt<CurrencyService>();
    for (var asset in activeAssets) {
      String type = asset.type ?? context.l10n.otherStr;
      // amount zaten toplam değeri içeriyor, quantity ile çarpmaya gerek yok
      double value = cur.convert(
        asset.amount,
        asset.paraBirimi,
        cur.currentCurrency,
      );
      totals[type] = (totals[type] ?? 0) + value;
      totalValue += value;
    }

    final (topType, topAmount) = _findTopCategory(totals);
    final sections = _buildPieChartSections(totals, totalValue, assetColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisHeaderCard(
            title: context.l10n.totalAssetLabel,
            totalAmount: CurrencyFormatter.format(totalValue),
            primaryColor: Colors.blue.shade600,
            icon: Icons.diamond_outlined,
            topCategoryLabel: context.l10n.mostValuableType,
            topCategoryName: topType,
            topCategoryAmount: CurrencyFormatter.format(topAmount),
          ),
          const SizedBox(height: 24),
          _buildPieChart(sections),
          const SizedBox(height: 24),
          _buildCategoryList(
            context.l10n.assetTypes,
            totals,
            totalValue,
            assetColors,
          ),
        ],
      ),
    );
  }

  // ========== YARDIMCI METODLAR ==========

  /// Kategori toplamlarını hesaplar
  (Map<String, double>, double) _calculateCategoryTotals(
    List<Map<String, dynamic>> expenses,
  ) {
    Map<String, double> totals = {};
    double totalAmount = 0;
    final cur = getIt<CurrencyService>();
    for (var h in expenses) {
      String cat = context.translateDbName(h['kategori'] ?? 'Diğer');
      double t = double.tryParse(h['tutar'].toString()) ?? 0;
      String pb = h['paraBirimi']?.toString() ?? 'TRY';
      double amount = cur.convert(t, pb, cur.currentCurrency);
      totals[cat] = (totals[cat] ?? 0) + amount;
      totalAmount += amount;
    }
    return (totals, totalAmount);
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
      final color = colors[index % colors.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: '${(value / total * 100).toStringAsFixed(0)}%',
          radius: isTouched ? 90.0 : 80.0,
          titleStyle: TextStyle(
            fontSize: isTouched ? 18.0 : 14.0,
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
  Widget _buildPieChart(List<PieChartSectionData> sections) {
    return Center(
      child: SizedBox(
        height: 220,
        child: PieChart(
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
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: sections,
          ),
        ),
      ),
    );
  }

  /// Kategori listesi widget'ı
  Widget _buildCategoryList(
    String title,
    Map<String, double> totals,
    double total,
    List<Color> colors, {
    Map<String, double>? categoryBudgets,
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
        ...totals.entries.toList().asMap().entries.map((entry) {
          int idx = entry.key;
          var e = entry.value;
          final color = colors[idx % colors.length];
          return LegendItem(
            title: e.key,
            value: e.value,
            color: color,
            total: total,
            budgetLimit: categoryBudgets?[e.key],
          );
        }),
      ],
    );
  }

  /// Ödeme yöntemine göre dağılım
  Widget _buildPaymentMethodDistribution(
    List<Map<String, dynamic>> monthlyExpenses,
  ) {
    Map<String, double> pmTotals = {};
    double pmTotal = 0;
    final cur = getIt<CurrencyService>();

    for (var h in monthlyExpenses) {
      String pmId = h['odemeYontemiId'] ?? 'unknown';
      double t = double.tryParse(h['tutar'].toString()) ?? 0;
      String pb = h['paraBirimi']?.toString() ?? 'TRY';
      double amount = cur.convert(t, pb, cur.currentCurrency);
      pmTotals[pmId] = (pmTotals[pmId] ?? 0) + amount;
      pmTotal += amount;
    }

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
