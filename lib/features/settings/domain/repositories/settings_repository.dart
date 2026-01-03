/// Ayarlar repository interface (Domain Layer)
/// Kullanıcı tercihlerini ve ayarlarını yöneten veri erişim kontratı
abstract class SettingsRepository {
  /// Sesli geri bildirim ayarını kontrol eder
  bool isVoiceFeedbackEnabled(String userId);

  /// Sesli geri bildirim ayarını kaydeder
  Future<void> saveVoiceFeedbackEnabled(String userId, bool enabled);

  /// Transfer işlem geçmişinde gösterilecek kayıt sayısını getirir
  /// -1 değeri "Tümü" anlamına gelir
  int getTransferHistoryLimit(String userId);

  /// Transfer işlem geçmişi limitini kaydeder
  /// -1 değeri "Tümü" anlamına gelir
  Future<void> saveTransferHistoryLimit(String userId, int limit);

  /// Tüm kullanıcı verilerini siler (hesap silme için)
  Future<void> deleteAllUserData(String userId);
}
