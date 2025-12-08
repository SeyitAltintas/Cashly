import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _usersBoxName = 'users_box';
  static const String _sessionBoxName = 'session_box';
  static const String _currentUserKey = 'current_user_id';

  Future<Box> _getUsersBox() async {
    if (!Hive.isBoxOpen(_usersBoxName)) {
      return await Hive.openBox(_usersBoxName);
    }
    return Hive.box(_usersBoxName);
  }

  Future<Box> _getSessionBox() async {
    if (!Hive.isBoxOpen(_sessionBoxName)) {
      return await Hive.openBox(_sessionBoxName);
    }
    return Hive.box(_sessionBoxName);
  }

  @override
  Future<void> registerUser(UserEntity user) async {
    final box = await _getUsersBox();
    final userModel = UserModel.fromEntity(user);
    await box.put(user.id, userModel.toMap());
    await setCurrentUser(user.id);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final box = await _getUsersBox();
    final userModel = UserModel.fromEntity(user);
    await box.put(user.id, userModel.toMap());

    // If updating current user, refresh session if needed (though session stores ID which doesn't change)
  }

  @override
  Future<void> deleteUser(String userId) async {
    final box = await _getUsersBox();
    await box.delete(userId);

    // Clear session data for deleted user
    final sessionBox = await _getSessionBox();
    final currentUserId = sessionBox.get(_currentUserKey);
    if (currentUserId == userId) {
      await logout();
    }

    // Clear last_user_id if it was set to the deleted user
    final lastUserId = sessionBox.get('last_user_id');
    if (lastUserId == userId) {
      await sessionBox.delete('last_user_id');
    }
  }

  @override
  Future<UserEntity?> loginUser(String id, String pin) async {
    final box = await _getUsersBox();
    final userData = box.get(id);

    if (userData != null) {
      final user = UserModel.fromMap(Map<String, dynamic>.from(userData));
      if (user.pin == pin) {
        // Update lastLoginAt while preserving all user data
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          pin: user.pin,
          profileImage: user.profileImage,
          createdAt: user.createdAt,
          lastLoginAt: DateTime.now(),
          biometricEnabled: user.biometricEnabled,
          securityQuestion: user.securityQuestion,
          securityAnswer: user.securityAnswer,
        );
        await box.put(id, updatedUser.toMap());
        await setCurrentUser(user.id);
        return updatedUser;
      }
    }
    return null;
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final box = await _getUsersBox();
    final users = <UserEntity>[];

    for (var key in box.keys) {
      final userData = box.get(key);
      if (userData != null) {
        users.add(UserModel.fromMap(Map<String, dynamic>.from(userData)));
      }
    }
    return users;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final sessionBox = await _getSessionBox();
    final currentUserId = sessionBox.get(_currentUserKey);

    if (currentUserId != null) {
      final usersBox = await _getUsersBox();
      final userData = usersBox.get(currentUserId);
      if (userData != null) {
        return UserModel.fromMap(Map<String, dynamic>.from(userData));
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final sessionBox = await _getSessionBox();
    await sessionBox.delete(_currentUserKey);
  }

  @override
  Future<void> setCurrentUser(String id) async {
    final sessionBox = await _getSessionBox();
    await sessionBox.put(_currentUserKey, id);
    await setLastUserId(id);
  }

  @override
  Future<String?> getLastUserId() async {
    final sessionBox = await _getSessionBox();
    return sessionBox.get('last_user_id');
  }

  @override
  Future<void> setLastUserId(String id) async {
    final sessionBox = await _getSessionBox();
    await sessionBox.put('last_user_id', id);
    await sessionBox.flush();
  }

  @override
  Future<UserEntity?> loginWithBiometric(String userId) async {
    final box = await _getUsersBox();
    final userData = box.get(userId);

    if (userData != null) {
      final user = UserModel.fromMap(Map<String, dynamic>.from(userData));
      if (user.biometricEnabled) {
        // Biyometrik aktifse, PIN olmadan giriş yap
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          pin: user.pin,
          profileImage: user.profileImage,
          createdAt: user.createdAt,
          lastLoginAt: DateTime.now(),
          biometricEnabled: user.biometricEnabled,
          securityQuestion: user.securityQuestion,
          securityAnswer: user.securityAnswer,
        );
        await box.put(userId, updatedUser.toMap());
        await setCurrentUser(user.id);
        return updatedUser;
      }
    }
    return null;
  }

  @override
  Future<void> updateBiometricPreference(String userId, bool enabled) async {
    final box = await _getUsersBox();
    final userData = box.get(userId);

    if (userData != null) {
      final user = UserModel.fromMap(Map<String, dynamic>.from(userData));
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        pin: user.pin,
        profileImage: user.profileImage,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
        biometricEnabled: enabled,
        securityQuestion: user.securityQuestion,
        securityAnswer: user.securityAnswer,
      );
      await box.put(userId, updatedUser.toMap());
    }
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    final box = await _getUsersBox();
    for (var key in box.keys) {
      final userData = box.get(key);
      if (userData != null) {
        final user = UserModel.fromMap(Map<String, dynamic>.from(userData));
        if (user.email.toLowerCase() == email.toLowerCase()) {
          return user;
        }
      }
    }
    return null;
  }

  @override
  Future<void> updateUserPin(String userId, String newPin) async {
    final box = await _getUsersBox();
    final userData = box.get(userId);

    if (userData != null) {
      final user = UserModel.fromMap(Map<String, dynamic>.from(userData));
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        pin: newPin,
        profileImage: user.profileImage,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
        biometricEnabled: user.biometricEnabled,
        securityQuestion: user.securityQuestion,
        securityAnswer: user.securityAnswer,
      );
      await box.put(userId, updatedUser.toMap());
    }
  }
}
