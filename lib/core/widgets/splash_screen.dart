import 'package:flutter/material.dart';

/// Özel splash screen - Logo boyutu üzerinde tam kontrol sağlar
/// Android 12 native splash kısıtlamasını aşmak için kullanılır
class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Zamanlama sabitleri
  static const _fadeInDuration = 1000; // ms
  static const _visibleDuration = 2000; // ms (2 saniye)
  static const _fadeOutDuration = 1000; // ms
  static const _totalDuration =
      _fadeInDuration + _visibleDuration + _fadeOutDuration; // 3 saniye

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: _totalDuration),
      vsync: this,
    );

    // Fade in → Görünür kalma → Fade out animasyonu
    // Ağırlıkları sürelere göre hesapla
    const fadeInWeight = _fadeInDuration / _totalDuration * 100;
    const visibleWeight = _visibleDuration / _totalDuration * 100;
    const fadeOutWeight = _fadeOutDuration / _totalDuration * 100;

    _fadeAnimation = TweenSequence<double>([
      // Fade in: 0 → 1 (500ms)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: fadeInWeight,
      ),
      // Görünür kalma: 1 → 1 (2 saniye)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: visibleWeight,
      ),
      // Fade out: 1 → 0 (500ms)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: fadeOutWeight,
      ),
    ]).animate(_controller);

    // Animasyonu başlat
    _controller.forward();

    // Animasyon bittiğinde yönlendir
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onInitializationComplete();
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
    // Responsive boyutlandırma
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = screenWidth * 0.40; // Ekranın %40'ı

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(opacity: _fadeAnimation.value, child: child);
          },
          child: SizedBox(
            width: logoWidth,
            child: Image.asset(
              'assets/image/seffaflogo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
