import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
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
    if (!context.read<ThemeManager>().isStreakAnimationEnabled) {
      return Future.value();
    }

    return showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StreakCelebrationDialog(
          streakCount: streakCount,
          newRank: newRank,
          onDismiss: () {
            if (dialogContext.mounted) {
              final route = ModalRoute.of(dialogContext);
              if (route != null && route.isCurrent) {
                final nav = Navigator.of(dialogContext, rootNavigator: true);
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
    _dismissTimer = Timer(Duration(seconds: _isRankUp ? 4 : 3), () {
      if (mounted) widget.onDismiss?.call();
    });
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
          child: _isRankUp ? _buildRankUpContent() : _buildStreakContent(),
        ),
      ),
    );
  }

  Widget _buildRankUpContent() {
    final rank = widget.newRank!;
    final profileImage = getIt<DashboardController>().profileImage;

    double getAvatarRadius(int level) {
      double ratio;
      switch (level) {
        case 1:
        case 2:
          ratio = 0.85;
          break;
        case 3:
        case 4:
        case 5:
        case 6:
          ratio = 0.88;
          break;
        case 7:
        case 9:
          ratio = 0.75;
          break;
        case 8:
          ratio = 0.77;
          break;
        default:
          ratio = 0.85;
      }
      return ((250 / 2.4) * ratio) / 2;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rank Lottie animasyonu
        ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan ışığı (Glow)
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: rank.glowColor.withValues(alpha: 0.6),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                Lottie.asset(
                  rank.lottieAsset,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
                if (profileImage != null && profileImage.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rank.glowColor.withValues(alpha: 0.8),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CircleAvatar(
                        radius: getAvatarRadius(rank.level),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        backgroundImage: ImageUtils.getProfileImageProvider(
                          profileImage,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Rank up başlığı
        FadeTransition(
          opacity: _textAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(_textAnimation),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.rankUpTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: rank.primaryColor,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: rank.glowColor.withValues(alpha: 0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Yeni rank adı
                Text(
                  rank.name,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
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
        ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset('assets/lottie/Fire.json', fit: BoxFit.contain),
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
                    shadows: [Shadow(color: Color(0x80FF6B35), blurRadius: 20)],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    AppLocalizations.of(context)!.streakDayWord,
                    style: const TextStyle(
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

        FadeTransition(
          opacity: _textAnimation,
          child: Text(
            _streakMessage(context, streak),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _streakMessage(BuildContext context, int streak) {
    final l10n = AppLocalizations.of(context)!;
    if (streak == 1) return l10n.streakMsgStart;
    if (streak == 3) return l10n.streakMsg3Days;
    if (streak == 7) return l10n.streakMsg1Week;
    if (streak == 14) return l10n.streakMsg2Weeks;
    if (streak == 30) return l10n.streakMsg1Month;
    if (streak == 100) return l10n.streakMsg100Days;
    if (streak % 30 == 0) return l10n.streakMsgMonthly(streak);
    if (streak % 7 == 0) return l10n.streakMsgWeekly(streak);
    return l10n.streakMsgDynamic(streak);
  }
}
