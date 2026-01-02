import 'package:flutter/material.dart';

/// Uygulama genelinde tutarlı SnackBar gösterimi için utility sınıfı.
///
/// Kullanım örnekleri:
/// ```dart
/// AppSnackBar.success(context, 'İşlem başarılı!');
/// AppSnackBar.error(context, 'Bir hata oluştu');
/// AppSnackBar.warning(context, 'Dikkat!');
/// AppSnackBar.info(context, 'Bilgi mesajı');
/// AppSnackBar.deleted(context, 'Öğe silindi', onUndo: () => _undoDelete());
/// ```
class AppSnackBar {
  AppSnackBar._(); // Private constructor - singleton pattern

  /// Başarı mesajı gösterir (yeşil tema)
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.check_circle_outline,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.green.shade700,
      icon: icon,
      duration: duration,
    );
  }

  /// Hata mesajı gösterir (kırmızı tema)
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.error_outline,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.red.shade800,
      icon: icon,
      duration: duration,
    );
  }

  /// Uyarı mesajı gösterir (turuncu tema)
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.warning_amber_outlined,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.orange.shade800,
      icon: icon,
      duration: duration,
    );
  }

  /// Bilgi mesajı gösterir (mavi tema)
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.info_outline,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.blue.shade700,
      icon: icon,
      duration: duration,
    );
  }

  /// Silme mesajı gösterir - "Geri Al" butonu ile (kırmızı tema)
  /// ⚠️ onUndo callback'i çağrılmadan önce context.mounted kontrolü yapılmalıdır
  static void deleted(
    BuildContext context,
    String message, {
    VoidCallback? onUndo,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!context.mounted) return;

    // Önce mevcut SnackBar'ı temizle
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        // Kullanıcı kaydırarak kapatabilsin
        dismissDirection: DismissDirection.horizontal,
        action: onUndo != null
            ? SnackBarAction(
                label: 'Geri Al',
                textColor: Colors.white,
                onPressed: onUndo,
              )
            : null,
      ),
    );
  }

  /// Aktif SnackBar'ı gizler (sayfa değişimlerinde kullanışlı)
  static void hide(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Özel SnackBar gösterir
  static void custom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      action: action,
      duration: duration,
    );
  }

  /// Temel SnackBar gösterim metodu
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        action: action,
      ),
    );
  }
}
