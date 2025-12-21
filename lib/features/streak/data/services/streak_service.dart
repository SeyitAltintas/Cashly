import 'package:hive_flutter/hive_flutter.dart';
import '../models/streak_model.dart';
import '../constants/streak_badges.dart';

/// Seri (Streak) yönetim servisi
/// Günlük giriş serisini takip eder ve günceller
class StreakService {
  StreakService._();

  static const String _boxName = 'streak_box';

  /// Her 7 günlük seride 1 dondurucu kazanılır
  static const int _freezeRewardInterval = 7;

  /// Maksimum biriktirilebilir dondurucu sayısı
  static const int _maxFreezeCount = 3;

  /// Seri verisini getir
  static StreakData getStreakData(String userId) {
    try {
      final box = Hive.box(_boxName);
      final data = box.get('streak_$userId');
      if (data == null) return StreakData.empty();
      return StreakData.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      return StreakData.empty();
    }
  }

  /// Seri verisini kaydet
  static Future<void> saveStreakData(String userId, StreakData data) async {
    try {
      final box = Hive.box(_boxName);
      await box.put('streak_$userId', data.toMap());
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// Uygulama açıldığında seriyi kontrol et ve güncelle
  /// Gün içinde birden fazla giriş yapılsa bile sadece bir kere sayılır
  static Future<StreakData> checkAndUpdateStreak(String userId) async {
    final currentData = getStreakData(userId);
    final today = _getDateString(DateTime.now());
    final lastLogin = currentData.lastLoginDate;

    // Bugün zaten giriş yaptıysa, mevcut veriyi döndür
    if (lastLogin == today) {
      return currentData;
    }

    // Yeni seri verisi hesapla
    StreakData newData;

    if (lastLogin.isEmpty) {
      // İlk giriş
      newData = StreakData(
        currentStreak: 1,
        longestStreak: 1,
        lastLoginDate: today,
        totalLoginDays: 1,
        earnedBadges: [],
        freezeCount: 1, // İlk giriş için 1 dondurucu
        usedFreezeToday: false,
        totalFreezesUsed: 0,
      );
    } else {
      final lastDate = DateTime.parse(lastLogin);
      final todayDate = DateTime.parse(today);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        // Dün giriş yaptı, seri devam ediyor
        final newStreak = currentData.currentStreak + 1;
        final newLongest = newStreak > currentData.longestStreak
            ? newStreak
            : currentData.longestStreak;

        // Her 7 günlük seride 1 dondurucu kazanılır (max 3)
        int newFreezeCount = currentData.freezeCount;
        if (newStreak > 0 && newStreak % _freezeRewardInterval == 0) {
          newFreezeCount = (newFreezeCount + 1).clamp(0, _maxFreezeCount);
        }

        newData = currentData.copyWith(
          currentStreak: newStreak,
          longestStreak: newLongest,
          lastLoginDate: today,
          totalLoginDays: currentData.totalLoginDays + 1,
          freezeCount: newFreezeCount,
          usedFreezeToday: false,
        );
      } else if (difference == 2 && currentData.canUseFreeze) {
        // 1 gün atlandı ama dondurucu var - seriyi koru!
        final newStreak = currentData.currentStreak + 1;
        final newLongest = newStreak > currentData.longestStreak
            ? newStreak
            : currentData.longestStreak;

        newData = currentData.copyWith(
          currentStreak: newStreak,
          longestStreak: newLongest,
          lastLoginDate: today,
          totalLoginDays: currentData.totalLoginDays + 1,
          freezeCount: currentData.freezeCount - 1, // Dondurucu kullan
          usedFreezeToday: true,
          totalFreezesUsed: currentData.totalFreezesUsed + 1,
        );
      } else {
        // Birden fazla gün atlandı veya dondurucu yok, seri sıfırlanıyor
        newData = currentData.copyWith(
          currentStreak: 1,
          lastLoginDate: today,
          totalLoginDays: currentData.totalLoginDays + 1,
          usedFreezeToday: false,
        );
      }
    }

    // Yeni kazanılan rozetleri kontrol et
    final earnedBadgeIds = _checkNewBadges(
      currentData.earnedBadges,
      newData.currentStreak,
    );

    if (earnedBadgeIds.isNotEmpty) {
      newData = newData.copyWith(
        earnedBadges: [...newData.earnedBadges, ...earnedBadgeIds],
      );
    }

    // Veriyi kaydet
    await saveStreakData(userId, newData);

    return newData;
  }

  /// Yeni kazanılan rozetleri kontrol et
  static List<String> _checkNewBadges(
    List<String> currentBadges,
    int streakCount,
  ) {
    final newBadges = <String>[];

    for (final badge in StreakBadges.allBadges) {
      if (streakCount >= badge.requiredStreak &&
          !currentBadges.contains(badge.id)) {
        newBadges.add(badge.id);
      }
    }

    return newBadges;
  }

  /// Tarih string'i oluştur (YYYY-MM-DD formatında)
  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Streak box'ını başlat
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }
}
