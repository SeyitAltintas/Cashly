import 'package:flutter/material.dart';

/// Animasyonlu kart wrapper widget'ı
/// Dashboard, Analysis ve diğer sayfalarda kullanılır
/// Fade-in ve yukarı kayma animasyonu uygular
class AnimatedCard extends StatefulWidget {
  /// Animasyon gecikmesi (milisaniye)
  final int delay;

  /// İçerik widget'ı
  final Widget child;

  const AnimatedCard({super.key, required this.delay, required this.child});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // FPS Optimizasyonu: Animasyonu delay süresi kadar gecikmeli başlat
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FPS Optimizasyonu: 
    // 1. FadeTransition ve SlideTransition, Opacity ve Transform'a göre native seviyede optimize edilmiştir (SaveLayer tetiklemez).
    // 2. RepaintBoundary, kompleks kart tasarımlarının (gölgeler, gradientler) animasyon boyunca saniyede 60 kez yeniden çizilmesini engeller.
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RepaintBoundary(
          child: widget.child,
        ),
      ),
    );
  }
}
