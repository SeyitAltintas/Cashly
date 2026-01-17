import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../income/data/models/income_model.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../streak/data/models/streak_model.dart';
import '../../../streak/presentation/widgets/streak_widget.dart';
import '../widgets/balance_card.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/budget_status_card.dart';
import '../widgets/asset_summary_card.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/credit_debt_card.dart';
import '../../../payment_methods/data/models/transfer_model.dart';
import '../controllers/dashboard_controller.dart';

/// Dashboard Sayfası
/// Ana finansal özeti gösterir
/// DashboardController ile entegre edilmiştir
class DashboardPage extends StatefulWidget {
  final String userName;
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Asset> varliklar;
  final List<PaymentMethod> odemeYontemleri;
  final double butceLimiti;
  final DateTime secilenAy;
  final StreakData streakData;
  final List<Transfer> transferler;

  const DashboardPage({
    super.key,
    required this.userName,
    required this.harcamalar,
    required this.gelirler,
    required this.varliklar,
    required this.odemeYontemleri,
    required this.butceLimiti,
    required this.secilenAy,
    required this.streakData,
    required this.transferler,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    // DI'dan controller al
    _controller = getIt<DashboardController>();
    // İlk veri yüklemesi
    _updateControllerData();
  }

  @override
  void didUpdateWidget(DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Props değiştiğinde controller'ı güncelle
    if (oldWidget.userName != widget.userName ||
        oldWidget.harcamalar != widget.harcamalar ||
        oldWidget.gelirler != widget.gelirler ||
        oldWidget.varliklar != widget.varliklar ||
        oldWidget.odemeYontemleri != widget.odemeYontemleri ||
        oldWidget.butceLimiti != widget.butceLimiti ||
        oldWidget.secilenAy != widget.secilenAy ||
        oldWidget.streakData != widget.streakData ||
        oldWidget.transferler != widget.transferler) {
      _updateControllerData();
    }
  }

  /// Controller'ı güncel verilerle güncelle
  void _updateControllerData() {
    _controller.updateData(
      userName: widget.userName,
      harcamalar: widget.harcamalar,
      gelirler: widget.gelirler,
      varliklar: widget.varliklar,
      odemeYontemleri: widget.odemeYontemleri,
      transferler: widget.transferler,
      butceLimiti: widget.butceLimiti,
      secilenAy: widget.secilenAy,
      streakData: widget.streakData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DashboardController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hoş Geldin Bölümü
                    _buildGreetingSection(context, controller),
                    const SizedBox(height: 24),

                    // Toplam Bakiye Kartı
                    BalanceCard(totalBalance: controller.totalBalance),
                    const SizedBox(height: 12),

                    // Kredi Kartı Borcu (varsa göster)
                    CreditDebtCard(totalDebt: controller.totalCreditDebt),
                    const SizedBox(height: 20),

                    // Bu Ay Özeti
                    MonthlySummaryCard(
                      monthlyExpense: controller.monthlyExpense,
                      monthlyIncome: controller.monthlyIncome,
                      netDiff: controller.netDiff,
                    ),
                    const SizedBox(height: 20),

                    // Bütçe Durumu
                    BudgetStatusCard(
                      monthlyExpense: controller.monthlyExpense,
                      butceLimiti: controller.butceLimiti,
                    ),
                    const SizedBox(height: 20),

                    // Varlık Özeti
                    AssetSummaryCard(totalAssets: controller.totalAssets),
                    const SizedBox(height: 20),

                    // Son İşlemler
                    RecentTransactionsCard(
                      harcamalar: controller.harcamalar,
                      gelirler: controller.gelirler,
                      transferler: controller.transferler,
                      odemeYontemleri: controller.odemeYontemleri,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Hoş geldin bölümünü oluşturur
  Widget _buildGreetingSection(
    BuildContext context,
    DashboardController controller,
  ) {
    return AnimatedCard(
      delay: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol taraf: Selamlama metni
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${controller.greeting},",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.userName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Sağ taraf: Seri widget'ı
          StreakWidget(streakData: controller.streakData),
        ],
      ),
    );
  }
}
