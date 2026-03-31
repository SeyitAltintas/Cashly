/// Varlık modeli - Altın, döviz, kripto vb. varlıkları temsil eder
class Asset {
  final String id;
  final String name;
  final double amount; // Güncel değer (toplam)
  final double quantity;
  final String category;
  final String? type;
  final DateTime lastUpdated;
  final DateTime purchaseDate; // Alış tarihi
  final double purchasePrice; // Alış fiyatı (toplam)
  final String paraBirimi;
  bool isDeleted;

  Asset({
    required this.id,
    required this.name,
    required this.amount,
    this.quantity = 1.0,
    required this.category,
    this.type,
    required this.lastUpdated,
    DateTime? purchaseDate,
    double? purchasePrice,
    this.paraBirimi = 'TRY',
    this.isDeleted = false,
  }) : purchaseDate = purchaseDate ?? lastUpdated,
       purchasePrice = purchasePrice ?? amount;

  /// Birim alış fiyatını hesaplar
  double get unitPurchasePrice => quantity > 0 ? purchasePrice / quantity : 0;

  /// Birim güncel fiyatı hesaplar
  double get unitCurrentPrice => quantity > 0 ? amount / quantity : 0;

  /// Kar/Zarar tutarını hesaplar
  double get profitLoss => amount - purchasePrice;

  /// Kar/Zarar yüzdesini hesaplar
  double get profitLossPercentage =>
      purchasePrice != 0 ? ((amount - purchasePrice) / purchasePrice) * 100 : 0;

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
      'purchaseDate': purchaseDate.toIso8601String(),
      'purchasePrice': purchasePrice,
      'paraBirimi': paraBirimi,
      'isDeleted': isDeleted,
    };
  }

  /// Map'ten Asset oluştur (veritabanından okuma için)
  /// Geriye dönük uyumluluk: Eski kayıtlarda purchaseDate/purchasePrice yoksa
  /// lastUpdated ve amount varsayılan olarak kullanılır
  factory Asset.fromMap(Map<String, dynamic> map) {
    final lastUpdated = map['lastUpdated'] != null
        ? DateTime.tryParse(map['lastUpdated'].toString()) ?? DateTime.now()
        : DateTime.now();
    final amount = (map['amount'] as num?)?.toDouble() ?? 0.0;

    return Asset(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name']?.toString() ?? 'İsimsiz Varlık',
      amount: amount,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      category: map['category']?.toString() ?? 'Diğer',
      type: map['type']?.toString(),
      lastUpdated: lastUpdated,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.tryParse(map['purchaseDate'].toString()) ?? lastUpdated
          : lastUpdated, // Geriye dönük uyumluluk
      purchasePrice:
          (map['purchasePrice'] as num?)?.toDouble() ??
          amount, // Geriye dönük uyumluluk
      paraBirimi: map['paraBirimi']?.toString() ?? 'TRY',
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  /// Güncellenmiş kopyasını oluşturur (immutable pattern)
  Asset copyWith({
    String? id,
    String? name,
    double? amount,
    double? quantity,
    String? category,
    String? type,
    DateTime? lastUpdated,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? paraBirimi,
    bool? isDeleted,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      type: type ?? this.type,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      paraBirimi: paraBirimi ?? this.paraBirimi,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
