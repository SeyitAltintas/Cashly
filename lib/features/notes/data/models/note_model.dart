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
    this.color,
    this.isPinned = false,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;

  /// flutter_quill Delta formatındaki JSON string
  final String deltaJson;

  /// Notun özel arka plan rengi (null ise varsayılan tema rengi)
  final int? color;
  
  final bool isPinned;

  /// Notun dahil olduğu kategori (etiket) ID'si
  final String? categoryId;

  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel copyWith({
    String? title,
    String? deltaJson,
    int? color,
    bool clearColor = false,
    bool? isPinned,
    String? categoryId,
    bool clearCategory = false,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      deltaJson: deltaJson ?? this.deltaJson,
      color: clearColor ? null : (color ?? this.color),
      isPinned: isPinned ?? this.isPinned,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'deltaJson': deltaJson,
        'color': color,
        'isPinned': isPinned,
        'categoryId': categoryId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
        id: (map['id'] as String?) ?? '',
        title: (map['title'] as String?) ?? '',
        deltaJson: (map['deltaJson'] as String?) ?? '[]',
        color: map['color'] as int?,
        isPinned: (map['isPinned'] as bool?) ?? false,
        categoryId: map['categoryId'] as String? ?? 
            ((map['categoryIds'] as List<dynamic>?)?.isNotEmpty == true 
                ? (map['categoryIds'] as List<dynamic>).first.toString() 
                : null),
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  factory NoteModel.empty() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rnd = Random().nextInt(9000) + 1000;
    return NoteModel(
      id: '${ts}_$rnd',
      deltaJson: '[]',
      color: null,
      isPinned: false,
      categoryId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
