import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/network_status_icon.dart';
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
import 'category_budget_detail_page.dart';

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
  final Map<String, double>? categoryBudgets;

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
    this.categoryBudgets,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateControllerData();
      }
    });
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateControllerData();
        }
      });
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
    // Kategori bütçelerini ayrıca set et (opsiyonel parametre)
    if (widget.categoryBudgets != null) {
      _controller.setCategoryBudgets(widget.categoryBudgets!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hoş Geldin Bölümü
                _GreetingSection(),
                SizedBox(height: 24),

                // Toplam Bakiye Kartı
                _BalanceSection(),
                SizedBox(height: 12),

                // Kredi Kartı Borcu
                _CreditDebtSection(),
                SizedBox(height: 20),

                // Bu Ay Özeti
                _MonthlySummarySection(),
                SizedBox(height: 20),

                // Bütçe Durumu
                _BudgetStatusSection(),
                SizedBox(height: 20),

                // Varlık Özeti
                _AssetSummarySection(),
                SizedBox(height: 20),

                // Son İşlemler
                _RecentTransactionsSection(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    final userName = context.select((DashboardController c) => c.userName);
    final streakData = context.select((DashboardController c) => c.streakData);

    return AnimatedCard(
      delay: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_getGreeting(context)},",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NetworkStatusIcon(),
              const SizedBox(width: 8),
              StreakWidget(streakData: streakData),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 6) return context.l10n.goodNight;
    if (hour < 12) return context.l10n.goodMorning;
    if (hour < 18) return context.l10n.goodAfternoon;
    return context.l10n.goodEvening;
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection();
  @override
  Widget build(BuildContext context) {
    final balance = context.select((DashboardController c) => c.totalBalance);
    return BalanceCard(totalBalance: balance);
  }
}

class _CreditDebtSection extends StatelessWidget {
  const _CreditDebtSection();
  @override
  Widget build(BuildContext context) {
    final debt = context.select((DashboardController c) => c.totalCreditDebt);
    return CreditDebtCard(totalDebt: debt);
  }
}

class _MonthlySummarySection extends StatelessWidget {
  const _MonthlySummarySection();
  @override
  Widget build(BuildContext context) {
    final expense = context.select((DashboardController c) => c.monthlyExpense);
    final income = context.select((DashboardController c) => c.monthlyIncome);
    final netDiff = context.select((DashboardController c) => c.netDiff);
    return MonthlySummaryCard(
      monthlyExpense: expense,
      monthlyIncome: income,
      netDiff: netDiff,
    );
  }
}

class _BudgetStatusSection extends StatelessWidget {
  const _BudgetStatusSection();
  @override
  Widget build(BuildContext context) {
    // Tüm güncellemeleri dinlemek için Consumer kullanıyoruz
    // çünkü bütçe kartı çok fazla değişkene bağlı
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return BudgetStatusCard(
          monthlyExpense: controller.monthlyExpense,
          butceLimiti: controller.butceLimiti,
          categoryBudgets: controller.categoryBudgets,
          categoryExpenses: controller.categoryExpenses,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryBudgetDetailPage(
                  categoryBudgets: controller.categoryBudgets,
                  categoryExpenses: controller.categoryExpenses,
                  totalBudget: controller.butceLimiti,
                  totalExpense: controller.monthlyExpense,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AssetSummarySection extends StatelessWidget {
  const _AssetSummarySection();
  @override
  Widget build(BuildContext context) {
    final assets = context.select((DashboardController c) => c.totalAssets);
    return AssetSummaryCard(totalAssets: assets);
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection();
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return RecentTransactionsCard(
          harcamalar: controller.harcamalar,
          gelirler: controller.gelirler,
          transferler: controller.transferler,
          odemeYontemleri: controller.odemeYontemleri,
        );
      },
    );
  }
}
