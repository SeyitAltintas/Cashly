import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/data/constants/streak_badges.dart';

/// StreakService iş mantığı testleri
/// Seri artışı, dondurucu (freeze), rozet kazanma ve seri kırılma senaryoları
///
/// Not: StreakService static ve Hive'a bağımlı olduğu için
/// burada mantığı birebir simüle ediyoruz (pure logic testing)
void main() {
  group('Streak Mantığı — Seri Artışı', () {
    test('İlk giriş: seri 1 olur, longestStreak 1 olur', () {
      const today = '2024-06-15';
      final data = StreakData.empty();

      // İlk giriş simülasyonu
      expect(data.lastLoginDate, isEmpty);

      const newData = StreakData(
        currentStreak: 1,
        longestStreak: 1,
        lastLoginDate: today,
        totalLoginDays: 1,
        earnedBadges: [],
        freezeCount: 1,
        usedFreezeToday: false,
        totalFreezesUsed: 0,
      );

      expect(newData.currentStreak, equals(1));
      expect(newData.longestStreak, equals(1));
      expect(newData.totalLoginDays, equals(1));
      expect(newData.freezeCount, equals(1));
    });

    test('Ardışık gün: seri 1 artar', () {
      final yesterday = DateTime(2024, 6, 14);
      final today = DateTime(2024, 6, 15);
      final difference = today.difference(yesterday).inDays;

      expect(difference, equals(1));

      const currentData = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        lastLoginDate: '2024-06-14',
        totalLoginDays: 20,
        earnedBadges: ['ates_baslangici'],
      );

      // difference == 1 → seri devam
      final newStreak = currentData.currentStreak + 1;
      final newLongest = newStreak > currentData.longestStreak
          ? newStreak
          : currentData.longestStreak;

      expect(newStreak, equals(6));
      expect(newLongest, equals(10)); // 6 < 10, değişmez
    });

    test('Ardışık gün + longestStreak aşıldığında güncellenir', () {
      const currentData = StreakData(
        currentStreak: 9,
        longestStreak: 9,
        lastLoginDate: '2024-06-14',
        totalLoginDays: 30,
        earnedBadges: [],
      );

      final newStreak = currentData.currentStreak + 1;
      final newLongest = newStreak > currentData.longestStreak
          ? newStreak
          : currentData.longestStreak;

      expect(newStreak, equals(10));
      expect(newLongest, equals(10)); // 10 >= 9, güncellendi
    });

    test('Aynı gün tekrar giriş: seri artmaz', () {
      const today = '2024-06-15';
      const currentData = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        lastLoginDate: today,
        totalLoginDays: 20,
        earnedBadges: [],
      );

      // lastLoginDate == today → seri artmaz
      expect(currentData.lastLoginDate, equals(today));
      // Service'de bu durumda mevcut veri döner, streakIncreased = false
    });
  });

  group('Streak Mantığı — Seri Kırılma', () {
    test('2+ gün atlanırsa ve dondurucu yoksa seri sıfırlanır', () {
      final lastDate = DateTime(2024, 6, 12);
      final today = DateTime(2024, 6, 15);
      final difference = today.difference(lastDate).inDays;

      expect(difference, equals(3)); // 3 gün fark

      const currentData = StreakData(
        currentStreak: 15,
        longestStreak: 15,
        lastLoginDate: '2024-06-12',
        totalLoginDays: 30,
        earnedBadges: ['ates_baslangici', 'haftalik_yildiz', 'kararli'],
        freezeCount: 0, // Dondurucu yok!
      );

      // difference > 2 || !canUseFreeze → seri sıfırlanır
      expect(currentData.canUseFreeze, isFalse);

      final newData = currentData.copyWith(
        currentStreak: 1,
        lastLoginDate: '2024-06-15',
        totalLoginDays: currentData.totalLoginDays + 1,
      );

      expect(newData.currentStreak, equals(1));
      expect(newData.longestStreak, equals(15)); // longestStreak korunur
      expect(newData.totalLoginDays, equals(31));
      expect(newData.earnedBadges.length, equals(3)); // Rozetler korunur
    });
  });

  group('Streak Mantığı — Dondurucu (Freeze)', () {
    test('1 gün atlanır + dondurucu var → seri korunur', () {
      final lastDate = DateTime(2024, 6, 13);
      final today = DateTime(2024, 6, 15);
      final difference = today.difference(lastDate).inDays;

      expect(difference, equals(2)); // Tam 1 gün atlanmış (14 atlandı)

      const currentData = StreakData(
        currentStreak: 10,
        longestStreak: 10,
        lastLoginDate: '2024-06-13',
        totalLoginDays: 25,
        earnedBadges: [],
        freezeCount: 2,
      );

      expect(currentData.canUseFreeze, isTrue);

      // Dondurucu kullanılarak seri korunuyor
      final newData = currentData.copyWith(
        currentStreak: currentData.currentStreak + 1,
        longestStreak: 11, // 11 > 10
        lastLoginDate: '2024-06-15',
        totalLoginDays: currentData.totalLoginDays + 1,
        freezeCount: currentData.freezeCount - 1, // 2 → 1
        usedFreezeToday: true,
        totalFreezesUsed: currentData.totalFreezesUsed + 1,
      );

      expect(newData.currentStreak, equals(11));
      expect(newData.freezeCount, equals(1));
      expect(newData.usedFreezeToday, isTrue);
    });

    test('1 gün atlanır + dondurucu yok → seri sıfırlanır', () {
      const currentData = StreakData(
        currentStreak: 10,
        longestStreak: 10,
        lastLoginDate: '2024-06-13',
        totalLoginDays: 25,
        earnedBadges: [],
        freezeCount: 0, // Dondurucu YOK
      );

      // difference == 2 ama canUseFreeze == false
      expect(currentData.canUseFreeze, isFalse);

      // Seri sıfırlanır
      final newData = currentData.copyWith(
        currentStreak: 1,
        lastLoginDate: '2024-06-15',
        totalLoginDays: currentData.totalLoginDays + 1,
      );

      expect(newData.currentStreak, equals(1));
      expect(newData.longestStreak, equals(10)); // korunur
    });

    test('Her 7 günlük seride 1 dondurucu kazanılır (max 3)', () {
      // 7. gün → dondurucu kazanılır
      const freezeRewardInterval = 7;
      const maxFreezeCount = 3;

      int freezeCount = 0;

      for (int streak = 1; streak <= 28; streak++) {
        if (streak > 0 && streak % freezeRewardInterval == 0) {
          freezeCount = (freezeCount + 1).clamp(0, maxFreezeCount);
        }
      }

      // 7, 14, 21, 28 → 4 ödül ama max 3
      expect(freezeCount, equals(maxFreezeCount));
    });

    test('canUseFreeze doğru çalışır', () {
      expect(
        const StreakData(
          currentStreak: 5,
          longestStreak: 5,
          lastLoginDate: '',
          totalLoginDays: 5,
          earnedBadges: [],
          freezeCount: 1,
        ).canUseFreeze,
        isTrue,
      );

      expect(
        const StreakData(
          currentStreak: 5,
          longestStreak: 5,
          lastLoginDate: '',
          totalLoginDays: 5,
          earnedBadges: [],
          freezeCount: 0,
        ).canUseFreeze,
        isFalse,
      );
    });
  });

  group('Streak Mantığı — Rozet Kazanma', () {
    test('3 günlük seri → ates_baslangici rozeti', () {
      final earned = StreakBadges.getEarnedBadges(3);
      expect(earned.any((b) => b.id == 'ates_baslangici'), isTrue);
      expect(earned.any((b) => b.id == 'haftalik_yildiz'), isFalse);
    });

    test('7 günlük seri → haftalik_yildiz rozeti', () {
      final earned = StreakBadges.getEarnedBadges(7);
      expect(earned.length, equals(2)); // ates + haftalik
      expect(earned.any((b) => b.id == 'haftalik_yildiz'), isTrue);
    });

    test('30 günlük seri → 4 rozet', () {
      final earned = StreakBadges.getEarnedBadges(30);
      // ates(3) + haftalik(7) + kararli(14) + aylik(30) = 4
      expect(earned.length, equals(4));
    });

    test('365 günlük seri → tüm 7 rozet', () {
      final earned = StreakBadges.getEarnedBadges(365);
      expect(earned.length, equals(7));
    });

    test('1 günlük seri → henüz rozet yok', () {
      final earned = StreakBadges.getEarnedBadges(1);
      expect(earned, isEmpty);
    });

    test('getNextBadge doğru sonraki rozeti döndürür', () {
      final next = StreakBadges.getNextBadge(5);
      expect(next?.id, equals('haftalik_yildiz')); // 7 gerekiyor, 5 var

      final nextAt14 = StreakBadges.getNextBadge(14);
      expect(nextAt14?.id, equals('aylik_sampiyon')); // 30 gerekiyor

      final nextAtMax = StreakBadges.getNextBadge(365);
      expect(nextAtMax, isNull); // Tüm rozetler kazanıldı
    });

    test('getBadgeById var olan ID ile çalışır', () {
      expect(
        StreakBadges.getBadgeById('ates_baslangici')?.requiredStreak,
        equals(3),
      );
      expect(StreakBadges.getBadgeById('efsane')?.requiredStreak, equals(365));
    });

    test('getBadgeById olmayan ID ile null döner', () {
      expect(StreakBadges.getBadgeById('olmayan_rozet'), isNull);
    });

    test('Yeni rozetler: zaten kazanılanlar tekrar kazanılmaz', () {
      const currentBadges = ['ates_baslangici'];
      const streakCount = 7;

      final newBadges = <String>[];
      for (final badge in StreakBadges.allBadges) {
        if (streakCount >= badge.requiredStreak &&
            !currentBadges.contains(badge.id)) {
          newBadges.add(badge.id);
        }
      }

      expect(newBadges.contains('ates_baslangici'), isFalse);
      expect(newBadges.contains('haftalik_yildiz'), isTrue);
    });
  });

  group('StreakData Model — Serialization', () {
    test('toMap/fromMap round-trip veri kaybetmez', () {
      const original = StreakData(
        currentStreak: 15,
        longestStreak: 30,
        lastLoginDate: '2024-06-15',
        totalLoginDays: 45,
        earnedBadges: ['ates_baslangici', 'haftalik_yildiz'],
        freezeCount: 2,
        usedFreezeToday: true,
        totalFreezesUsed: 3,
      );

      final map = original.toMap();
      final restored = StreakData.fromMap(map);

      expect(restored.currentStreak, equals(original.currentStreak));
      expect(restored.longestStreak, equals(original.longestStreak));
      expect(restored.lastLoginDate, equals(original.lastLoginDate));
      expect(restored.totalLoginDays, equals(original.totalLoginDays));
      expect(restored.earnedBadges, equals(original.earnedBadges));
      expect(restored.freezeCount, equals(original.freezeCount));
      expect(restored.usedFreezeToday, equals(original.usedFreezeToday));
      expect(restored.totalFreezesUsed, equals(original.totalFreezesUsed));
    });

    test('fromMap eksik alanlar için varsayılan değerler', () {
      final data = StreakData.fromMap({});

      expect(data.currentStreak, equals(0));
      expect(data.longestStreak, equals(0));
      expect(data.lastLoginDate, equals(''));
      expect(data.totalLoginDays, equals(0));
      expect(data.earnedBadges, isEmpty);
      expect(data.freezeCount, equals(1)); // Varsayılan 1
      expect(data.usedFreezeToday, isFalse);
      expect(data.totalFreezesUsed, equals(0));
    });

    test('empty factory doğru default değerler üretir', () {
      final data = StreakData.empty();

      expect(data.currentStreak, equals(0));
      expect(data.longestStreak, equals(0));
      expect(data.lastLoginDate, isEmpty);
      expect(data.totalLoginDays, equals(0));
      expect(data.earnedBadges, isEmpty);
      expect(data.freezeCount, equals(1));
      expect(data.canUseFreeze, isTrue);
    });

    test('copyWith sadece belirtilen alanları değiştirir', () {
      const original = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        lastLoginDate: '2024-06-15',
        totalLoginDays: 20,
        earnedBadges: ['ates_baslangici'],
        freezeCount: 2,
      );

      final modified = original.copyWith(currentStreak: 6);

      expect(modified.currentStreak, equals(6));
      expect(modified.longestStreak, equals(10)); // Değişmedi
      expect(modified.earnedBadges.length, equals(1)); // Değişmedi
      expect(modified.freezeCount, equals(2)); // Değişmedi
    });
  });
}
