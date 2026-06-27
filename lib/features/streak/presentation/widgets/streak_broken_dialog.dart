import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Seri kırıldığında gösterilen dramatik uyarı dialog'u.
/// Kullanıcıya "Reklam İzle" (pasif) veya "Sıfırdan Başla" (aktif) seçeneği sunar.
class StreakBrokenDialog extends StatefulWidget {
  /// Kırılan seri sayısı (örn: 15)
  final int brokenStreakCount;
  final VoidCallback onDismiss;

  const StreakBrokenDialog({
    super.key,
    required this.brokenStreakCount,
    required this.onDismiss,
  });

  static Future<void> show(BuildContext context, int brokenStreakCount) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // Kullanıcı bir seçim yapmalı
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StreakBrokenDialog(
          brokenStreakCount: brokenStreakCount,
          onDismiss: () {
            if (dialogContext.mounted) {
              final nav = Navigator.of(dialogContext, rootNavigator: true);
              if (nav.canPop()) nav.pop();
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
  State<StreakBrokenDialog> createState() => _StreakBrokenDialogState();
}

class _StreakBrokenDialogState extends State<StreakBrokenDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    unawaited(_startHaptics());
  }

  Future<void> _startHaptics() async {
    if (!HapticService.isCelebrationEnabled) return;
    await HapticService.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await HapticService.heavyImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kırık kalp animasyonu
          ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Lottie.asset(
                'assets/lottie/Fire.json',
                fit: BoxFit.contain,
                // Ters renk hissi için grayscale shader olabilir, şimdilik aynı asset kullanılıyor
              ),
            ),
          ),
          const SizedBox(height: 12),

          // "💔 Eyvah!" başlığı
          FadeTransition(
            opacity: _textAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(_textAnimation),
              child: Column(
                children: [
                  // Uyarı başlığı (Arka plansız)
                  Text(
                    AppLocalizations.of(context)!.streakBrokenTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE53935),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gün sayısı
                  Text(
                    AppLocalizations.of(context)!.streakBrokenHeadline(widget.brokenStreakCount),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Alt açıklama
                  Text(
                    AppLocalizations.of(context)!.streakBrokenDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.70),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 📺 Reklam İzle butonu (pasif/soluk)
                  Opacity(
                    opacity: 0.38,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: null, // Şimdilik pasif
                        icon: const Text('📺', style: TextStyle(fontSize: 18)),
                        label: Text(
                          AppLocalizations.of(context)!.watchAdToSaveStreak,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF1565C0),
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ❌ Sıfırdan Başla butonu (aktif, çerçevesiz)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: widget.onDismiss,
                      icon: const Text('❌', style: TextStyle(fontSize: 16)),
                      label: Text(
                        AppLocalizations.of(context)!.startFromZero,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.75),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
