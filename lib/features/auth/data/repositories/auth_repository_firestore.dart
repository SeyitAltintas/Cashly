import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../features/streak/data/services/streak_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_repository_impl.dart';

/// Firebase Authentication kullanan Auth Repository implementasyonu
///
/// NOT: Cashly UI'da girişler 4-6 haneli PIN ile yapıldığı için
/// Firebase Auth'ta mecburi olan güçlü şifre kuralını atlamak adına
/// PIN'in arkasına statik bir "padding" eklenerek güçlü bir şifre elde ediliyor.
/// Böylece "Hesap Oluştur / E-mail + PIN ile bulut senkronize" deneyimi
/// tamamen şeffaf çalışıyor ve AuthRules da "request.auth.uid" ile korunuyor.
class AuthRepositoryFirestore implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepositoryImpl _localHiveRepo = AuthRepositoryImpl();

  String _generateFirebasePassword(String pin) {
    return 'CASHLY_${pin}_SECURE_2026';
  }

  @override
  Future<UserEntity> registerUser(UserEntity user) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: _generateFirebasePassword(user.pin),
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
        securityQuestion: user.securityQuestion,
        securityAnswer: user.securityAnswer,
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
        password: _generateFirebasePassword(pin),
      );

      // Firebase'in gerçek UID'sini alıyoruz.
      // Hive'daki eski UUID bununla eşleşmiyorsa, Firestore'un kural denetimi
      // request.auth.uid != userId nedeniyle permission-denied fırlatacaktır.
      // Cözüm: Hive kaydını her giriste Firebase UID ile eşitleyelim.
      final firebaseUid = credential.user?.uid;
      if (firebaseUid != null && firebaseUid != localUser.id) {
        debugPrint(
          "loginUser: Hive UID ('${localUser.id}') != Firebase UID ('$firebaseUid'). Güncelleniyor..."
        );
        final correctedUser = UserEntity(
          id: firebaseUid,
          name: localUser.name,
          email: localUser.email,
          pin: localUser.pin,
          profileImage: localUser.profileImage,
          createdAt: localUser.createdAt,
          biometricEnabled: localUser.biometricEnabled,
          securityQuestion: localUser.securityQuestion,
          securityAnswer: localUser.securityAnswer,
        );
        await _localHiveRepo.registerUser(correctedUser);
        await _localHiveRepo.setCurrentUser(firebaseUid);
        try { await _localHiveRepo.deleteUser(localUser.id); } catch (_) {}

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
        password: _generateFirebasePassword(pin),
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
        await CloudSyncService.syncAllUserData(user.id)
            .timeout(const Duration(seconds: 15));
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
    // Önce lokal Hive'da ara (hızlı, offline)
    final localUser = await _localHiveRepo.getUserByEmail(email);
    if (localUser != null) return localUser;

    // Hive'da bulunamadıysa Firestore'dan ara (yeni cihaz / yeniden kurulum)
    try {
      final snapshot = await _firestore
          .collection('users')
          .get()
          .timeout(const Duration(seconds: 10));

      for (final userDoc in snapshot.docs) {
        final profileSnap = await userDoc.reference
            .collection('profile')
            .doc('info')
            .get()
            .timeout(const Duration(seconds: 5));

        if (profileSnap.exists && profileSnap.data() != null) {
          final data = profileSnap.data()!;
          if ((data['email'] as String?)?.toLowerCase() ==
              email.toLowerCase()) {
            final userModel = UserModel.fromMap(data);
            // Lokale kaydet ki bir sonraki seferde Hive'dan hızlı gelsin
            await _localHiveRepo.registerUser(userModel);
            return userModel;
          }
        }
      }
    } catch (e) {
      debugPrint('getUserByEmail Firestore fallback hatası: $e');
    }
    return null;
  }

  @override
  Future<void> updateUserPin(String userId, String newPin) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.updatePassword(_generateFirebasePassword(newPin));
      }
      await _localHiveRepo.updateUserPin(userId, newPin);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('info')
          .set({'pin': newPin}, SetOptions(merge: true));
    } catch (e) {
      throw Exception("PIN güncellenemedi: ${e.toString()}");
    }
  }
}
