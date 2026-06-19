import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/services/haptic_service.dart';
import '../../data/constants/streak_badges.dart';

/// Rank atlandığında veya seri arttığında gösterilen kutlama dialog'u
class StreakCelebrationDialog extends StatefulWidget {
  /// Streak artışı için eski constructor (backward compat)
  final int streakCount;

  /// Rank atlama bilgisi (null ise sadece seri kutlaması)
  final RankTier? newRank;

  final VoidCallback? onDismiss;

  const StreakCelebrationDialog({
    super.key,
    required this.streakCount,
    this.newRank,
    this.onDismiss,
  });

  /// Seri artışı kutlaması (eski API - backward compat)
  static Future<void> show(BuildContext context, int streakCount) {
    return _showDialog(context, streakCount, null);
  }

  /// Rank atlama kutlaması
  static Future<void> showRankUp(
    BuildContext context,
    int streakCount,
    RankTier newRank,
  ) {
    return _showDialog(context, streakCount, newRank);
  }

  static Future<void> _showDialog(
    BuildContext context,
    int streakCount,
    RankTier? newRank,
  ) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StreakCelebrationDialog(
          streakCount: streakCount,
          newRank: newRank,
          onDismiss: () {
            if (dialogContext.mounted) {
              final route = ModalRoute.of(dialogContext);
              if (route != null && route.isCurrent) {
                final nav =
                    Navigator.of(dialogContext, rootNavigator: true);
                if (nav.canPop()) nav.pop();
              }
            }
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  State<StreakCelebrationDialog> createState() =>
      _StreakCelebrationDialogState();
}

class _StreakCelebrationDialogState extends State<StreakCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textAnimation;
  Timer? _dismissTimer;

  bool get _isRankUp => widget.newRank != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    unawaited(_startCelebrationHaptics());

    // Rank up için 4 saniye, normal seri için 3 saniye
    _dismissTimer = Timer(
      Duration(seconds: _isRankUp ? 4 : 3),
      () {
        if (mounted) widget.onDismiss?.call();
      },
    );
  }

  Future<void> _startCelebrationHaptics() async {
    if (!HapticService.isCelebrationEnabled) return;
    await HapticService.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || !HapticService.isCelebrationEnabled) return;
    await HapticService.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || !HapticService.isCelebrationEnabled) return;
    await HapticService.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticService.heavyImpact();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return _isRankUp ? _buildRankUpContent() : _buildStreakContent();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRankUpContent() {
    final rank = widget.newRank!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rank Lottie animasyonu
        Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: 180,
            height: 180,
            child: Lottie.asset(
              rank.lottieAsset,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Opacity(
          opacity: _textAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textAnimation.value)),
            child: Column(
              children: [
                // "RANK UP!" etiketi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [rank.primaryColor, rank.glowColor],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: rank.glowColor.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Text(
                    '🎉 RANK UP!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Yeni rank adı
                Text(
                  rank.name,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: rank.primaryColor,
                    shadows: [
                      Shadow(
                        color: rank.glowColor.withValues(alpha: 0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  rank.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakContent() {
    final streak = widget.streakCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/lottie/Fire.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),

        Opacity(
          opacity: _textAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textAnimation.value)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF6B35),
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Color(0x80FF6B35),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'GÜN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Opacity(
          opacity: _textAnimation.value,
          child: Text(
            _streakMessage(streak),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color:
                  Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _streakMessage(int streak) {
    if (streak == 1) return 'Harika bir başlangıç! 🚀';
    if (streak == 3) return 'Üç gün arka arkaya! Devam et! 💪';
    if (streak == 7) return 'Bir hafta! Muhteşem! ⭐';
    if (streak == 14) return 'İki hafta! Alışkanlık oldu! 🔥';
    if (streak == 30) return 'Bir ay! İnanılmaz! 🏆';
    if (streak == 100) return 'Tam 100 gün! Efsanesin! 👑';
    if (streak % 30 == 0) return '$streak gün! Harikasın! 🎊';
    if (streak % 7 == 0) return '$streak gün! Süper seri! 💫';
    return 'Serin devam ediyor! $streak gün! 🔥';
  }
}
