/// Tekrarlayan işlem repository interface (Domain Layer)
/// Sabit gider şablonları ve tekrarlayan gelirler için merkezi veri erişim kontratı.
abstract class RecurringRepository {
  /// Sabit gider şablonlarını getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Şablon listesi (Map formatında)
  List<Map<String, dynamic>> getFixedExpenseTemplates(String userId);

  /// Sabit gider şablonlarını kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [templates] - Kaydedilecek şablon listesi
  Future<void> saveFixedExpenseTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  );

  /// Tekrarlayan gelirleri getirir
  /// [userId] - Kullanıcı ID'si
  /// Döndürür: Tekrarlayan gelir listesi (Map formatında)
  List<Map<String, dynamic>> getRecurringIncomes(String userId);

  /// Tekrarlayan gelirleri kaydeder
  /// [userId] - Kullanıcı ID'si
  /// [incomes] - Kaydedilecek tekrarlayan gelir listesi
  Future<void> saveRecurringIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  );
}
