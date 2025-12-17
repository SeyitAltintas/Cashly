/// Para transferi için model sınıfı
class Transfer {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;
  final String? description;

  Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.description,
  });

  /// Map'ten Transfer nesnesi oluşturur
  factory Transfer.fromMap(Map<String, dynamic> map) {
    return Transfer(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fromAccountId: map['fromAccountId'] ?? '',
      toAccountId: map['toAccountId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      description: map['description'],
    );
  }

  /// Transfer nesnesini Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  /// Kopyalama metodu
  Transfer copyWith({
    String? id,
    String? fromAccountId,
    String? toAccountId,
    double? amount,
    DateTime? date,
    String? description,
  }) {
    return Transfer(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
