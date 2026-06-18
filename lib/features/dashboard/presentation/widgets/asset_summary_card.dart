import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_card_container.dart';
/// Varlık Özeti Kartı Widget'ı
/// Toplam varlık değerini gösterir
class AssetSummaryCard extends StatelessWidget {
  final double totalAssets;
  final VoidCallback? onTap;

  const AssetSummaryCard({super.key, required this.totalAssets, this.onTap});

  /// Varlık listesinden toplam değeri hesaplar
  static double calculateTotalAssetValue(List<Asset> varliklar) {
    double total = 0;
    for (var v in varliklar.where((a) => !a.isDeleted)) {
      // amount zaten toplam değeri içeriyor, quantity ile çarpmaya gerek yok
      total += v.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isObscured = context.select((DashboardController c) => c.isObscured);

    return AnimatedCard(
      delay: 400,
      child: DashboardCardContainer(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorConstants.maviVurgu.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.diamond_outlined,
                color: ColorConstants.maviVurgu,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.totalAsset,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            ObscuredAmountText(
              CurrencyFormatter.formatInteger(totalAssets),
              isObscured: isObscured,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: ColorConstants.maviVurgu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
