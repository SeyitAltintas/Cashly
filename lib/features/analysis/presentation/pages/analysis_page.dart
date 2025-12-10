import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../assets/data/models/asset_model.dart';

class AnalysisPage extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;
  final List<Asset> assets;
  final DateTime selectedDate;

  const AnalysisPage({
    super.key,
    required this.expenses,
    required this.assets,
    required this.selectedDate,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;
  late Map<String, Color> categoryColors;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    categoryColors = {
      'Gelir': Colors.green,
      'Gider': Colors.red,
      'Yatırım': Colors.blue,
      'Diğer': Theme.of(context).colorScheme.surfaceContainerHighest,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Analiz ve Raporlar"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.54),
          tabs: const [
            Tab(text: "Harcamalar"),
            Tab(text: "Varlıklar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildExpenseAnalysis(), _buildAssetAnalysis()],
      ),
    );
  }

  Widget _buildExpenseAnalysis() {
    // Filter expenses for the selected month
    List<Map<String, dynamic>> monthlyExpenses = widget.expenses.where((h) {
      if (h['silindi'] == true) return false;
      DateTime date =
          DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
      return date.year == widget.selectedDate.year &&
          date.month == widget.selectedDate.month;
    }).toList();

    if (monthlyExpenses.isEmpty) {
      return _buildEmptyState("Bu ay için harcama verisi yok.");
    }

    // Calculate totals by category
    Map<String, double> totals = {};
    double totalAmount = 0;

    for (var h in monthlyExpenses) {
      String cat = h['kategori'] ?? "Diğer";
      double amount = double.tryParse(h['tutar'].toString()) ?? 0;
      totals[cat] = (totals[cat] ?? 0) + amount;
      totalAmount += amount;
    }

    final List<Color> vibrantColors = [
      const Color(0xFFFF5252), // Canlı Kırmızı
      const Color(0xFFFF6F00), // Koyu Turuncu
      const Color(0xFFFFC107), // Sarı/Amber
      const Color(0xFF00C853), // Canlı Yeşil
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF2196F3), // Mavi
      const Color(0xFF9C27B0), // Mor
      const Color(0xFFE91E63), // Pembe
      const Color(0xFF4CAF50), // Yeşil
      const Color(0xFFFF9800), // Turuncu
      const Color(0xFF673AB7), // Derin Mor
      const Color(0xFF03A9F4), // Açık Mavi
      const Color(0xFFCDDC39), // Lime
      const Color(0xFFFF5722), // Derin Turuncu
    ];

    List<PieChartSectionData> sections = [];
    int index = 0;
    totals.forEach((key, value) {
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 110.0 : 100.0;
      final color = vibrantColors[index % vibrantColors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: '${(value / totalAmount * 100).toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      );
      index++;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildSummaryCard(
            "Toplam Harcama",
            "${totalAmount.toStringAsFixed(2)} ₺",
            ColorConstants.kirmiziVurgu,
          ),
          const SizedBox(height: 20),
          ...totals.entries.toList().asMap().entries.map((entry) {
            int idx = entry.key;
            var e = entry.value;
            final color = vibrantColors[idx % vibrantColors.length];
            return _buildLegendItem(e.key, e.value, color, totalAmount);
          }),
        ],
      ),
    );
  }

  Widget _buildAssetAnalysis() {
    List<Asset> activeAssets = widget.assets
        .where((a) => !a.isDeleted)
        .toList();

    if (activeAssets.isEmpty) {
      return _buildEmptyState("Henüz varlık eklenmemiş.");
    }

    Map<String, double> totals = {};
    double totalValue = 0;

    for (var asset in activeAssets) {
      String type = asset.type ?? "Diğer";
      // Calculate total value based on amount * quantity if applicable, or just amount
      // Assuming amount is unit price and quantity is count, or amount is total value.
      // Based on previous context, 'amount' seems to be total value or unit price depending on implementation.
      // Let's check AddAssetSheet. It has 'amount' (Miktar/Değer) and 'quantity' (Adet).
      // If quantity is > 0, total = amount * quantity? Or is amount the total value?
      // In AddAssetSheet: "Miktar(TL)" is entered. "Adet" is entered.
      // Usually users enter Unit Price * Quantity = Total.
      // However, in simple apps, users might just enter "Total Value".
      // Let's assume 'amount' is the value the user sees as "Miktar".
      // If the user enters "Gram Altın", "10 Adet", "2500 TL" (Unit Price), then total is 25000.
      // But if the user enters "Nakit", "1 Adet", "5000 TL", total is 5000.
      // Let's assume 'amount' is the TOTAL value for simplicity unless we see calculation logic elsewhere.
      // Checking home_page.dart... it just lists assets.
      // Let's assume 'amount' is the value to sum up.

      double value = asset.amount;
      // If quantity is used for calculation it should be handled in the model or service.
      // For now, I will use 'amount' as the value.

      totals[type] = (totals[type] ?? 0) + value;
      totalValue += value;
    }

    List<PieChartSectionData> sections = [];
    int index = 0;
    final List<Color> vibrantColors = [
      Theme.of(context).colorScheme.secondary,
      const Color(0xFF03DAC6),
      const Color(0xFFCF6679),
      const Color(0xFF3700B3),
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.tealAccent,
      Colors.amberAccent,
      Colors.lightGreenAccent,
    ];

    totals.forEach((key, value) {
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 110.0 : 100.0;
      final color = vibrantColors[index % vibrantColors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: '${(value / totalValue * 100).toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      );
      index++;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildSummaryCard(
            "Toplam Varlık",
            "${totalValue.toStringAsFixed(2)} ₺",
            Colors.greenAccent,
          ),
          const SizedBox(height: 20),
          ...totals.entries.toList().asMap().entries.map((entry) {
            int idx = entry.key;
            var e = entry.value;
            final color = vibrantColors[idx % vibrantColors.length];
            return _buildLegendItem(e.key, e.value, color, totalValue);
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 80, color: Colors.white12),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String title,
    double value,
    Color color,
    double total,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${value.toStringAsFixed(2)} ₺",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "%${(value / total * 100).toStringAsFixed(1)}",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
