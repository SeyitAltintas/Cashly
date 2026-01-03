/// Varlık (Asset) Repository
/// DatabaseHelper'dan ayrılmış varlık veri işlemleri
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Varlık verisi ile ilgili tüm CRUD işlemleri
class AssetRepository {
  static const String _boxName = 'cashly_box';
  static Box get _box => Hive.box(_boxName);

  // --- VARLIK İŞLEMLERİ ---

  /// Kullanıcının varlıklarını getirir
  static List<Map<String, dynamic>> varliklariGetir(String userId) {
    try {
      final veri = _box.get('varliklar_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Varlıklar getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının varlıklarını kaydeder
  static Future<void> varliklariKaydet(
    String userId,
    List<Map<String, dynamic>> varliklar,
  ) async {
    try {
      await _box.put('varliklar_$userId', varliklar);
    } catch (e) {
      debugPrint('Varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }

  // --- SİLİNEN VARLIKLAR ---

  /// Silinen varlıkları getirir
  static List<Map<String, dynamic>> silinenVarliklariGetir(String userId) {
    try {
      final veri = _box.get('silinen_varliklar_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Silinen varlıklar getirilirken hata: $e');
      return [];
    }
  }

  /// Silinen varlıkları kaydeder
  static Future<void> silinenVarliklariKaydet(
    String userId,
    List<Map<String, dynamic>> varliklar,
  ) async {
    try {
      await _box.put('silinen_varliklar_$userId', varliklar);
    } catch (e) {
      debugPrint('Silinen varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }
}
