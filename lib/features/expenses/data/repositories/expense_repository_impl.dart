import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/expense_repository.dart';

/// Harcama repository implementasyonu (Data Layer)
/// Bu sınıf, ExpenseRepository interface'ini Hive veritabanı ile uygular.
class ExpenseRepositoryImpl implements ExpenseRepository {
  static const String _boxName = 'cashly_box';
  Box get _box => Hive.box(_boxName);

  /// Varsayılan harcama kategorileri
  static List<Map<String, dynamic>> get defaultCategories => [
    {'isim': 'Yemek ve Kafe', 'ikon': 'restaurant'},
    {'isim': 'Market ve Atıştırmalık', 'ikon': 'shopping_basket'},
    {'isim': 'Araç ve Ulaşım', 'ikon': 'two_wheeler'},
    {'isim': 'Hediye ve Özel', 'ikon': 'card_giftcard'},
    {'isim': 'Sabit Giderler', 'ikon': 'credit_card'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  @override
  List<Map<String, dynamic>> getExpenses(String userId) {
    final cacheKey = 'expenses_$userId';

    // Önce cache'den bak
    final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    try {
      final data = _box.get('harcamalar_$userId', defaultValue: []);
      final result = List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
      // Cache'e kaydet
      CacheService.set(cacheKey, result);
      return result;
    } catch (e) {
      debugPrint('Harcamalar getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveExpenses(
    String userId,
    List<Map<String, dynamic>> expenses,
  ) async {
    try {
      await _box.put('harcamalar_$userId', expenses);
      // Cache'i güncelle
      CacheService.set('expenses_$userId', expenses);
    } catch (e) {
      debugPrint('Harcamalar kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  double getBudget(String userId) {
    final cacheKey = 'budget_$userId';

    // Önce cache'den bak
    final cached = CacheService.get<double>(cacheKey);
    if (cached != null) return cached;

    try {
      final result =
          _box.get('butce_limiti_$userId', defaultValue: 8000.0) as double;
      CacheService.set(cacheKey, result);
      return result;
    } catch (e) {
      debugPrint('Bütçe getirilirken hata: $e');
      return 8000.0;
    }
  }

  @override
  Future<void> saveBudget(String userId, double limit) async {
    try {
      await _box.put('butce_limiti_$userId', limit);
      CacheService.set('budget_$userId', limit);
    } catch (e) {
      debugPrint('Bütçe kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getFixedExpenseTemplates(String userId) {
    try {
      final data = _box.get('sabit_gider_sablonlari_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Sabit gider şablonları getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveFixedExpenseTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  ) async {
    try {
      await _box.put('sabit_gider_sablonlari_$userId', templates);
    } catch (e) {
      debugPrint('Sabit gider şablonları kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getCategories(String userId) {
    try {
      final data = _box.get('kategoriler_$userId', defaultValue: null);
      if (data == null) {
        saveCategories(userId, defaultCategories);
        return defaultCategories;
      }
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Kategoriler getirilirken hata: $e');
      return defaultCategories;
    }
  }

  @override
  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      await _box.put('kategoriler_$userId', categories);
    } catch (e) {
      debugPrint('Kategoriler kaydedilirken hata: $e');
      rethrow;
    }
  }
}
