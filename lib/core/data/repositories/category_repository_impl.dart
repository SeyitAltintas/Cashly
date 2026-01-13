import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/category_repository.dart';

/// Kategori repository implementasyonu (Data Layer)
/// Harcama ve gelir kategorileri için Hive veritabanı implementasyonu.
class CategoryRepositoryImpl implements CategoryRepository {
  static const String _boxName = 'cashly_box';
  Box get _box => Hive.box(_boxName);

  /// Varsayılan harcama kategorileri
  static List<Map<String, dynamic>> get defaultExpenseCategories => [
    {'isim': 'Yemek ve Kafe', 'ikon': 'restaurant'},
    {'isim': 'Market ve Atıştırmalık', 'ikon': 'shopping_basket'},
    {'isim': 'Araç ve Ulaşım', 'ikon': 'two_wheeler'},
    {'isim': 'Hediye ve Özel', 'ikon': 'card_giftcard'},
    {'isim': 'Sabit Giderler', 'ikon': 'credit_card'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  /// Varsayılan gelir kategorileri
  static List<Map<String, dynamic>> get defaultIncomeCategories => [
    {'isim': 'Maaş', 'ikon': 'work'},
    {'isim': 'Freelance', 'ikon': 'laptop'},
    {'isim': 'Yatırım', 'ikon': 'trending_up'},
    {'isim': 'Kira Geliri', 'ikon': 'home'},
    {'isim': 'Hediye', 'ikon': 'card_giftcard'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  // ===== HARCAMA KATEGORİLERİ =====

  @override
  List<Map<String, dynamic>> getExpenseCategories(String userId) {
    try {
      final data = _box.get('kategoriler_$userId', defaultValue: null);
      if (data == null) {
        saveExpenseCategories(userId, defaultExpenseCategories);
        return defaultExpenseCategories;
      }
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Harcama kategorileri getirilirken hata: $e');
      return defaultExpenseCategories;
    }
  }

  @override
  Future<void> saveExpenseCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      await _box.put('kategoriler_$userId', categories);
    } catch (e) {
      debugPrint('Harcama kategorileri kaydedilirken hata: $e');
      rethrow;
    }
  }

  // ===== GELİR KATEGORİLERİ =====

  @override
  List<Map<String, dynamic>> getIncomeCategories(String userId) {
    try {
      final data = _box.get('gelir_kategorileri_$userId', defaultValue: null);
      if (data == null) {
        saveIncomeCategories(userId, defaultIncomeCategories);
        return defaultIncomeCategories;
      }
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Gelir kategorileri getirilirken hata: $e');
      return defaultIncomeCategories;
    }
  }

  @override
  Future<void> saveIncomeCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      await _box.put('gelir_kategorileri_$userId', categories);
    } catch (e) {
      debugPrint('Gelir kategorileri kaydedilirken hata: $e');
      rethrow;
    }
  }
}
