import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../controllers/dashboard_controller.dart';

/// Toplam Bakiye Kartı Widget'ı
/// Dashboard'da toplam finansal durumu gösterir
class BalanceCard extends StatefulWidget {
  final double totalBalance;

  const BalanceCard({super.key, required this.totalBalance});

  /// Nakit ve Banka hesaplarından toplam bakiyeyi hesaplar
  /// Kredi kartları dahil edilmez
  static double calculateTotalBalance(List<PaymentMethod> odemeYontemleri) {
    double total = 0;
    for (var pm in odemeYontemleri.where((p) => !p.isDeleted)) {
      // Sadece nakit ve banka hesaplarını dahil et
      if (pm.type != 'kredi') {
        total += pm.balance;
      }
    }
    return total;
  }

  /// Toplam kredi kartı borcunu hesaplar
  /// Not: Kredi kartı bakiyeleri negatif olarak saklanır, bu yüzden abs() kullanıyoruz
  static double calculateTotalCreditDebt(List<PaymentMethod> odemeYontemleri) {
    double total = 0;
    for (var pm in odemeYontemleri.where((p) => !p.isDeleted)) {
      if (pm.type == 'kredi') {
        // Bakiye negatif olarak saklanıyor, pozitif borç değeri için abs() kullan
        total += pm.balance.abs();
      }
    }
    return total;
  }

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  DateTime? _lastTapTime;

  void _cycleCurrency(BuildContext context) {
    // Çok hızlı peş peşe basmaları önlemek için 500 ms'lik bir koruma (throttle)
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500) {
      return;
    }
    _lastTapTime = now;

    HapticService.selectionClick();
    final currencyService = context.read<CurrencyService>();
    final currentCurrency = currencyService.currentCurrency;

    // Sadece TRY ve USD arasında geçiş yap
    final nextCurrency = currentCurrency == 'TRY' ? 'USD' : 'TRY';

    currencyService.setCurrency(nextCurrency);
  }

  void _toggleObscure() {
    HapticService.selectionClick();
    context.read<DashboardController>().toggleObscured();
  }

  double _calculateCashBalance(BuildContext context) {
    try {
      final controller = context.read<DashboardController>();
      final currencyService = context.read<CurrencyService>();
      final targetCurrency = currencyService.currentCurrency;

      double cashBalance = 0;
      for (var pm in controller.odemeYontemleri.where((p) => !p.isDeleted)) {
        if (pm.type == 'nakit') {
          cashBalance += currencyService.convert(
            pm.balance,
            pm.paraBirimi,
            targetCurrency,
          );
        }
      }
      return cashBalance;
    } catch (e, stackTrace) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isObscured = context.select((DashboardController c) => c.isObscured);
    final monthlyIncome = context.select(
      (DashboardController c) => c.monthlyIncome,
    );

    // Verileri hesapla
    final cashBalance = _calculateCashBalance(context);

    return AnimatedCard(
      delay: 100,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF152A4A), Color(0xFF0A1426)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A1426).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Arka plan dalgası
              Positioned(
                right: -80,
                bottom: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),
              Positioned(
                right: -20,
                top: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                ),
              ),

              // Kart İçeriği
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst Kısım: Başlık ve Göz İkonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.totalBalance,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleObscure,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isObscured
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Orta Kısım: Ana Bakiye
                    GestureDetector(
                      onTap: () => _cycleCurrency(context),
                      child: ObscuredAmountText(
                        CurrencyFormatter.format(widget.totalBalance),
                        isObscured: isObscured,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Bu Ay Geliri
                    Row(
                      children: [
                        const Text(
                          "Bu ay",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ObscuredAmountText(
                          CurrencyFormatter.formatSigned(
                            monthlyIncome,
                            showPlus: true,
                          ),
                          isObscured: isObscured,
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Ayraç Çizgisi
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),

                    const SizedBox(height: 16),

                    // Alt Kısım: Nakit Bilgisi
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Nakit:",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        ObscuredAmountText(
                          CurrencyFormatter.format(cashBalance),
                          isObscured: isObscured,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
