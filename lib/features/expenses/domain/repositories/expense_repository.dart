/// Harcama repository interface (Domain Layer)
/// Bu interface, harcama verilerine erişim için soyut bir kontrat tanımlar.
/// Data katmanındaki implementation bu interface'i uygular.
abstract class ExpenseRepository {
  /// Kullanıcının tüm harcamalarını getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Harcama listesi (Map formatında)
  List<Map<String, dynamic>> getExpenses(String userId);

  /// Yeni bir harcama ekler
  /// [userId] - Kullanıcı ID'si
  /// [expense] - Eklenecek harcama verisi
  Future<void> addExpense(String userId, Map<String, dynamic> expense);

  /// Mevcut bir harcamayı günceller
  /// [userId] - Kullanıcı ID'si
  /// [expense] - Güncellenecek harcama verisi
  Future<void> updateExpense(String userId, Map<String, dynamic> expense);

  /// Bir harcamayı siler
  /// [userId] - Kullanıcı ID'si
  /// [expenseId] - Silinecek harcama ID'si
  Future<void> deleteExpense(String userId, String expenseId);

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

  /// Kategori bazlı bütçe limitlerini getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Kategori adı -> Limit miktarı Map'i
  Map<String, double> getCategoryBudgets(String userId);

  /// Kategori bazlı bütçe limitlerini kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [budgets] - Kategori adı -> Limit miktarı Map'i
  Future<void> saveCategoryBudgets(String userId, Map<String, double> budgets);
}
