import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/data/constants/streak_badges.dart';

/// Rank sistemi unit testleri
/// StreakController DI gerektirdiği için sadece model/util fonksiyonları test edilir
void main() {
  group('RankTiers - XP hesaplama testleri', () {
    test('0 XP ile Acemi ranku alınır', () {
      final rank = RankTiers.fromXp(0);
      expect(rank.level, equals(1));
      expect(rank.name, equals('Acemi'));
    });

    test('500 XP ile Meraklı ranku alınır', () {
      final rank = RankTiers.fromXp(500);
      expect(rank.level, equals(2));
      expect(rank.name, equals('Meraklı'));
    });

    test('1500 XP ile Müdavim ranku alınır', () {
      final rank = RankTiers.fromXp(1500);
      expect(rank.level, equals(3));
      expect(rank.name, equals('Müdavim'));
    });

    test('55000 XP ile Cashly Efsanesi ranku alınır', () {
      final rank = RankTiers.fromXp(55000);
      expect(rank.level, equals(9));
      expect(rank.name, equals('Cashly Efsanesi'));
    });

    test('Sonraki rank doğru hesaplanır', () {
      final next = RankTiers.nextTierFrom(0);
      expect(next?.level, equals(2));
      expect(next?.name, equals('Meraklı'));
    });

    test('Max rankta sonraki rank null döner', () {
      final next = RankTiers.nextTierFrom(55000);
      expect(next, isNull);
    });

    test('İlerleme yüzdesi doğru hesaplanır', () {
      // 500 ile 1500 arasında 750 XP = %25 ilerleme
      final progress = RankTiers.progressToNext(750);
      expect(progress, closeTo(0.25, 0.01));
    });

    test('Max rankta ilerleme yüzdesi 1.0', () {
      final progress = RankTiers.progressToNext(55000);
      expect(progress, equals(1.0));
    });

    test('Sonraki ranka kalan XP doğru hesaplanır', () {
      final xpToNext = RankTiers.xpToNextTier(0); // Acemi → Meraklı (500 XP)
      expect(xpToNext, equals(500));
    });

    test('allTiers listesi 9 kademe içerir', () {
      expect(RankTiers.allTiers.length, equals(9));
    });

    test('allTiers kademeleri sıralıdır', () {
      const tiers = RankTiers.allTiers;
      for (int i = 0; i < tiers.length - 1; i++) {
        expect(tiers[i].level, lessThan(tiers[i + 1].level));
        expect(tiers[i].requiredXp, lessThanOrEqualTo(tiers[i + 1].requiredXp));
      }
    });
  });

  group('RankData - Model testleri', () {
    test('RankData.empty() varsayılan değerleri doğru', () {
      final data = RankData.empty();
      expect(data.totalXp, equals(0));
      expect(data.currentStreak, equals(0));
      expect(data.longestStreak, equals(0));
      expect(data.lastLoginDate, isEmpty);
      expect(data.totalLoginDays, equals(0));
      expect(data.lastResetYear, equals(DateTime.now().year));
    });

    test('RankData Map dönüşümü çalışır', () {
      const original = RankData(
        totalXp: 1500,
        currentStreak: 7,
        longestStreak: 14,
        lastLoginDate: '2025-01-01',
        totalLoginDays: 30,
        lastResetYear: 2025,
      );

      final map = original.toMap();
      final restored = RankData.fromMap(map);

      expect(restored.totalXp, equals(original.totalXp));
      expect(restored.currentStreak, equals(original.currentStreak));
      expect(restored.longestStreak, equals(original.longestStreak));
      expect(restored.lastLoginDate, equals(original.lastLoginDate));
      expect(restored.totalLoginDays, equals(original.totalLoginDays));
      expect(restored.lastResetYear, equals(original.lastResetYear));
    });

    test('RankData.copyWith() kısmen güncelleme yapar', () {
      const original = RankData(
        totalXp: 500,
        currentStreak: 5,
        longestStreak: 10,
        lastLoginDate: '2025-01-01',
        totalLoginDays: 20,
        lastResetYear: 2025,
      );

      final updated = original.copyWith(totalXp: 1500, currentStreak: 6);

      expect(updated.totalXp, equals(1500));
      expect(updated.currentStreak, equals(6));
      // Güncellenmeyenler korunur
      expect(updated.longestStreak, equals(original.longestStreak));
      expect(updated.lastLoginDate, equals(original.lastLoginDate));
    });
  });

  group('XP Kazanma Sabitleri', () {
    test('Günlük giriş XP değeri pozitiftir', () {
      expect(RankTiers.dailyLoginXp, greaterThan(0));
    });

    test('7 günlük seri bonusu günlük XP\'den büyüktür', () {
      expect(RankTiers.weeklyStreakBonusXp, greaterThan(RankTiers.dailyLoginXp));
    });

    test('30 günlük seri bonusu haftalık bonustan büyüktür', () {
      expect(RankTiers.monthlyStreakBonusXp, greaterThan(RankTiers.weeklyStreakBonusXp));
    });
  });
}
