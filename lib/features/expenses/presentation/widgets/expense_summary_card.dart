import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/utils/currency_formatter.dart';

/// Harcama özet kartı widget'ı - Carousel formatında
/// Sayfa 1: Toplam harcama ve tarih seçimi
/// Sayfa 2: Bütçe durumu bar'ı
class ExpenseSummaryCard extends StatefulWidget {
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
  State<ExpenseSummaryCard> createState() => _ExpenseSummaryCardState();
}

class _ExpenseSummaryCardState extends State<ExpenseSummaryCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 120, // Sabit yükseklik
      child: Column(
        children: [
          // Carousel içeriği
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildTotalExpensePage(context),
                _buildBudgetPage(context),
              ],
            ),
          ),
          // Sayfa göstergesi
          const SizedBox(height: 6),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  /// Sayfa 1: Toplam Harcama ve Tarih Seçimi
  Widget _buildTotalExpensePage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.25),
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ay seçici satırı
          _buildMonthSelector(context),
          const SizedBox(height: 4),
          // Toplam harcama satırı
          Row(
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
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(widget.toplamTutar),
                    style: TextStyle(
                      color: ColorConstants.kirmiziVurgu,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_down,
                  color: ColorConstants.kirmiziVurgu,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sayfa 2: Bütçe Durumu
  Widget _buildBudgetPage(BuildContext context) {
    final double dolulukOrani = (widget.toplamTutar / widget.butceLimiti).clamp(
      0.0,
      1.0,
    );
    final double kalanLimit = widget.butceLimiti - widget.toplamTutar;
    final double asilanMiktar = widget.toplamTutar - widget.butceLimiti;

    Color barRengi = Theme.of(context).colorScheme.secondary;
    if (dolulukOrani > 0.5) barRengi = Colors.orangeAccent;
    if (dolulukOrani > 0.8) barRengi = ColorConstants.kirmiziVurgu;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.25),
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Bütçe Durumu",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                "%${(dolulukOrani * 100).toStringAsFixed(0)}",
                style: TextStyle(
                  color: barRengi,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Limit: ${CurrencyFormatter.format(widget.butceLimiti)}",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              kalanLimit < 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.kirmiziVurgu,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Aşıldı: ${CurrencyFormatter.formatWithoutSymbol(asilanMiktar)} ₺",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      "Kalan: ${CurrencyFormatter.format(kalanLimit)}",
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ay seçici
  Widget _buildMonthSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: widget.oncekiAy,
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            size: 16,
          ),
        ),
        GestureDetector(
          onTap: widget.ayYilSeciciAc,
          child: Row(
            children: [
              Text(
                widget.ayIsmi.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: widget.sonrakiAy,
          child: Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            size: 16,
          ),
        ),
      ],
    );
  }

  /// Sayfa göstergesi (dots)
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: _currentPage == index ? 16 : 6,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? ColorConstants.kirmiziVurgu
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
