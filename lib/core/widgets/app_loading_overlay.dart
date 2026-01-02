import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Uygulama genelinde tutarlı loading ve başarı overlay'leri için utility sınıfı.
///
/// Kullanım örnekleri:
/// ```dart
/// AppLoadingOverlay.show(context, message: 'Yükleniyor...');
/// AppLoadingOverlay.hide(context);
/// AppLoadingOverlay.showSuccess(context, message: 'Başarılı!');
/// ```
class AppLoadingOverlay {
  AppLoadingOverlay._(); // Private constructor - singleton pattern

  /// Loading overlay'i gösterir (kullanıcı kapatamaz)
  static void show(
    BuildContext context, {
    String message = 'Yükleniyor...',
    String lottieAsset = 'assets/lottie/verigeriyukleme.json',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(lottieAsset, width: 300, height: 300),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Loading overlay'i kapatır
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Başarı overlay'ini gösterir ve belirtilen süre sonra otomatik kapanır
  static Future<void> showSuccess(
    BuildContext context, {
    String message = 'İşlem başarılı!',
    String lottieAsset = 'assets/lottie/Success_animation.json',
    Duration duration = const Duration(seconds: 2),
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(lottieAsset, width: 300, height: 300),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(duration);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
