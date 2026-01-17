import 'package:flutter/material.dart';
import '../../data/models/streak_model.dart';
import '../../data/constants/streak_badges.dart';

/// Streak Controller
/// Seri sayfası için ChangeNotifier tabanlı state yönetimi sağlar.
/// Rozet hesaplamaları, başarım listesi ve freeze yönetimini merkezi olarak yönetir.
class StreakController extends ChangeNotifier {
  // ===== STATE =====

  StreakData _streakData = StreakData.empty();
  StreakData get streakData => _streakData;

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

  // ===== VERİ YÖNETİMİ =====

  /// Streak verisini güncelle
  void updateStreakData(StreakData data) {
    _streakData = data;
    notifyListeners();
  }

  /// State'i yenile
  void refresh() {
    notifyListeners();
  }
}
