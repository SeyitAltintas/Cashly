import '../domain/entities/user_entity.dart';
import 'repositories/auth_repository_impl.dart';

/// Varsayılan test kullanıcısını veritabanına ekler
/// Bu kullanıcı geçici olarak test amaçlıdır ve daha sonra silinebilir
Future<void> initializeDefaultUser() async {
  try {
    final authRepository = AuthRepositoryImpl();

    // Tüm kullanıcıları kontrol et
    final allUsers = await authRepository.getAllUsers();

    // E-posta adresi ile kullanıcı var mı kontrol et
    const defaultEmail = 'seyitaltintas8@gmail.com';
    final userExists = allUsers.any((user) => user.email == defaultEmail);

    if (!userExists) {
      // Varsayılan kullanıcıyı oluştur
      final defaultUser = UserEntity(
        id: defaultEmail, // E-posta adresini ID olarak kullan
        name: 'Seyit Altıntaş',
        email: defaultEmail,
        pin: '2580',
        profileImage: null,
        createdAt: DateTime.now(),
        biometricEnabled: false,
        securityQuestion: 'İlk evcil hayvanının adı nedir?',
        securityAnswer: 'pamuk', // Cevap normalize edilmiş halde (küçük harf)
      );

      // Kullanıcıyı kaydet
      await authRepository.registerUser(defaultUser);
    } else {
      // Kullanıcı mevcut, güvenlik sorusu eksik mi kontrol et
      final existingUser = allUsers.firstWhere(
        (user) => user.email == defaultEmail,
      );
      if (existingUser.securityQuestion == null ||
          existingUser.securityAnswer == null) {
        // Güvenlik sorusu eksikse güncelle
        final updatedUser = UserEntity(
          id: existingUser.id,
          name: existingUser.name,
          email: existingUser.email,
          pin: existingUser.pin,
          profileImage: existingUser.profileImage,
          createdAt: existingUser.createdAt,
          lastLoginAt: existingUser.lastLoginAt,
          biometricEnabled: existingUser.biometricEnabled,
          securityQuestion: 'İlk evcil hayvanının adı nedir?',
          securityAnswer: 'pamuk', // Cevap normalize edilmiş halde (küçük harf)
        );
        await authRepository.updateUser(updatedUser);
      }
    }
  } catch (e) {
    // Hata olsa bile uygulamayı çalıştırmaya devam et
  }
}
