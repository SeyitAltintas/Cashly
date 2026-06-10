import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../utils/analysis_colors.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../widgets/analysis_widgets.dart';
import '../widgets/analysis_filters.dart';
import 'pdf_export_page.dart';
import '../controllers/analysis_controller.dart';
import '../../../dashboard/presentation/widgets/budget_status_card.dart';
import '../../../dashboard/presentation/pages/category_budget_detail_page.dart';
import 'package:intl/intl.dart';
part '../views/expense_analysis_view.part.dart';
part '../views/income_analysis_view.part.dart';
part '../views/asset_analysis_view.part.dart';
part '../widgets/analysis_charts.part.dart';
part '../widgets/expense_insights.part.dart';
part '../widgets/income_insights.part.dart';
part '../widgets/asset_insights.part.dart';
part '../widgets/analysis_components.part.dart';

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
  final ValueNotifier<ChartViewType> _chartTypeNotifier = ValueNotifier(
    ChartViewType.pie,
  );
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
    _controller.addListener(_onControllerChanged);
    _tabController = TabController(length: 3, vsync: this);

    // Verileri Controller'a push et ve state'i ayarla
    _controller.initData(
      harcamalar: widget.expenses,
      gelirler: widget.incomes,
      varliklar: widget.assets,
      odemeYontemleri: widget.paymentMethods,
      secilenAy: widget.selectedDate,
      userId: widget.userId,
    );

    // Sekme değiştiğinde touchedIndex'i sıfırla ve UI'yi (örn. AppBar) güncelle
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.resetTouchedIndex();
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
        userId: widget.userId,
      );
    }
  }

  void _onControllerChanged() {
    // Scaffold ListenableBuilder ile rebuild edilecek, setState kullanmıyoruz
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _chartTypeNotifier.dispose();
    // Controller singleton olduğu için dispose etmiyoruz
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: Listenable.merge([_controller, _tabController]),
          builder: (context, _) => _buildAppBar(context),
        ),
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([_controller, _tabController]),
            builder: (context, _) => _buildStickyHeader(context),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (_controller.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface),
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildExpenseAnalysis(),
                    _buildIncomeAnalysis(),
                    _buildAssetAnalysis(),
                  ],
                );
              },
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
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(context.l10n.analysisAndReports),
      actions: [
        if (!_isCurrentTabEmpty)
          IconButton(
            icon: Icon(Icons.file_download_outlined, color: Theme.of(context).colorScheme.onSurface),
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
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
                    labelColor: Theme.of(context).colorScheme.onSurface,
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
          Expanded(child: TimeFilterSelector(controller: _controller)),
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
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChartTypeToggle(
                    type: ChartViewType.pie,
                    icon: Icons.pie_chart_rounded,
                    chartTypeNotifier: _chartTypeNotifier,
                  ),
                  ChartTypeToggle(
                    type: ChartViewType.bar,
                    icon: Icons.bar_chart_rounded,
                    chartTypeNotifier: _chartTypeNotifier,
                  ),
                  ChartTypeToggle(
                    type: ChartViewType.line,
                    icon: Icons.show_chart_rounded,
                    chartTypeNotifier: _chartTypeNotifier,
                  ),
                ],
              ),
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
    if (colors.isEmpty) return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return colors[index % colors.length];
  }

  /// Pasta grafiği widget'ı

  /// Ortak chart wrapper (Toggle + Chart)

  /// Çizgi (Line) Grafik widget'ı

  /// Çubuk (Bar) Grafik widget'ı

  /// Ödeme yöntemine göre dağılım

  /// En yüksek 3 harcamayı gösteren widget
  // ========== VARLIK ANALİZİ WİDGET'LARI ==========

  /// Özellik 1: Kârlılık Liderleri - ROI en yüksek 3 varlık

  /// Özellik 2: Portföy Çeşitliliği

  /// Özellik 3: Likidite Durumu

  // ========== GELİR ANALİZİ WİDGET'LARI ==========

  /// Özellik 1: En Büyük 3 Gelir (Düzenli gelirler hariç)
  /// Controller üzerinden tüm tarihsel veriye bakarak düzenli kategorileri tespit eder.
  /// Farklı aylarda 2+ kez görünen kategoriler "düzenli" sayılır.

  /// Özellik 2: Gelir Kararlılığı (Düzenli vs Değişken)

  /// Özellik 3: Günlük Kazanç Hızı
  /// Her zaman dönemin TOPLAM gün sayısına böler (geçen gün sayısına değil).
  /// Böylece maaş gibi toplu ödemeler ayın 10'unda girse bile
  /// günlük oran yapay şekilde şişirilmez.

  /// Özellik 5: Tasarruf Potansiyeli

  /// Bilgi kartı (boş durumlar için yeniden kullanılabilir)

  /// Detaylı bilgi bottom sheet'i göster
}

class AnalysisShimmerLayout extends StatelessWidget {
  const AnalysisShimmerLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.auto(
      context: context,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Chart Placeholder
            const SizedBox(height: 16),
            const ShimmerCircle(size: 200),
            const SizedBox(height: 32),

            // List Items Placeholder
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      ShimmerCircle(size: 48),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 120, height: 16),
                            SizedBox(height: 8),
                            ShimmerBox(width: 80, height: 12),
                          ],
                        ),
                      ),
                      ShimmerBox(width: 60, height: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
