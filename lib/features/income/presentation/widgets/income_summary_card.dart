import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class IncomeSummaryCard extends StatelessWidget {
  final String ayIsmi;
  final double toplamGelir;
  final VoidCallback oncekiAy;
  final VoidCallback sonrakiAy;
  final VoidCallback ayYilSeciciAc;
  final int gelirSayisi;

  const IncomeSummaryCard({
    super.key,
    required this.ayIsmi,
    required this.toplamGelir,
    required this.oncekiAy,
    required this.sonrakiAy,
    required this.ayYilSeciciAc,
    required this.gelirSayisi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive degerler hesapla
          final cardWidth = constraints.maxWidth;
          final cardHeight = (cardWidth / 2.2).clamp(150.0, 200.0);

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
                  Colors.green.shade600.withValues(alpha: 0.25),
                  Colors.green.shade600.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.shade600.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ust Satir: Baslik ve Tarih
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol Ust: Etiket
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.totalIncomeLabel,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: labelFontSize,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Sag Ust: Ay Secici
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sol Ok
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: oncekiAy,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          // Ay Ismi
                          GestureDetector(
                            onTap: ayYilSeciciAc,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                ayIsmi.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          // Sag Ok
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: sonrakiAy,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Orta: Buyuk Tutar
                Text(
                  CurrencyFormatter.format(toplamGelir),
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontSize: amountFontSize,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),

                SizedBox(height: padding * 0.75),

                // Alt: Ikonik Gosterim
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Colors.green.shade200,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.monthlyIncomeCount(gelirSayisi),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
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
