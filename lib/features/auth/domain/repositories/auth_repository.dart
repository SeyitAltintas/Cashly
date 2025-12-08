import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> registerUser(UserEntity user);
  Future<UserEntity?> loginUser(String id, String pin);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<void> setCurrentUser(String id);
  Future<String?> getLastUserId();
  Future<void> setLastUserId(String id);

  // Biyometrik giriş metodları
  Future<UserEntity?> loginWithBiometric(String userId);
  Future<void> updateBiometricPreference(String userId, bool enabled);
}
