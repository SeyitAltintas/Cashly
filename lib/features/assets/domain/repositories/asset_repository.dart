/// Varlık repository interface (Domain Layer)
/// Bu interface, varlık verilerine erişim için soyut bir kontrat tanımlar.
abstract class AssetRepository {
  /// Kullanıcının tüm varlıklarını getirir
  List<Map<String, dynamic>> getAssets(String userId);

  /// Yeni bir varlık ekler
  Future<void> addAsset(String userId, Map<String, dynamic> asset);

  /// Mevcut bir varlığı günceller
  Future<void> updateAsset(String userId, Map<String, dynamic> asset);

  /// Bir varlığı siler
  Future<void> deleteAsset(String userId, String assetId);

  /// Silinen varlıkları getirir (geri dönüşüm kutusu için)
  List<Map<String, dynamic>> getDeletedAssets(String userId);

  /// Geri dönüşüm kutusuna varlık ekler
  Future<void> addDeletedAsset(String userId, Map<String, dynamic> asset);

  /// Geri dönüşüm kutusundan varlık siler
  Future<void> removeDeletedAsset(String userId, String assetId);
}
