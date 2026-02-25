import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/exceptions/app_exceptions.dart';

/// AppException hiyerarşisi testleri
/// Her exception tipi: factory constructor'lar, mesajlar, kodlar ve toString
void main() {
  group('AppException — Temel', () {
    test('mesaj ve kod doğru döner', () {
      const e = AppException('Test hata', code: 'TEST');
      expect(e.message, equals('Test hata'));
      expect(e.code, equals('TEST'));
    });

    test('toString doğru format', () {
      const e = AppException('Bir hata', code: 'ERR');
      expect(e.toString(), equals('AppException: Bir hata (Code: ERR)'));
    });

    test('opsiyonel alanlar null olabilir', () {
      const e = AppException('Basit hata');
      expect(e.code, isNull);
      expect(e.originalError, isNull);
      expect(e.stackTrace, isNull);
    });

    test('originalError korunur', () {
      const original = FormatException('bad format');
      const e = AppException('Wrap', originalError: original);
      expect(e.originalError, isA<FormatException>());
    });
  });

  group('AuthException — Factory Constructors', () {
    test('userNotFound doğru mesaj ve kod', () {
      final e = AuthException.userNotFound();
      expect(e.message, equals('Kullanıcı bulunamadı'));
      expect(e.code, equals('USER_NOT_FOUND'));
    });

    test('invalidPin doğru mesaj ve kod', () {
      final e = AuthException.invalidPin();
      expect(e.message, equals('Hatalı PIN girdiniz'));
      expect(e.code, equals('INVALID_PIN'));
    });

    test('biometricFailed doğru mesaj ve kod', () {
      final e = AuthException.biometricFailed();
      expect(e.code, equals('BIOMETRIC_FAILED'));
    });

    test('emailAlreadyExists doğru mesaj ve kod', () {
      final e = AuthException.emailAlreadyExists();
      expect(e.code, equals('EMAIL_EXISTS'));
    });

    test('noSecurityQuestion doğru kod', () {
      final e = AuthException.noSecurityQuestion();
      expect(e.code, equals('NO_SECURITY_QUESTION'));
    });

    test('wrongSecurityAnswer doğru kod', () {
      final e = AuthException.wrongSecurityAnswer();
      expect(e.code, equals('WRONG_SECURITY_ANSWER'));
    });

    test('toString AuthException prefix ile', () {
      final e = AuthException.invalidPin();
      expect(e.toString(), startsWith('AuthException:'));
    });
  });

  group('DatabaseException — Factory Constructors', () {
    test('initFailed orijinal hatayı korur', () {
      final e = DatabaseException.initFailed('disk error');
      expect(e.code, equals('INIT_FAILED'));
      expect(e.originalError, equals('disk error'));
    });

    test('readFailed kodu doğru', () {
      final e = DatabaseException.readFailed('err');
      expect(e.code, equals('READ_FAILED'));
    });

    test('writeFailed kodu doğru', () {
      final e = DatabaseException.writeFailed('err');
      expect(e.code, equals('WRITE_FAILED'));
    });

    test('deleteFailed kodu doğru', () {
      final e = DatabaseException.deleteFailed('err');
      expect(e.code, equals('DELETE_FAILED'));
    });

    test('notFound mesajına item eklenir', () {
      final e = DatabaseException.notFound('Harcama');
      expect(e.message, equals('Harcama bulunamadı'));
      expect(e.code, equals('NOT_FOUND'));
    });
  });

  group('ValidationException — Factory Constructors', () {
    test('required alan adını içerir', () {
      final e = ValidationException.required('Tutar');
      expect(e.message, contains('Tutar'));
      expect(e.fieldName, equals('Tutar'));
      expect(e.code, equals('REQUIRED_FIELD'));
    });

    test('invalidFormat alan adını içerir', () {
      final e = ValidationException.invalidFormat('Email');
      expect(e.message, contains('Email'));
      expect(e.code, equals('INVALID_FORMAT'));
    });

    test('outOfRange min ve max aralığını gösterir', () {
      final e = ValidationException.outOfRange('Tutar', min: 0, max: 1000000);
      expect(e.message, contains('0'));
      expect(e.message, contains('1000000'));
      expect(e.code, equals('OUT_OF_RANGE'));
    });

    test('outOfRange sadece min', () {
      final e = ValidationException.outOfRange('Miktar', min: 1);
      expect(e.message, contains('en az 1'));
    });

    test('outOfRange sadece max', () {
      final e = ValidationException.outOfRange('Adet', max: 100);
      expect(e.message, contains('en fazla 100'));
    });

    test('toString fieldName içerir', () {
      final e = ValidationException.required('İsim');
      expect(e.toString(), contains('Field: İsim'));
    });
  });

  group('NetworkException — Factory Constructors', () {
    test('noConnection doğru kod', () {
      final e = NetworkException.noConnection();
      expect(e.code, equals('NO_CONNECTION'));
      expect(e.message, contains('bağlantı'));
    });

    test('timeout doğru kod', () {
      final e = NetworkException.timeout();
      expect(e.code, equals('TIMEOUT'));
    });

    test('serverError status code içerir', () {
      final e = NetworkException.serverError(500);
      expect(e.message, contains('500'));
      expect(e.code, equals('SERVER_ERROR'));
    });

    test('serverError null status code', () {
      final e = NetworkException.serverError(null);
      expect(e.message, isNot(contains('null')));
    });
  });

  group('ExportException — Factory Constructors', () {
    test('pdfCreationFailed doğru kod', () {
      final e = ExportException.pdfCreationFailed('err');
      expect(e.code, equals('PDF_CREATION_FAILED'));
    });

    test('csvCreationFailed doğru kod', () {
      final e = ExportException.csvCreationFailed('err');
      expect(e.code, equals('CSV_CREATION_FAILED'));
    });

    test('shareFailed doğru kod', () {
      final e = ExportException.shareFailed('err');
      expect(e.code, equals('SHARE_FAILED'));
    });

    test('fontLoadFailed doğru kod', () {
      final e = ExportException.fontLoadFailed('err');
      expect(e.code, equals('FONT_LOAD_FAILED'));
    });
  });

  group('StorageException — Factory Constructors', () {
    test('backupFailed doğru kod', () {
      final e = StorageException.backupFailed('err');
      expect(e.code, equals('BACKUP_FAILED'));
    });

    test('restoreFailed doğru kod', () {
      final e = StorageException.restoreFailed('err');
      expect(e.code, equals('RESTORE_FAILED'));
    });

    test("tum CRUD factory'ler dogru kod", () {
      expect(StorageException.createFailed('e').code, equals('CREATE_FAILED'));
      expect(StorageException.readFailed('e').code, equals('READ_FAILED'));
      expect(StorageException.writeFailed('e').code, equals('WRITE_FAILED'));
      expect(StorageException.deleteFailed('e').code, equals('DELETE_FAILED'));
    });
  });

  group('AssetException — Factory Constructors', () {
    test('priceUpdateFailed doğru kod', () {
      final e = AssetException.priceUpdateFailed('api error');
      expect(e.code, equals('PRICE_UPDATE_FAILED'));
      expect(e.originalError, equals('api error'));
    });

    test('invalidAssetType tipi mesaja ekler', () {
      final e = AssetException.invalidAssetType('xyz');
      expect(e.message, contains('xyz'));
      expect(e.code, equals('INVALID_ASSET_TYPE'));
    });

    test('calculationFailed doğru kod', () {
      final e = AssetException.calculationFailed('div by zero');
      expect(e.code, equals('CALCULATION_FAILED'));
    });
  });

  group('Exception Hiyerarşisi', () {
    test('tüm exception\'lar AppException\'dan türer', () {
      expect(AuthException.invalidPin(), isA<AppException>());
      expect(DatabaseException.readFailed('e'), isA<AppException>());
      expect(ValidationException.required('x'), isA<AppException>());
      expect(NetworkException.noConnection(), isA<AppException>());
      expect(ExportException.pdfCreationFailed('e'), isA<AppException>());
      expect(StorageException.backupFailed('e'), isA<AppException>());
      expect(AssetException.invalidAssetType('x'), isA<AppException>());
    });

    test('tüm exception\'lar Exception interface\'ini implemente eder', () {
      expect(AuthException.invalidPin(), isA<Exception>());
      expect(DatabaseException.readFailed('e'), isA<Exception>());
      expect(NetworkException.noConnection(), isA<Exception>());
    });
  });
}
