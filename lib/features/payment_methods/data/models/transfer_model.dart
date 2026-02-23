/// Para transferi için model sınıfı
/// Hem anlık hem de zamanlanmış transferleri destekler
class Transfer {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;
  final String? description;
  final String paraBirimi;

  /// Transfer zamanlanmış mı? (ileri tarihli transfer)
  final bool isScheduled;

  /// Zamanlanmış transfer uygulandı mı?
  final bool isExecuted;

  /// Transfer başarısız mı? (yetersiz bakiye, silinmiş hesap vb.)
  final bool isFailed;

  /// Başarısızlık nedeni
  final String? failureReason;

  Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.description,
    this.paraBirimi = 'TRY',
    this.isScheduled = false,
    this.isExecuted = false,
    this.isFailed = false,
    this.failureReason,
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
      paraBirimi: map['paraBirimi'] ?? 'TRY',
      isScheduled: map['isScheduled'] ?? false,
      isExecuted: map['isExecuted'] ?? false,
      isFailed: map['isFailed'] ?? false,
      failureReason: map['failureReason'],
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
      'paraBirimi': paraBirimi,
      'isScheduled': isScheduled,
      'isExecuted': isExecuted,
      'isFailed': isFailed,
      'failureReason': failureReason,
    };
  }

  /// Transfer tarihinin bugün veya geçmişte olup olmadığını kontrol eder
  bool get isDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transferDate = DateTime(date.year, date.month, date.day);
    return !transferDate.isAfter(today);
  }

  /// Bekleyen zamanlanmış transfer mi? (tarihi gelmiş ama uygulanmamış ve başarısız değil)
  bool get isPending => isScheduled && !isExecuted && !isFailed && isDue;

  /// Kopyalama metodu
  Transfer copyWith({
    String? id,
    String? fromAccountId,
    String? toAccountId,
    double? amount,
    DateTime? date,
    String? description,
    String? paraBirimi,
    bool? isScheduled,
    bool? isExecuted,
    bool? isFailed,
    String? failureReason,
  }) {
    return Transfer(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      paraBirimi: paraBirimi ?? this.paraBirimi,
      isScheduled: isScheduled ?? this.isScheduled,
      isExecuted: isExecuted ?? this.isExecuted,
      isFailed: isFailed ?? this.isFailed,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
