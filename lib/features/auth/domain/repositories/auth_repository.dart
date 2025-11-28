import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> registerUser(UserEntity user);
  Future<UserEntity?> loginUser(String id, String pin);
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<void> setCurrentUser(String id);
  Future<String?> getLastUserId();
  Future<void> setLastUserId(String id);
}
