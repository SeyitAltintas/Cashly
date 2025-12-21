import 'package:flutter/material.dart';
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

/// Dashboard Sayfası
/// Ana finansal özeti gösterir
class DashboardPage extends StatelessWidget {
  final String userName;
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Asset> varliklar;
  final List<PaymentMethod> odemeYontemleri;
  final double butceLimiti;
  final DateTime secilenAy;
  final StreakData streakData;

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
  });

  /// Saate göre selamlama mesajı
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return "İyi geceler";
    if (hour < 12) return "Günaydın";
    if (hour < 18) return "İyi günler";
    return "İyi akşamlar";
  }

  /// Aylık toplam harcamayı hesaplar
  double _getMonthlyExpense() {
    double total = 0;
    for (var h in harcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null &&
          tarih.year == secilenAy.year &&
          tarih.month == secilenAy.month) {
        total += (h['tutar'] as num?)?.toDouble() ?? 0;
      }
    }
    return total;
  }

  /// Aylık toplam geliri hesaplar
  double _getMonthlyIncome() {
    double total = 0;
    for (var g in gelirler) {
      if (g.isDeleted) continue;
      if (g.date.year == secilenAy.year && g.date.month == secilenAy.month) {
        total += g.amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final totalBalance = BalanceCard.calculateTotalBalance(odemeYontemleri);
    final totalCreditDebt = BalanceCard.calculateTotalCreditDebt(
      odemeYontemleri,
    );
    final monthlyExpense = _getMonthlyExpense();
    final monthlyIncome = _getMonthlyIncome();
    final netDiff = monthlyIncome - monthlyExpense;
    final totalAssets = AssetSummaryCard.calculateTotalAssetValue(varliklar);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hoş Geldin Bölümü
              _buildGreetingSection(context, greeting),
              const SizedBox(height: 24),

              // Toplam Bakiye Kartı
              BalanceCard(totalBalance: totalBalance),
              const SizedBox(height: 12),

              // Kredi Kartı Borcu (varsa göster)
              CreditDebtCard(totalDebt: totalCreditDebt),
              const SizedBox(height: 20),

              // Bu Ay Özeti
              MonthlySummaryCard(
                monthlyExpense: monthlyExpense,
                monthlyIncome: monthlyIncome,
                netDiff: netDiff,
              ),
              const SizedBox(height: 20),

              // Bütçe Durumu
              BudgetStatusCard(
                monthlyExpense: monthlyExpense,
                butceLimiti: butceLimiti,
              ),
              const SizedBox(height: 20),

              // Varlık Özeti
              AssetSummaryCard(totalAssets: totalAssets),
              const SizedBox(height: 20),

              // Son İşlemler
              RecentTransactionsCard(
                harcamalar: harcamalar,
                gelirler: gelirler,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Hoş geldin bölümünü oluşturur
  Widget _buildGreetingSection(BuildContext context, String greeting) {
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
                  "$greeting,",
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
          // Sağ taraf: Seri widget'ı
          StreakWidget(streakData: streakData),
        ],
      ),
    );
  }
}
