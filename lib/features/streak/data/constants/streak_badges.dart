import 'package:flutter/material.dart';

/// Rozet tanımı
class StreakBadge {
  /// Rozet benzersiz kimliği
  final String id;

  /// Rozet adı
  final String name;

  /// Rozet açıklaması
  final String description;

  /// Gereken minimum seri sayısı
  final int requiredStreak;

  /// Rozet ikonu
  final IconData icon;

  /// Rozet rengi
  final Color color;

  /// Rozet emoji
  final String emoji;

  const StreakBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredStreak,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}

/// Tüm rozetlerin tanımları
class StreakBadges {
  StreakBadges._();

  /// Ateş Başlangıcı - 3 gün
  static const atesBaslangici = StreakBadge(
    id: 'ates_baslangici',
    name: 'Ateş Başlangıcı',
    description: '3 gün üst üste giriş yaptın!',
    requiredStreak: 3,
    icon: Icons.local_fire_department,
    color: Color(0xFFFF6B35),
    emoji: '🔥',
  );

  /// Haftalık Yıldız - 7 gün
  static const haftalikYildiz = StreakBadge(
    id: 'haftalik_yildiz',
    name: 'Haftalık Yıldız',
    description: '7 gün üst üste giriş yaptın!',
    requiredStreak: 7,
    icon: Icons.star,
    color: Color(0xFFFFD700),
    emoji: '⭐',
  );

  /// Kararlı - 14 gün
  static const kararli = StreakBadge(
    id: 'kararli',
    name: 'Kararlı',
    description: '2 hafta boyunca her gün giriş yaptın!',
    requiredStreak: 14,
    icon: Icons.fitness_center,
    color: Color(0xFF4FC3F7),
    emoji: '💪',
  );

  /// Aylık Şampiyon - 30 gün
  static const aylikSampiyon = StreakBadge(
    id: 'aylik_sampiyon',
    name: 'Aylık Şampiyon',
    description: '1 ay boyunca her gün giriş yaptın!',
    requiredStreak: 30,
    icon: Icons.military_tech,
    color: Color(0xFFFFB300),
    emoji: '🏅',
  );

  /// Süper Seri - 60 gün
  static const superSeri = StreakBadge(
    id: 'super_seri',
    name: 'Süper Seri',
    description: '2 ay boyunca her gün giriş yaptın!',
    requiredStreak: 60,
    icon: Icons.diamond,
    color: Color(0xFF9C27B0),
    emoji: '💎',
  );

  /// Seri Ustası - 100 gün
  static const seriUstasi = StreakBadge(
    id: 'seri_ustasi',
    name: 'Seri Ustası',
    description: '100 gün üst üste giriş yaptın!',
    requiredStreak: 100,
    icon: Icons.workspace_premium,
    color: Color(0xFFE53935),
    emoji: '👑',
  );

  /// Efsane - 365 gün
  static const efsane = StreakBadge(
    id: 'efsane',
    name: 'Efsane',
    description: '1 yıl boyunca her gün giriş yaptın!',
    requiredStreak: 365,
    icon: Icons.emoji_events,
    color: Color(0xFF78909C),
    emoji: '🏆',
  );

  /// Tüm rozetler listesi (sıralı)
  static const List<StreakBadge> allBadges = [
    atesBaslangici,
    haftalikYildiz,
    kararli,
    aylikSampiyon,
    superSeri,
    seriUstasi,
    efsane,
  ];

  /// Kimliğe göre rozet bul
  static StreakBadge? getBadgeById(String id) {
    try {
      return allBadges.firstWhere((badge) => badge.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Belirli bir seri sayısı için kazanılan rozetleri getir
  static List<StreakBadge> getEarnedBadges(int streakCount) {
    return allBadges
        .where((badge) => streakCount >= badge.requiredStreak)
        .toList();
  }

  /// Bir sonraki kazanılacak rozeti getir
  static StreakBadge? getNextBadge(int streakCount) {
    try {
      return allBadges.firstWhere(
        (badge) => streakCount < badge.requiredStreak,
      );
    } catch (_) {
      return null; // Tüm rozetler kazanıldı
    }
  }
}
