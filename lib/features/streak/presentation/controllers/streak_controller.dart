import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/domain/usecases/streak_usecases.dart';
import '../../data/models/streak_model.dart';
import '../../data/services/streak_service.dart';
import '../../data/constants/streak_badges.dart';

/// Streak Controller
/// Seri sayfası için ChangeNotifier tabanlı state yönetimi sağlar.
/// Rozet hesaplamaları, başarım listesi ve freeze yönetimini merkezi olarak yönetir.
/// Use Case entegrasyonu ile Clean Architecture prensiplerini destekler.
class StreakController extends ChangeNotifier {
  // ===== USE CASES =====
  late final GetStreakData _getStreakData;
  late final CheckAndUpdateStreak _checkAndUpdateStreak;
  late final UseFreeze _useFreeze;

  // ===== STATE =====

  StreakData _streakData = StreakData.empty();
  StreakData get streakData => _streakData;

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
      _getStreakData = getIt<GetStreakData>();
      _checkAndUpdateStreak = getIt<CheckAndUpdateStreak>();
      _useFreeze = getIt<UseFreeze>();
    } catch (e) {
      // DI henüz hazır değilse (test ortamı vb.)
      debugPrint('StreakController: Use case init hatası - $e');
    }
  }

  // ===== HESAPLAMALAR =====

  /// Kazanılan rozetler
  List<StreakBadge> get earnedBadges =>
      StreakBadges.getEarnedBadges(_streakData.currentStreak);

  /// Sonraki rozet (varsa)
  StreakBadge? get nextBadge =>
      StreakBadges.getNextBadge(_streakData.currentStreak);

  /// Tüm rozetler
  List<StreakBadge> get allBadges => StreakBadges.allBadges;

  /// Sonraki freeze'e kalan gün
  int get nextFreezeIn => 7 - (_streakData.currentStreak % 7);

  /// Sonraki rozete kalan gün
  int get daysToNextBadge {
    final next = nextBadge;
    if (next == null) return 0;
    return next.requiredStreak - _streakData.currentStreak;
  }

  /// Sonraki rozet ilerleme yüzdesi (0.0 - 1.0)
  double get nextBadgeProgress {
    final next = nextBadge;
    if (next == null) return 1.0;
    return _streakData.currentStreak / next.requiredStreak;
  }

  /// Rozetin kazanılıp kazanılmadığını kontrol et
  bool isBadgeEarned(StreakBadge badge) {
    return earnedBadges.contains(badge);
  }

  /// Başarılar listesi
  List<Map<String, dynamic>> get achievements => [
    {
      'icon': Icons.play_arrow,
      'title': 'İlk Adım',
      'description': 'Uygulamayı ilk kez açtın',
      'earned': _streakData.totalLoginDays >= 1,
    },
    {
      'icon': Icons.local_fire_department,
      'title': 'Seri Başlatıcı',
      'description': '3 günlük seri oluştur',
      'earned': _streakData.longestStreak >= 3,
    },
    {
      'icon': Icons.ac_unit,
      'title': 'Seri Koruyucu',
      'description': 'Bir seri koruyucu kullan',
      'earned': _streakData.totalFreezesUsed >= 1,
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Düzenli Kullanıcı',
      'description': 'Toplam 10 gün giriş yap',
      'earned': _streakData.totalLoginDays >= 10,
    },
    {
      'icon': Icons.trending_up,
      'title': 'Süreklilik Ustası',
      'description': '30 günlük seri oluştur',
      'earned': _streakData.longestStreak >= 30,
    },
    {
      'icon': Icons.all_inclusive,
      'title': 'Finansal Guru',
      'description': 'Toplam 100 gün giriş yap',
      'earned': _streakData.totalLoginDays >= 100,
    },
  ];

  /// Kazanılan başarı sayısı
  int get earnedAchievementsCount =>
      achievements.where((a) => a['earned'] == true).length;

  /// Toplam başarı sayısı
  int get totalAchievementsCount => achievements.length;

  // ===== USE CASE METODLARI =====

  /// Streak verisini repository'den getir (Use Case)
  void loadStreakData(String userId) {
    _userId = userId;
    try {
      _streakData = _getStreakData(GetStreakDataParams(userId: userId));
      notifyListeners();
    } catch (e) {
      debugPrint('StreakController: loadStreakData hatası - $e');
    }
  }

  /// Streak'i kontrol et ve güncelle (Use Case)
  Future<StreakResult?> checkAndUpdate() async {
    if (_userId == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _checkAndUpdateStreak(
        CheckAndUpdateStreakParams(userId: _userId!),
      );

      // Streak verisini güncelle
      loadStreakData(_userId!);

      return result;
    } catch (e) {
      debugPrint('StreakController: checkAndUpdate hatası - $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dondurucu kullan (Use Case)
  Future<bool> useFreeze() async {
    if (_userId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _useFreeze(UseFreezeParams(userId: _userId!));

      if (result != null) {
        _streakData = result;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('StreakController: useFreeze hatası - $e');
      return false;
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

  /// Streak verisini güncelle (manuel)
  void updateStreakData(StreakData data) {
    _streakData = data;
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
