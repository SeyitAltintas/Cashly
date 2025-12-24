import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/asset_repository.dart';

/// Varlık repository implementasyonu (Data Layer)
/// Bu sınıf, AssetRepository interface'ini Hive veritabanı ile uygular.
class AssetRepositoryImpl implements AssetRepository {
  static const String _boxName = 'cashly_box';
  Box get _box => Hive.box(_boxName);

  @override
  List<Map<String, dynamic>> getAssets(String userId) {
    try {
      final data = _box.get('varliklar_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Varlıklar getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    try {
      await _box.put('varliklar_$userId', assets);
    } catch (e) {
      debugPrint('Varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedAssets(String userId) {
    try {
      final data = _box.get('silinen_varliklar_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Silinen varlıklar getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveDeletedAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    try {
      await _box.put('silinen_varliklar_$userId', assets);
    } catch (e) {
      debugPrint('Silinen varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }
}
