/// Gelir (Income) Repository
/// DatabaseHelper'dan ayrılmış gelir veri işlemleri
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Gelir verisi ile ilgili tüm CRUD işlemleri
class IncomeRepository {
  static const String _boxName = 'cashly_box';
  static Box get _box => Hive.box(_boxName);

  // Varsayılan gelir kategorileri
  static List<Map<String, dynamic>> get defaultGelirKategorileri => [
    {'isim': 'Maaş', 'ikon': 'work'},
    {'isim': 'Freelance', 'ikon': 'laptop'},
    {'isim': 'Yatırım', 'ikon': 'trending_up'},
    {'isim': 'Kira Geliri', 'ikon': 'home'},
    {'isim': 'Hediye', 'ikon': 'card_giftcard'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  // --- GELİR İŞLEMLERİ ---

  /// Kullanıcının gelirlerini getirir
  static List<Map<String, dynamic>> gelirleriGetir(String userId) {
    try {
      final veri = _box.get('gelirler_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Gelirler getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının gelirlerini kaydeder
  static Future<void> gelirleriKaydet(
    String userId,
    List<Map<String, dynamic>> gelirler,
  ) async {
    try {
      await _box.put('gelirler_$userId', gelirler);
    } catch (e) {
      debugPrint('Gelirler kaydedilirken hata: $e');
      rethrow;
    }
  }

  // --- GELİR KATEGORİLERİ ---

  /// Gelir kategorilerini getirir
  static List<Map<String, dynamic>> gelirKategorileriGetir(String userId) {
    try {
      final veri = _box.get('gelir_kategorileri_$userId', defaultValue: null);
      if (veri == null) {
        gelirKategorileriKaydet(userId, defaultGelirKategorileri);
        return defaultGelirKategorileri;
      }
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Gelir kategorileri getirilirken hata: $e');
      return defaultGelirKategorileri;
    }
  }

  /// Gelir kategorilerini kaydeder
  static Future<void> gelirKategorileriKaydet(
    String userId,
    List<Map<String, dynamic>> kategoriler,
  ) async {
    try {
      await _box.put('gelir_kategorileri_$userId', kategoriler);
    } catch (e) {
      debugPrint('Gelir kategorileri kaydedilirken hata: $e');
      rethrow;
    }
  }

  // --- TEKRARLAYAN GELİRLER ---

  /// Kullanıcının tekrarlayan gelirlerini getirir
  static List<Map<String, dynamic>> tekrarlayanGelirleriGetir(String userId) {
    try {
      final veri = _box.get('tekrarlayan_gelirler_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting recurring incomes: $e');
      return [];
    }
  }

  /// Kullanıcının tekrarlayan gelirlerini kaydeder
  static Future<void> tekrarlayanGelirleriKaydet(
    String userId,
    List<Map<String, dynamic>> gelirler,
  ) async {
    try {
      await _box.put('tekrarlayan_gelirler_$userId', gelirler);
    } catch (e) {
      debugPrint('Error saving recurring incomes: $e');
      rethrow;
    }
  }
}
