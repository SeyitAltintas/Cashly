import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _usersBoxName = 'users_box';
  static const String _sessionBoxName = 'session_box';
  static const String _currentUserKey = 'current_user_id';

  Future<Box> _getUsersBox() async {
    if (!Hive.isBoxOpen(_usersBoxName)) {
      // FIX-9: Yerel hafızadaki PIN sızıntısını kapatmak için AES şifreli kutu kullanıyoruz
      return await SecureStorageService.openSecureBox(_usersBoxName);
    }
    return Hive.box(_usersBoxName);
  }

  Future<Box> _getSessionBox() async {
    if (!Hive.isBoxOpen(_sessionBoxName)) {
      // FIX-9: Session bilgileri de güvenli kutuda tutulmalı
      return await SecureStorageService.openSecureBox(_sessionBoxName);
    }
    return Hive.box(_sessionBoxName);
  }

  @override
  Future<UserEntity> registerUser(UserEntity user) async {
    final box = await _getUsersBox();
    final userModel = UserModel.fromEntity(user);
    await box.put(user.id, userModel.toMap());
    await setCurrentUser(user.id);
    return user;
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
        );
        await box.put(id, updatedUser.toMap());
        await setCurrentUser(user.id);
        return updatedUser;
      }
    }
    return null;
  }

  @override
  Future<UserEntity?> loginByEmail(String email, String pin) async {
    final box = await _getUsersBox();
    for (var key in box.keys) {
      final userData = box.get(key);
      if (userData != null) {
        final user = UserModel.fromMap(Map<String, dynamic>.from(userData));
        if (user.email.toLowerCase() == email.toLowerCase() &&
            user.pin == pin) {
          return await loginUser(user.id, pin);
        }
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
        final userModel = UserModel.fromMap(
          Map<String, dynamic>.from(userData),
        );
        // FIX-11: PIN sızıntısını önlemek için, UI'a gönderilen liste hafızasında
        // açık PIN kodlarını temizliyoruz.
        users.add(
          UserModel(
            id: userModel.id,
            name: userModel.name,
            email: userModel.email,
            pin: '', // PIN RAM'den gizleniyor
            profileImage: userModel.profileImage,
            createdAt: userModel.createdAt,
            lastLoginAt: userModel.lastLoginAt,
            biometricEnabled: userModel.biometricEnabled,
            activeSessionId: userModel.activeSessionId,
          ),
        );
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
      );
      await box.put(userId, updatedUser.toMap());
    }
  }

  @override
  Future<void> sendPinResetEmailLink(String email) async {
    // Sadece Firestore versiyonunda implemente edilir.
  }

  @override
  Future<bool> verifyEmailLinkAndSetPin(
    String email,
    String emailLink,
    String newPin,
  ) async {
    // Sadece Firestore versiyonunda implemente edilir.
    return false;
  }

  // --- GÜVENLİK YAMASI: Offline Brute-force Koruma Metodları ---
  Future<int> getFailedOfflineAttempts(String userId) async {
    final sessionBox = await _getSessionBox();
    return sessionBox.get('failed_attempts_$userId', defaultValue: 0) as int;
  }

  Future<void> incrementFailedOfflineAttempts(String userId) async {
    final sessionBox = await _getSessionBox();
    final current = await getFailedOfflineAttempts(userId);
    await sessionBox.put('failed_attempts_$userId', current + 1);
    if (current + 1 >= 5) {
      // 5 başarısız denemede 5 dakika kilitle
      await sessionBox.put(
        'lockout_until_$userId',
        DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
      );
    }
  }

  Future<void> resetFailedOfflineAttempts(String userId) async {
    final sessionBox = await _getSessionBox();
    await sessionBox.delete('failed_attempts_$userId');
    await sessionBox.delete('lockout_until_$userId');
  }

  Future<DateTime?> getOfflineLockoutUntil(String userId) async {
    final sessionBox = await _getSessionBox();
    final dateStr = sessionBox.get('lockout_until_$userId');
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }
  // -------------------------------------------------------------

  /// Çevrimdışı TTL kontrolü için son online doğrulama zamanını kaydeder
  Future<void> updateLastOnlineSync(String userId) async {
    final sessionBox = await _getSessionBox();
    await sessionBox.put(
      'last_online_sync_$userId',
      DateTime.now().toIso8601String(),
    );
  }

  /// Çevrimdışı TTL kontrolü için son online doğrulama zamanını getirir
  Future<DateTime?> getLastOnlineSync(String userId) async {
    final sessionBox = await _getSessionBox();
    final dateStr = sessionBox.get('last_online_sync_$userId');
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }
}
