import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/payment_method_repository.dart';

/// Ödeme yöntemi repository implementasyonu (Data Layer)
/// Bu sınıf, PaymentMethodRepository interface'ini Hive veritabanı ile uygular.
class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  static const String _boxName = 'cashly_box';
  Box get _box => Hive.box(_boxName);

  /// Varsayılan ödeme yöntemleri
  static List<Map<String, dynamic>> get defaultPaymentMethods => [
    {
      'id': 'nakit_default',
      'name': 'Nakit',
      'type': 'nakit',
      'lastFourDigits': null,
      'balance': 0.0,
      'limit': null,
      'colorIndex': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'isDeleted': false,
    },
  ];

  @override
  List<Map<String, dynamic>> getPaymentMethods(String userId) {
    try {
      final data = _box.get('odeme_yontemleri_$userId', defaultValue: null);
      // Null veya boş liste ise varsayılan Nakit'i oluştur
      if (data == null || (data is List && data.isEmpty)) {
        savePaymentMethods(userId, defaultPaymentMethods);
        return defaultPaymentMethods;
      }
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Ödeme yöntemleri getirilirken hata: $e');
      return defaultPaymentMethods;
    }
  }

  @override
  Future<void> savePaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  ) async {
    try {
      await _box.put('odeme_yontemleri_$userId', methods);
    } catch (e) {
      debugPrint('Ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId) {
    try {
      final data = _box.get(
        'silinen_odeme_yontemleri_$userId',
        defaultValue: [],
      );
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Silinen ödeme yöntemleri getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveDeletedPaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  ) async {
    try {
      await _box.put('silinen_odeme_yontemleri_$userId', methods);
    } catch (e) {
      debugPrint('Silinen ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  String? getDefaultPaymentMethod(String userId) {
    try {
      final savedValue = _box.get('varsayilan_odeme_yontemi_$userId');
      // Null ise varsayılan olarak Nakit'i ayarla ve döndür
      if (savedValue == null) {
        saveDefaultPaymentMethod(userId, 'nakit_default');
        return 'nakit_default';
      }
      return savedValue;
    } catch (e) {
      debugPrint('Varsayılan ödeme yöntemi getirilirken hata: $e');
      return 'nakit_default';
    }
  }

  @override
  Future<void> saveDefaultPaymentMethod(String userId, String? methodId) async {
    try {
      if (methodId == null) {
        await _box.delete('varsayilan_odeme_yontemi_$userId');
      } else {
        await _box.put('varsayilan_odeme_yontemi_$userId', methodId);
      }
    } catch (e) {
      debugPrint('Varsayılan ödeme yöntemi kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getTransfers(String userId) {
    try {
      final data = _box.get('transferler_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Transferler getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveTransfers(
    String userId,
    List<Map<String, dynamic>> transfers,
  ) async {
    try {
      await _box.put('transferler_$userId', transfers);
    } catch (e) {
      debugPrint('Transferler kaydedilirken hata: $e');
      rethrow;
    }
  }
}
