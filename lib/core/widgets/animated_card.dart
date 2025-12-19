import 'package:flutter/material.dart';

/// Animasyonlu kart wrapper widget'ı
/// Dashboard, Analysis ve diğer sayfalarda kullanılır
/// Fade-in ve yukarı kayma animasyonu uygular
class AnimatedCard extends StatelessWidget {
  /// Animasyon gecikmesi (milisaniye)
  final int delay;

  /// İçerik widget'ı
  final Widget child;

  const AnimatedCard({super.key, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      builder: (context, value, c) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
