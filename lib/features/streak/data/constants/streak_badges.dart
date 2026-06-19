import 'package:flutter/material.dart';

/// Rank kademesi tanımı
class RankTier {
  /// Rank seviyesi (1-9)
  final int level;

  /// Rank benzersiz kimliği
  final String id;

  /// Rank adı (Türkçe)
  final String name;

  /// Rank açıklaması
  final String description;

  /// Gerekli minimum XP
  final int requiredXp;

  /// Lottie animasyon dosyası yolu
  final String lottieAsset;

  /// Ana renk
  final Color primaryColor;

  /// Parıldama rengi
  final Color glowColor;

  const RankTier({
    required this.level,
    required this.id,
    required this.name,
    required this.description,
    required this.requiredXp,
    required this.lottieAsset,
    required this.primaryColor,
    required this.glowColor,
  });
}

/// Tüm rank kademelerinin tanımları
class RankTiers {
  RankTiers._();

  // ===== 9 RANK KADEMESİ =====

  static const acemi = RankTier(
    level: 1,
    id: 'acemi',
    name: 'Acemi',
    description: 'Cashly yolculuğunuz başlıyor!',
    requiredXp: 0,
    lottieAsset: 'assets/lottie/rank/level_1_silver.json',
    primaryColor: Color(0xFF9E9E9E),
    glowColor: Color(0xFFBDBDBD),
  );

  static const merakli = RankTier(
    level: 2,
    id: 'merakli',
    name: 'Meraklı',
    description: 'Finansal dünyayı keşfetmeye başladınız.',
    requiredXp: 500,
    lottieAsset: 'assets/lottie/rank/level_2_silver.json',
    primaryColor: Color(0xFF78909C),
    glowColor: Color(0xFF90A4AE),
  );

  static const mudavim = RankTier(
    level: 3,
    id: 'mudavim',
    name: 'Müdavim',
    description: 'Düzenli kullanıcı olma yolundasınız.',
    requiredXp: 1500,
    lottieAsset: 'assets/lottie/rank/level_3_gold.json',
    primaryColor: Color(0xFFFFA726),
    glowColor: Color(0xFFFFD54F),
  );

  static const aliskIn = RankTier(
    level: 4,
    id: 'aliskın',
    name: 'Alışkın',
    description: 'Cashly artık alışkanlığınız oldu!',
    requiredXp: 3500,
    lottieAsset: 'assets/lottie/rank/level_4_gold.json',
    primaryColor: Color(0xFFFFB300),
    glowColor: Color(0xFFFFCA28),
  );

  static const tutkun = RankTier(
    level: 5,
    id: 'tutkun',
    name: 'Tutkun',
    description: 'Finansal tutkunuz fark yaratıyor.',
    requiredXp: 7000,
    lottieAsset: 'assets/lottie/rank/level_5_gold.json',
    primaryColor: Color(0xFFFF8F00),
    glowColor: Color(0xFFFFA000),
  );

  static const sadik = RankTier(
    level: 6,
    id: 'sadık',
    name: 'Sadık',
    description: 'Cashly\'ye olan bağlılığınız takdire şayan.',
    requiredXp: 12000,
    lottieAsset: 'assets/lottie/rank/level_6_gold.json',
    primaryColor: Color(0xFFE65100),
    glowColor: Color(0xFFFF6D00),
  );

  static const kidemli = RankTier(
    level: 7,
    id: 'kidemli',
    name: 'Kıdemli',
    description: 'Deneyimli bir Cashly kullanıcısısınız.',
    requiredXp: 20000,
    lottieAsset: 'assets/lottie/rank/level_7_gold.json',
    primaryColor: Color(0xFFAD1457),
    glowColor: Color(0xFFE91E63),
  );

  static const vazgecilmez = RankTier(
    level: 8,
    id: 'vazgecilmez',
    name: 'Vazgeçilmez',
    description: 'Cashly sizin için vazgeçilmez, siz Cashly için!',
    requiredXp: 35000,
    lottieAsset: 'assets/lottie/rank/level_8_purple.json',
    primaryColor: Color(0xFF6A1B9A),
    glowColor: Color(0xFF9C27B0),
  );

  static const cashlyEfsanesi = RankTier(
    level: 9,
    id: 'cashly_efsanesi',
    name: 'Cashly Efsanesi',
    description: 'Finansal özgürlüğün zirvesine ulaştınız. Efsanesiniz!',
    requiredXp: 55000,
    lottieAsset: 'assets/lottie/rank/level_9_puple.json',
    primaryColor: Color(0xFF4A148C),
    glowColor: Color(0xFF7B1FA2),
  );

  /// Tüm ranklar listesi (sıralı)
  static const List<RankTier> allTiers = [
    acemi,
    merakli,
    mudavim,
    aliskIn,
    tutkun,
    sadik,
    kidemli,
    vazgecilmez,
    cashlyEfsanesi,
  ];

  // ===== XP KAZANMA DEĞERLERİ =====

  /// Günlük giriş XP'si
  static const int dailyLoginXp = 10;

  /// 7 günlük seri bonus XP'si
  static const int weeklyStreakBonusXp = 30;

  /// 30 günlük seri bonus XP'si
  static const int monthlyStreakBonusXp = 100;

  // ===== YARDIMCI METODLAR =====

  /// XP'ye göre mevcut rank tier'ını getir
  static RankTier fromXp(int xp) {
    RankTier current = allTiers.first;
    for (final tier in allTiers) {
      if (xp >= tier.requiredXp) {
        current = tier;
      } else {
        break;
      }
    }
    return current;
  }

  /// Bir sonraki rank tier'ını getir (null = max rank)
  static RankTier? nextTierFrom(int xp) {
    final current = fromXp(xp);
    final nextLevel = current.level + 1;
    try {
      return allTiers.firstWhere((t) => t.level == nextLevel);
    } catch (_) {
      return null;
    }
  }

  /// ID'ye göre rank tier'ı bul
  static RankTier? getById(String id) {
    try {
      return allTiers.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sonraki rank'a olan XP yüzdesini hesapla (0.0 - 1.0)
  static double progressToNext(int xp) {
    final current = fromXp(xp);
    final next = nextTierFrom(xp);
    if (next == null) return 1.0;

    final xpInCurrentTier = xp - current.requiredXp;
    final xpNeededForNext = next.requiredXp - current.requiredXp;
    if (xpNeededForNext <= 0) return 1.0;

    return (xpInCurrentTier / xpNeededForNext).clamp(0.0, 1.0);
  }

  /// Sonraki rank'a kalan XP miktarı
  static int xpToNextTier(int xp) {
    final next = nextTierFrom(xp);
    if (next == null) return 0;
    return (next.requiredXp - xp).clamp(0, next.requiredXp);
  }
}

// Backward compatibility alias
typedef StreakBadge = RankTier;
typedef StreakBadges = RankTiers;
