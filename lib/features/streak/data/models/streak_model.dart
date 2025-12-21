/// Seri (Streak) veri modeli
/// Kullanıcının günlük giriş serisini takip eder
class StreakData {
  /// Mevcut seri sayısı
  final int currentStreak;

  /// En uzun seri kaydı
  final int longestStreak;

  /// Son giriş tarihi (YYYY-MM-DD formatında)
  final String lastLoginDate;

  /// Toplam giriş günü sayısı
  final int totalLoginDays;

  /// Kazanılan rozet ID'leri
  final List<String> earnedBadges;

  /// Kalan dondurucu (freeze) sayısı
  /// Bir gün atlanırsa seriyi korumak için kullanılır
  final int freezeCount;

  /// Bugün dondurucu kullanıldı mı
  final bool usedFreezeToday;

  /// Toplam kullanılan dondurucu sayısı
  final int totalFreezesUsed;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastLoginDate,
    required this.totalLoginDays,
    required this.earnedBadges,
    this.freezeCount = 1, // Varsayılan 1 dondurucu ile başla
    this.usedFreezeToday = false,
    this.totalFreezesUsed = 0,
  });

  /// Boş/yeni kullanıcı için varsayılan değerler
  factory StreakData.empty() {
    return const StreakData(
      currentStreak: 0,
      longestStreak: 0,
      lastLoginDate: '',
      totalLoginDays: 0,
      earnedBadges: [],
      freezeCount: 1, // Yeni kullanıcıya 1 dondurucu ver
      usedFreezeToday: false,
      totalFreezesUsed: 0,
    );
  }

  /// Map'ten StreakData oluştur
  factory StreakData.fromMap(Map<String, dynamic> map) {
    return StreakData(
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastLoginDate: map['lastLoginDate'] as String? ?? '',
      totalLoginDays: map['totalLoginDays'] as int? ?? 0,
      earnedBadges: List<String>.from(map['earnedBadges'] ?? []),
      freezeCount: map['freezeCount'] as int? ?? 1,
      usedFreezeToday: map['usedFreezeToday'] as bool? ?? false,
      totalFreezesUsed: map['totalFreezesUsed'] as int? ?? 0,
    );
  }

  /// StreakData'yı Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLoginDate': lastLoginDate,
      'totalLoginDays': totalLoginDays,
      'earnedBadges': earnedBadges,
      'freezeCount': freezeCount,
      'usedFreezeToday': usedFreezeToday,
      'totalFreezesUsed': totalFreezesUsed,
    };
  }

  /// Güncellenmiş kopya oluştur
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastLoginDate,
    int? totalLoginDays,
    List<String>? earnedBadges,
    int? freezeCount,
    bool? usedFreezeToday,
    int? totalFreezesUsed,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      totalLoginDays: totalLoginDays ?? this.totalLoginDays,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      freezeCount: freezeCount ?? this.freezeCount,
      usedFreezeToday: usedFreezeToday ?? this.usedFreezeToday,
      totalFreezesUsed: totalFreezesUsed ?? this.totalFreezesUsed,
    );
  }

  /// Dondurucu kullanılabilir mi?
  bool get canUseFreeze => freezeCount > 0;

  @override
  String toString() {
    return 'StreakData(current: $currentStreak, longest: $longestStreak, '
        'lastLogin: $lastLoginDate, totalDays: $totalLoginDays, '
        'freezeCount: $freezeCount)';
  }
}
