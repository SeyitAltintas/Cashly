import '../../data/models/streak_model.dart';

/// Seri (Streak) repository interface (Domain Layer)
/// Günlük giriş serisini takip eden veri erişim kontratı
abstract class StreakRepository {
  /// Kullanıcının seri verisini getirir
  StreakData getStreakData(String userId);

  /// Kullanıcının seri verisini kaydeder
  Future<void> saveStreakData(String userId, StreakData data);

  /// Streak box'ını başlatır
  Future<void> initialize();
}
