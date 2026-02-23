/// Ödeme yöntemi modeli (Banka Kartı, Kredi Kartı, Nakit vb.)
class PaymentMethod {
  final String id;
  final String name; // "Ziraat Bankası", "Nakit"
  final String type; // "banka", "kredi", "nakit"
  final String? lastFourDigits; // Son 4 hane (opsiyonel)
  final double balance; // Mevcut bakiye
  final double? limit; // Kredi kartı limiti (opsiyonel)
  final int colorIndex; // Kart rengi (0-5 arası)
  final DateTime createdAt;
  final String paraBirimi;
  bool isDeleted;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.lastFourDigits,
    required this.balance,
    this.limit,
    this.colorIndex = 0,
    required this.createdAt,
    this.paraBirimi = 'TRY',
    this.isDeleted = false,
  });

  /// Ödeme yöntemini Map'e dönüştür (veritabanına kayıt için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'lastFourDigits': lastFourDigits,
      'balance': balance,
      'limit': limit,
      'colorIndex': colorIndex,
      'createdAt': createdAt.toIso8601String(),
      'paraBirimi': paraBirimi,
      'isDeleted': isDeleted,
    };
  }

  /// Map'ten PaymentMethod oluştur (veritabanından okuma için)
  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      lastFourDigits: map['lastFourDigits'] as String?,
      balance: (map['balance'] as num).toDouble(),
      limit: (map['limit'] as num?)?.toDouble(),
      colorIndex: map['colorIndex'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      paraBirimi: map['paraBirimi'] as String? ?? 'TRY',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  /// Ödeme yöntemini kopyala (güncelleme için)
  PaymentMethod copyWith({
    String? id,
    String? name,
    String? type,
    String? lastFourDigits,
    double? balance,
    double? limit,
    int? colorIndex,
    DateTime? createdAt,
    String? paraBirimi,
    bool? isDeleted,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      balance: balance ?? this.balance,
      limit: limit ?? this.limit,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      paraBirimi: paraBirimi ?? this.paraBirimi,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Kart tipi görüntü adı
  String get typeDisplayName {
    switch (type) {
      case 'banka':
        return 'Banka Kartı';
      case 'kredi':
        return 'Kredi Kartı';
      case 'nakit':
        return 'Nakit';
      default:
        return type;
    }
  }

  /// Kredi kartı için kalan limit
  double? get remainingLimit {
    if (type == 'kredi' && limit != null) {
      return limit! - balance;
    }
    return null;
  }
}
