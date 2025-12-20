import 'package:flutter/material.dart';
import '../../data/models/streak_model.dart';
import '../pages/streak_page.dart';

/// Dashboard'da gösterilecek seri widget'ı
/// Ateş ikonu ve seri sayısını gösterir, tıklandığında detay sayfasına gider
class StreakWidget extends StatelessWidget {
  final StreakData streakData;

  const StreakWidget({super.key, required this.streakData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToStreakPage(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6B35).withValues(alpha: 0.2),
              const Color(0xFFFF8C00).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ateş animasyonu
            _buildFireIcon(),
            const SizedBox(width: 6),
            // Seri sayısı
            Text(
              '${streakData.currentStreak}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFireIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      onEnd: () {},
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFFF4500)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds),
        child: const Icon(
          Icons.local_fire_department,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateToStreakPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreakPage(streakData: streakData),
      ),
    );
  }
}
