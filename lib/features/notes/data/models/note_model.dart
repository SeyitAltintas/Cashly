import 'dart:math';

/// Not modeli — Hive'da JSON string olarak saklanır.
///
/// Tip adapter kullanmak yerine `Map<String, dynamic>` pattern'i tercih edildi.
/// Bu yaklaşım projedeki [NotificationSettings] ile tutarlıdır.
class NoteModel {
  const NoteModel({
    required this.id,
    required this.deltaJson,
    this.title = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;

  /// flutter_quill Delta formatındaki JSON string
  final String deltaJson;

  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel copyWith({
    String? title,
    String? deltaJson,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      deltaJson: deltaJson ?? this.deltaJson,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'deltaJson': deltaJson,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
        id: (map['id'] as String?) ?? '',   // EC-16: null-safe cast; '' → catch'e düşer
        title: (map['title'] as String?) ?? '',
        deltaJson: (map['deltaJson'] as String?) ?? '[]',
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  /// Boş bir not oluşturur — yeni not sayfası açıldığında kullanılır.
  /// Benzersiz ID: mikrosaniye + 4 haneli random suffix → çakışmaz.
  factory NoteModel.empty() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rnd = Random().nextInt(9000) + 1000; // 1000-9999
    return NoteModel(
      id: '${ts}_$rnd',
      deltaJson: '[]',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
