import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../assets/data/models/asset_model.dart';

/// Varlık Özeti Kartı Widget'ı
/// Toplam varlık değerini gösterir
class AssetSummaryCard extends StatelessWidget {
  final double totalAssets;

  const AssetSummaryCard({super.key, required this.totalAssets});

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
    return AnimatedCard(
      delay: 400,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900.withValues(alpha: 0.3),
              Colors.blue.shade700.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.shade400.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Toplam Varlık",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(totalAssets),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade300,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade400.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.diamond_outlined,
                color: Colors.blue.shade300,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
