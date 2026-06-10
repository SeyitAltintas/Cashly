import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';
import '../controllers/dashboard_controller.dart';

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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorConstants.maviVurgu.withValues(alpha: 0.9),
                ColorConstants.maviVurgu.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ColorConstants.maviVurgu.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.totalAsset,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ObscuredAmountText(
                    CurrencyFormatter.format(totalAssets),
                    isObscured: isObscured,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
