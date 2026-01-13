import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/recurring_repository.dart';

/// Tekrarlayan işlem repository implementasyonu (Data Layer)
/// Sabit gider şablonları ve tekrarlayan gelirler için Hive veritabanı implementasyonu.
class RecurringRepositoryImpl implements RecurringRepository {
  static const String _boxName = 'cashly_box';
  Box get _box => Hive.box(_boxName);

  // ===== SABİT GİDER ŞABLONLARI =====

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

  // ===== TEKRARLAYAN GELİRLER =====

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
