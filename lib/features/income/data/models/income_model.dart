/// Gelir verisi için model sınıfı
class Income {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime date;
  final String? paymentMethodId; // Hangi hesaba eklendi?
  final String paraBirimi;
  bool isDeleted;

  Income({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    this.paymentMethodId,
    this.paraBirimi = 'TRY',
    this.isDeleted = false,
  });

  /// Map'ten Income nesnesi oluşturur
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] ?? DateTime.now().toString(),
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Diğer',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      paymentMethodId: map['paymentMethodId'],
      paraBirimi: map['paraBirimi'] ?? 'TRY',
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  /// Income nesnesini Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'paraBirimi': paraBirimi,
      'isDeleted': isDeleted,
    };
  }

  /// Kopyalama metodu
  Income copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    DateTime? date,
    String? paymentMethodId,
    String? paraBirimi,
    bool? isDeleted,
  }) {
    return Income(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paraBirimi: paraBirimi ?? this.paraBirimi,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
