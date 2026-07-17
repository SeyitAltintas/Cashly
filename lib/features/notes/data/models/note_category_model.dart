import 'dart:math';

class NoteCategoryModel {
  const NoteCategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  NoteCategoryModel copyWith({
    String? name,
  }) {
    return NoteCategoryModel(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NoteCategoryModel.fromMap(Map<String, dynamic> map) => NoteCategoryModel(
        id: (map['id'] as String?) ?? '',
        name: (map['name'] as String?) ?? '',
        createdAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() 
            : DateTime.now(),
      );

  factory NoteCategoryModel.create({required String name}) {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rnd = Random().nextInt(9000) + 1000;
    return NoteCategoryModel(
      id: '${ts}_$rnd',
      name: name,
      createdAt: DateTime.now(),
    );
  }
}
