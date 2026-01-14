import 'package:flutter/material.dart';
import 'error_screen.dart';

/// Widget ağacındaki hataları yakalayan ve güvenli bir şekilde işleyen widget.
///
/// Kullanım:
/// ```dart
/// ErrorBoundary(
///   child: RiskyWidget(),
///   onError: (error, stackTrace) {
///     // Opsiyonel: Analytics'e gönder
///     Analytics.logError(error, stackTrace);
///   },
/// )
/// ```
///
/// Veya basit kullanım:
/// ```dart
/// ErrorBoundary(child: MyWidget())
/// ```
class ErrorBoundary extends StatefulWidget {
  /// Sarmalanan child widget
  final Widget child;

  /// Hata oluştuğunda çağrılacak callback
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Özelleştirilmiş hata widget'ı (null ise varsayılan ErrorScreen kullanılır)
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  /// Hata sonrası tekrar deneme aktif mi?
  final bool enableRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.errorBuilder,
    this.enableRetry = true,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  /// Yakalanan hata bilgisi
  Object? _error;

  /// Hata durumunu kontrol eder
  bool get _hasError => _error != null;

  /// Hata durumunu sıfırlar ve widget'ı yeniden oluşturur
  void _retry() {
    setState(() {
      _error = null;
    });
  }

  /// Hatayı yakalar ve state'i günceller
  void _handleError(Object error, StackTrace stackTrace) {
    // Hata callback'ini çağır (analytics, logging vb.)
    widget.onError?.call(error, stackTrace);

    // Debug modda hatayı logla
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ ERROR BOUNDARY CAUGHT ERROR');
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // State'i güncelle
    if (mounted) {
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hata durumundaysa hata ekranını göster
    if (_hasError) {
      return _buildErrorWidget();
    }

    // Normal durum: ErrorWidget.builder ile hataları yakala
    return _ErrorBoundaryScope(onError: _handleError, child: widget.child);
  }

  /// Hata durumunda gösterilecek widget
  Widget _buildErrorWidget() {
    // Özelleştirilmiş error builder varsa onu kullan
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(_error!, _retry);
    }

    // Varsayılan kompakt hata widget'ı
    return _DefaultErrorWidget(
      error: _error!,
      onRetry: widget.enableRetry ? _retry : null,
    );
  }
}

/// ErrorBoundary scope - hata yakalama mekanizması için
class _ErrorBoundaryScope extends StatelessWidget {
  final Widget child;
  final void Function(Object error, StackTrace stackTrace) onError;

  const _ErrorBoundaryScope({required this.child, required this.onError});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Varsayılan hata widget'ı - kompakt ve kullanıcı dostu
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hata ikonu
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),

          // Hata mesajı
          Text(
            'Bir hata oluştu',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Bu bileşen yüklenirken bir sorun oluştu.',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          // Tekrar dene butonu
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sayfa seviyesinde kullanılacak tam ekran Error Boundary
///
/// Kullanım:
/// ```dart
/// PageErrorBoundary(
///   child: ExpensesPage(),
///   pageName: 'Harcamalar',
/// )
/// ```
class PageErrorBoundary extends StatefulWidget {
  /// Sarmalanan sayfa widget'ı
  final Widget child;

  /// Sayfa adı (hata mesajında kullanılır)
  final String pageName;

  /// Hata oluştuğunda çağrılacak callback
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Ana sayfaya dönüş butonu gösterilsin mi?
  final bool showHomeButton;

  const PageErrorBoundary({
    super.key,
    required this.child,
    required this.pageName,
    this.onError,
    this.showHomeButton = true,
  });

  @override
  State<PageErrorBoundary> createState() => _PageErrorBoundaryState();
}

class _PageErrorBoundaryState extends State<PageErrorBoundary> {
  Object? _error;

  bool get _hasError => _error != null;

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return ErrorScreen(
        errorMessage: '${widget.pageName} sayfası yüklenirken bir hata oluştu.',
        onRetry: _retry,
      );
    }

    return widget.child;
  }
}

/// ErrorBoundary helper mixin - StatefulWidget'larda kullanılabilir
///
/// Kullanım:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with ErrorBoundaryMixin {
///   @override
///   Widget build(BuildContext context) {
///     return wrapWithErrorBoundary(
///       child: RiskyWidget(),
///       fallback: Text('Hata oluştu'),
///     );
///   }
/// }
/// ```
mixin ErrorBoundaryMixin<T extends StatefulWidget> on State<T> {
  /// Widget'ı ErrorBoundary ile sarar
  Widget wrapWithErrorBoundary({
    required Widget child,
    Widget? fallback,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return ErrorBoundary(
      onError: onError,
      errorBuilder: fallback != null ? (error, retry) => fallback : null,
      child: child,
    );
  }
}
