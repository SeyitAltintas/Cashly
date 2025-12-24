import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/income_repository.dart';

/// Gelir repository implementasyonu (Data Layer)
/// Bu sınıf, IncomeRepository interface'ini Hive veritabanı ile uygular.
class IncomeRepositoryImpl implements IncomeRepository {
  static const String _boxName = 'cashly_box';
  Box get _box => Hive.box(_boxName);

  /// Varsayılan gelir kategorileri
  static List<Map<String, dynamic>> get defaultCategories => [
    {'isim': 'Maaş', 'ikon': 'work'},
    {'isim': 'Freelance', 'ikon': 'laptop'},
    {'isim': 'Yatırım', 'ikon': 'trending_up'},
    {'isim': 'Kira Geliri', 'ikon': 'home'},
    {'isim': 'Hediye', 'ikon': 'card_giftcard'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  @override
  List<Map<String, dynamic>> getIncomes(String userId) {
    final cacheKey = 'incomes_$userId';

    final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    try {
      final data = _box.get('gelirler_$userId', defaultValue: []);
      final result = List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
      CacheService.set(cacheKey, result);
      return result;
    } catch (e) {
      debugPrint('Gelirler getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {
    try {
      await _box.put('gelirler_$userId', incomes);
      CacheService.set('incomes_$userId', incomes);
    } catch (e) {
      debugPrint('Gelirler kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getCategories(String userId) {
    try {
      final data = _box.get('gelir_kategorileri_$userId', defaultValue: null);
      if (data == null) {
        saveCategories(userId, defaultCategories);
        return defaultCategories;
      }
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Gelir kategorileri getirilirken hata: $e');
      return defaultCategories;
    }
  }

  @override
  Future<void> saveCategories(
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

  @override
  List<Map<String, dynamic>> getRecurringIncomes(String userId) {
    try {
      final data = _box.get('tekrarlayan_gelirler_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Tekrarlayan gelirler getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveRecurringIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {
    try {
      await _box.put('tekrarlayan_gelirler_$userId', incomes);
    } catch (e) {
      debugPrint('Tekrarlayan gelirler kaydedilirken hata: $e');
      rethrow;
    }
  }
}
