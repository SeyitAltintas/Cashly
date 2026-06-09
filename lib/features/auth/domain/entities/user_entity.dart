class UserEntity {
  final String id;
  final String name;
  final String email;
  final String pin;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool biometricEnabled;
  final String? activeSessionId; // Tekil oturum kontrolü için

  UserEntity({
    required this.id,
    required String name,
    required this.email,
    required this.pin,
    this.profileImage,
    required this.createdAt,
    this.lastLoginAt,
    this.biometricEnabled = false,
    this.activeSessionId,
  }) : name = _formatName(name);

  static String _formatName(String name) {
    if (name.trim().isEmpty) return name;
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return '';
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
