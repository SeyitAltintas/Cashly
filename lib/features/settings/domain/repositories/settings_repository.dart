/// Ayarlar repository interface (Domain Layer)
/// Kullanıcı tercihlerini ve ayarlarını yöneten veri erişim kontratı
abstract class SettingsRepository {
  /// Sesli geri bildirim ayarını kontrol eder
  bool isVoiceFeedbackEnabled(String userId);

  /// Sesli geri bildirim ayarını kaydeder
  Future<void> saveVoiceFeedbackEnabled(String userId, bool enabled);

  /// Tüm kullanıcı verilerini siler (hesap silme için)
  Future<void> deleteAllUserData(String userId);
}
