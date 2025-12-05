class Asset {
  final String id;
  final String name;
  final double amount;
  final double quantity;
  final String category;
  final String? type;
  final DateTime lastUpdated;
  bool isDeleted;

  Asset({
    required this.id,
    required this.name,
    required this.amount,
    this.quantity = 1.0,
    required this.category,
    this.type,
    required this.lastUpdated,
    this.isDeleted = false,
  });

  /// Varlığı Map'e dönüştür (veritabanına kayıt için)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'quantity': quantity,
      'category': category,
      'type': type,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Map'ten Asset oluştur (veritabanından okuma için)
  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      category: map['category'] as String,
      type: map['type'] as String?,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}
