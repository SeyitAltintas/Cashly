import 'package:cashly/features/auth/domain/entities/user_entity.dart';

/// Test ortamında kullanılacak yardımcı fonksiyonlar ve örnek veriler
class TestHelpers {
  /// Örnek kullanıcı oluşturur
  static UserEntity createTestUser({
    String? id,
    String? name,
    String? email,
    String? pin,
    bool biometricEnabled = false,
    String? securityQuestion,
    String? securityAnswer,
  }) {
    return UserEntity(
      id: id ?? 'test-user-id-123',
      name: name ?? 'Test Kullanıcı',
      email: email ?? 'test@example.com',
      pin: pin ?? '1234',
      createdAt: DateTime(2024, 1, 1),
      biometricEnabled: biometricEnabled,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer,
    );
  }

  /// Örnek harcama verisi oluşturur
  static Map<String, dynamic> createTestExpense({
    String? id,
    String? isim,
    double? tutar,
    String? kategori,
    DateTime? tarih,
  }) {
    return {
      'id': id ?? 'expense-123',
      'isim': isim ?? 'Test Harcama',
      'tutar': tutar ?? 100.0,
      'kategori': kategori ?? 'Yemek & Kafe',
      'tarih': (tarih ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Örnek varlık verisi oluşturur
  static Map<String, dynamic> createTestAsset({
    String? id,
    String? isim,
    double? deger,
    String? tip,
  }) {
    return {
      'id': id ?? 'asset-123',
      'isim': isim ?? 'Test Varlık',
      'deger': deger ?? 1000.0,
      'tip': tip ?? 'Nakit',
    };
  }
}
