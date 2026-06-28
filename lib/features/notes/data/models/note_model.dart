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
        id: map['id'] as String,
        title: (map['title'] as String?) ?? '',
        deltaJson: (map['deltaJson'] as String?) ?? '[]',
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  /// Boş bir not oluşturur — yeni not sayfası açıldığında kullanılır.
  factory NoteModel.empty() => NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        deltaJson: '[]',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
