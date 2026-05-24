class UserEntity {
  final String id;
  final String name;
  final String email;
  final String pin;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool biometricEnabled;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.pin,
    this.profileImage,
    required this.createdAt,
    this.lastLoginAt,
    this.biometricEnabled = false,
  });
}
