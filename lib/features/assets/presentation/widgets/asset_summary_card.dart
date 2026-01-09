import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class AssetSummaryCard extends StatelessWidget {
  final double totalAssets;
  final int assetCount;

  const AssetSummaryCard({
    super.key,
    required this.totalAssets,
    required this.assetCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 160,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600.withValues(alpha: 0.25),
            Colors.blue.shade600.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade600.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: Başlık ve İkon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.diamond_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "TOPLAM VARLIK",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Sağ üstte opsiyonel ikon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.show_chart,
                  color: Colors.blue.shade300,
                  size: 16,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Orta: Büyük Tutar
          Text(
            CurrencyFormatter.format(totalAssets),
            style: TextStyle(
              color: Colors.blue.shade400,
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 15),

          // Alt: Varlık Sayısı
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.blue.shade200,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "Toplam $assetCount adet varlık kaydı",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
