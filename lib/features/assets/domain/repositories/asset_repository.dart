/// Varlık repository interface (Domain Layer)
/// Bu interface, varlık verilerine erişim için soyut bir kontrat tanımlar.
import '../../../../core/services/batch_service.dart';

abstract class AssetRepository {
  /// Kullanıcının tüm varlıklarını getirir
  List<Map<String, dynamic>> getAssets(String userId);

  /// Yeni bir varlık ekler
  Future<void> addAsset(String userId, Map<String, dynamic> asset);

  /// Mevcut bir varlığı günceller
  Future<void> updateAsset(String userId, Map<String, dynamic> asset);

  /// Bir varlığı siler (kalıcı veya çöp kutusuna)
  Future<void> deleteAsset(String userId, String assetId);

  /// Geri dönüşüm kutusundaki varlıkları getirir
  List<Map<String, dynamic>> getDeletedAssets(String userId);

  /// Geri dönüşüm kutusuna varlık ekler
  Future<void> addDeletedAsset(String userId, Map<String, dynamic> asset);

  Future<void> saveDeletedAssets(String userId, List<Map<String, dynamic>> assets);

  /// Geri dönüşüm kutusundan varlık siler
  Future<void> removeDeletedAsset(String userId, String assetId);

  /// Batch Operations
  BatchOperation getAddAssetOperation(String userId, Map<String, dynamic> asset);
  BatchOperation getUpdateAssetOperation(String userId, Map<String, dynamic> asset);
  BatchOperation getDeleteAssetOperation(String userId, String id);
}
