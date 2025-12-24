/// Varlık repository interface (Domain Layer)
/// Bu interface, varlık verilerine erişim için soyut bir kontrat tanımlar.
abstract class AssetRepository {
  /// Kullanıcının tüm varlıklarını getirir
  List<Map<String, dynamic>> getAssets(String userId);

  /// Kullanıcının varlıklarını kaydeder
  Future<void> saveAssets(String userId, List<Map<String, dynamic>> assets);

  /// Silinen varlıkları getirir (geri dönüşüm kutusu için)
  List<Map<String, dynamic>> getDeletedAssets(String userId);

  /// Silinen varlıkları kaydeder
  Future<void> saveDeletedAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  );
}
