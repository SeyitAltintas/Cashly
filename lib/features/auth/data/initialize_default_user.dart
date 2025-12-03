import 'package:flutter/foundation.dart';
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
        pin: '8520',
        profileImage: null,
      );

      // Kullanıcıyı kaydet
      await authRepository.registerUser(defaultUser);
      debugPrint(
        '✓ Varsayılan test kullanıcısı oluşturuldu: ${defaultUser.name}',
      );
    } else {
      debugPrint('✓ Varsayılan test kullanıcısı zaten mevcut');
    }
  } catch (e) {
    debugPrint('⚠ Varsayılan kullanıcı oluşturma hatası: $e');
    // Hata olsa bile uygulamayı çalıştırmaya devam et
  }
}
