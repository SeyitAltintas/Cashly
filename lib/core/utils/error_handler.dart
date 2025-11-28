import 'package:flutter/material.dart';

/// Error handling ve kullanıcı feedback yardımcı fonksiyonları
class ErrorHandler {
  /// Hata mesajı gösterir (kırmızı tema)
  ///
  /// Örnek: ErrorHandler.showErrorSnackBar(context, "Bir hata oluştu");
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFCF6679),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Başarı mesajı gösterir (mor tema)
  ///
  /// Örnek: ErrorHandler.showSuccessSnackBar(context, "Kayıt başarılı!");
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF9D00FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Uyarı mesajı gösterir (turuncu tema)
  ///
  /// Örnek: ErrorHandler.showWarningSnackBar(context, "Bütçe limitine yaklaştınız");
  static void showWarningSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Database hata mesajlarını kullanıcı dostu hale getirir
  ///
  /// Örnek: ErrorHandler.handleDatabaseError(context, exception);
  static void handleDatabaseError(BuildContext context, dynamic error) {
    String userMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';

    // Log error for debugging
    debugPrint('Database Error: $error');

    // Özel hata mesajları
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('not found')) {
      userMessage = 'Veri bulunamadı';
    } else if (errorString.contains('connection')) {
      userMessage = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
    } else if (errorString.contains('timeout')) {
      userMessage = 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
    } else if (errorString.contains('permission')) {
      userMessage = 'Erişim izni hatası';
    }

    showErrorSnackBar(context, userMessage);
  }

  /// Genel hata loglama (development için)
  ///
  /// Örnek: ErrorHandler.logError("API Hatası", exception, stackTrace);
  static void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ ERROR in $context');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Onay dialogu gösterir
  ///
  /// Örnek:
  /// ```dart
  /// final confirmed = await ErrorHandler.showConfirmDialog(
  ///   context,
  ///   title: "Silme Onayı",
  ///   message: "Bu öğeyi silmek istediğinize emin misiniz?"
  /// );
  /// ```
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Evet',
    String cancelText = 'İptal',
    bool isDanger = false,
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDanger
                    ? const Color(0xFFCF6679)
                    : const Color(0xFFBB86FC),
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Loading dialog gösterir
  ///
  /// Kullanım:
  /// ```dart
  /// ErrorHandler.showLoadingDialog(context);
  /// // Async işlem
  /// Navigator.pop(context); // Dialog'u kapat
  /// ```
  static void showLoadingDialog(BuildContext context, {String? message}) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF9D00FF)),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message, style: const TextStyle(color: Colors.white)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
