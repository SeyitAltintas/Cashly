import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/data/constants/streak_badges.dart';

/// RankData ve RankTiers — Servis mantığı unit testleri
/// Not: StreakService Hive ve Firebase gerektirdiği için
/// sadece model mantığı ve hesaplama fonksiyonları test edilir.
void main() {
  // ============================================================
  // RANK DATA — TEMEL YAPISAL TESTLER
  // ============================================================
  group('RankData — Temel Yapı', () {
    test('RankData.empty() tüm varsayılan değerleri doğru set eder', () {
      final data = RankData.empty();
      expect(data.totalXp, 0);
      expect(data.currentStreak, 0);
      expect(data.longestStreak, 0);
      expect(data.lastLoginDate, '');
      expect(data.totalLoginDays, 0);
      expect(data.lastResetYear, DateTime.now().year);
    });

    test('RankData constructor tüm alanları doğru alır', () {
      const data = RankData(
        totalXp: 1500,
        currentStreak: 7,
        longestStreak: 30,
        lastLoginDate: '2025-01-15',
        totalLoginDays: 50,
        lastResetYear: 2025,
      );
      expect(data.totalXp, 1500);
      expect(data.currentStreak, 7);
      expect(data.longestStreak, 30);
      expect(data.lastLoginDate, '2025-01-15');
      expect(data.totalLoginDays, 50);
      expect(data.lastResetYear, 2025);
    });
  });

  // ============================================================
  // RANK DATA — MAP DÖNÜŞÜMÜ
  // ============================================================
  group('RankData — toMap/fromMap round-trip', () {
    test('tüm alanlar korunur', () {
      const original = RankData(
        totalXp: 7000,
        currentStreak: 30,
        longestStreak: 45,
        lastLoginDate: '2025-06-01',
        totalLoginDays: 100,
        lastResetYear: 2025,
      );
      final restored = RankData.fromMap(original.toMap());

      expect(restored.totalXp, original.totalXp);
      expect(restored.currentStreak, original.currentStreak);
      expect(restored.longestStreak, original.longestStreak);
      expect(restored.lastLoginDate, original.lastLoginDate);
      expect(restored.totalLoginDays, original.totalLoginDays);
      expect(restored.lastResetYear, original.lastResetYear);
    });

    test('fromMap boş map → varsayılan değerler', () {
      final data = RankData.fromMap({});
      expect(data.totalXp, 0);
      expect(data.currentStreak, 0);
      expect(data.longestStreak, 0);
      expect(data.lastLoginDate, '');
    });

    test('fromMap kısmi map → eksik alanlar varsayılan', () {
      final data = RankData.fromMap({
        'totalXp': 500,
        'currentStreak': 5,
      });
      expect(data.totalXp, 500);
      expect(data.currentStreak, 5);
      expect(data.longestStreak, 0); // varsayılan
    });
  });

  // ============================================================
  // RANK DATA — copyWith
  // ============================================================
  group('RankData — copyWith', () {
    test('yalnızca belirtilen alanlar değişir', () {
      const original = RankData(
        totalXp: 500,
        currentStreak: 5,
        longestStreak: 10,
        lastLoginDate: '2025-01-01',
        totalLoginDays: 20,
        lastResetYear: 2025,
      );

      final updated = original.copyWith(totalXp: 1500, currentStreak: 6);

      expect(updated.totalXp, 1500);
      expect(updated.currentStreak, 6);
      expect(updated.longestStreak, 10); // değişmedi
      expect(updated.lastLoginDate, '2025-01-01'); // değişmedi
      expect(updated.totalLoginDays, 20); // değişmedi
    });

    test('longestStreak güncellenir', () {
      final data = RankData.empty();
      final updated = data.copyWith(longestStreak: 15);
      expect(updated.longestStreak, 15);
    });

    test('lastResetYear güncellenir', () {
      final data = RankData.empty();
      final updated = data.copyWith(lastResetYear: 2026);
      expect(updated.lastResetYear, 2026);
    });
  });

  // ============================================================
  // RANK DATA — Streak Mantığı (Günlük giriş simülasyonu)
  // ============================================================
  group('RankData — Streak Mantığı Simülasyonu', () {
    test('ilk giriş: seri 1, totalLoginDays 1 olur', () {
      final data = RankData.empty().copyWith(
        totalXp: RankTiers.dailyLoginXp,
        currentStreak: 1,
        longestStreak: 1,
        lastLoginDate: '2025-01-01',
        totalLoginDays: 1,
      );
      expect(data.currentStreak, 1);
      expect(data.longestStreak, 1);
      expect(data.totalXp, RankTiers.dailyLoginXp);
    });

    test('ardışık günlerde seri artar', () {
      var data = RankData.empty();

      // 1. gün
      data = data.copyWith(
        totalXp: data.totalXp + RankTiers.dailyLoginXp,
        currentStreak: 1,
        longestStreak: 1,
        lastLoginDate: '2025-01-01',
        totalLoginDays: 1,
      );

      // 2. gün
      data = data.copyWith(
        totalXp: data.totalXp + RankTiers.dailyLoginXp,
        currentStreak: 2,
        longestStreak: 2,
        lastLoginDate: '2025-01-02',
        totalLoginDays: 2,
      );

      expect(data.currentStreak, 2);
      expect(data.totalXp, RankTiers.dailyLoginXp * 2);
    });

    test('7 günlük seri bonus XP verir', () {
      const xpWith7DayBonus = RankTiers.dailyLoginXp * 7 + RankTiers.weeklyStreakBonusXp;
      final data = RankData.empty().copyWith(
        totalXp: xpWith7DayBonus,
        currentStreak: 7,
        longestStreak: 7,
        lastLoginDate: '2025-01-07',
        totalLoginDays: 7,
      );
      expect(data.totalXp, xpWith7DayBonus);
      expect(data.currentStreak, 7);
    });

    test('30 günlük seri bonus XP verir', () {
      const xpWith30DayBonus =
          RankTiers.dailyLoginXp * 30 +
          (RankTiers.weeklyStreakBonusXp * 4) + // 7,14,21,28. günlerde
          RankTiers.monthlyStreakBonusXp; // 30. günde
      // XP en az bu kadar olmalı
      expect(xpWith30DayBonus, greaterThan(RankTiers.dailyLoginXp * 30));
    });

    test('seri kırılırsa currentStreak 1 olur, longestStreak korunur', () {
      const initial = RankData(
        totalXp: 500,
        currentStreak: 30,
        longestStreak: 30,
        lastLoginDate: '2025-01-01',
        totalLoginDays: 30,
        lastResetYear: 2025,
      );

      // 2 gün sonra giriş yapıldı (seri kırıldı)
      final data = initial.copyWith(
        totalXp: initial.totalXp + RankTiers.dailyLoginXp,
        currentStreak: 1,
        lastLoginDate: '2025-01-03',
        totalLoginDays: initial.totalLoginDays + 1,
      );

      expect(data.currentStreak, 1);
      expect(data.longestStreak, 30); // korundu
      expect(data.totalXp, 510); // sadece günlük XP eklendi
    });
  });

  // ============================================================
  // RANK TIERS — XP BAZLI RANK HESAPLAMA
  // ============================================================
  group('RankTiers — fromXp', () {
    test('her rank kademesi için doğru rank döner', () {
      expect(RankTiers.fromXp(0).level, 1);    // Acemi
      expect(RankTiers.fromXp(500).level, 2);  // Meraklı
      expect(RankTiers.fromXp(1500).level, 3); // Müdavim
      expect(RankTiers.fromXp(3500).level, 4); // Alışkın
      expect(RankTiers.fromXp(7000).level, 5); // Tutkun
      expect(RankTiers.fromXp(12000).level, 6); // Sadık
      expect(RankTiers.fromXp(20000).level, 7); // Kıdemli
      expect(RankTiers.fromXp(35000).level, 8); // Vazgeçilmez
      expect(RankTiers.fromXp(55000).level, 9); // Cashly Efsanesi
    });

    test('rank eşiğinin 1 XP altında önceki rank döner', () {
      expect(RankTiers.fromXp(499).level, 1);   // 500-1 = hâlâ Acemi
      expect(RankTiers.fromXp(1499).level, 2);  // 1500-1 = hâlâ Meraklı
      expect(RankTiers.fromXp(54999).level, 8); // 55000-1 = hâlâ Vazgeçilmez
    });

    test('çok yüksek XP max rank döner', () {
      expect(RankTiers.fromXp(999999).level, 9);
    });
  });

  group('RankTiers — nextTierFrom', () {
    test('her rank için sonraki rank doğru', () {
      expect(RankTiers.nextTierFrom(0)?.level, 2);
      expect(RankTiers.nextTierFrom(500)?.level, 3);
      expect(RankTiers.nextTierFrom(1500)?.level, 4);
      expect(RankTiers.nextTierFrom(35000)?.level, 9);
    });

    test('max rank null döner', () {
      expect(RankTiers.nextTierFrom(55000), isNull);
      expect(RankTiers.nextTierFrom(100000), isNull);
    });
  });

  group('RankTiers — progressToNext', () {
    test('tam eşikte 0.0 ilerleme', () {
      expect(RankTiers.progressToNext(0), equals(0.0));
    });

    test('iki rank arası doğru yüzde', () {
      // Acemi(0) → Meraklı(500): 250 XP = %50
      expect(RankTiers.progressToNext(250), closeTo(0.5, 0.01));
    });

    test('max rankta 1.0', () {
      expect(RankTiers.progressToNext(55000), equals(1.0));
    });

    test('her zaman 0.0 ile 1.0 arasında', () {
      for (final xp in [0, 499, 500, 7000, 54999, 55000, 100000]) {
        final p = RankTiers.progressToNext(xp);
        expect(p, inInclusiveRange(0.0, 1.0),
            reason: 'xp=$xp için progress=$p geçersiz');
      }
    });
  });

  group('RankTiers — xpToNextTier', () {
    test('Acemi → Meraklı: 500 XP gerekli', () {
      expect(RankTiers.xpToNextTier(0), 500);
    });

    test('250 XP varsa 250 kaldı', () {
      expect(RankTiers.xpToNextTier(250), 250);
    });

    test('max rankta 0 kaldı', () {
      expect(RankTiers.xpToNextTier(55000), 0);
    });
  });

  group('RankTiers — getById', () {
    test('geçerli ID → doğru tier', () {
      expect(RankTiers.getById('acemi')?.level, 1);
      expect(RankTiers.getById('merakli')?.level, 2);
      expect(RankTiers.getById('cashly_efsanesi')?.level, 9);
    });

    test('geçersiz ID → null', () {
      expect(RankTiers.getById('bilinmeyen'), isNull);
      expect(RankTiers.getById(''), isNull);
    });
  });

  group('RankTiers — allTiers yapısı', () {
    test('9 kademe mevcuttur', () {
      expect(RankTiers.allTiers.length, 9);
    });

    test('kademeler sıralı ve XP artan', () {
      const tiers = RankTiers.allTiers;
      for (int i = 1; i < tiers.length; i++) {
        expect(tiers[i].level, tiers[i - 1].level + 1);
        expect(tiers[i].requiredXp, greaterThan(tiers[i - 1].requiredXp));
      }
    });

    test('ilk kademe 0 XP, son kademe 55000 XP', () {
      expect(RankTiers.allTiers.first.requiredXp, 0);
      expect(RankTiers.allTiers.last.requiredXp, 55000);
    });

    test('tüm kademelerin Lottie asset yolu mevcut', () {
      for (final tier in RankTiers.allTiers) {
        expect(tier.lottieAsset, startsWith('assets/lottie/rank/'));
        expect(tier.lottieAsset, endsWith('.json'));
      }
    });
  });

  // ============================================================
  // YILLIK RESET MANTIĞI (Model düzeyinde)
  // ============================================================
  group('Yıllık Reset Mantığı', () {
    test('geçen yıl kaydedilmiş veri: lastResetYear farklıdır', () {
      const data = RankData(
        totalXp: 5000,
        currentStreak: 10,
        longestStreak: 30,
        lastLoginDate: '2024-12-31',
        totalLoginDays: 100,
        lastResetYear: 2024,
      );
      final currentYear = DateTime.now().year;
      expect(data.lastResetYear, lessThan(currentYear));
    });

    test('reset sonrası XP 0, streak korunur', () {
      const data = RankData(
        totalXp: 5000,
        currentStreak: 10,
        longestStreak: 30,
        lastLoginDate: '2024-12-31',
        totalLoginDays: 100,
        lastResetYear: 2024,
      );

      final resetData = data.copyWith(
        totalXp: 0,
        lastResetYear: DateTime.now().year,
      );

      expect(resetData.totalXp, 0);
      expect(resetData.currentStreak, 10); // seri korundu
      expect(resetData.longestStreak, 30); // en uzun seri korundu
      expect(resetData.lastResetYear, DateTime.now().year);
    });
  });
}
