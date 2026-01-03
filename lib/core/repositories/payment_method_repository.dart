/// Ödeme Yöntemi (Payment Method) Repository
/// DatabaseHelper'dan ayrılmış ödeme yöntemi veri işlemleri
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Ödeme yöntemi verisi ile ilgili tüm CRUD işlemleri
class PaymentMethodRepository {
  static const String _boxName = 'cashly_box';
  static Box get _box => Hive.box(_boxName);

  // Varsayılan ödeme yöntemleri
  static List<Map<String, dynamic>> get defaultOdemeYontemleri => [
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

  // --- ÖDEME YÖNTEMLERİ ---

  /// Kullanıcının ödeme yöntemlerini getirir
  static List<Map<String, dynamic>> odemeYontemleriGetir(String userId) {
    try {
      final veri = _box.get('odeme_yontemleri_$userId', defaultValue: null);
      if (veri == null) {
        odemeYontemleriKaydet(userId, defaultOdemeYontemleri);
        return defaultOdemeYontemleri;
      }
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Ödeme yöntemleri getirilirken hata: $e');
      return defaultOdemeYontemleri;
    }
  }

  /// Kullanıcının ödeme yöntemlerini kaydeder
  static Future<void> odemeYontemleriKaydet(
    String userId,
    List<Map<String, dynamic>> yontemler,
  ) async {
    try {
      await _box.put('odeme_yontemleri_$userId', yontemler);
    } catch (e) {
      debugPrint('Ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  // --- SİLİNEN ÖDEME YÖNTEMLERİ ---

  /// Silinen ödeme yöntemlerini getirir
  static List<Map<String, dynamic>> silinenOdemeYontemleriGetir(String userId) {
    try {
      final veri = _box.get(
        'silinen_odeme_yontemleri_$userId',
        defaultValue: [],
      );
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Silinen ödeme yöntemleri getirilirken hata: $e');
      return [];
    }
  }

  /// Silinen ödeme yöntemlerini kaydeder
  static Future<void> silinenOdemeYontemleriKaydet(
    String userId,
    List<Map<String, dynamic>> yontemler,
  ) async {
    try {
      await _box.put('silinen_odeme_yontemleri_$userId', yontemler);
    } catch (e) {
      debugPrint('Silinen ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  // --- VARSAYILAN ÖDEME YÖNTEMİ ---

  /// Varsayılan ödeme yöntemini getirir
  static String? varsayilanOdemeYontemiGetir(String userId) {
    try {
      return _box.get('varsayilan_odeme_yontemi_$userId');
    } catch (e) {
      debugPrint('Varsayılan ödeme yöntemi getirilirken hata: $e');
      return null;
    }
  }

  /// Varsayılan ödeme yöntemini kaydeder
  static Future<void> varsayilanOdemeYontemiKaydet(
    String userId,
    String? paymentMethodId,
  ) async {
    try {
      if (paymentMethodId == null) {
        await _box.delete('varsayilan_odeme_yontemi_$userId');
      } else {
        await _box.put('varsayilan_odeme_yontemi_$userId', paymentMethodId);
      }
    } catch (e) {
      debugPrint('Varsayılan ödeme yöntemi kaydedilirken hata: $e');
      rethrow;
    }
  }

  // --- TRANSFER İŞLEMLERİ ---

  /// Kullanıcının transferlerini getirir
  static List<Map<String, dynamic>> transferleriGetir(String userId) {
    try {
      final veri = _box.get('transferler_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting transfers: $e');
      return [];
    }
  }

  /// Kullanıcının transferlerini kaydeder
  static Future<void> transferleriKaydet(
    String userId,
    List<Map<String, dynamic>> transferler,
  ) async {
    try {
      await _box.put('transferler_$userId', transferler);
    } catch (e) {
      debugPrint('Error saving transfers: $e');
      rethrow;
    }
  }
}
