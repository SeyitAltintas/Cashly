import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/services/haptic_service.dart';

/// Seri yükseldiğinde gösterilen kutlama dialog'u
/// Ekranın ortasında büyük animasyon ve tebrik mesajı gösterir
class StreakCelebrationDialog extends StatefulWidget {
  final int streakCount;
  final VoidCallback? onDismiss;

  const StreakCelebrationDialog({
    super.key,
    required this.streakCount,
    this.onDismiss,
  });

  /// Dialog'u göstermek için static metod
  static Future<void> show(BuildContext context, int streakCount) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StreakCelebrationDialog(
          streakCount: streakCount,
          onDismiss: () {
            if (dialogContext.mounted) {
              final route = ModalRoute.of(dialogContext);
              if (route != null && route.isCurrent) {
                final nav = Navigator.of(dialogContext, rootNavigator: true);
                if (nav.canPop()) {
                  nav.pop();
                }
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

    // Haptic feedback - 3 saniye boyunca titreşim
    _startCelebrationHaptics();

    // 3 saniye sonra otomatik kapat
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  /// Kutlama titreşim melodisi
  /// 1x uzun + 1x uzun + 1x daha uzun (aynı güçte, artan süre)
  /// Ayarlardan kapatılabilir
  void _startCelebrationHaptics() async {
    // Ayardan kontrol et
    if (!HapticService.isCelebrationEnabled) return;

    // İlk uzun titreşim (100ms)
    await HapticService.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || !HapticService.isCelebrationEnabled) return;

    // İkinci uzun titreşim (100ms)
    await HapticService.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || !HapticService.isCelebrationEnabled) return;

    // Üçüncü daha uzun titreşim (400ms - 4 kat uzun)
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

  String _getCelebrationMessage(BuildContext context) {
    final l = context.l10n;
    final streak = widget.streakCount;
    if (streak == 1) return l.streakMsg1;
    if (streak == 3) return l.streakMsg3;
    if (streak == 7) return l.streakMsg7;
    if (streak == 14) return l.streakMsg14;
    if (streak == 30) return l.streakMsg30;
    if (streak == 100) return l.streakMsg100;
    if (streak == 365) return l.streakMsg365;
    if (streak % 100 == 0) return l.streakMsgMultiple100;
    if (streak % 30 == 0) return l.streakMsgMultiple30;
    if (streak % 7 == 0) return l.streakMsgMultiple7;
    return l.streakMsgDefault;
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fire.json Animasyonu - büyük
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

                  // Seri sayısı ve gün
                  Opacity(
                    opacity: _textAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _textAnimation.value)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${widget.streakCount}',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFF6B35),
                              height: 1,
                              shadows: [
                                Shadow(
                                  color: const Color(
                                    0xFFFF6B35,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              context.l10n.streakCelebrationDayLabel,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tebrik mesajı
                  Opacity(
                    opacity: _textAnimation.value,
                    child: Text(
                      _getCelebrationMessage(context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
