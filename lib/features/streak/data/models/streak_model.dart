/// Rank (Sıralama) veri modeli
/// Kullanıcının XP birikimini ve giriş serisini takip eder
class RankData {
  /// Toplam kazanılan XP (yıllık reset olur)
  final int totalXp;

  /// Mevcut giriş serisi
  final int currentStreak;

  /// En uzun seri kaydı
  final int longestStreak;

  /// Son giriş tarihi (YYYY-MM-DD formatında)
  final String lastLoginDate;

  /// Toplam giriş günü sayısı
  final int totalLoginDays;

  /// XP'nin son sıfırlandığı yıl (yıllık reset için)
  final int lastResetYear;

  const RankData({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastLoginDate,
    required this.totalLoginDays,
    required this.lastResetYear,
  });

  /// Boş/yeni kullanıcı için varsayılan değerler
  factory RankData.empty() {
    return RankData(
      totalXp: 0,
      currentStreak: 0,
      longestStreak: 0,
      lastLoginDate: '',
      totalLoginDays: 0,
      lastResetYear: DateTime.now().year,
    );
  }

  /// Map'ten RankData oluştur
  factory RankData.fromMap(Map<String, dynamic> map) {
    return RankData(
      totalXp: map['totalXp'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastLoginDate: map['lastLoginDate'] as String? ?? '',
      totalLoginDays: map['totalLoginDays'] as int? ?? 0,
      lastResetYear: map['lastResetYear'] as int? ?? DateTime.now().year,
    );
  }

  /// RankData'yı Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'totalXp': totalXp,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLoginDate': lastLoginDate,
      'totalLoginDays': totalLoginDays,
      'lastResetYear': lastResetYear,
    };
  }

  /// Güncellenmiş kopya oluştur
  RankData copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    String? lastLoginDate,
    int? totalLoginDays,
    int? lastResetYear,
  }) {
    return RankData(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      totalLoginDays: totalLoginDays ?? this.totalLoginDays,
      lastResetYear: lastResetYear ?? this.lastResetYear,
    );
  }

  @override
  String toString() {
    return 'RankData(totalXp: $totalXp, streak: $currentStreak, '
        'longest: $longestStreak, lastLogin: $lastLoginDate)';
  }
}

// Backward compatibility: eski streak referansları için alias
typedef StreakData = RankData;
