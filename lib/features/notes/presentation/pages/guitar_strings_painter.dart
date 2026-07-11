import 'dart:math' as math;

import 'package:flutter/material.dart';

class GuitarStringsPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double amplitude;
  final List<double> phases;
  final bool isListening;

  GuitarStringsPainter({
    required this.color,
    required this.progress,
    required this.amplitude,
    required this.phases,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double micRadius = 44.0;
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    const int stringCount = 5;
    final double spacing = size.height / (stringCount + 1);

    for (int i = 0; i < stringCount; i++) {
      final double y = spacing * (i + 1);
      final double phase = phases[i];
      // FreqMultiplier MUST be an integer to loop perfectly when progress wraps from 1.0 back to 0.0
      final double freqMultiplier = (i % 2 == 0) ? 1.0 : 2.0;
      final double t = progress * math.pi * 2 * freqMultiplier + phase;
      final double opacityBase = 0.3 + (0.4 * (1.0 - ((i - stringCount / 2).abs() / (stringCount / 2))));
      final double opacity = isListening ? opacityBase + (amplitude * 0.3) : opacityBase;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = 1.5 + (amplitude * 1.0)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      const int segments = 80;
      bool started = false;

      for (int s = 0; s <= segments; s++) {
        final double x = (s / segments) * size.width;
        final dx = x - cx;
        final dy = y - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < micRadius) {
          if (started) {
            canvas.drawPath(path, paint);
            path.reset();
            started = false;
          }
          continue;
        }
        final double midDistNorm = (x - cx).abs() / cx;
        final double stringAmplitude = amplitude * 50.0 * math.cos(midDistNorm * math.pi / 2);
        final double vibration = stringAmplitude * math.sin(t + (x / size.width) * math.pi * 3);
        final double finalY = y + vibration;
        if (!started) {
          path.moveTo(x, finalY);
          started = true;
        } else {
          path.lineTo(x, finalY);
        }
      }
      if (started) canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GuitarStringsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.isListening != isListening;
  }
}
