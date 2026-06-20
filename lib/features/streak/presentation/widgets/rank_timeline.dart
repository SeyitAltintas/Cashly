import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/constants/streak_badges.dart';
import '../controllers/streak_controller.dart';

/// Candy Crush stili Zikzaklı Rank Yolculuğu
class RankTimeline extends StatefulWidget {
  final StreakController controller;
  final void Function(BuildContext, RankTier, bool) onTierTap;

  const RankTimeline({
    super.key,
    required this.controller,
    required this.onTierTap,
  });

  @override
  State<RankTimeline> createState() => _RankTimelineState();
}

class _RankTimelineState extends State<RankTimeline> {
  late ScrollController _scrollController;

  // Yollar için Aurora/Gökkuşağı tarzı özel renk paleti
  // (Acemi'den Grandmaster'a doğru görsel zenginlik katar)
  static const List<Color> _pathColors = [
    Color(0xFF81D4FA), // 1. Acemi (Açık Mavi)
    Color(0xFF29B6F6), // 2. Çırak (Mavi)
    Color(0xFF26A69A), // 3. Maceracı (Zümrüt)
    Color(0xFF66BB6A), // 4. Uzman (Yeşil)
    Color(0xFFFFCA28), // 5. Şövalye (Altın)
    Color(0xFFFF7043), // 6. Kahraman (Mercan/Turuncu)
    Color(0xFFEC407A), // 7. Efsane (Pembe)
    Color(0xFFAB47BC), // 8. Usta (Mor)
    Color(0xFF7E57C2), // 9. Grandmaster (Koyu Mor)
  ];

