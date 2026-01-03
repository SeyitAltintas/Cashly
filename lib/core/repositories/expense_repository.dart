/// Harcama (Expense) Repository
/// DatabaseHelper'dan ayrılmış harcama veri işlemleri
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Harcama verisi ile ilgili tüm CRUD işlemleri
class ExpenseRepository {
  static const String _boxName = 'cashly_box';
  static Box get _box => Hive.box(_boxName);

  // Varsayılan kategoriler
  static List<Map<String, dynamic>> get defaultKategoriler => [
    {'isim': 'Yemek & Kafe', 'ikon': 'restaurant'},
    {'isim': 'Market & Atıştırmalık', 'ikon': 'shopping_basket'},
    {'isim': 'Araç & Ulaşım', 'ikon': 'two_wheeler'},
    {'isim': 'Hediye & Özel', 'ikon': 'card_giftcard'},
    {'isim': 'Sabit Giderler', 'ikon': 'credit_card'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  // --- HARCAMA İŞLEMLERİ ---

  /// Kullanıcının harcamalarını getirir
  static List<Map<String, dynamic>> harcamalariGetir(String userId) {
    try {
      final veri = _box.get('harcamalar_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting expenses: $e');
      return [];
    }
  }

  /// Kullanıcının harcamalarını kaydeder
  static Future<void> harcamalariKaydet(
    String userId,
    List<Map<String, dynamic>> harcamalar,
  ) async {
    try {
      await _box.put('harcamalar_$userId', harcamalar);
    } catch (e) {
      debugPrint('Error saving expenses: $e');
      rethrow;
    }
  }

  // --- BÜTÇE AYARLARI ---

  /// Kullanıcının bütçe limitini getirir
  static double butceGetir(String userId) {
    try {
      return _box.get('butce_limiti_$userId', defaultValue: 8000.0);
    } catch (e) {
      debugPrint('Error getting budget: $e');
      return 8000.0;
    }
  }

  /// Kullanıcının bütçe limitini kaydeder
  static Future<void> butceKaydet(String userId, double yeniLimit) async {
    try {
      await _box.put('butce_limiti_$userId', yeniLimit);
    } catch (e) {
      debugPrint('Error saving budget: $e');
      rethrow;
    }
  }

  // --- SABİT GİDER ŞABLONLARI ---

  /// Sabit gider şablonlarını getirir
  static List<Map<String, dynamic>> sabitGiderSablonlariGetir(String userId) {
    try {
      final veri = _box.get('sabit_gider_sablonlari_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting fixed expenses: $e');
      return [];
    }
  }

  /// Sabit gider şablonlarını kaydeder
  static Future<void> sabitGiderSablonlariKaydet(
    String userId,
    List<Map<String, dynamic>> sablonlar,
  ) async {
    try {
      await _box.put('sabit_gider_sablonlari_$userId', sablonlar);
    } catch (e) {
      debugPrint('Error saving fixed expenses: $e');
      rethrow;
    }
  }

  // --- KATEGORİ YÖNETİMİ ---

  /// Kullanıcının kategorilerini getirir
  static List<Map<String, dynamic>> kategorileriGetir(String userId) {
    try {
      final veri = _box.get('kategoriler_$userId', defaultValue: null);
      if (veri == null) {
        kategorileriKaydet(userId, defaultKategoriler);
        return defaultKategoriler;
      }
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return defaultKategoriler;
    }
  }

  /// Kullanıcının kategorilerini kaydeder
  static Future<void> kategorileriKaydet(
    String userId,
    List<Map<String, dynamic>> kategoriler,
  ) async {
    try {
      await _box.put('kategoriler_$userId', kategoriler);
    } catch (e) {
      debugPrint('Error saving categories: $e');
      rethrow;
    }
  }
}
