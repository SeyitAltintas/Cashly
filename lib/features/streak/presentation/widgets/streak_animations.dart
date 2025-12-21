import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animasyonlu ateş ikonu widget'ı
/// Seri sayfasında büyük ateş ikonu olarak kullanılır
class AnimatedFireIcon extends StatefulWidget {
  final double size;
  final bool showParticles;

  const AnimatedFireIcon({
    super.key,
    this.size = 64,
    this.showParticles = true,
  });

  @override
  State<AnimatedFireIcon> createState() => _AnimatedFireIconState();
}

class _AnimatedFireIconState extends State<AnimatedFireIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;

  // Parçacık animasyonları
  final List<_FireParticle> _particles = [];
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Nabız animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Hafif döndürme animasyonu
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _rotateController.repeat(reverse: true);

    // Parçacık animasyonu
    if (widget.showParticles) {
      _particleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _initParticles();
      _particleController.repeat();
    }
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      _particles.add(
        _FireParticle(
          angle: random.nextDouble() * math.pi * 2,
          speed: 0.3 + random.nextDouble() * 0.4,
          size: 3 + random.nextDouble() * 4,
          delay: random.nextDouble(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    if (widget.showParticles) {
      _particleController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan parıldama
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: widget.size * 1.3 * _pulseAnimation.value,
                height: widget.size * 1.3 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.4),
                      const Color(0xFFFF6B35).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Parçacıklar
          if (widget.showParticles)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size * 1.5, widget.size * 1.5),
                  painter: _FireParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                    baseSize: widget.size,
                  ),
                );
              },
            ),

          // Ana ateş ikonu
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _rotateController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: math.sin(_rotateController.value * math.pi * 2) * 0.05,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFD700), // Altın
                        Color(0xFFFF6B35), // Turuncu
                        Color(0xFFFF4500), // Kırmızı
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.4, 1.0],
                    ).createShader(bounds),
                    child: Icon(
                      Icons.local_fire_department,
                      size: widget.size,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FireParticle {
  final double angle;
  final double speed;
  final double size;
  final double delay;

  _FireParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.delay,
  });
}

class _FireParticlePainter extends CustomPainter {
  final List<_FireParticle> particles;
  final double progress;
  final double baseSize;

  _FireParticlePainter({
    required this.particles,
    required this.progress,
    required this.baseSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      // Gecikmeyi hesapla
      double particleProgress = (progress + particle.delay) % 1.0;

      // Yukarı doğru hareket
      final distance = baseSize * 0.3 + (particleProgress * baseSize * 0.5);
      final dx = math.cos(particle.angle - math.pi / 2) * distance * 0.3;
      final dy = -particleProgress * distance;

      // Opacity ve boyut azalması
      final opacity = (1.0 - particleProgress) * 0.7;
      final currentSize = particle.size * (1.0 - particleProgress * 0.5);

      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD700),
          const Color(0xFFFF4500),
          particleProgress,
        )!.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx + dx, center.dy + dy),
        currentSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FireParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Seri sayısı animasyonu - sayı artarken animasyon
class AnimatedStreakNumber extends StatelessWidget {
  final int number;
  final double fontSize;
  final Color color;

  const AnimatedStreakNumber({
    super.key,
    required this.number,
    this.fontSize = 72,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(number),
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Rozet kazanma konfeti animasyonu
class BadgeEarnedAnimation extends StatefulWidget {
  final Widget child;
  final bool showAnimation;
  final VoidCallback? onAnimationComplete;

  const BadgeEarnedAnimation({
    super.key,
    required this.child,
    this.showAnimation = true,
    this.onAnimationComplete,
  });

  @override
  State<BadgeEarnedAnimation> createState() => _BadgeEarnedAnimationState();
}

class _BadgeEarnedAnimationState extends State<BadgeEarnedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  final List<_ConfettiParticle> _confetti = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Konfeti oluştur
    _initConfetti();

    if (widget.showAnimation) {
      _controller.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }

  void _initConfetti() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _confetti.add(
        _ConfettiParticle(
          angle: random.nextDouble() * math.pi * 2,
          speed: 100 + random.nextDouble() * 150,
          rotationSpeed: random.nextDouble() * 4 - 2,
          color: [
            const Color(0xFFFFD700),
            const Color(0xFFFF6B35),
            const Color(0xFF4CAF50),
            const Color(0xFF2196F3),
            const Color(0xFFE91E63),
          ][random.nextInt(5)],
          size: 4 + random.nextDouble() * 6,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAnimation) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Konfeti
            if (_controller.value > 0 && _controller.value < 0.8)
              CustomPaint(
                size: const Size(200, 200),
                painter: _ConfettiPainter(
                  confetti: _confetti,
                  progress: _controller.value,
                ),
              ),
            // Rozet
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double angle;
  final double speed;
  final double rotationSpeed;
  final Color color;
  final double size;

  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.rotationSpeed,
    required this.color,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in confetti) {
      final distance = particle.speed * progress;
      final dx = math.cos(particle.angle) * distance;
      final dy =
          math.sin(particle.angle) * distance + (progress * 50); // Yerçekimi

      final opacity = (1.0 - progress * 1.2).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx + dx, center.dy + dy);
      canvas.rotate(particle.rotationSpeed * progress * math.pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
