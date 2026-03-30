import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      await _firestore.collection('users').doc(firebaseUser.uid).collection('profile').doc('info').set(model.toMap());
      
      // Çoklu hesap desteği ve offline kullanım için cihazın lokal Hive'ına da kaydediyoruz
      await _localHiveRepo.registerUser(finalUser);
      return finalUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("Bu e-posta adresi zaten kullanılıyor.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Geçersiz e-posta adresi.");
      }
      throw Exception("Kayıt hatası: ${e.message}");
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
      await _firebaseAuth.signInWithEmailAndPassword(
        email: localUser.email,
        password: _generateFirebasePassword(pin),
      );
      
      return await _localHiveRepo.loginUser(id, pin);
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Login Error: ${e.message}");
      // Hive PIN verify hatası gibi davransın
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
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).collection('profile').doc('info').get();
        if (doc.exists && doc.data() != null) {
          final userModel = UserModel.fromMap(doc.data()!);
          
          await _localHiveRepo.registerUser(userModel); // create or update on device
          await _localHiveRepo.setCurrentUser(userModel.id);
          
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
    await _firestore.collection('users').doc(user.id).collection('profile').doc('info').set(
      model.toMap(), 
      SetOptions(merge: true),
    );
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
    // Bulut yapısında bile offline session cache çalışsın
    return await _localHiveRepo.getCurrentUser();
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
    // Eğer firebase session açıksa direkt biyometrik okut
    if (firebaseUser != null && firebaseUser.uid == userId) {
       return await _localHiveRepo.loginWithBiometric(userId);
    }
    // Değilse, Firebase oturumu arka planda düşmüş olabilir. PIN istenmesi daha güvenlidir.
    // Ancak offline akışı kesmemek için Hive'a devrediyoruz.
    return await _localHiveRepo.loginWithBiometric(userId);
  }

  @override
  Future<void> updateBiometricPreference(String userId, bool enabled) async {
    await _localHiveRepo.updateBiometricPreference(userId, enabled);
    await _firestore.collection('users').doc(userId).collection('profile').doc('info').set(
      {'biometricEnabled': enabled}, 
      SetOptions(merge: true),
    );
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    return await _localHiveRepo.getUserByEmail(email);
  }

  @override
  Future<void> updateUserPin(String userId, String newPin) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.updatePassword(_generateFirebasePassword(newPin));
      }
      await _localHiveRepo.updateUserPin(userId, newPin);
      await _firestore.collection('users').doc(userId).collection('profile').doc('info').set(
        {'pin': newPin}, 
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception("PIN güncellenemedi: ${e.toString()}");
    }
  }
}
