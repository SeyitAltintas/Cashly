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
    this.snippet = '',
    this.searchableText = '',
    this.color,
    this.isPinned = false,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String title;

  /// flutter_quill Delta formatındaki JSON string
  final String deltaJson;

  /// Liste görünümünde gösterilecek kısa özet metin
  final String snippet;

  /// Arama için önceden hesaplanmış düz metin (küçük harf, Türkçe uyumlu).
  /// Not kaydedilirken repository tarafından doldurulur.
  /// Eski Hive kayıtlarında bu alan yoksa boş string olarak okunur.
  final String searchableText;

  /// Notun özel arka plan rengi (null ise varsayılan tema rengi)
  final int? color;

  final bool isPinned;

  final String? categoryId;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  NoteModel copyWith({
    String? title,
    String? deltaJson,
    String? snippet,
    String? searchableText,
    int? color,
    bool clearColor = false,
    bool? isPinned,
    String? categoryId,
    bool clearCategory = false,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      deltaJson: deltaJson ?? this.deltaJson,
      snippet: snippet ?? this.snippet,
      searchableText: searchableText ?? this.searchableText,
      color: clearColor ? null : (color ?? this.color),
      isPinned: isPinned ?? this.isPinned,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'deltaJson': deltaJson,
        'snippet': snippet,
        'searchableText': searchableText,
        'color': color,
        'isPinned': isPinned,
        'categoryId': categoryId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
        id: (map['id'] as String?) ?? '',
        title: (map['title'] as String?) ?? '',
        deltaJson: (map['deltaJson'] as String?) ?? '[]',
        snippet: (map['snippet'] as String?) ?? '',
        // Eski kayıtlarda bu alan yoktur → boş string ile güvenli fallback
        searchableText: (map['searchableText'] as String?) ?? '',
        color: map['color'] as int?,
        isPinned: (map['isPinned'] as bool?) ?? false,
        categoryId: map['categoryId'] as String? ??
            ((map['categoryIds'] as List<dynamic>?)?.isNotEmpty == true
                ? (map['categoryIds'] as List<dynamic>).first.toString()
                : null),
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        deletedAt: map['deletedAt'] != null
            ? DateTime.tryParse(map['deletedAt'].toString())
            : null,
      );

  factory NoteModel.empty() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rnd = Random().nextInt(9000) + 1000;
    return NoteModel(
      id: '${ts}_$rnd',
      deltaJson: '[]',
      snippet: '',
      color: null,
      isPinned: false,
      categoryId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
    );
  }
}
