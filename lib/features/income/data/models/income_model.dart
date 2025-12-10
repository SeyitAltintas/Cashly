/// Gelir verisi için model sınıfı
class Income {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime date;
  bool isDeleted;

  Income({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
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
    bool? isDeleted,
  }) {
    return Income(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
