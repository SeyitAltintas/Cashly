import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cashly/features/auth/domain/entities/user_entity.dart';
import 'package:cashly/features/auth/domain/repositories/auth_repository.dart';

/// Mock AuthRepository - testlerde gerçek veritabanını kullanmadan test yapabilmek için
class MockAuthRepository implements AuthRepository {
  final List<UserEntity> _users = [];
  String? _currentUserId;
  String? _lastUserId;

  @override
  Future<UserEntity> registerUser(UserEntity user) async {
    _users.add(user);
    _currentUserId = user.id;
    _lastUserId = user.id;
    return user;
  }

  @override
  Future<UserEntity?> loginByEmail(String email, String pin) async {
    try {
      final user = _users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase() && u.pin == pin);
      _currentUserId = user.id;
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserEntity?> loginUser(String id, String pin) async {
    try {
      final user = _users.firstWhere((u) => u.id == id && u.pin == pin);
      _currentUserId = user.id;
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUserId == null) return null;
    try {
      return _users.firstWhere((u) => u.id == _currentUserId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    _currentUserId = null;
  }

  @override
  Future<List<UserEntity>> getAllUsers() async => _users;

  @override
  Future<void> setCurrentUser(String id) async {
    _currentUserId = id;
    _lastUserId = id;
  }

  @override
  Future<String?> getLastUserId() async => _lastUserId;

  @override
  Future<void> setLastUserId(String id) async {
    _lastUserId = id;
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    _users.removeWhere((u) => u.id == userId);
    if (_currentUserId == userId) {
      _currentUserId = null;
    }
  }

  @override
  Future<UserEntity?> loginWithBiometric(String userId) async {
    try {
      final user = _users.firstWhere(
        (u) => u.id == userId && u.biometricEnabled,
      );
      _currentUserId = user.id;
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateBiometricPreference(String userId, bool enabled) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _users[index];
      _users[index] = UserEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        pin: user.pin,
        createdAt: user.createdAt,
        biometricEnabled: enabled,
        securityQuestion: user.securityQuestion,
        securityAnswer: user.securityAnswer,
      );
    }
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    try {
      return _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateUserPin(String userId, String newPin) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _users[index];
      _users[index] = UserEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        pin: newPin,
        createdAt: user.createdAt,
        biometricEnabled: user.biometricEnabled,
        securityQuestion: user.securityQuestion,
        securityAnswer: user.securityAnswer,
      );
    }
  }
}

void main() {
  group('AuthController', () {
    late MockAuthRepository mockRepository;
    late AuthController authController;

    setUp(() {
      mockRepository = MockAuthRepository();
      authController = AuthController(mockRepository);
    });

    group('register', () {
      test('başarılı kayıt true döner ve currentUser ayarlanır', () async {
        final result = await authController.register(
          'Test Kullanıcı',
          'test@example.com',
          '1234',
        );

        expect(result, isTrue);
        expect(authController.currentUser, isNotNull);
        expect(authController.currentUser!.name, equals('Test Kullanıcı'));
        expect(authController.currentUser!.email, equals('test@example.com'));
        expect(authController.error, isNull);
      });

      test('güvenlik sorusu ile kayıt başarılı olur', () async {
        final result = await authController.register(
          'Test Kullanıcı',
          'test@example.com',
          '1234',
          securityQuestion: 'Evcil hayvanınızın adı?',
          securityAnswer: 'Boncuk',
        );

        expect(result, isTrue);
        expect(
          authController.currentUser!.securityQuestion,
          equals('Evcil hayvanınızın adı?'),
        );
        expect(
          authController.currentUser!.securityAnswer,
          equals('boncuk'),
        ); // lowercase
      });
    });

    group('login', () {
      setUp(() async {
        // Önce bir kullanıcı kaydet
        await authController.register('Test User', 'test@example.com', '1234');
        await authController.logout();
      });

      test('doğru PIN ile giriş başarılı olur', () async {
        final users = await authController.getAllUsers();
        final userId = users.first.id;

        final result = await authController.login(userId, '1234');

        expect(result, isTrue);
        expect(authController.currentUser, isNotNull);
        expect(authController.error, isNull);
      });

      test('yanlış PIN ile giriş başarısız olur', () async {
        final users = await authController.getAllUsers();
        final userId = users.first.id;

        final result = await authController.login(userId, '9999');

        expect(result, isFalse);
        expect(authController.currentUser, isNull);
        expect(authController.error, isNotNull);
      });
    });

    group('loginByEmail', () {
      setUp(() async {
        await authController.register('Test User', 'test@example.com', '1234');
        await authController.logout();
      });

      test('doğru email ve PIN ile giriş başarılı olur', () async {
        final result = await authController.loginByEmail(
          'test@example.com',
          '1234',
        );

        expect(result, isTrue);
        expect(authController.currentUser, isNotNull);
      });

      test('olmayan email ile giriş başarısız olur', () async {
        final result = await authController.loginByEmail(
          'unknown@example.com',
          '1234',
        );

        expect(result, isFalse);
        expect(authController.error, contains('bulunamadı'));
      });

      test('yanlış PIN ile giriş başarısız olur', () async {
        final result = await authController.loginByEmail(
          'test@example.com',
          '9999',
        );

        expect(result, isFalse);
        expect(authController.error, contains('PIN'));
      });
    });

    group('logout', () {
      test('çıkış yaptıktan sonra currentUser null olur', () async {
        await authController.register('Test User', 'test@example.com', '1234');
        expect(authController.currentUser, isNotNull);

        await authController.logout();

        expect(authController.currentUser, isNull);
      });
    });

    group('getUserByEmail', () {
      test('kayıtlı email için kullanıcı döner', () async {
        await authController.register('Ali', 'ali@example.com', '1234');

        final user = await authController.getUserByEmail('ali@example.com');

        expect(user, isNotNull);
        expect(user!.name, equals('Ali'));
      });

      test('kayıtlı olmayan email için null döner', () async {
        final user = await authController.getUserByEmail('unknown@example.com');

        expect(user, isNull);
      });
    });

    group('verifySecurityAnswerAndResetPin', () {
      setUp(() async {
        await authController.register(
          'Güvenlik Testi',
          'guvenlik@example.com',
          '1234',
          securityQuestion: 'Doğum yeriniz?',
          securityAnswer: 'İstanbul',
        );
        await authController.logout();
      });

      test('doğru cevap ile PIN sıfırlanır', () async {
        final result = await authController.verifySecurityAnswerAndResetPin(
          'guvenlik@example.com',
          'İstanbul',
          '5678',
        );

        expect(result, isTrue);

        // Yeni PIN ile giriş yapabilmeli
        final loginResult = await authController.loginByEmail(
          'guvenlik@example.com',
          '5678',
        );
        expect(loginResult, isTrue);
      });

      test('yanlış cevap ile PIN sıfırlanmaz', () async {
        final result = await authController.verifySecurityAnswerAndResetPin(
          'guvenlik@example.com',
          'Ankara',
          '5678',
        );

        expect(result, isFalse);
        expect(authController.error, isNotNull);
      });
    });

    group('biometric', () {
      test('biyometrik tercih güncellenebilir', () async {
        await authController.register('Bio User', 'bio@example.com', '1234');
        final userId = authController.currentUser!.id;

        expect(authController.isBiometricEnabled, isFalse);

        await authController.setBiometricEnabled(userId, true);

        // CheckAuth çağırarak güncel kullanıcıyı al
        await authController.checkAuth();
        expect(authController.isBiometricEnabled, isTrue);
      });
    });
  });
}
