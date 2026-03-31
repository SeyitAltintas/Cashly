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
    super.securityQuestion,
    super.securityAnswer,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Kullanıcı',
      email: map['email']?.toString() ?? '',
      pin: map['pin']?.toString() ?? '',
      profileImage: map['profileImage']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(), // Fallback for existing users
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'].toString())
          : null,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
      securityQuestion: map['securityQuestion']?.toString(),
      securityAnswer: map['securityAnswer']?.toString(),
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
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
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
      securityQuestion: entity.securityQuestion,
      securityAnswer: entity.securityAnswer,
    );
  }
}