  @override
  void initState() {
    super.initState();
    int currentIndex = RankTiers.allTiers.indexWhere(
      (t) => t.level == widget.controller.currentRank.level,
    );
    double initialOffset = 0.0;
    if (currentIndex > 0) {
      // Her bir tile 180 piksel yükseklikte
      initialOffset = (currentIndex * 180.0) - 60.0;
      if (initialOffset < 0) initialOffset = 0.0;
    }
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tiers = RankTiers.allTiers;

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Candy Crush mantığı (Aşağıdan yukarı)
      padding: const EdgeInsets.only(
        bottom: 60,
        top:
            350, // Grandmaster'ın daha rahat görülebilmesi için üst boşluk artırıldı
      ), // Üstteki kartların arkasında kalması için pay
      itemCount: tiers.length,
      itemBuilder: (context, index) {
        final tier = tiers[index];
        final isUnlocked = widget.controller.isTierUnlocked(tier);
        final isCurrent = widget.controller.currentRank.level == tier.level;
        final isFirst = index == 0;
        final isLast = index == tiers.length - 1;
        final isNextUnlocked = index + 1 < tiers.length
            ? widget.controller.isTierUnlocked(tiers[index + 1])
            : false;

        // XP Progress
        double progress = RankTiers.progressToNext(widget.controller.totalXp);
        const Color progressColor = Color(0xFF4CAF50); // Mat yeşil
        final Color lockedLineColor = Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.1);

        // Yollar için özel tanımlanmış palet rengi
        final Color nodePathColor = _pathColors[index];

        // Üst Çizgi Doluluk Oranı (Sonraki ranka)
        double topFill = 0.0;
        Color topTargetColor = lockedLineColor;
        bool isTopProgress = false;

        if (isNextUnlocked) {
          topFill = 1.0;
          topTargetColor = _pathColors[index + 1];
        } else if (isCurrent) {
          topFill = (progress * 2).clamp(0.0, 1.0);
          topTargetColor = progressColor;
          isTopProgress = true;
        }

        // Alt Çizgi Doluluk Oranı (Önceki ranktan)
        double bottomFill = 0.0;
        Color bottomSourceColor = lockedLineColor;
        bool isBottomProgress = false;

        if (isUnlocked) {
          bottomFill = 1.0;
          bottomSourceColor = index > 0 ? _pathColors[index - 1] : nodePathColor;
        } else if (index > 0 &&
            widget.controller.currentRank.level == tiers[index - 1].level) {
          bottomFill = ((progress - 0.5) * 2).clamp(0.0, 1.0);
          bottomSourceColor = progressColor;
          isBottomProgress = true;
        }

        // Çift sayılar solda, tek sayılar sağda
        final isLeft = index % 2 == 0;

        // Düğümün ve yolların matematiksel merkezleri
        final screenWidth = MediaQuery.of(context).size.width;
        final double nodeX = isLeft ? screenWidth * 0.25 : screenWidth * 0.75;
        const double nodeY = 180 * 0.425; // 76.5

        return SizedBox(
          height: 180, // Düğüm ve yollar için sabit yükseklik
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // --- KIVRIMLI YOL ÇİZİMİ ---
              Positioned.fill(
                child: CustomPaint(
                  painter: _PathPainter(
                    isLeft: isLeft,
                    isFirst: isFirst,
                    isLast: isLast,
                    topFill: topFill,
                    bottomFill: bottomFill,
                    nodeColor: nodePathColor,
                    topTargetColor: topTargetColor,
                    bottomSourceColor: bottomSourceColor,
                    lockedColor: lockedLineColor,
                    isTopProgress: isTopProgress,
                    isBottomProgress: isBottomProgress,
                  ),
                ),
              ),

              // --- DEVASA RANK DÜĞÜMÜ VE YÜZEN METİNLER ---
              Positioned(
                left: nodeX - 70, // 140 genişliğindeki kutuyu tam merkeze oturt
                top:
                    nodeY -
                    35, // 70 yüksekliğindeki düğümün merkezini nodeY'ye oturt
                width: 140, // Metinlerin sığması için yeterli genişlik
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rozet (Badge)
                    GestureDetector(
                      onTap: () => widget.onTierTap(context, tier, isUnlocked),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.surface, // Her zaman arka plan rengi
                          border: Border.all(
                            color: isUnlocked
                                ? tier.primaryColor
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.10),
                            width: 3, // Çerçeve kalınlığı 5'ten 3'e düşürüldü
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: tier.primaryColor.withValues(
                                      alpha: 0.35,
                                    ), // Parlama opaklığı azaltıldı
                                    blurRadius:
                                        12, // Parlama yayılımı azaltıldı
                                    spreadRadius:
                                        1, // Parlama kalınlığı azaltıldı
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: ClipOval(
                          child: isUnlocked
                              ? Padding(
                                  padding: const EdgeInsets.all(
                                    12.0,
                                  ), // Animasyonun kenarlardan kırpılmasını engeller
                                  child: RepaintBoundary(
                                    child: Lottie.asset(
                                      tier.lottieAsset,
                                      fit: BoxFit
                                          .contain, // cover yerine contain kullanıldı
                                      repeat:
                                          false, // Animasyon 1 kere oynar ve son karede durur
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.lock_rounded,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Yüzen Metin Etiketleri
                    Text(
                      tier.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isUnlocked
                            ? tier.primaryColor
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isCurrent)
                      const SizedBox.shrink() // Şuan Buradasın yazısı kaldırıldı
                    else if (isUnlocked)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: tier.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tamamlandı',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: tier.primaryColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Hedef: ${tier.requiredXp} XP',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Yılan (S-Curve) benzeri yolu çizen CustomPainter
class _PathPainter extends CustomPainter {
  final bool isLeft;
  final bool isFirst;
  final bool isLast;

  final double topFill;
  final double bottomFill;
  final Color nodeColor;
  final Color topTargetColor;
  final Color bottomSourceColor;

  final Color lockedColor;
  final bool isTopProgress;
  final bool isBottomProgress;

  _PathPainter({
    required this.isLeft,
    required this.isFirst,
    required this.isLast,
    required this.topFill,
    required this.bottomFill,
    required this.nodeColor,
    required this.topTargetColor,
    required this.bottomSourceColor,
    required this.lockedColor,
    required this.isTopProgress,
    required this.isBottomProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double midX = size.width / 2;
    final double nodeX = isLeft ? size.width * 0.25 : size.width * 0.75;

    // Align(y: -0.15) kullanıldığı için düğümün tam merkezi:
    // ( -0.15 + 1 ) / 2 = 0.425
    final double nodeY = size.height * 0.425;

    // Alt Çizgi (Aşağıdaki/Önceki düğüme bağlanan yol)
    if (!isFirst) {
      Path basePath = Path();
      basePath.moveTo(midX, size.height);
      basePath.cubicTo(
        midX,
        nodeY + (size.height - nodeY) / 2, // Eğimi orantılı dağıt
        nodeX,
        nodeY + (size.height - nodeY) / 2,
        nodeX,
        nodeY,
      );

      // Kilitli arkaplan yolu
      final lockedPaint = Paint()
        ..color = lockedColor
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(basePath, lockedPaint);

      // İlerleme yolu (Yeşil veya tamamlanmış)
      if (bottomFill > 0.0) {
        final fillPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(midX, size.height),
            Offset(nodeX, nodeY),
            [Color.lerp(bottomSourceColor, nodeColor, 0.5)!, nodeColor],
          )
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        if (!isBottomProgress && bottomFill >= 1.0) {
          // Tamamen açık rank
          canvas.drawPath(basePath, fillPaint);
        } else {
          // Kısmi doluluk (Mat yeşil) - Ölü bölgeyi (sonraki düğüm) hesapla
          final metrics = basePath.computeMetrics().first;
          final totalLen = metrics.length;
          const deadZone = 35.0; // Kilitli düğümün yarıçapı (70 / 2)
          final visibleLen = totalLen - deadZone;

          final extractLen = visibleLen * bottomFill;
          final extractPath = metrics.extractPath(0.0, extractLen);
          canvas.drawPath(extractPath, fillPaint);
        }
      }
    }

    // Üst Çizgi (Yukarıdaki/Sonraki düğüme bağlanan yol)
    if (!isLast) {
      Path basePath = Path();
      basePath.moveTo(nodeX, nodeY);
      basePath.cubicTo(nodeX, nodeY / 2, midX, nodeY / 2, midX, 0);

      // Kilitli arkaplan yolu
      final lockedPaint = Paint()
        ..color = lockedColor
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(basePath, lockedPaint);

      // İlerleme yolu (Yeşil veya tamamlanmış)
      if (topFill > 0.0) {
        final fillPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(nodeX, nodeY),
            Offset(midX, 0),
            [nodeColor, Color.lerp(nodeColor, topTargetColor, 0.5)!],
          )
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        if (!isTopProgress && topFill >= 1.0) {
          // Tamamen açık rank
          canvas.drawPath(basePath, fillPaint);
        } else {
          // Kısmi doluluk (Mat yeşil) - Ölü bölgeyi (mevcut düğüm) hesapla
          final metrics = basePath.computeMetrics().first;
          final totalLen = metrics.length;
          const deadZone = 35.0; // Mevcut düğümün yarıçapı (70 / 2)
          final visibleLen = totalLen - deadZone;

          // Dead zone'u her zaman çiziyoruz ki çizgi düğümün kenarından çıksın
          final extractLen = deadZone + (visibleLen * topFill);
          final extractPath = metrics.extractPath(0.0, extractLen);
          canvas.drawPath(extractPath, fillPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.isLeft != isLeft ||
        oldDelegate.topFill != topFill ||
        oldDelegate.bottomFill != bottomFill;
  }
}
