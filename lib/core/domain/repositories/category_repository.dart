/// Kategori yönetimi repository interface (Domain Layer)
/// Harcama ve gelir kategorileri için merkezi veri erişim kontratı.
abstract class CategoryRepository {
  /// Harcama kategorilerini getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Kategori listesi (Map formatında)
  List<Map<String, dynamic>> getExpenseCategories(String userId);

  /// Harcama kategorilerini kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [categories] - Kaydedilecek kategori listesi
  Future<void> saveExpenseCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  );

  /// Gelir kategorilerini getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Kategori listesi (Map formatında)
  List<Map<String, dynamic>> getIncomeCategories(String userId);

  /// Gelir kategorilerini kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [categories] - Kaydedilecek kategori listesi
  Future<void> saveIncomeCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  );
}
