/// Harcama repository interface (Domain Layer)
/// Bu interface, harcama verilerine erişim için soyut bir kontrat tanımlar.
/// Data katmanındaki implementation bu interface'i uygular.
abstract class ExpenseRepository {
  /// Kullanıcının tüm harcamalarını getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Harcama listesi (Map formatında)
  List<Map<String, dynamic>> getExpenses(String userId);

  /// Kullanıcının harcamalarını kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [expenses] - Kaydedilecek harcama listesi
  Future<void> saveExpenses(String userId, List<Map<String, dynamic>> expenses);

  /// Kullanıcının bütçe limitini getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Bütçe limiti (varsayılan: 8000.0)
  double getBudget(String userId);

  /// Kullanıcının bütçe limitini kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [limit] - Yeni bütçe limiti
  Future<void> saveBudget(String userId, double limit);

  /// Sabit gider şablonlarını getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Sabit gider şablon listesi
  List<Map<String, dynamic>> getFixedExpenseTemplates(String userId);

  /// Sabit gider şablonlarını kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [templates] - Kaydedilecek şablon listesi
  Future<void> saveFixedExpenseTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  );

  /// Harcama kategorilerini getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Kategori listesi
  /// Not: CategoryRepository.getExpenseCategories alternatif olarak kullanılabilir
  List<Map<String, dynamic>> getCategories(String userId);

  /// Harcama kategorilerini kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [categories] - Kaydedilecek kategori listesi
  /// Not: CategoryRepository.saveExpenseCategories alternatif olarak kullanılabilir
  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  );
}
