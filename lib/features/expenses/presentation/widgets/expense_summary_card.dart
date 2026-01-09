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
      height: 180, // Sabit yükseklik - Daha da artırıldı
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                        Icons.wallet,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "TOPLAM HARCAMA",
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
                    // Sol Ok - Genişletilmiş Dokunma Alanı
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.oncekiAy,
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

                    // Ay İsmi - Ayrı Dokunma Alanı
                    GestureDetector(
                      onTap: widget.ayYilSeciciAc,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          widget.ayIsmi.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    // Sağ Ok - Genişletilmiş Dokunma Alanı
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.sonrakiAy,
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
            CurrencyFormatter.format(widget.toplamTutar),
            style: TextStyle(
              color: ColorConstants.kirmiziVurgu,
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
              Icon(
                Icons.trending_down,
                color: Colors.redAccent.shade100,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "Bu ayki harcamalar",
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

  /// Sayfa 2: Bütçe Durumu
  Widget _buildBudgetPage(BuildContext context) {
    final double dolulukOrani = (widget.toplamTutar / widget.butceLimiti).clamp(
      0.0,
      1.0,
    );
    final double kalanLimit = widget.butceLimiti - widget.toplamTutar;

    Color barRengi = Theme.of(context).colorScheme.secondary;
    if (dolulukOrani > 0.5) barRengi = Colors.orangeAccent;
    if (dolulukOrani > 0.8) barRengi = ColorConstants.kirmiziVurgu;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BÜTÇE DURUMU",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: barRengi.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "%${(dolulukOrani * 100).toStringAsFixed(0)}",
                  style: TextStyle(
                    color: barRengi,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: dolulukOrani,
              backgroundColor: Colors.black.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(barRengi),
              minHeight: 12,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "KALAN",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(kalanLimit),
                    style: TextStyle(
                      color: kalanLimit < 0
                          ? ColorConstants.kirmiziVurgu
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "TOPLAM LİMİT",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(widget.butceLimiti),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
