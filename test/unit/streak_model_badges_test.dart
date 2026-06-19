import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/data/constants/streak_badges.dart';

/// RankData Model + RankTiers — Kapsamlı Unit Testleri
void main() {
  // ============================================================
  // RANK DATA MODEL
  // ============================================================
  group('RankData — Constructor', () {
    test('tüm alanlar doğru set edilir', () {
      const data = RankData(
        totalXp: 1500,
        currentStreak: 10,
        longestStreak: 15,
        lastLoginDate: '2024-06-15',
        totalLoginDays: 50,
        lastResetYear: 2025,
      );
      expect(data.totalXp, 1500);
      expect(data.currentStreak, 10);
      expect(data.longestStreak, 15);
      expect(data.lastLoginDate, '2024-06-15');
      expect(data.totalLoginDays, 50);
      expect(data.lastResetYear, 2025);
    });
  });

  group('RankData.empty', () {
    test('boş veri ile başlatılır', () {
      final data = RankData.empty();
      expect(data.totalXp, 0);
      expect(data.currentStreak, 0);
      expect(data.longestStreak, 0);
      expect(data.lastLoginDate, '');
      expect(data.totalLoginDays, 0);
      expect(data.lastResetYear, DateTime.now().year);
    });
  });

  group('RankData — toMap / fromMap', () {
    test('round-trip tutarlı', () {
      const original = RankData(
        totalXp: 7000,
        currentStreak: 30,
        longestStreak: 45,
        lastLoginDate: '2024-07-01',
        totalLoginDays: 100,
        lastResetYear: 2025,
      );
      final map = original.toMap();
      final restored = RankData.fromMap(map);

      expect(restored.totalXp, original.totalXp);
      expect(restored.currentStreak, original.currentStreak);
      expect(restored.longestStreak, original.longestStreak);
      expect(restored.lastLoginDate, original.lastLoginDate);
      expect(restored.totalLoginDays, original.totalLoginDays);
      expect(restored.lastResetYear, original.lastResetYear);
    });

    test('fromMap eksik alanlar için varsayılan değerleri kullanır', () {
      final data = RankData.fromMap({});
      expect(data.totalXp, 0);
      expect(data.currentStreak, 0);
      expect(data.longestStreak, 0);
      expect(data.lastLoginDate, '');
    });
  });

  group('RankData — copyWith', () {
    test('streak ve XP güncellenir, diğerleri korunur', () {
      final original = RankData.empty();
      final updated = original.copyWith(
        totalXp: 500,
        currentStreak: 5,
        totalLoginDays: 5,
      );
      expect(updated.totalXp, 500);
      expect(updated.currentStreak, 5);
      expect(updated.totalLoginDays, 5);
      expect(updated.longestStreak, 0); // değişmedi
    });
  });

  group('RankData — toString', () {
    test('okunabilir format', () {
      const data = RankData(
        totalXp: 1500,
        currentStreak: 7,
        longestStreak: 14,
        lastLoginDate: '2024-06-15',
        totalLoginDays: 30,
        lastResetYear: 2025,
      );
      final str = data.toString();
      expect(str, contains('totalXp: 1500'));
      expect(str, contains('streak: 7'));
      expect(str, contains('longest: 14'));
    });
  });

  // ============================================================
  // RANK TIERS
  // ============================================================
  group('RankTiers — allTiers', () {
    test('9 kademe tanımlanmış', () {
      expect(RankTiers.allTiers.length, 9);
    });

    test('sıralama level ve requiredXp\'e göre artan', () {
      for (int i = 1; i < RankTiers.allTiers.length; i++) {
        expect(
          RankTiers.allTiers[i].level,
          greaterThan(RankTiers.allTiers[i - 1].level),
        );
        expect(
          RankTiers.allTiers[i].requiredXp,
          greaterThan(RankTiers.allTiers[i - 1].requiredXp),
        );
      }
    });

    test('ilk kademe 0 XP gerektirir', () {
      expect(RankTiers.allTiers.first.requiredXp, 0);
      expect(RankTiers.allTiers.first.id, 'acemi');
    });

    test('son kademe 55000 XP gerektirir', () {
      expect(RankTiers.allTiers.last.requiredXp, 55000);
      expect(RankTiers.allTiers.last.id, 'cashly_efsanesi');
    });
  });

  group('RankTiers.fromXp', () {
    test('0 XP → Acemi', () {
      final rank = RankTiers.fromXp(0);
      expect(rank.level, 1);
      expect(rank.name, 'Acemi');
    });

    test('499 XP → hâlâ Acemi', () {
      final rank = RankTiers.fromXp(499);
      expect(rank.level, 1);
    });

    test('500 XP → Meraklı', () {
      final rank = RankTiers.fromXp(500);
      expect(rank.level, 2);
    });

    test('55000 XP → Cashly Efsanesi', () {
      final rank = RankTiers.fromXp(55000);
      expect(rank.level, 9);
    });

    test('100000 XP (aşırı) → hâlâ Cashly Efsanesi', () {
      final rank = RankTiers.fromXp(100000);
      expect(rank.level, 9);
    });
  });

  group('RankTiers.nextTierFrom', () {
    test('0 XP → sonraki Meraklı (500)', () {
      final next = RankTiers.nextTierFrom(0);
      expect(next, isNotNull);
      expect(next!.id, 'merakli');
    });

    test('500 XP → sonraki Müdavim (1500)', () {
      final next = RankTiers.nextTierFrom(500);
      expect(next, isNotNull);
      expect(next!.requiredXp, 1500);
    });

    test('55000+ XP → null (max rank)', () {
      expect(RankTiers.nextTierFrom(55000), isNull);
      expect(RankTiers.nextTierFrom(100000), isNull);
    });
  });

  group('RankTiers.progressToNext', () {
    test('0 XP → 0.0 ilerleme', () {
      expect(RankTiers.progressToNext(0), equals(0.0));
    });

    test('max rank → 1.0 ilerleme', () {
      expect(RankTiers.progressToNext(55000), equals(1.0));
    });

    test('İki rank arasında doğru yüzde', () {
      // Acemi (0) → Meraklı (500): 250 XP = %50
      final progress = RankTiers.progressToNext(250);
      expect(progress, closeTo(0.5, 0.01));
    });

    test('0.0 ile 1.0 arasında kalır', () {
      for (final xp in [0, 100, 500, 1000, 5000, 20000, 55000, 100000]) {
        final progress = RankTiers.progressToNext(xp);
        expect(progress, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('RankTiers.xpToNextTier', () {
    test('0 XP → 500 XP gerekli (Acemi → Meraklı)', () {
      expect(RankTiers.xpToNextTier(0), equals(500));
    });

    test('250 XP → 250 XP kaldı', () {
      expect(RankTiers.xpToNextTier(250), equals(250));
    });

    test('max rank → 0 XP kaldı', () {
      expect(RankTiers.xpToNextTier(55000), equals(0));
    });
  });

  group('RankTiers.getById', () {
    test('mevcut ID → kademe döner', () {
      final tier = RankTiers.getById('merakli');
      expect(tier, isNotNull);
      expect(tier!.level, 2);
    });

    test('bilinmeyen ID → null', () {
      expect(RankTiers.getById('bilinmeyen'), isNull);
    });

    test('boş ID → null', () {
      expect(RankTiers.getById(''), isNull);
    });
  });

  group('XP Sabitleri', () {
    test('Günlük giriş XP pozitif', () {
      expect(RankTiers.dailyLoginXp, greaterThan(0));
    });

    test('7 günlük bonus günlük XP\'den büyük', () {
      expect(RankTiers.weeklyStreakBonusXp, greaterThan(RankTiers.dailyLoginXp));
    });

    test('30 günlük bonus haftalık bonustan büyük', () {
      expect(
        RankTiers.monthlyStreakBonusXp,
        greaterThan(RankTiers.weeklyStreakBonusXp),
      );
    });
  });
}
