class UserEntity {
  final String id;
  final String name;
  final String email;
  final String pin;
  final String? profileImage;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.pin,
    this.profileImage,
  });
}
