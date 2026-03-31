import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:cashly/core/services/secure_storage_service.dart';
import '../models/streak_model.dart';
import '../constants/streak_badges.dart';

/// Seri güncelleme sonucu
/// Seri verisi ve artış bilgisini içerir
class StreakResult {
  final StreakData data;
  final bool streakIncreased; // Seri bu giriş ile arttı mı?
  final int previousStreak; // Önceki seri değeri

  const StreakResult({
    required this.data,
    required this.streakIncreased,
    required this.previousStreak,
  });
}

/// Seri (Streak) yönetim servisi
/// Günlük giriş serisini takip eder ve günceller
class StreakService {
  StreakService._();

  static const String _boxName = 'streak_box';
  static const String _logName = 'StreakService';

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
    } catch (e, stackTrace) {
      developer.log(
        'Seri verisi okunurken hata',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return StreakData.empty();
    }
  }

  /// Seri verisini kaydet (Hive + Firestore)
  static Future<void> saveStreakData(String userId, StreakData data) async {
    try {
      // 1. Hive'a hizli yaz (UI aninda guncellenir)
      final box = Hive.box(_boxName);
      await box.put('streak_$userId', data.toMap());

      // 2. Firebase oturumu varsa buluta da yaz (fire-and-forget)
      if (FirebaseAuth.instance.currentUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('streak')
            .doc('data')
            .set(data.toMap())
            .catchError((e) {
          developer.log('Streak Firestore yazilamadi: $e', name: _logName);
        });
      }

      developer.log(
        'Seri verisi kaydedildi: streak=${data.currentStreak}, userId=$userId',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Seri verisi kaydedilirken hata',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Firestore'dan streak verisini cek ve Hive'a yaz
  /// Giris yapildiginda cagirilir - cihaz degisiminde streak'i geri yukler
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

      if (doc.exists && doc.data() != null) {
        final cloudData = StreakData.fromMap(doc.data()!);
        final localData = getStreakData(userId);

        // Buluttaki streak daha yuksekse veya local bos ise buluttakini al
        if (cloudData.currentStreak > localData.currentStreak ||
            localData.lastLoginDate.isEmpty) {
          final box = Hive.box(_boxName);
          await box.put('streak_$userId', cloudData.toMap());
          developer.log(
            'Streak buluttan yuklendi: ${cloudData.currentStreak} gun',
            name: _logName,
          );
        }
      }
    } catch (e) {
      developer.log('Streak sync hatasi (offline?): $e', name: _logName);
    }
  }

  /// Uygulama açıldığında seriyi kontrol et ve güncelle
  /// Gün içinde birden fazla giriş yapılsa bile sadece bir kere sayılır
  /// StreakResult döndürür - seri artışını kontrol edebilirsiniz
  static Future<StreakResult> checkAndUpdateStreak(String userId) async {
    final currentData = getStreakData(userId);
    final today = _getDateString(DateTime.now());
    final lastLogin = currentData.lastLoginDate;
    final previousStreak = currentData.currentStreak;

    // Bugün zaten giriş yaptıysa, mevcut veriyi döndür (artış yok)
    if (lastLogin == today) {
      return StreakResult(
        data: currentData,
        streakIncreased: false,
        previousStreak: previousStreak,
      );
    }

    // Yeni seri verisi hesapla
    StreakData newData;
    bool streakIncreased = false;

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
      streakIncreased = true; // İlk giriş de artış sayılır
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
        streakIncreased = true;
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
        streakIncreased = true; // Korunan seri de artış sayılır
      } else {
        // Birden fazla gün atlandı veya dondurucu yok, seri sıfırlanıyor
        newData = currentData.copyWith(
          currentStreak: 1,
          lastLoginDate: today,
          totalLoginDays: currentData.totalLoginDays + 1,
          usedFreezeToday: false,
        );
        streakIncreased = true; // Sıfırlandıktan sonra 1'e döndü
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

    return StreakResult(
      data: newData,
      streakIncreased: streakIncreased,
      previousStreak: previousStreak,
    );
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
      await SecureStorageService.openSecureBox(_boxName);
    }
  }
}
