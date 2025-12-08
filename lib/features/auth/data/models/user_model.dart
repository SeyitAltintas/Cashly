import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.pin,
    super.profileImage,
    required super.createdAt,
    super.lastLoginAt,
    super.biometricEnabled = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      pin: map['pin'] as String,
      profileImage: map['profileImage'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(), // Fallback for existing users
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pin': pin,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'biometricEnabled': biometricEnabled,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      pin: entity.pin,
      profileImage: entity.profileImage,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      biometricEnabled: entity.biometricEnabled,
    );
  }
}
