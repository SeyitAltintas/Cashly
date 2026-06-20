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

  @override
  void initState() {
    super.initState();
    int currentIndex = RankTiers.allTiers.indexWhere((t) => t.level == widget.controller.currentRank.level);
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
      padding: const EdgeInsets.only(bottom: 60, top: 260), // Üstteki kartların arkasında kalması için pay
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
            
        // Çift sayılar solda, tek sayılar sağda
        final isLeft = index % 2 == 0;

        return SizedBox(
          height: 180, // Düğüm ve yollar için sabit yükseklik
          child: Stack(
            children: [
              // --- KIVRIMLI YOL ÇİZİMİ ---
              Positioned.fill(
                child: CustomPaint(
                  painter: _PathPainter(
                    isLeft: isLeft,
                    isFirst: isFirst,
                    isLast: isLast,
                    isUnlocked: isUnlocked,
                    isNextUnlocked: isNextUnlocked,
                    currentColor: tier.primaryColor,
                    nextColor: isLast ? Colors.transparent : tiers[index + 1].primaryColor,
                    lockedColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              
              // --- DEVASA RANK DÜĞÜMÜ VE METİNLER ---
              Align(
                alignment: isLeft ? const Alignment(-0.5, 0) : const Alignment(0.5, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rozet (Badge)
                    GestureDetector(
                      onTap: () => widget.onTierTap(context, tier, isUnlocked),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface, // Her zaman arka plan rengi
                          border: Border.all(
                            color: isUnlocked 
                                ? tier.primaryColor 
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                            width: 5,
                          ),
                          boxShadow: isCurrent 
                              ? [
                                  BoxShadow(
                                    color: tier.primaryColor.withValues(alpha: 0.5), 
                                    blurRadius: 20, 
                                    spreadRadius: 4
                                  )
                                ] 
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                        ),
                        child: ClipOval(
                          child: isUnlocked
                              ? Padding(
                                  padding: const EdgeInsets.all(12.0), // Animasyonun kenarlardan kırpılmasını engeller
                                  child: RepaintBoundary(
                                    child: Lottie.asset(
                                      tier.lottieAsset,
                                      fit: BoxFit.contain, // cover yerine contain kullanıldı
                                      repeat: false, // Animasyon 1 kere oynar ve son karede durur
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.lock_rounded,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
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
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    if (isCurrent)
                      Text(
                        'Şu An Buradasın',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: tier.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      )
                    else if (isUnlocked)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16, color: tier.primaryColor),
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
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
  final bool isUnlocked;
  final bool isNextUnlocked;
  final Color currentColor;
  final Color nextColor;
  final Color lockedColor;

  _PathPainter({
    required this.isLeft,
    required this.isFirst,
    required this.isLast,
    required this.isUnlocked,
    required this.isNextUnlocked,
    required this.currentColor,
    required this.nextColor,
    required this.lockedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double midX = size.width / 2;
    // Node hizalaması Alignment(-0.5, 0) veya Alignment(0.5, 0) yapılmıştı.
    // -0.5 = %25 genişlik, 0.5 = %75 genişlik.
    final double nodeX = isLeft ? size.width * 0.25 : size.width * 0.75;
    final double centerY = size.height / 2;

    // Alt Çizgi (Aşağıdaki/Önceki düğüme bağlanan yol)
    if (!isFirst) {
      final paint = Paint()
        ..color = isUnlocked ? currentColor : lockedColor
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Path path = Path();
      path.moveTo(nodeX, centerY);
      // Yumuşak bir S-Kıvrımı ile merkeze in
      path.cubicTo(
        nodeX, centerY + (centerY / 2),
        midX, centerY + (centerY / 2),
        midX, size.height,
      );
      canvas.drawPath(path, paint);
    }

    // Üst Çizgi (Yukarıdaki/Sonraki düğüme bağlanan yol)
    if (!isLast) {
      final paint = Paint()
        ..color = isNextUnlocked ? nextColor : lockedColor
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Path path = Path();
      path.moveTo(nodeX, centerY);
      // Yumuşak bir S-Kıvrımı ile merkeze çık
      path.cubicTo(
        nodeX, centerY / 2,
        midX, centerY / 2,
        midX, 0,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.isLeft != isLeft ||
        oldDelegate.isUnlocked != isUnlocked ||
        oldDelegate.isNextUnlocked != isNextUnlocked;
  }
}
