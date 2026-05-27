/// Gelir repository interface (Domain Layer)
/// Bu interface, gelir verilerine erişim için soyut bir kontrat tanımlar.
abstract class IncomeRepository {
  /// Kullanıcının tüm gelirlerini getirir
  List<Map<String, dynamic>> getIncomes(String userId);

  /// Seçilen aya ait gelirleri gerçek zamanlı dinler
  Stream<List<Map<String, dynamic>>> watchIncomesByMonth(String userId, DateTime month);

  /// Yeni bir gelir ekler
  Future<void> addIncome(String userId, Map<String, dynamic> income);

  /// Mevcut bir geliri günceller
  Future<void> updateIncome(String userId, Map<String, dynamic> income);

  /// Bir geliri siler
  Future<void> deleteIncome(String userId, String incomeId);

  /// Gelir kategorilerini getirir
  /// Not: CategoryRepository.getIncomeCategories alternatif olarak kullanılabilir
  List<Map<String, dynamic>> getCategories(String userId);

  /// Gelir kategorilerini kaydeder
  /// Not: CategoryRepository.saveIncomeCategories alternatif olarak kullanılabilir
  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  );

  /// Tekrarlayan gelirleri getirir
  /// Not: RecurringRepository.getRecurringIncomes alternatif olarak kullanılabilir
  List<Map<String, dynamic>> getRecurringIncomes(String userId);

  /// Tekrarlayan gelirleri kaydeder
  /// Not: RecurringRepository.saveRecurringIncomes alternatif olarak kullanılabilir
  Future<void> saveRecurringIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  );
}
