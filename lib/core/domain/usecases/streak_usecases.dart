import 'base_usecase.dart';
import '../../../features/streak/domain/repositories/streak_repository.dart';
import '../../../features/streak/data/models/streak_model.dart';
import '../../../features/streak/data/services/streak_service.dart';

// ===== RANK USE CASES =====

/// Rank verisini getir
class GetStreakData implements UseCaseSync<RankData, GetStreakDataParams> {
  final StreakRepository repository;

  GetStreakData(this.repository);

  @override
  RankData call(GetStreakDataParams params) {
    return repository.getStreakData(params.userId);
  }
}

class GetStreakDataParams {
  final String userId;
  const GetStreakDataParams({required this.userId});
}

/// Rank'ı kontrol et ve güncelle
/// Uygulama açıldığında çağrılır
class CheckAndUpdateStreak
    implements UseCase<StreakResult, CheckAndUpdateStreakParams> {
  CheckAndUpdateStreak();

  @override
  Future<StreakResult> call(CheckAndUpdateStreakParams params) async {
    return await StreakService.checkAndUpdateStreak(params.userId);
  }
}

class CheckAndUpdateStreakParams {
  final String userId;
  const CheckAndUpdateStreakParams({required this.userId});
}

/// Rank verisini kaydet
class SaveStreakData implements UseCase<void, SaveStreakDataParams> {
  SaveStreakData();

  @override
  Future<void> call(SaveStreakDataParams params) async {
    await StreakService.saveStreakData(params.userId, params.data);
  }
}

class SaveStreakDataParams {
  final String userId;
  final RankData data;
  const SaveStreakDataParams({required this.userId, required this.data});
}
