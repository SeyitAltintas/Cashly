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

  @override
  Widget build(BuildContext context) {
    final isObscured = context.select((DashboardController c) => c.isObscured);

    return AnimatedCard(
      delay: 100,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3460).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Sol alt dekoratif parıltı
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Sağ üst dekoratif parıltı
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Kart İçeriği
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              context.l10n.totalBalance,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _toggleObscure,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () => _cycleCurrency(context),
                      child: ObscuredAmountText(
                        CurrencyFormatter.format(widget.totalBalance),
                        isObscured: isObscured,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1.5,
                          color: widget.totalBalance >= 0
                              ? Colors.white
                              : Colors.red.shade300,
                        ),
                      ),
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
