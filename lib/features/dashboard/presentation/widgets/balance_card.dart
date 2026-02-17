import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Toplam Bakiye Kartı Widget'ı
/// Dashboard'da toplam finansal durumu gösterir
class BalanceCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(totalBalance),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: totalBalance >= 0
                    ? Colors.green.shade300
                    : Colors.red.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
