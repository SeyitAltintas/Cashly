/// Cashly uygulaması için özel exception sınıfları
///
/// Bu sınıflar uygulamadaki farklı hata türlerini kategorize etmek ve
/// kullanıcıya anlamlı hata mesajları göstermek için kullanılır.

/// Temel exception sınıfı - tüm uygulama exception'ları bundan türer
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Kimlik doğrulama ile ilgili hatalar
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Kullanıcı bulunamadı
  factory AuthException.userNotFound() =>
      const AuthException('Kullanıcı bulunamadı', code: 'USER_NOT_FOUND');

  /// Hatalı PIN
  factory AuthException.invalidPin() =>
      const AuthException('Hatalı PIN girdiniz', code: 'INVALID_PIN');

  /// Biyometrik doğrulama hatası
  factory AuthException.biometricFailed() => const AuthException(
    'Biyometrik doğrulama başarısız',
    code: 'BIOMETRIC_FAILED',
  );

  /// Email zaten kayıtlı
  factory AuthException.emailAlreadyExists() => const AuthException(
    'Bu e-posta adresi zaten kayıtlı',
    code: 'EMAIL_EXISTS',
  );

  /// Güvenlik sorusu tanımlanmamış
  factory AuthException.noSecurityQuestion() => const AuthException(
    'Bu hesap için güvenlik sorusu tanımlanmamış',
    code: 'NO_SECURITY_QUESTION',
  );

  /// Yanlış güvenlik cevabı
  factory AuthException.wrongSecurityAnswer() => const AuthException(
    'Güvenlik sorusuna verdiğiniz cevap yanlış',
    code: 'WRONG_SECURITY_ANSWER',
  );

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Veritabanı işlemleri ile ilgili hatalar
class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Veritabanı başlatma hatası
  factory DatabaseException.initFailed(dynamic error) => DatabaseException(
    'Veritabanı başlatılamadı',
    code: 'INIT_FAILED',
    originalError: error,
  );

  /// Veri okuma hatası
  factory DatabaseException.readFailed(dynamic error) => DatabaseException(
    'Veri okunamadı',
    code: 'READ_FAILED',
    originalError: error,
  );

  /// Veri yazma hatası
  factory DatabaseException.writeFailed(dynamic error) => DatabaseException(
    'Veri kaydedilemedi',
    code: 'WRITE_FAILED',
    originalError: error,
  );

  /// Veri silme hatası
  factory DatabaseException.deleteFailed(dynamic error) => DatabaseException(
    'Veri silinemedi',
    code: 'DELETE_FAILED',
    originalError: error,
  );

  /// Veri bulunamadı
  factory DatabaseException.notFound(String item) =>
      DatabaseException('$item bulunamadı', code: 'NOT_FOUND');

  @override
  String toString() =>
      'DatabaseException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Doğrulama (validation) hataları
class ValidationException extends AppException {
  final String? fieldName;

  const ValidationException(super.message, {this.fieldName, super.code});

  /// Zorunlu alan eksik
  factory ValidationException.required(String fieldName) => ValidationException(
    '$fieldName alanı zorunludur',
    fieldName: fieldName,
    code: 'REQUIRED_FIELD',
  );

  /// Geçersiz format
  factory ValidationException.invalidFormat(String fieldName) =>
      ValidationException(
        '$fieldName formatı geçersiz',
        fieldName: fieldName,
        code: 'INVALID_FORMAT',
      );

  /// Değer aralık dışında
  factory ValidationException.outOfRange(
    String fieldName, {
    num? min,
    num? max,
  }) {
    String message = '$fieldName değeri';
    if (min != null && max != null) {
      message += ' $min ile $max arasında olmalıdır';
    } else if (min != null) {
      message += ' en az $min olmalıdır';
    } else if (max != null) {
      message += ' en fazla $max olabilir';
    }
    return ValidationException(
      message,
      fieldName: fieldName,
      code: 'OUT_OF_RANGE',
    );
  }

  @override
  String toString() =>
      'ValidationException: $message${fieldName != null ? ' (Field: $fieldName)' : ''}';
}

/// Ağ/İnternet ile ilgili hatalar (gelecekte kullanılmak üzere)
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Bağlantı hatası
  factory NetworkException.noConnection() =>
      const NetworkException('İnternet bağlantısı yok', code: 'NO_CONNECTION');

  /// Zaman aşımı
  factory NetworkException.timeout() =>
      const NetworkException('İşlem zaman aşımına uğradı', code: 'TIMEOUT');

  /// Sunucu hatası
  factory NetworkException.serverError(int? statusCode) => NetworkException(
    'Sunucu hatası${statusCode != null ? ' ($statusCode)' : ''}',
    code: 'SERVER_ERROR',
  );

  @override
  String toString() =>
      'NetworkException: $message${code != null ? ' (Code: $code)' : ''}';
}
