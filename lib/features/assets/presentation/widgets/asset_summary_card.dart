import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive degerler hesapla
          final cardWidth = constraints.maxWidth;
          final cardHeight = (cardWidth / 2.5).clamp(130.0, 180.0);

          // Responsive font boyutlari
          final amountFontSize = (cardWidth * 0.09).clamp(24.0, 36.0);
          final labelFontSize = (cardWidth * 0.028).clamp(9.0, 11.0);
          final subtitleFontSize = (cardWidth * 0.03).clamp(10.0, 12.0);
          final padding = (cardWidth * 0.05).clamp(14.0, 20.0);

          return Container(
            height: cardHeight,
            padding: EdgeInsets.fromLTRB(
              padding,
              padding * 0.8,
              padding,
              padding * 0.8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorConstants.maviVurgu.withValues(alpha: 0.9),
                  ColorConstants.maviVurgu.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorConstants.maviVurgu.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ust Satir: Baslik ve Ikon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.diamond_outlined,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.l10n.totalAssetLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: labelFontSize,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Sag ustte opsiyonel ikon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.show_chart,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Orta: Buyuk Tutar
                Text(
                  CurrencyFormatter.format(totalAssets),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: amountFontSize,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),

                SizedBox(height: padding * 0.75),

                // Alt: Varlik Sayisi
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.totalAssetCount(assetCount),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
