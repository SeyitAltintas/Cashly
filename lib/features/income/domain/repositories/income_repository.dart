/// Gelir repository interface (Domain Layer)
/// Bu interface, gelir verilerine erişim için soyut bir kontrat tanımlar.
abstract class IncomeRepository {
  /// Kullanıcının tüm gelirlerini getirir
  List<Map<String, dynamic>> getIncomes(String userId);

  /// Kullanıcının gelirlerini kaydeder
  Future<void> saveIncomes(String userId, List<Map<String, dynamic>> incomes);

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
