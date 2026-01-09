import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

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
      height: 180,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
        border: Border.all(color: Colors.green.shade600.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: Başlık ve Tarih
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol Üst: Etiket
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
                        "TOPLAM GELİR",
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
                ],
              ),
              // Sağ Üst: Ay Seçici (Minimal & Touch Optimized)
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
                    // Ay İsmi
                    GestureDetector(
                      onTap: ayYilSeciciAc,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    // Sağ Ok
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

          // Orta: Büyük Tutar
          Text(
            CurrencyFormatter.format(toplamGelir),
            style: TextStyle(
              color: Colors.green.shade400,
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 15),

          // Alt: İkonik Gösterim
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green.shade200, size: 16),
              const SizedBox(width: 4),
              Text(
                "Bu ay $gelirSayisi gelir kaydı",
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
