/// Bildirim sistemi için özel exception sınıfları
library;

/// Ana bildirim exception sınıfı
class NotificationException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const NotificationException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'NotificationException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Bildirim izni reddedildiğinde
class NotificationPermissionDeniedException extends NotificationException {
  const NotificationPermissionDeniedException([
    super.message = 'Bildirim izni reddedildi',
  ]) : super(code: 'PERMISSION_DENIED');
}

/// Bildirim zamanlama hatası
class NotificationScheduleException extends NotificationException {
  final int? notificationId;

  const NotificationScheduleException(
    super.message, {
    this.notificationId,
    super.originalError,
  }) : super(code: 'SCHEDULE_ERROR');

  @override
  String toString() =>
      'NotificationScheduleException: $message${notificationId != null ? ' (id: $notificationId)' : ''}';
}

/// Platform spesifik hatalar (Android/iOS)
class NotificationPlatformException extends NotificationException {
  final String platform;

  const NotificationPlatformException(
    super.message, {
    required this.platform,
    super.originalError,
  }) : super(code: 'PLATFORM_ERROR');

  @override
  String toString() => 'NotificationPlatformException [$platform]: $message';
}

/// Bildirim iptal hatası
class NotificationCancelException extends NotificationException {
  final int? notificationId;

  const NotificationCancelException(
    super.message, {
    this.notificationId,
    super.originalError,
  }) : super(code: 'CANCEL_ERROR');
}
