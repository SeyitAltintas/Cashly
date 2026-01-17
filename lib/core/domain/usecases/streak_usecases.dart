import 'base_usecase.dart';
import '../../../features/streak/domain/repositories/streak_repository.dart';
import '../../../features/streak/data/models/streak_model.dart';
import '../../../features/streak/data/services/streak_service.dart';

// ===== STREAK USE CASES =====

/// Seri verisini getir
class GetStreakData implements UseCaseSync<StreakData, GetStreakDataParams> {
  final StreakRepository repository;

  GetStreakData(this.repository);

  @override
  StreakData call(GetStreakDataParams params) {
    return repository.getStreakData(params.userId);
  }
}

class GetStreakDataParams {
  final String userId;
  const GetStreakDataParams({required this.userId});
}

/// Seriyi kontrol et ve güncelle
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

/// Seri verisini kaydet
class SaveStreakData implements UseCase<void, SaveStreakDataParams> {
  SaveStreakData();

  @override
  Future<void> call(SaveStreakDataParams params) async {
    await StreakService.saveStreakData(params.userId, params.data);
  }
}

class SaveStreakDataParams {
  final String userId;
  final StreakData data;
  const SaveStreakDataParams({required this.userId, required this.data});
}

/// Dondurucu (freeze) kullan
class UseFreeze implements UseCase<StreakData?, UseFreezeParams> {
  final StreakRepository repository;

  UseFreeze(this.repository);

  @override
  Future<StreakData?> call(UseFreezeParams params) async {
    final currentData = repository.getStreakData(params.userId);

    // Dondurucu var mı kontrol et
    if (!currentData.canUseFreeze) {
      return null; // Dondurucu yok
    }

    // Dondurucu kullan
    final updatedData = currentData.copyWith(
      freezeCount: currentData.freezeCount - 1,
      usedFreezeToday: true,
      totalFreezesUsed: currentData.totalFreezesUsed + 1,
    );

    await StreakService.saveStreakData(params.userId, updatedData);
    return updatedData;
  }
}

class UseFreezeParams {
  final String userId;
  const UseFreezeParams({required this.userId});
}

/// Rozet kontrolü - Yeni rozet kazanıldı mı?
class CheckNewBadges
    implements UseCaseSync<List<String>, CheckNewBadgesParams> {
  CheckNewBadges();

  @override
  List<String> call(CheckNewBadgesParams params) {
    // Mevcut seri değerine göre yeni kazanılan rozetleri döndür
    // Bu hesaplama StreakController'da zaten yapılıyor
    // Use case olarak sarmalanması Clean Architecture için
    return [];
  }
}

class CheckNewBadgesParams {
  final int currentStreak;
  final List<String> earnedBadges;
  const CheckNewBadgesParams({
    required this.currentStreak,
    required this.earnedBadges,
  });
}
