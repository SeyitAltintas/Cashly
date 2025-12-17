import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';

/// Harcama özet kartı widget'ı
/// Toplam harcama, bütçe durumu ve ay seçici içerir
class ExpenseSummaryCard extends StatelessWidget {
  final String ayIsmi;
  final double toplamTutar;
  final double butceLimiti;
  final VoidCallback oncekiAy;
  final VoidCallback sonrakiAy;
  final VoidCallback ayYilSeciciAc;

  const ExpenseSummaryCard({
    super.key,
    required this.ayIsmi,
    required this.toplamTutar,
    required this.butceLimiti,
    required this.oncekiAy,
    required this.sonrakiAy,
    required this.ayYilSeciciAc,
  });

  @override
  Widget build(BuildContext context) {
    final double dolulukOrani = (toplamTutar / butceLimiti).clamp(0.0, 1.0);
    final double kalanLimit = butceLimiti - toplamTutar;
    final double asilanMiktar = toplamTutar - butceLimiti;

    Color barRengi = Theme.of(context).colorScheme.secondary;
    if (dolulukOrani > 0.5) barRengi = Colors.orangeAccent;
    if (dolulukOrani > 0.8) barRengi = ColorConstants.kirmiziVurgu;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Ay seçici satırı
          _buildMonthSelector(context),
          Divider(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 10),
          // Toplam harcama satırı
          _buildTotalExpenseRow(context),
          const SizedBox(height: 16),
          // Bütçe durumu
          _buildBudgetProgress(
            context,
            dolulukOrani,
            kalanLimit,
            asilanMiktar,
            barRengi,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            size: 18,
          ),
          onPressed: oncekiAy,
        ),
        TextButton(
          onPressed: ayYilSeciciAc,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: Row(
            children: [
              Text(
                ayIsmi.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            size: 18,
          ),
          onPressed: sonrakiAy,
        ),
      ],
    );
  }

  Widget _buildTotalExpenseRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Toplam Harcama",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${toplamTutar.toStringAsFixed(2)} ₺",
              style: TextStyle(
                color: ColorConstants.kirmiziVurgu,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.trending_down,
            color: ColorConstants.kirmiziVurgu,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgress(
    BuildContext context,
    double dolulukOrani,
    double kalanLimit,
    double asilanMiktar,
    Color barRengi,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Bütçe Durumu",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                "%${(dolulukOrani * 100).toStringAsFixed(0)}",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: dolulukOrani,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(barRengi),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: kalanLimit < 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.kirmiziVurgu,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Limit aşıldı: ${asilanMiktar.toStringAsFixed(2)} ₺",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    "Kalan: ${kalanLimit.toStringAsFixed(2)} ₺",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
