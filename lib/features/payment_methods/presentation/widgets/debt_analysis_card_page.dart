import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/utils/currency_formatter.dart';
import '../../data/models/payment_method_model.dart';

/// Carousel Sayfa 2: Borç Analizi
/// Kredi kartı borçları ve limit kullanım oranını gösterir
class DebtAnalysisCardPage extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;

  const DebtAnalysisCardPage({super.key, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    // Kredi kartlarını al
    final krediKartlar = paymentMethods
        .where((pm) => pm.type == 'kredi')
        .toList();
    final toplamBorc = krediKartlar.fold(0.0, (sum, pm) => sum + pm.balance);
    final toplamLimit = krediKartlar.fold(
      0.0,
      (sum, pm) => sum + (pm.limit ?? 0),
    );
    final kullanimOrani = toplamLimit > 0
        ? (toplamBorc / toplamLimit).clamp(0.0, 1.0)
        : 0.0;

    // Duruma göre renk belirleme
    Color durumRengi = Colors.greenAccent;
    if (kullanimOrani > 0.5) {
      durumRengi = Colors.orangeAccent;
    }
    if (kullanimOrani > 0.8) {
      durumRengi = ColorConstants.kirmiziVurgu;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.25),
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                Icons.trending_down,
                color: Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'TOPLAM BORÇ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Toplam borç tutarı
          Text(
            CurrencyFormatter.format(toplamBorc),
            style: TextStyle(
              color: toplamBorc > 0
                  ? ColorConstants.kirmiziVurgu
                  : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          // Limit kullanım oranı progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Limit Kullanımı',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '%${(kullanimOrani * 100).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: durumRengi,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: kullanimOrani,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(durumRengi),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Alt bilgi chip'leri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DebtInfoChip(
                label: 'Kullanılan',
                value: CurrencyFormatter.format(toplamBorc),
                color: ColorConstants.kirmiziVurgu,
              ),
              _DebtInfoChip(
                label: 'Toplam Limit',
                value: CurrencyFormatter.format(toplamLimit),
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Borç bilgi chip widget'ı
class _DebtInfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DebtInfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
