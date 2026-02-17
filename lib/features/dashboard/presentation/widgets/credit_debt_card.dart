import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/extensions/l10n_extensions.dart';

/// Kredi Kartı Borç Kartı Widget'ı
/// Dashboard'da toplam kredi kartı borcunu gösterir
class CreditDebtCard extends StatelessWidget {
  final double totalDebt;

  const CreditDebtCard({super.key, required this.totalDebt});

  @override
  Widget build(BuildContext context) {
    // Borç yoksa widget'ı gösterme
    if (totalDebt <= 0) {
      return const SizedBox.shrink();
    }

    return AnimatedCard(
      delay: 150,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade900.withValues(alpha: 0.3),
              Colors.red.shade800.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade400.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // İkon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade400.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.credit_card,
                color: Colors.red.shade300,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Metin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.creditCardDebt,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalDebt),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
