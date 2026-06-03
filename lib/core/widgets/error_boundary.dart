import 'package:flutter/material.dart';
import 'package:cashly/core/services/error_logger_service.dart';
import 'package:cashly/core/widgets/fallback_error_widget.dart';

/// Flutter'da build hataları ErrorWidget.builder ile global olarak yakalanır.
/// Bu [ErrorBoundary] widget'i ise özellikle asenkron işlemlerde, 
/// state güncellemelerinde veya callback'lerde oluşabilecek hataları manuel
/// sarmalamak ve izole etmek için kullanılır.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace stackTrace)? fallbackBuilder;
  final Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
    this.onError,
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
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _error!, _stackTrace!);
      }
      return FallbackErrorWidget(
        details: FlutterErrorDetails(
          exception: _error!,
          stack: _stackTrace,
          library: 'ErrorBoundary',
        ),
        onRetry: resetError,
      );
    }

    return widget.child;
  }
}
