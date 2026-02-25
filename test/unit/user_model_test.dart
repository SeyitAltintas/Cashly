import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/auth/data/models/user_model.dart';
import 'package:cashly/features/auth/domain/entities/user_entity.dart';

/// UserModel & UserEntity — Kapsamlı Unit Testleri
void main() {
  final now = DateTime(2024, 6, 15, 10, 30);

  group('UserEntity — Constructor', () {
    test('zorunlu alanlar doğru set edilir', () {
      final entity = UserEntity(
        id: 'u-1',
        name: 'Ali',
        email: 'ali@test.com',
        pin: '1234',
        createdAt: now,
      );
      expect(entity.id, 'u-1');
      expect(entity.name, 'Ali');
      expect(entity.email, 'ali@test.com');
      expect(entity.pin, '1234');
      expect(entity.profileImage, isNull);
      expect(entity.lastLoginAt, isNull);
      expect(entity.biometricEnabled, isFalse);
      expect(entity.securityQuestion, isNull);
      expect(entity.securityAnswer, isNull);
    });
  });

  group('UserModel — Constructor', () {
    test('tüm alanlar doğru set edilir', () {
      final user = UserModel(
        id: 'u-2',
        name: 'Veli',
        email: 'veli@test.com',
        pin: '5678',
        createdAt: now,
        profileImage: '/path/to/image.png',
        lastLoginAt: now,
        biometricEnabled: true,
        securityQuestion: 'Soru?',
        securityAnswer: 'Cevap',
      );
      expect(user.profileImage, '/path/to/image.png');
      expect(user.biometricEnabled, isTrue);
      expect(user.securityQuestion, 'Soru?');
      expect(user.securityAnswer, 'Cevap');
    });
  });

  group('UserModel — toMap / fromMap', () {
    test('round-trip tutarlı', () {
      final original = UserModel(
        id: 'u-3',
        name: 'Ayşe',
        email: 'ayse@test.com',
        pin: '0000',
        createdAt: now,
        biometricEnabled: true,
        securityQuestion: 'Hayvanın?',
        securityAnswer: 'Kedi',
      );
      final map = original.toMap();
      final restored = UserModel.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.pin, original.pin);
      expect(restored.biometricEnabled, original.biometricEnabled);
      expect(restored.securityQuestion, original.securityQuestion);
      expect(restored.securityAnswer, original.securityAnswer);
    });

    test('toMap tüm anahtarları içerir', () {
      final user = UserModel(
        id: 'u-4',
        name: 'T',
        email: 't@t.com',
        pin: '1111',
        createdAt: now,
      );
      final map = user.toMap();
      expect(map.containsKey('id'), isTrue);
      expect(map.containsKey('name'), isTrue);
      expect(map.containsKey('email'), isTrue);
      expect(map.containsKey('pin'), isTrue);
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('biometricEnabled'), isTrue);
    });

    test('fromMap geriye dönük uyumluluk (biometricEnabled yok)', () {
      final map = {
        'id': 'old-1',
        'name': 'Eski',
        'email': 'e@e.com',
        'pin': '9999',
      };
      final user = UserModel.fromMap(map);
      expect(user.biometricEnabled, isFalse);
      expect(user.securityQuestion, isNull);
      expect(user.lastLoginAt, isNull);
    });

    test('fromMap lastLoginAt null olabilir', () {
      final map = {
        'id': 'u-5',
        'name': 'T',
        'email': 'e@e.com',
        'pin': '1234',
        'lastLoginAt': null,
      };
      final user = UserModel.fromMap(map);
      expect(user.lastLoginAt, isNull);
    });
  });

  group('UserModel.fromEntity', () {
    test('entity → model dönüşümü tutarlı', () {
      final entity = UserEntity(
        id: 'u-6',
        name: 'Fatma',
        email: 'fatma@test.com',
        pin: '4321',
        createdAt: now,
        biometricEnabled: true,
      );
      final model = UserModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.email, entity.email);
      expect(model.pin, entity.pin);
      expect(model.biometricEnabled, entity.biometricEnabled);
    });
  });
}
