import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.totalBalance,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _toggleObscure,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          isObscured ? Icons.visibility_off : Icons.visibility,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _cycleCurrency(context),
              child: Text(
                CurrencyFormatter.format(
                  widget.totalBalance,
                  isObscured: isObscured,
                ),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: widget.totalBalance >= 0
                      ? Colors.green.shade300
                      : Colors.red.shade300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
