import 'dart:math';
import 'package:flutter/material.dart';

/// Para düşme animasyonu widget'ı
/// Harcama eklendiğinde kısa süreliğine gösterilir
class MoneyRainAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;
  final int coinCount;

  const MoneyRainAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 1500),
    this.coinCount = 15,
  });

  @override
  State<MoneyRainAnimation> createState() => _MoneyRainAnimationState();
}

class _MoneyRainAnimationState extends State<MoneyRainAnimation>
    with TickerProviderStateMixin {
  late List<_CoinData> coins;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Rastgele para verileri oluştur
    final random = Random();
    coins = List.generate(widget.coinCount, (index) {
      return _CoinData(
        startX: random.nextDouble(),
        startY: -0.1 - random.nextDouble() * 0.3,
        endY: 1.1 + random.nextDouble() * 0.2,
        rotation: random.nextDouble() * 4 * pi,
        delay: random.nextDouble() * 0.3,
        size: 24.0 + random.nextDouble() * 16,
        emoji: _getRandomMoneyEmoji(random),
      );
    });

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  String _getRandomMoneyEmoji(Random random) {
    const emojis = ['💰', '💵', '💸', '🪙', '💲'];
    return emojis[random.nextInt(emojis.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: coins.map((coin) {
              // Her para için gecikme hesapla
              final adjustedProgress =
                  ((_controller.value - coin.delay) / (1 - coin.delay)).clamp(
                    0.0,
                    1.0,
                  );

              if (adjustedProgress <= 0) return const SizedBox.shrink();

              final currentY =
                  coin.startY + (coin.endY - coin.startY) * adjustedProgress;
              final currentRotation = coin.rotation * adjustedProgress;

              // Fade out towards end
              final opacity = adjustedProgress > 0.7
                  ? (1.0 - adjustedProgress) / 0.3
                  : 1.0;

              return Positioned(
                left: coin.startX * MediaQuery.of(context).size.width,
                top: currentY * MediaQuery.of(context).size.height,
                child: Transform.rotate(
                  angle: currentRotation,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Text(
                      coin.emoji,
                      style: TextStyle(fontSize: coin.size),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CoinData {
  final double startX;
  final double startY;
  final double endY;
  final double rotation;
  final double delay;
  final double size;
  final String emoji;

  _CoinData({
    required this.startX,
    required this.startY,
    required this.endY,
    required this.rotation,
    required this.delay,
    required this.size,
    required this.emoji,
  });
}

/// Animasyonu göstermek için overlay kullanır
class MoneyAnimationOverlay {
  static OverlayEntry? _overlayEntry;

  /// Para yağmuru animasyonunu göster
  static void show(BuildContext context) {
    // Önce varsa kaldır
    hide();

    _overlayEntry = OverlayEntry(
      builder: (context) => const MoneyRainAnimation(onComplete: hide),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Animasyonu kaldır
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
