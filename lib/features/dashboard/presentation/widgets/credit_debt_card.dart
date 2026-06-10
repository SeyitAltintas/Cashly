import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';
import '../controllers/dashboard_controller.dart';

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

    final isObscured = context.select((DashboardController c) => c.isObscured);

    return AnimatedCard(
      delay: 150,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorConstants.kirmiziVurgu.withValues(alpha: 0.9),
              ColorConstants.kirmiziVurgu.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            // İkon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.credit_card,
                color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ObscuredAmountText(
                    CurrencyFormatter.format(totalDebt),
                    isObscured: isObscured,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
