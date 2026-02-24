import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/streak/presentation/controllers/streak_controller.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/data/constants/streak_badges.dart';

void main() {
  group('StreakController Local Calculation Tests', () {
    late StreakController controller;

    setUp(() {
      controller = StreakController();
    });

    test(
      'Yeni kullanıcı rozetleri sıfırdır ve Freeze günü 7. güne işaret eder',
      () {
        final streakData = StreakData(
          currentStreak: 0,
          longestStreak: 0,
          totalLoginDays: 0,
          totalFreezesUsed: 0,
          lastLoginDate: DateTime.now().toIso8601String(),
          earnedBadges: [],
        );

        controller.updateStreakData(streakData);

        expect(controller.earnedBadges.length, equals(0));
        // 7'ye bölünen ilerlemede sonraki freeze kazanımına 7 gün vardır
        expect(controller.nextFreezeIn, equals(7));

        // İlk badge (3 günlük starter badge)
        expect(controller.nextBadge?.requiredStreak, equals(3));
        expect(controller.daysToNextBadge, equals(3));
        // Yüzde 0 ilerleme
        expect(controller.nextBadgeProgress, equals(0.0));
      },
    );

    test('3 günlük streak ile ilk rozeti kazanır', () {
      final streakData = StreakData(
        currentStreak: 3,
        longestStreak: 3,
        totalLoginDays: 3,
        totalFreezesUsed: 0,
        lastLoginDate: DateTime.now().toIso8601String(),
        earnedBadges: ['ates_baslangici'],
      );

      controller.updateStreakData(streakData);

      expect(controller.earnedBadges.length, equals(1));
      expect(controller.earnedBadges.first.name, equals('Ateş Başlangıcı'));

      // Şimdiki hedef Gümüş (haftalık_yildiz) olmalı (7 günlük seri)
      expect(controller.nextBadge?.name, equals('Haftalık Yıldız'));
      expect(controller.daysToNextBadge, equals(4)); // 7 - 3 = 4

      // İlerleme yüzdesi 3 / 7 olmalı
      expect(controller.nextBadgeProgress, closeTo(3 / 7, 0.01));
    });

    test('Rozet kazanma boolean fonksiyonu çalışır', () {
      final streakData = StreakData(
        currentStreak: 7,
        longestStreak: 7,
        totalLoginDays: 7,
        totalFreezesUsed: 0,
        lastLoginDate: DateTime.now().toIso8601String(),
        earnedBadges: ['ates_baslangici', 'haftalik_yildiz'],
      );

      controller.updateStreakData(streakData);

      // Toplamda 2 rozet kazanmış oldu
      expect(controller.earnedBadges.length, equals(2));

      final bronzBadge = StreakBadges.allBadges.firstWhere(
        (b) => b.id == 'ates_baslangici',
      );
      final altinBadge = StreakBadges.allBadges.firstWhere(
        (b) => b.id == 'kararli',
      );

      expect(controller.isBadgeEarned(bronzBadge), isTrue); // Kazanılmış
      expect(controller.isBadgeEarned(altinBadge), isFalse); // Kazanılmamış
    });
  });
}
