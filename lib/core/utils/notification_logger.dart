import 'package:flutter/foundation.dart';

/// Bildirim sistemi için yapılandırılmış logging utility
/// Debug modda detaylı log, release modda sessiz çalışır
class NotificationLogger {
  static final NotificationLogger _instance = NotificationLogger._internal();
  factory NotificationLogger() => _instance;
  NotificationLogger._internal();

  /// Debug modu (varsayılan: kDebugMode)
  bool _debugMode = kDebugMode;

  /// Debug modunu ayarla
  void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  /// Log seviyeleri
  void debug(String message, {Map<String, dynamic>? data}) {
    _log('DEBUG', message, data: data);
  }

  void info(String message, {Map<String, dynamic>? data}) {
    _log('INFO', message, data: data);
  }

  void warning(String message, {Map<String, dynamic>? data}) {
    _log('WARNING', message, data: data);
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log('ERROR', message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Bildirim operasyonlarını logla
  void logOperation({
    required String operation,
    int? notificationId,
    String? notificationType,
    bool success = true,
    String? details,
  }) {
    final data = <String, dynamic>{
      'operation': operation,
      if (notificationId != null) 'id': notificationId,
      if (notificationType != null) 'type': notificationType,
      'success': success,
      if (details != null) 'details': details,
    };

    if (success) {
      info('Notification operation: $operation', data: data);
    } else {
      warning('Notification operation failed: $operation', data: data);
    }
  }

  /// Zamanlama operasyonlarını logla
  void logSchedule({
    required String scheduleName,
    required DateTime scheduledTime,
    int? notificationId,
    bool success = true,
  }) {
    final data = <String, dynamic>{
      'schedule': scheduleName,
      'time': scheduledTime.toIso8601String(),
      if (notificationId != null) 'id': notificationId,
      'success': success,
    };

    if (success) {
      info(
        'Scheduled: $scheduleName at ${scheduledTime.toString()}',
        data: data,
      );
    } else {
      warning('Schedule failed: $scheduleName', data: data);
    }
  }

  /// Permission durumunu logla
  void logPermission({required bool granted, String? platform}) {
    final status = granted ? 'granted' : 'denied';
    info(
      'Notification permission $status',
      data: {'granted': granted, if (platform != null) 'platform': platform},
    );
  }

  /// İç log metodu
  void _log(
    String level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_debugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();

    buffer.write('[$timestamp] ');
    buffer.write('[$level] ');
    buffer.write('[Notification] ');
    buffer.write(message);

    if (data != null && data.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(data.entries.map((e) => '${e.key}=${e.value}').join(', '));
    }

    debugPrint(buffer.toString());

    if (error != null) {
      debugPrint('  Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('  StackTrace: $stackTrace');
    }
  }
}

/// Global logger instance için kısayol
final notificationLogger = NotificationLogger();
