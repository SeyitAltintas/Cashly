import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/data/constants/streak_badges.dart';

/// StreakData Model + StreakBadges — Kapsamlı Unit Testleri
void main() {
  // ============================================================
  // STREAK DATA MODEL
  // ============================================================
  group('StreakData — Constructor', () {
    test('tüm alanlar doğru set edilir', () {
      const data = StreakData(
        currentStreak: 10,
        longestStreak: 15,
        lastLoginDate: '2024-06-15',
        totalLoginDays: 50,
        earnedBadges: ['ates_baslangici', 'haftalik_yildiz'],
      );
      expect(data.currentStreak, 10);
      expect(data.longestStreak, 15);
      expect(data.lastLoginDate, '2024-06-15');
      expect(data.totalLoginDays, 50);
      expect(data.earnedBadges.length, 2);
      expect(data.freezeCount, 1); // varsayılan
      expect(data.usedFreezeToday, isFalse);
      expect(data.totalFreezesUsed, 0);
    });
  });

  group('StreakData.empty', () {
    test('boş veri ile başlatılır', () {
      final data = StreakData.empty();
      expect(data.currentStreak, 0);
      expect(data.longestStreak, 0);
      expect(data.lastLoginDate, '');
      expect(data.totalLoginDays, 0);
      expect(data.earnedBadges, isEmpty);
      expect(data.freezeCount, 1);
      expect(data.usedFreezeToday, isFalse);
    });
  });

  group('StreakData — canUseFreeze', () {
    test('freezeCount > 0 → true', () {
      const data = StreakData(
        currentStreak: 5,
        longestStreak: 5,
        lastLoginDate: '',
        totalLoginDays: 5,
        earnedBadges: [],
        freezeCount: 2,
      );
      expect(data.canUseFreeze, isTrue);
    });

    test('freezeCount == 0 → false', () {
      const data = StreakData(
        currentStreak: 5,
        longestStreak: 5,
        lastLoginDate: '',
        totalLoginDays: 5,
        earnedBadges: [],
        freezeCount: 0,
      );
      expect(data.canUseFreeze, isFalse);
    });
  });

  group('StreakData — toMap / fromMap', () {
    test('round-trip tutarlı', () {
      const original = StreakData(
        currentStreak: 30,
        longestStreak: 45,
        lastLoginDate: '2024-07-01',
        totalLoginDays: 100,
        earnedBadges: ['ates_baslangici', 'haftalik_yildiz', 'kararli'],
        freezeCount: 3,
        usedFreezeToday: true,
        totalFreezesUsed: 5,
      );
      final map = original.toMap();
      final restored = StreakData.fromMap(map);

      expect(restored.currentStreak, original.currentStreak);
      expect(restored.longestStreak, original.longestStreak);
      expect(restored.lastLoginDate, original.lastLoginDate);
      expect(restored.totalLoginDays, original.totalLoginDays);
      expect(restored.earnedBadges.length, original.earnedBadges.length);
      expect(restored.freezeCount, original.freezeCount);
      expect(restored.usedFreezeToday, original.usedFreezeToday);
      expect(restored.totalFreezesUsed, original.totalFreezesUsed);
    });

    test('fromMap varsayılan değerler', () {
      final data = StreakData.fromMap({});
      expect(data.currentStreak, 0);
      expect(data.longestStreak, 0);
      expect(data.earnedBadges, isEmpty);
      expect(data.freezeCount, 1);
    });
  });

  group('StreakData — copyWith', () {
    test('streak güncellenir', () {
      final original = StreakData.empty();
      final updated = original.copyWith(currentStreak: 5, totalLoginDays: 5);
      expect(updated.currentStreak, 5);
      expect(updated.totalLoginDays, 5);
      expect(updated.longestStreak, 0);
    });

    test('freeze güncellenir', () {
      final original = StreakData.empty();
      final updated = original.copyWith(
        freezeCount: 0,
        usedFreezeToday: true,
        totalFreezesUsed: 1,
      );
      expect(updated.freezeCount, 0);
      expect(updated.usedFreezeToday, isTrue);
      expect(updated.totalFreezesUsed, 1);
    });
  });

  group('StreakData — toString', () {
    test('okunabilir format', () {
      const data = StreakData(
        currentStreak: 7,
        longestStreak: 14,
        lastLoginDate: '2024-06-15',
        totalLoginDays: 30,
        earnedBadges: [],
      );
      final str = data.toString();
      expect(str, contains('current: 7'));
      expect(str, contains('longest: 14'));
      expect(str, contains('totalDays: 30'));
    });
  });

  // ============================================================
  // STREAK BADGES
  // ============================================================
  group('StreakBadges — allBadges', () {
    test('7 rozet tanımlanmış', () {
      expect(StreakBadges.allBadges.length, 7);
    });

    test('sıralama requiredStreak\'e göre artan', () {
      for (int i = 1; i < StreakBadges.allBadges.length; i++) {
        expect(
          StreakBadges.allBadges[i].requiredStreak,
          greaterThan(StreakBadges.allBadges[i - 1].requiredStreak),
        );
      }
    });

    test('ilk rozet 3 gün gerektirir', () {
      expect(StreakBadges.allBadges.first.requiredStreak, 3);
      expect(StreakBadges.allBadges.first.id, 'ates_baslangici');
    });

    test('son rozet 365 gün gerektirir', () {
      expect(StreakBadges.allBadges.last.requiredStreak, 365);
      expect(StreakBadges.allBadges.last.id, 'efsane');
    });
  });

  group('StreakBadges.getBadgeById', () {
    test('mevcut ID → rozet döner', () {
      final badge = StreakBadges.getBadgeById('haftalik_yildiz');
      expect(badge, isNotNull);
      expect(badge!.requiredStreak, 7);
    });

    test('bilinmeyen ID → null', () {
      expect(StreakBadges.getBadgeById('yok'), isNull);
    });

    test('boş ID → null', () {
      expect(StreakBadges.getBadgeById(''), isNull);
    });
  });

  group('StreakBadges.getEarnedBadges', () {
    test('0 gün → boş liste', () {
      expect(StreakBadges.getEarnedBadges(0), isEmpty);
    });

    test('2 gün → boş (3 gerekiyor)', () {
      expect(StreakBadges.getEarnedBadges(2), isEmpty);
    });

    test('3 gün → 1 rozet (Ateş Başlangıcı)', () {
      final badges = StreakBadges.getEarnedBadges(3);
      expect(badges.length, 1);
      expect(badges.first.id, 'ates_baslangici');
    });

    test('7 gün → 2 rozet', () {
      expect(StreakBadges.getEarnedBadges(7).length, 2);
    });

    test('30 gün → 4 rozet', () {
      expect(StreakBadges.getEarnedBadges(30).length, 4);
    });

    test('100 gün → 6 rozet', () {
      expect(StreakBadges.getEarnedBadges(100).length, 6);
    });

    test('365 gün → 7 rozet (tümü)', () {
      expect(StreakBadges.getEarnedBadges(365).length, 7);
    });

    test('1000 gün → 7 rozet (üst sınır)', () {
      expect(StreakBadges.getEarnedBadges(1000).length, 7);
    });
  });

  group('StreakBadges.getNextBadge', () {
    test('0 gün → sonraki Ateş Başlangıcı (3)', () {
      final next = StreakBadges.getNextBadge(0);
      expect(next, isNotNull);
      expect(next!.id, 'ates_baslangici');
    });

    test('3 gün → sonraki Haftalık Yıldız (7)', () {
      final next = StreakBadges.getNextBadge(3);
      expect(next, isNotNull);
      expect(next!.id, 'haftalik_yildiz');
    });

    test('100 gün → sonraki Efsane (365)', () {
      final next = StreakBadges.getNextBadge(100);
      expect(next, isNotNull);
      expect(next!.id, 'efsane');
    });

    test('365+ gün → null (tümü kazanılmış)', () {
      expect(StreakBadges.getNextBadge(365), isNull);
      expect(StreakBadges.getNextBadge(500), isNull);
    });
  });
}
