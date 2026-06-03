import 'package:flutter/material.dart';
import 'package:cashly/core/services/error_logger_service.dart';
import 'package:cashly/core/widgets/fallback_error_widget.dart';

/// Flutter'da build hataları ErrorWidget.builder ile global olarak yakalanır.
/// Bu [ErrorBoundary] widget'i ise özellikle asenkron işlemlerde, 
/// state güncellemelerinde veya callback'lerde oluşabilecek hataları manuel
/// sarmalamak ve izole etmek için kullanılır.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final Function(Object error, StackTrace stackTrace)? onError;
  final bool enableRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.enableRetry = true,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  void reportError(Object error, StackTrace stackTrace) {
    if (!mounted) return;
    
    // Log the error
    ErrorLoggerService.logError(
      'ErrorBoundary Yakaladı: $error',
      stackTrace: stackTrace.toString(),
    );

    widget.onError?.call(error, stackTrace);

    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  void resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, resetError);
      }
      return FallbackErrorWidget(
        details: FlutterErrorDetails(
          exception: _error!,
          stack: _stackTrace,
          library: 'ErrorBoundary',
        ),
        onRetry: widget.enableRetry ? resetError : null,
      );
    }

    // Try-catch build anında işe yaramaz ama future builder benzeri manuel state durumları için kılıf
    return widget.child;
  }
}

/// Tüm sayfanın (route) çökmesini engellemek için özelleşmiş ErrorBoundary.
class PageErrorBoundary extends StatelessWidget {
  final String pageName;
  final Widget child;
  final bool showHomeButton;

  const PageErrorBoundary({
    super.key,
    required this.pageName,
    required this.child,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (error, stackTrace) {
        ErrorLoggerService.logError(
          '$pageName sayfası yüklenirken hata oluştu: $error',
          stackTrace: stackTrace.toString(),
        );
      },
      child: child,
    );
  }
}
