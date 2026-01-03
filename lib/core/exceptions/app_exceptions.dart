/// Cashly uygulaması için özel exception sınıfları
///
/// Bu sınıflar uygulamadaki farklı hata türlerini kategorize etmek ve
/// kullanıcıya anlamlı hata mesajları göstermek için kullanılır.
library;

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

/// Ağ/İnternet ile ilgili hatalar
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

/// PDF/CSV dışa aktarma hataları
class ExportException extends AppException {
  const ExportException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// PDF oluşturma hatası
  factory ExportException.pdfCreationFailed(dynamic error) => ExportException(
    'PDF dosyası oluşturulamadı',
    code: 'PDF_CREATION_FAILED',
    originalError: error,
  );

  /// CSV oluşturma hatası
  factory ExportException.csvCreationFailed(dynamic error) => ExportException(
    'CSV dosyası oluşturulamadı',
    code: 'CSV_CREATION_FAILED',
    originalError: error,
  );

  /// Dosya paylaşma hatası
  factory ExportException.shareFailed(dynamic error) => ExportException(
    'Dosya paylaşılamadı',
    code: 'SHARE_FAILED',
    originalError: error,
  );

  /// Font yükleme hatası
  factory ExportException.fontLoadFailed(dynamic error) => ExportException(
    'Yazı tipi yüklenemedi',
    code: 'FONT_LOAD_FAILED',
    originalError: error,
  );

  @override
  String toString() =>
      'ExportException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Dosya/Depolama işlem hataları
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Dosya oluşturma hatası
  factory StorageException.createFailed(dynamic error) => StorageException(
    'Dosya oluşturulamadı',
    code: 'CREATE_FAILED',
    originalError: error,
  );

  /// Dosya okuma hatası
  factory StorageException.readFailed(dynamic error) => StorageException(
    'Dosya okunamadı',
    code: 'READ_FAILED',
    originalError: error,
  );

  /// Dosya yazma hatası
  factory StorageException.writeFailed(dynamic error) => StorageException(
    'Dosya yazılamadı',
    code: 'WRITE_FAILED',
    originalError: error,
  );

  /// Dosya silme hatası
  factory StorageException.deleteFailed(dynamic error) => StorageException(
    'Dosya silinemedi',
    code: 'DELETE_FAILED',
    originalError: error,
  );

  /// Yedekleme hatası
  factory StorageException.backupFailed(dynamic error) => StorageException(
    'Yedekleme başarısız',
    code: 'BACKUP_FAILED',
    originalError: error,
  );

  /// Geri yükleme hatası
  factory StorageException.restoreFailed(dynamic error) => StorageException(
    'Geri yükleme başarısız',
    code: 'RESTORE_FAILED',
    originalError: error,
  );

  @override
  String toString() =>
      'StorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Varlık (Asset) işlem hataları
class AssetException extends AppException {
  const AssetException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Fiyat güncelleme hatası
  factory AssetException.priceUpdateFailed(dynamic error) => AssetException(
    'Varlık fiyatı güncellenemedi',
    code: 'PRICE_UPDATE_FAILED',
    originalError: error,
  );

  /// Geçersiz varlık tipi
  factory AssetException.invalidAssetType(String type) =>
      AssetException('Geçersiz varlık tipi: $type', code: 'INVALID_ASSET_TYPE');

  /// Hesaplama hatası
  factory AssetException.calculationFailed(dynamic error) => AssetException(
    'Varlık hesaplaması yapılamadı',
    code: 'CALCULATION_FAILED',
    originalError: error,
  );

  @override
  String toString() =>
      'AssetException: $message${code != null ? ' (Code: $code)' : ''}';
}
