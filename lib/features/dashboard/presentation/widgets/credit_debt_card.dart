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
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: ColorConstants.kirmiziVurgu,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.creditCardDebt,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              ObscuredAmountText(
                CurrencyFormatter.formatInteger(totalDebt),
                isObscured: isObscured,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.kirmiziVurgu,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
