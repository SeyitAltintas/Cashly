import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/domain/usecases/streak_usecases.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';
import '../../data/services/streak_service.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';

/// Rank Controller
/// XP birikimi, rank hesaplamaları ve seri yönetimini merkezi olarak yönetir.
class StreakController extends ChangeNotifier with SafeNotifierMixin {
  // ===== USE CASES =====
  late final GetStreakData _getRankData;
  late final CheckAndUpdateStreak _checkAndUpdateRank;

  // ===== STATE =====

  RankData _rankData = RankData.empty();
  /// Rank verisi (eski ad: streakData — backward compat)
  RankData get streakData => _rankData;

  String? _userId;
  String? get userId => _userId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ===== CONSTRUCTOR =====

  StreakController() {
    _initUseCases();
  }

  void _initUseCases() {
    try {
      _getRankData = getIt<GetStreakData>();
      _checkAndUpdateRank = getIt<CheckAndUpdateStreak>();
    } catch (e) {
      debugPrint('RankController: Use case init hatası - $e');
    }
  }

  // ===== RANK HESAPLAMALARI =====

  /// Mevcut rank kademesi
  RankTier get currentRank => RankTiers.fromXp(_rankData.totalXp);

  /// Bir sonraki rank kademesi (null = max rank)
  RankTier? get nextRank => RankTiers.nextTierFrom(_rankData.totalXp);

  /// Sonraki rank'a ilerleme yüzdesi (0.0 - 1.0)
  double get progressToNextRank => RankTiers.progressToNext(_rankData.totalXp);

  /// Sonraki rank'a kalan XP
  int get xpToNextRank => RankTiers.xpToNextTier(_rankData.totalXp);

  /// Tüm rank kademeleri
  List<RankTier> get allTiers => RankTiers.allTiers;

  /// Belirli bir rank kazanıldı mı?
  bool isTierUnlocked(RankTier tier) {
    return _rankData.totalXp >= tier.requiredXp;
  }

  // ===== SERİ HESAPLAMALARI =====

  /// Seri bilgisi için backward compat getter'lar
  int get currentStreak => _rankData.currentStreak;
  int get longestStreak => _rankData.longestStreak;
  int get totalXp => _rankData.totalXp;
  int get totalLoginDays => _rankData.totalLoginDays;

  // ===== USE CASE METODLARI =====

  /// Rank verisini getir
  void loadStreakData(String userId) {
    _userId = userId;
    try {
      _rankData = _getRankData(GetStreakDataParams(userId: userId));
      notifyListeners();
    } catch (e) {
      debugPrint('RankController: loadRankData hatası - $e');
    }
  }

  /// Rank'ı kontrol et ve güncelle
  Future<StreakResult?> checkAndUpdate() async {
    if (_userId == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _checkAndUpdateRank(
        CheckAndUpdateStreakParams(userId: _userId!),
      );
      loadStreakData(_userId!);
      return result;
    } catch (e) {
      debugPrint('RankController: checkAndUpdate hatası - $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== VERİ YÖNETİMİ =====

  /// User ID'yi ayarla
  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (userId != null) {
        loadStreakData(userId);
      }
    }
  }

  /// Rank verisini güncelle (manuel)
  void updateStreakData(RankData data) {
    _rankData = data;
    notifyListeners();
  }

  /// State'i yenile
  void refresh() {
    if (_userId != null) {
      loadStreakData(_userId!);
    } else {
      notifyListeners();
    }
  }
}
