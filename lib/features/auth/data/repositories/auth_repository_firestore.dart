import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../features/streak/data/services/streak_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_repository_impl.dart';

class AuthRepositoryFirestore implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepositoryImpl _localHiveRepo = AuthRepositoryImpl();
  @override
  Future<UserEntity> registerUser(UserEntity user) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.pin,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception("Kullanıcı oluşturulamadı.");

      // Firestore kuralları için FirebaseAuth tarafından üretilen UID'yi almalıyız
      final finalUser = UserEntity(
        id: firebaseUser.uid,
        name: user.name,
        email: user.email,
        pin: user.pin,
        profileImage: user.profileImage,
        createdAt: user.createdAt,
        biometricEnabled: user.biometricEnabled,
      );

      final model = UserModel.fromEntity(finalUser);
      try {
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .collection('profile')
            .doc('info')
            .set(model.toMap())
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint("Firestore'a kullanıcı profili yazılamadı: $e");
        // Firestore'a yazılamasa da kullanıcı Firebase Auth ve Hive'da oluşturulmuş kabul edilsin.
        // Hata fırlatmıyoruz ki kayıt işlemi offline modda iptal olmasın.
      }

      // Çoklu hesap desteği ve offline kullanım için cihazın lokal Hive'ına da kaydediyoruz
      await _localHiveRepo.registerUser(finalUser);
      return finalUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(
          "Bu e-posta adresi zaten kullanılıyor. Lütfen farklı bir tane seçin veya giriş yapın.",
        );
      } else if (e.code == 'invalid-email') {
        throw Exception("Geçersiz e-posta adresi.");
      }
      throw Exception("Kayıt hatası: ${e.message}");
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('configuration_not_found') ||
          errorStr.contains('recaptcha') ||
          errorStr.contains('internal error')) {
        throw Exception(
          "Cihaz güvenliği doğrulanamadı. (Lütfen ağ bağlantınızı ve Firebase API konfigürasyonunuzu kontrol edin.)",
        );
      }
      throw Exception("Bir hata oluştu: $e");
    }
  }

  @override
  Future<UserEntity?> loginUser(String id, String pin) async {
    final localUsers = await _localHiveRepo.getAllUsers();
    final localUserIndex = localUsers.indexWhere((u) => u.id == id);

    if (localUserIndex == -1) {
      throw Exception("Kullanıcı bulunamadı");
    }

    final localUser = localUsers[localUserIndex];

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: localUser.email,
        password: pin,
      );

      // Firebase'in gerçek UID'sini alıyoruz.
      // Hive'daki eski UUID bununla eşleşmiyorsa, Firestore'un kural denetimi
      // request.auth.uid != userId nedeniyle permission-denied fırlatacaktır.
      // Cözüm: Hive kaydını her giriste Firebase UID ile eşitleyelim.
      final firebaseUid = credential.user?.uid;
      if (firebaseUid != null && firebaseUid != localUser.id) {
        debugPrint(
          "loginUser: Hive UID ('${localUser.id}') != Firebase UID ('$firebaseUid'). Güncelleniyor...",
        );
        final correctedUser = UserEntity(
          id: firebaseUid,
          name: localUser.name,
          email: localUser.email,
          pin: localUser.pin,
          profileImage: localUser.profileImage,
          createdAt: localUser.createdAt,
          biometricEnabled: localUser.biometricEnabled,
        );
        await _localHiveRepo.registerUser(correctedUser);
        await _localHiveRepo.setCurrentUser(firebaseUid);
        try {
          await _localHiveRepo.deleteUser(localUser.id);
        } catch (_) {}

        // UID düzeltmesinin ardından bulut verisini hemen çek
        await CloudSyncService.syncAllUserData(firebaseUid);
        return correctedUser;
      }

      final loggedInUser = await _localHiveRepo.loginUser(id, pin);
      if (loggedInUser != null) {
        await CloudSyncService.syncAllUserData(loggedInUser.id);
        await StreakService.syncFromCloud(loggedInUser.id);
      }
      return loggedInUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Login Error: ${e.message}");
      return null;
    }
  }

  @override
  Future<UserEntity?> loginByEmail(String email, String pin) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: pin,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        // Cihaz değiştiğinde profili buluttan çek ve lokale yaz
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .collection('profile')
            .doc('info')
            .get();
        if (doc.exists && doc.data() != null) {
          final userModel = UserModel.fromMap(doc.data()!);

          await _localHiveRepo.registerUser(
            userModel,
          ); // create or update on device
          await _localHiveRepo.setCurrentUser(userModel.id);
          await CloudSyncService.syncAllUserData(userModel.id);
          await StreakService.syncFromCloud(userModel.id);
          return userModel;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase loginByEmail Error: ${e.message}");
      return null;
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _localHiveRepo.updateUser(user);
    final model = UserModel.fromEntity(user);
    await _firestore
        .collection('users')
        .doc(user.id)
        .collection('profile')
        .doc('info')
        .set(model.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        // Veritabanı verilerinin silindiği varsayılır (SettingsRepository tarafında yapılıyor)
        await user.delete();
      }
      await _localHiveRepo.deleteUser(userId);
    } catch (e) {
      debugPrint("Firebase Account Delete Error: $e");
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    return await _localHiveRepo.getAllUsers();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Bulut yapısında bile offline session auth cache çalışsın
    final user = await _localHiveRepo.getCurrentUser();

    // Eğer ortada geçerli bir kullanıcı varsa, in-memory cache olan
    // CacheService'in uygulama açılır açılmaz Firestore'dan dolması ŞARTTIR.
    if (user != null) {
      try {
        await CloudSyncService.syncAllUserData(
          user.id,
        ).timeout(const Duration(seconds: 15));
        await StreakService.syncFromCloud(user.id);
      } catch (e) {
        debugPrint('getCurrentUser CloudSync Hatasi: $e');
      }
    }

    return user;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _localHiveRepo.logout();
  }

  @override
  Future<void> setCurrentUser(String id) async {
    await _localHiveRepo.setCurrentUser(id);
  }

  @override
  Future<String?> getLastUserId() async {
    return await _localHiveRepo.getLastUserId();
  }

  @override
  Future<void> setLastUserId(String id) async {
    await _localHiveRepo.setLastUserId(id);
  }

  @override
  Future<UserEntity?> loginWithBiometric(String userId) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null && firebaseUser.uid == userId) {
      final user = await _localHiveRepo.loginWithBiometric(userId);
      if (user != null) {
        await CloudSyncService.syncAllUserData(user.id);
        await StreakService.syncFromCloud(user.id);
      }
      return user;
    }
    // Firebase oturumu düşmüşse Hive'dan döndür ve yine de sync dene
    final user = await _localHiveRepo.loginWithBiometric(userId);
    if (user != null) {
      await CloudSyncService.syncAllUserData(user.id);
      await StreakService.syncFromCloud(user.id);
    }
    return user;
  }

  @override
  Future<void> updateBiometricPreference(String userId, bool enabled) async {
    await _localHiveRepo.updateBiometricPreference(userId, enabled);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('info')
        .set({'biometricEnabled': enabled}, SetOptions(merge: true));
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    // Lokal Hive cache'de ara (aynı cihaz / offline).
    return await _localHiveRepo.getUserByEmail(email);
  }

  @override
  Future<void> sendPinResetEmailLink(String email) async {
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://cashly-c0acc.firebaseapp.com/__/auth/action?email=$email',
        handleCodeInApp: true,
        androidPackageName: 'com.seyitaltintas.cashly',
        androidInstallApp: true,
        androidMinimumVersion: "1",
      );

      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
    } catch (e) {
      throw Exception("E-posta bağlantısı gönderilemedi: ${e.toString()}");
    }
  }

  @override
  Future<bool> verifyEmailLinkAndSetPin(
    String email,
    String emailLink,
    String newPin,
  ) async {
    try {
      if (_firebaseAuth.isSignInWithEmailLink(emailLink)) {
        // Oturum aç
        final credential = await _firebaseAuth.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );

        final user = credential.user;
        if (user != null) {
          // Yeni şifreyi ayarla
          await user.updatePassword(newPin);

          // Locale kaydet
          await _localHiveRepo.updateUserPin(user.uid, newPin);
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception("E-posta bağlantısı doğrulanamadı: ${e.toString()}");
    }
  }

  @override
  Future<void> updateUserPin(String userId, String newPin) async {
    try {
      // 1. Firebase Auth şifresi güncelle
      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.updatePassword(newPin);
      }
      // 2. Lokal Hive güncelle
      await _localHiveRepo.updateUserPin(userId, newPin);
      // NOT: newPin Firestore'a kasıtlı olarak yazılmıyor.
      // PIN Firebase Auth şifresine encode edilmiş durumda, ayrıca saklamak güvenlik riski.
    } catch (e) {
      throw Exception("PIN güncellenemedi: ${e.toString()}");
    }
  }
}
