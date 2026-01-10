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
  final DateTime secilenAy;
  final List<Map<String, dynamic>> harcamalar;

  const ExpenseSummaryCard({
    super.key,
    required this.ayIsmi,
    required this.toplamTutar,
    required this.butceLimiti,
    required this.oncekiAy,
    required this.sonrakiAy,
    required this.ayYilSeciciAc,
    required this.secilenAy,
    required this.harcamalar,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive degerler hesapla
          final cardWidth = constraints.maxWidth;
          final cardHeight = (cardWidth / 2.2).clamp(150.0, 200.0);

          return SizedBox(
            height: cardHeight + 20, // Page indicator icin ek alan
            child: Column(
              children: [
                // Carousel icerigi
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildTotalExpensePage(context, cardWidth),
                      _buildBudgetPage(context, cardWidth),
                      _buildDailyAveragePage(context, cardWidth),
                    ],
                  ),
                ),
                // Sayfa gostergesi
                const SizedBox(height: 6),
                _buildPageIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Sayfa 1: Toplam Harcama ve Tarih Secimi
  Widget _buildTotalExpensePage(BuildContext context, double cardWidth) {
    // Responsive font boyutlari
    final amountFontSize = (cardWidth * 0.09).clamp(24.0, 36.0);
    final labelFontSize = (cardWidth * 0.028).clamp(9.0, 11.0);
    final subtitleFontSize = (cardWidth * 0.03).clamp(10.0, 12.0);
    final padding = (cardWidth * 0.05).clamp(14.0, 20.0);

    return Container(
      padding: EdgeInsets.fromLTRB(
        padding,
        padding * 0.8,
        padding,
        padding * 0.8,
      ),
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
                          fontSize: labelFontSize,
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

          // Orta: Buyuk Tutar
          Text(
            CurrencyFormatter.format(widget.toplamTutar),
            style: TextStyle(
              color: ColorConstants.kirmiziVurgu,
              fontSize: amountFontSize,
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
                  fontSize: subtitleFontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sayfa 2: Butce Durumu
  Widget _buildBudgetPage(BuildContext context, double cardWidth) {
    // Responsive padding
    final padding = (cardWidth * 0.05).clamp(14.0, 20.0);

    final double dolulukOrani = (widget.toplamTutar / widget.butceLimiti).clamp(
      0.0,
      1.0,
    );
    final double kalanLimit = widget.butceLimiti - widget.toplamTutar;

    Color barRengi = Theme.of(context).colorScheme.secondary;
    if (dolulukOrani > 0.5) barRengi = Colors.orangeAccent;
    if (dolulukOrani > 0.8) barRengi = ColorConstants.kirmiziVurgu;

    return Container(
      padding: EdgeInsets.all(padding),
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

  /// Sayfa 3: Gunluk Harcama Ortalamasi
  Widget _buildDailyAveragePage(BuildContext context, double cardWidth) {
    // Aydaki gun sayisini hesapla
    final int aydakiGunSayisi = DateTime(
      widget.secilenAy.year,
      widget.secilenAy.month + 1,
      0,
    ).day;

    // Bugunun tarihi
    final now = DateTime.now();
    final bugunSecilenAydaMi =
        now.year == widget.secilenAy.year &&
        now.month == widget.secilenAy.month;

    // Gecen gun sayisini hesapla (bu ay icinse bugun, degilse ay sonu)
    final int gecenGunSayisi = bugunSecilenAydaMi ? now.day : aydakiGunSayisi;

    // Gunluk ortalama
    final double gunlukOrtalama = gecenGunSayisi > 0
        ? widget.toplamTutar / gecenGunSayisi
        : 0;

    // Bugünkü harcamayı hesapla
    double bugunHarcama = 0;
    for (var h in widget.harcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        if (tarih.year == now.year &&
            tarih.month == now.month &&
            tarih.day == now.day) {
          bugunHarcama += (h['tutar'] as num?)?.toDouble() ?? 0;
        }
      }
    }

    // Karşılaştırma
    final bool ortalamaninAltinda = bugunHarcama < gunlukOrtalama;
    final double fark = (bugunHarcama - gunlukOrtalama).abs();

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
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "GÜNLÜK ORTALAMA",
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
              // Gün sayısı badge'i
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$gecenGunSayisi gün",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Ortalama tutar
          Text(
            CurrencyFormatter.format(gunlukOrtalama),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 32,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 15),

          // Alt bilgi satırı
          Row(
            children: [
              // Bugünkü harcama
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.today,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Bugün: ${CurrencyFormatter.format(bugunHarcama)}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Karşılaştırma mesajı
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      ortalamaninAltinda
                          ? Icons.trending_down
                          : Icons.trending_up,
                      color: ortalamaninAltinda
                          ? Colors.greenAccent
                          : Colors.redAccent.shade100,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        ortalamaninAltinda
                            ? "${CurrencyFormatter.format(fark)} az"
                            : "${CurrencyFormatter.format(fark)} fazla",
                        style: TextStyle(
                          color: ortalamaninAltinda
                              ? Colors.greenAccent
                              : Colors.redAccent.shade100,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
      children: List.generate(3, (index) {
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
