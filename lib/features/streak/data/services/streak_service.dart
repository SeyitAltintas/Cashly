import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:cashly/core/services/secure_storage_service.dart';
import '../models/streak_model.dart';
import '../constants/streak_badges.dart';

/// Rank güncelleme sonucu
class StreakResult {
  final RankData data;
  final bool streakIncreased;
  final int previousStreak;
  final bool rankedUp;
  final RankTier? newRank;
  /// Seri 3 günden fazla girilmeyip kırıldıysa true
  final bool streakBroken;

  const StreakResult({
    required this.data,
    required this.streakIncreased,
    required this.previousStreak,
    this.rankedUp = false,
    this.newRank,
    this.streakBroken = false,
  });
}

/// Rank (XP + Seri) yönetim servisi
/// Günlük giriş serisi ve XP'yi takip eder
class StreakService {
  StreakService._();

  static const String _boxName = 'streak_box';
  static const String _logName = 'RankService';

  // ===== VERİ OKUMA / YAZMA =====

  /// Rank verisini getir
  static RankData getStreakData(String userId) {
    try {
      final box = Hive.box(_boxName);
      final data = box.get('streak_$userId');
      if (data == null) return RankData.empty();
      return RankData.fromMap(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      developer.log(
        'Rank verisi okunurken hata',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return RankData.empty();
    }
  }

  /// Rank verisini kaydet (Hive + Firestore)
  static Future<void> saveStreakData(String userId, RankData data) async {
    try {
      final box = Hive.box(_boxName);
      await box.put('streak_$userId', data.toMap());

      if (FirebaseAuth.instance.currentUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('streak')
            .doc('data')
            .set(data.toMap())
            .catchError((e) {
              developer.log('Rank Firestore yazılamadı: $e', name: _logName);
            });
      }

      developer.log(
        'Rank verisi kaydedildi: xp=${data.totalXp}, streak=${data.currentStreak}',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Rank verisi kaydedilirken hata',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Firestore'dan rank verisini çek ve Hive'a yaz
  static Future<void> syncFromCloud(String userId) async {
    if (userId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('streak')
          .doc('data')
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists || doc.data() == null) return;

      final cloudData = RankData.fromMap(doc.data()!);
      final localData = getStreakData(userId);

      if (!_cloudDataWins(cloudData, localData)) return;

      final box = Hive.box(_boxName);
      await box.put('streak_$userId', cloudData.toMap());
      developer.log(
        'Rank buluttan yüklendi: ${cloudData.totalXp} XP',
        name: _logName,
      );
    } catch (e) {
      developer.log('Rank sync hatası (offline?): $e', name: _logName);
    }
  }

  /// Bulut verisinin yerel veriye göre öncelikli olup olmadığını belirler
  static bool _cloudDataWins(RankData cloud, RankData local) {
    if (local.lastLoginDate.isEmpty) return true;
    if (cloud.lastLoginDate.isEmpty) return false;

    final cloudDate = DateTime.tryParse(cloud.lastLoginDate);
    final localDate = DateTime.tryParse(local.lastLoginDate);

    if (cloudDate == null || localDate == null) {
      return cloud.totalXp > local.totalXp;
    }
    if (cloudDate.isAfter(localDate)) return true;
    if (cloudDate.isAtSameMomentAs(localDate)) {
      return cloud.totalXp > local.totalXp;
    }
    return false;
  }

  // ===== ANA GÜNCELLEME MANTIĞI =====

  /// Uygulama açıldığında rank/seri kontrol et ve güncelle
  static Future<StreakResult> checkAndUpdateStreak(String userId) async {
    var currentData = getStreakData(userId);
    final today = _getDateString(DateTime.now());
    final currentYear = DateTime.now().year;

    // --- YILLIK RESET KONTROLÜ ---
    if (currentData.lastResetYear < currentYear) {
      developer.log(
        'Yıllık XP reset: ${currentData.lastResetYear} → $currentYear',
        name: _logName,
      );
      currentData = currentData.copyWith(
        totalXp: 0,
        lastResetYear: currentYear,
      );
      await saveStreakData(userId, currentData);
    }

    final lastLogin = currentData.lastLoginDate;
    final previousStreak = currentData.currentStreak;
    final previousRank = RankTiers.fromXp(currentData.totalXp);

    // Bugün zaten giriş yaptıysa, artış yok
    if (lastLogin == today) {
      return StreakResult(
        data: currentData,
        streakIncreased: false,
        previousStreak: previousStreak,
      );
    }

    // Yeni veriyi hesapla
    RankData newData;
    bool streakIncreased = false;
    int earnedXp = 0;

    if (lastLogin.isEmpty) {
      // İlk giriş
      earnedXp = RankTiers.dailyLoginXp;
      newData = RankData(
        totalXp: currentData.totalXp + earnedXp,
        currentStreak: 1,
        longestStreak: 1,
        lastLoginDate: today,
        totalLoginDays: 1,
        lastResetYear: currentData.lastResetYear,
      );
      streakIncreased = true;
    } else {
      final lastDate = DateTime.parse(lastLogin);
      final todayDate = DateTime.parse(today);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference <= 0) {
        return StreakResult(
          data: currentData,
          streakIncreased: false,
          previousStreak: previousStreak,
        );
      } else if (difference <= 3) {
        // Seri devam ediyor (3 güne kadar esneklik)
        final newStreak = currentData.currentStreak + 1;
        final newLongest = newStreak > currentData.longestStreak
            ? newStreak
            : currentData.longestStreak;

        earnedXp = RankTiers.dailyLoginXp;

        // 7 günlük seri bonusu
        if (newStreak % 7 == 0) {
          earnedXp += RankTiers.weeklyStreakBonusXp;
          developer.log('7 günlük seri bonusu: +${RankTiers.weeklyStreakBonusXp} XP', name: _logName);
        }

        // 30 günlük seri bonusu
        if (newStreak % 30 == 0) {
          earnedXp += RankTiers.monthlyStreakBonusXp;
          developer.log('30 günlük seri bonusu: +${RankTiers.monthlyStreakBonusXp} XP', name: _logName);
        }

        newData = currentData.copyWith(
          totalXp: currentData.totalXp + earnedXp,
          currentStreak: newStreak,
          longestStreak: newLongest,
          lastLoginDate: today,
          totalLoginDays: currentData.totalLoginDays + 1,
        );
        streakIncreased = true;
      } else {
        // Seri kırıldı (difference > 3)
        earnedXp = RankTiers.dailyLoginXp;
        newData = currentData.copyWith(
          totalXp: currentData.totalXp + earnedXp,
          currentStreak: 1,
          lastLoginDate: today,
          totalLoginDays: currentData.totalLoginDays + 1,
        );
        // streakBroken işareti aşağıda StreakResult'a ekleniyor
        await saveStreakData(userId, newData);
        final newRankBroken = RankTiers.fromXp(newData.totalXp);
        final rankedUpBroken = newRankBroken.level > previousRank.level;
        developer.log(
          'Seri kırıldı: previousStreak=$previousStreak | +$earnedXp XP',
          name: _logName,
        );
        return StreakResult(
          data: newData,
          streakIncreased: false,
          previousStreak: previousStreak,
          rankedUp: rankedUpBroken,
          newRank: rankedUpBroken ? newRankBroken : null,
          streakBroken: previousStreak > 0,
        );
      }
    }

    // Rank atlama kontrolü
    final newRank = RankTiers.fromXp(newData.totalXp);
    final rankedUp = newRank.level > previousRank.level;

    developer.log(
      'Rank güncellendi: +$earnedXp XP → toplam ${newData.totalXp} XP | '
      'Rank: ${newRank.name}${rankedUp ? ' 🎉 RANK UP!' : ''}',
      name: _logName,
    );

    await saveStreakData(userId, newData);

    return StreakResult(
      data: newData,
      streakIncreased: streakIncreased,
      previousStreak: previousStreak,
      rankedUp: rankedUp,
      newRank: rankedUp ? newRank : null,
    );
  }

  // ===== YARDIMCI METODLAR =====

  /// Tarih string'i oluştur (YYYY-MM-DD formatında)
  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Rank box'ını başlat
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await SecureStorageService.openSecureBox(_boxName);
    }
  }
}
