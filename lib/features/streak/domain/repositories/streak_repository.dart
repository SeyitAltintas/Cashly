import '../../data/models/streak_model.dart';

/// Rank repository interface (Domain Layer)
abstract class StreakRepository {
  /// Kullanıcının rank verisini getirir
  RankData getStreakData(String userId);

  /// Kullanıcının rank verisini kaydeder
  Future<void> saveStreakData(String userId, RankData data);

  /// Rank box'ını başlatır
  Future<void> initialize();
}
