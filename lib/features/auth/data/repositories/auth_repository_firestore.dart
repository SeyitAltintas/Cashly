import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/exceptions/session_expired_exception.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../features/streak/data/services/streak_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_repository_impl.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import 'package:bcrypt/bcrypt.dart';


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
        // FIX-1: toFirestoreMap() kullanılıyor — PIN asla Firestore'a yazılmaz.
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .collection('profile')
            .doc('info')
            .set(model.toFirestoreMap())
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint("Firestore'a kullanıcı profili yazılamadı: $e");
        // Firestore'a yazılamasa da kullanıcı Firebase Auth ve Hive'da oluşturulmuş kabul edilsin.
        // Hata fırlatmıyoruz ki kayıt işlemi offline modda iptal olmasın.
      }

      // Çoklu hesap desteği ve offline kullanım için cihazın lokal Hive'ına da kaydediyoruz
      await _localHiveRepo.registerUser(finalUser);
      await SecureStorageService.saveBiometricPin(firebaseUser.uid, user.pin);
      return await _createAndSaveSession(finalUser);
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
      final credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: localUser.email, password: pin)
          .timeout(const Duration(seconds: 10));

      final firebaseUid = credential.user?.uid;
      
      // Şifre dışarıdan (Şifremi Unuttum ile) sıfırlanmışsa lokal DB'yi güncelle
      bool isPinChanged = false;
      try {
        isPinChanged = !BCrypt.checkpw(pin, localUser.pin);
      } catch (_) {
        // Hashing error means pin format is wrong, so it must be changed
        isPinChanged = true;
      }
      
      if (isPinChanged) {
        await _localHiveRepo.updateUserPin(localUser.id, '', pin);
      }

      // Firebase'in gerçek UID'sini alıyoruz.
      // Hive'daki eski UUID bununla eşleşmiyorsa güncelleniyor.
      if (firebaseUid != null && firebaseUid != localUser.id) {
        if (kDebugMode) {
          debugPrint(
            'loginUser: Hive UID != Firebase UID — güncelleniyor.',
          );
        }
        final correctedUser = UserEntity(
          id: firebaseUid,
          name: localUser.name,
          email: localUser.email,
          pin: BCrypt.hashpw(pin, BCrypt.gensalt()),
          profileImage: localUser.profileImage,
          createdAt: localUser.createdAt,
          biometricEnabled: localUser.biometricEnabled,
        );
        await _localHiveRepo.registerUser(correctedUser);
        await _localHiveRepo.setCurrentUser(firebaseUid);
        try {
          await _localHiveRepo.deleteUser(localUser.id);
        } catch (_) {}

        await CloudSyncService.syncAllUserData(firebaseUid);
        return await _createAndSaveSession(correctedUser);
      }

      final loggedInUser = await _localHiveRepo.loginUser(id, pin);
      if (loggedInUser != null) {
        await SecureStorageService.saveBiometricPin(id, pin);
        final userWithSession = await _createAndSaveSession(loggedInUser);
        await CloudSyncService.syncAllUserData(userWithSession.id);
        await StreakService.syncFromCloud(userWithSession.id);
        return userWithSession;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // OFFLINE FALLBACK: Ağ hatası veya bağlanamama durumunda yerel PIN ile doğrula.
      // Bu sayede kullanıcı internetsiz ortamda da PIN ile giriş yapabilir.
      if (e.code == 'network-request-failed') {
        if (kDebugMode) {
          debugPrint('loginUser: Ağ bağlantısı yok, offline fallback...');
        }
        return _offlinePinFallback(localUser, pin);
      }
      if (kDebugMode) {
        debugPrint('Firebase Login Error [${e.code}]: ${e.message}');
      }
      return null;
    } catch (e) {
      // Timeout veya diğer beklenmedik ağ hataları için de offline fallback.
      final msg = e.toString().toLowerCase();
      if (msg.contains('timeout') ||
          msg.contains('socketexception') ||
          msg.contains('failed host lookup')) {
        if (kDebugMode) {
          debugPrint('loginUser: Bağlantı zaman aşımı, offline fallback...');
        }
        return _offlinePinFallback(localUser, pin);
      }
      rethrow;
    }
  }

  /// İnternet erişimi olmadığında, daha önce bu cihaza kaydedilmiş PIN ile
  /// doğrulama yapar. Cloud sync atlanır; uygulama bir sonraki açılışta senkronize eder.
  Future<UserEntity?> _offlinePinFallback(
    UserEntity localUser,
    String pin,
  ) async {
    // GÜVENLİK YAMASI: Kaba kuvvet (Brute-force) koruması
    final lockoutUntil = await _localHiveRepo.getOfflineLockoutUntil(
      localUser.id,
    );
    if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
      final waitMinutes = lockoutUntil.difference(DateTime.now()).inMinutes;
      throw Exception(
        'Çok fazla hatalı giriş yaptınız. Güvenlik nedeniyle lütfen ${waitMinutes > 0 ? waitMinutes : 1} dakika bekleyip tekrar deneyin.',
      );
    }

    final loggedInUser = await _localHiveRepo.loginUser(localUser.id, pin);
    if (loggedInUser != null) {
      await _localHiveRepo.resetFailedOfflineAttempts(localUser.id);
      await SecureStorageService.saveBiometricPin(localUser.id, pin);
      if (kDebugMode) {
        debugPrint('loginUser: Offline mod — yerel PIN ile doğrulandı.');
      }
      return loggedInUser;
    }

    await _localHiveRepo.incrementFailedOfflineAttempts(localUser.id);
    final attempts = await _localHiveRepo.getFailedOfflineAttempts(
      localUser.id,
    );
    final remaining = 5 - attempts;

    if (kDebugMode) {
      debugPrint('loginUser: Offline mod — PIN yanlış, kalan hak: $remaining');
    }
    if (remaining <= 0) {
      throw Exception(
        'Çok fazla hatalı giriş yaptınız. Güvenlik nedeniyle uygulamanız 5 dakika süreyle kilitlenmiştir.',
      );
    } else {
      throw Exception('Hatalı PIN. Kalan deneme hakkınız: $remaining');
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
            .get(
              NetworkService().isOffline
                  ? const GetOptions(source: Source.cache)
                  : const GetOptions(),
            );
        if (doc.exists && doc.data() != null) {
          final userModelFromFirestore = UserModel.fromMap(doc.data()!);

          // Yerel Biyometrik ayarını koru veya yeni cihazsa false yap
          final existingLocalUser = await _localHiveRepo.getUserByEmail(email);
          final localBiometricState =
              existingLocalUser?.biometricEnabled ?? false;

          // FIX-7: Firestore'da PIN güvenli tutulmadığı (olmadığı) için
          // inen profilde PIN boştur. Cihaza kaydetmeden önce başarılı olan
          // gerçek PIN'i enjekte ediyoruz ki sonraki girişlerde kilitlenmesin.
          final userModel = UserModel(
            id: userModelFromFirestore.id,
            name: userModelFromFirestore.name,
            email: userModelFromFirestore.email,
            pin: pin,
            profileImage: userModelFromFirestore.profileImage,
            createdAt: userModelFromFirestore.createdAt,
            lastLoginAt: userModelFromFirestore.lastLoginAt,
            biometricEnabled:
                localBiometricState, // GÜVENLİK YAMASI (Edge Case 2)
          );

          await _localHiveRepo.registerUser(
            userModel,
          ); // create or update on device
          await SecureStorageService.saveBiometricPin(userModel.id, pin);
          final userWithSession = await _createAndSaveSession(userModel);
          await CloudSyncService.syncAllUserData(userWithSession.id);
          await StreakService.syncFromCloud(userWithSession.id);
          return userWithSession;
        } else {
          // FIX: Phantom Registration
          // Eğer profil Firestore'da yoksa (kayıt esnasında internet kopmuşsa), yeni cihaza girişte kilitlenmeyi önler.
          debugPrint(
            "loginByEmail: Firestore profili bulunamadı. Yeniden oluşturuluyor...",
          );
          final userModel = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Kullanıcı',
            email: firebaseUser.email ?? email,
            pin: pin,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            biometricEnabled: false,
          );

          try {
            await _firestore
                .collection('users')
                .doc(firebaseUser.uid)
                .collection('profile')
                .doc('info')
                .set(userModel.toFirestoreMap())
                .timeout(const Duration(seconds: 5));
          } catch (e) {
            debugPrint(
              "loginByEmail: Phantom profili buluta yazılamadı (offline?): $e",
            );
          }

          await _localHiveRepo.registerUser(userModel);
          await SecureStorageService.saveBiometricPin(firebaseUser.uid, pin);
          final userWithSession = await _createAndSaveSession(userModel);
          // Sync service will just create empty folders locally for new accounts
          await CloudSyncService.syncAllUserData(userWithSession.id);
          return userWithSession;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        debugPrint(
          'loginByEmail: Ağ bağlantısı yok, yerel PIN doğrulamasına geçiliyor...',
        );
        return await _localHiveRepo.loginByEmail(email, pin);
      }
      debugPrint("Firebase loginByEmail Error: ${e.message}");
      return null;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('timeout') ||
          msg.contains('socketexception') ||
          msg.contains('failed host lookup')) {
        debugPrint(
          'loginByEmail: Bağlantı zaman aşımı, yerel PIN doğrulamasına geçiliyor...',
        );
        return await _localHiveRepo.loginByEmail(email, pin);
      }
      return null;
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _localHiveRepo.updateUser(user);
    final model = UserModel.fromEntity(user);
    // FIX-5: toFirestoreMap() kullanılıyor — profil güncellemesinde de PIN asla
    // Firestore'a yazılmaz. toMap() kullanmak önceki PIN güvenlik yamasını deliyordu.
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('profile')
          .doc('info')
          .set(model.toFirestoreMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('updateUser: Firestore güncelleme başarısız (offline?): $e');
      // Lokal güncelleme zaten yapıldı; bulut sync bir sonraki açılışta tekrar denenecek.
    }
  }

  Future<void> _deleteUserFirestoreData(String userId) async {
    if (NetworkService().isOffline) {
      throw Exception('Hesabınızı tamamen silebilmemiz için internet bağlantısı gereklidir. Lütfen internetinizi kontrol edip tekrar deneyin.');
    }

    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // Silinmesi gereken bilinen alt koleksiyonlar
      final collections = [
        'expenses',
        'incomes',
        'assets',
        'paymentMethods',
        'transfers',
        'expenseCategories',
        'incomeCategories',
        'recurringExpenses',
        'recurringIncomes',
        'deletedPaymentMethods',
        'deletedAssets',
        'settings',
        'profile',
        'streak',
      ];

      final List<DocumentReference> allDocsToDelete = [];

      for (final collectionName in collections) {
        final querySnapshot = await userDoc.collection(collectionName).get();
        for (final doc in querySnapshot.docs) {
          allDocsToDelete.add(doc.reference);
        }
      }
      allDocsToDelete.add(userDoc);

      // GÜVENLİK/PERFORMANS YAMASI: Firestore batch limiti maksimum 500 işlemdir.
      // 500'erlik parçalara bölerek Ghost Data temizliğini gerçekleştiriyoruz.
      const int batchSize = 500;
      for (int i = 0; i < allDocsToDelete.length; i += batchSize) {
        final batch = _firestore.batch();
        final end = (i + batchSize < allDocsToDelete.length) ? i + batchSize : allDocsToDelete.length;
        for (int j = i; j < end; j++) {
          batch.delete(allDocsToDelete[j]);
        }
        await batch.commit();
      }

      debugPrint('Cloud verileri başarıyla silindi (Ghost Data temizlendi). Toplam silinen belge: ${allDocsToDelete.length}');
    } catch (e) {
      debugPrint('Kullanıcı verilerini silerken hata oluştu: $e');
      throw Exception('Kullanıcı verileri silinemedi. Lütfen internet bağlantınızı kontrol edin.');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null && firebaseUser.uid == userId) {
      try {
        // GHOST DATA VULNERABILITY FIX: 
        // Firebase Auth kimliği silinmeden önce Firestore verilerini temizle.
        await _deleteUserFirestoreData(userId);

        await firebaseUser.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // FIX-6: Oturum eskimiş — Firebase yeniden kimlik doğrulama istiyor.
          // Lokal veriyi silmeden hata fırlat; UI kullanıcıyı yeniden giriş yapmaya yönlendirmeli.
          throw Exception(
            'requires-recent-login: Hesabı silmek için lütfen çıkış yapıp tekrar giriş yapın.',
          );
        } else if (e.code == 'network-request-failed') {
          // OFFLINE GHOST ACCOUNT BUG FIX: İnternet yoksa hesabı silme
          // Eğer burada hata fırlatmazsak, Firebase silinmez ama lokal veriler silinir.
          throw Exception(
            'Hesabınızı tamamen silebilmemiz için internet bağlantısı gereklidir. Lütfen internetinizi kontrol edip tekrar deneyin.',
          );
        }
        // Başka Firebase hataları (ör. ağ) → logla ama yerel temizliği yine de yap
        debugPrint('deleteUser Firebase hatası [${e.code}]: ${e.message}');
        // FIX: Diğer tüm Firebase ağ hatalarında işlemi iptal et. Lokal temizliği durdur.
        throw Exception(
          'Hesabınız silinirken bir ağ hatası oluştu. Lütfen bağlantınızı kontrol edip tekrar deneyin.',
        );
      } catch (e) {
        debugPrint('deleteUser beklenmedik hata: $e');
        // GÜVENLİK YAMASI (Edge Case 3): Eğer Firebase işlemi başardıysa ama bize
        // Timeout/Ağ hatası düştüyse, Ghost Account kalmaması için en azından
        // kullanıcının bu cihazdaki oturumunu kapatıyoruz.
        await logout();
        throw Exception(
          'Hesabınızı silerken bir ağ hatası oluştu. İşlem tamamlanmış olabilir, emin olmak için tekrar giriş yapmayı deneyin.',
        );
      }
    }
    // Firebase hesabı başarıyla silindiyse (veya zaten yoksa) lokal veriyi temizle.
    // Hata fırlatılan durumlarda buraya ulaşılmaz.
    await SecureStorageService.deleteBiometricPin(userId);
    await _localHiveRepo.deleteUser(userId);
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
        // FIX: Tekil oturum kontrolü (Single Device Policy)
        // Kullanıcı internete bağlıysa Firestore'daki aktif oturum ID'sini kontrol et.
        final profileDoc = await _firestore
            .collection('users')
            .doc(user.id)
            .collection('profile')
            .doc('info')
            .get(
              NetworkService().isOffline
                  ? const GetOptions(source: Source.cache)
                  : const GetOptions(),
            )
            .timeout(const Duration(seconds: 5));

        if (profileDoc.exists) {
          final firestoreSessionId =
              profileDoc.data()?['activeSessionId'] as String?;
          if (firestoreSessionId != null &&
              user.activeSessionId != null &&
              firestoreSessionId != user.activeSessionId) {
            // Başka cihazdan giriş yapılmış! Yerel oturumu temizle ve hata fırlat.
            await logout();
            throw SessionExpiredException(
              'Hesabınıza başka bir cihazdan giriş yapıldığı için güvenlik nedeniyle bu cihazdaki oturumunuz sonlandırılmıştır.',
            );
          }
        }

        await CloudSyncService.syncAllUserData(
          user.id,
        ).timeout(const Duration(seconds: 15));
        await StreakService.syncFromCloud(user.id);

        // Başarılı online doğrulama sonrası TTL süresini güncelle
        await _localHiveRepo.updateLastOnlineSync(user.id);
      } catch (e) {
        if (e is SessionExpiredException) rethrow; // Hatayı UI'a ilet
        debugPrint('getCurrentUser CloudSync Hatasi (offline?): $e');

        // GÜVENLİK YAMASI: Auto-Login Offline TTL Kontrolü
        final lastSync = await _localHiveRepo.getLastOnlineSync(user.id);
        if (lastSync != null) {
          final diff = DateTime.now().difference(lastSync);
          if (diff.isNegative) {
            throw SessionExpiredException(
              'Güvenlik nedeniyle (cihaz saati hatalı) lütfen internete bağlanarak giriş yapın.',
            );
          }
          if (diff.inHours > 48) {
            throw SessionExpiredException(
              'Güvenlik nedeniyle (uzun süredir çevrimdışısınız) oturumunuz zaman aşımına uğradı. Lütfen PIN kodunuz ile tekrar giriş yapın.',
            );
          }
        } else {
          throw SessionExpiredException(
            'Güvenlik nedeniyle ilk girişinizde internet bağlantısı gereklidir.',
          );
        }
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

    if (firebaseUser == null || firebaseUser.uid != userId) {
      final savedPin = await SecureStorageService.getBiometricPin(userId);
      if (savedPin != null) {
        final localUser = await _localHiveRepo.loginWithBiometric(userId);
        if (localUser != null) {
          try {
            await _firebaseAuth.signInWithEmailAndPassword(
              email: localUser.email,
              password: savedPin,
            );
            // Re-auth başarılı: yeni session oluştur ve döndür
            final refreshedUser = await _createAndSaveSession(localUser);
            await CloudSyncService.syncAllUserData(refreshedUser.id);
            await StreakService.syncFromCloud(refreshedUser.id);
            return refreshedUser;
          } catch (e) {
            throw Exception(
              'Güvenlik nedeniyle (oturum süresi doldu) lütfen PIN kodunuz ile manuel giriş yapın.',
            );
          }
        } else {
          throw Exception('Kullanıcı bulunamadı.');
        }
      } else {
        throw Exception(
          'Güvenlik nedeniyle (oturum süresi doldu) lütfen PIN kodunuz ile giriş yapın.',
        );
      }
    }

    final user = await _localHiveRepo.loginWithBiometric(userId);

    if (user == null) return null;

    // firebaseUser null kontrolü yukarıda yapıldığı için oturum aktiftir.
    try {
      // Single Device Policy kontrolü
      final profileDoc = await _firestore
          .collection('users')
          .doc(user.id)
          .collection('profile')
          .doc('info')
          .get(
            NetworkService().isOffline
                ? const GetOptions(source: Source.cache)
                : const GetOptions(),
          )
          .timeout(const Duration(seconds: 5));

      if (profileDoc.exists) {
        final firestoreSessionId =
            profileDoc.data()?['activeSessionId'] as String?;
        if (firestoreSessionId != null &&
            user.activeSessionId != null &&
            firestoreSessionId != user.activeSessionId) {
          await logout();
          throw SessionExpiredException(
            'Hesabınıza başka bir cihazdan giriş yapıldığı için güvenlik nedeniyle bu cihazdaki oturumunuz sonlandırılmıştır. Lütfen tekrar PIN ile giriş yapın.',
          );
        }
      }

      // Yeni session oluştur ve kaydet (her başarılı biyometrik girişte)
      final sessionUser = await _createAndSaveSession(user);
      await CloudSyncService.syncAllUserData(sessionUser.id);
      await StreakService.syncFromCloud(sessionUser.id);
      return sessionUser;
    } catch (e) {
      if (e is SessionExpiredException) rethrow;
      debugPrint('Biyometrik giriş sonrası sync hatası (offline?): $e');

      // ÇEVRİMDIŞI TTL KONTROLÜ
      final lastSync = await _localHiveRepo.getLastOnlineSync(user.id);
      if (lastSync != null) {
        final diff = DateTime.now().difference(lastSync);
        if (diff.isNegative) {
          throw SessionExpiredException(
            'Güvenlik nedeniyle (cihaz saati hatalı) lütfen internete bağlanarak giriş yapın.',
          );
        }
        if (diff.inHours > 48) {
          throw SessionExpiredException(
            'Güvenlik nedeniyle (uzun süredir çevrimdışı) lütfen internete bağlanarak veya PIN kodunuzu girerek tekrar giriş yapın.',
          );
        }
      } else {
        throw SessionExpiredException(
          'Güvenlik nedeniyle ilk biyometrik girişinizde internet bağlantısı gereklidir.',
        );
      }

      return user;
    }
  }

  @override
  Future<void> updateBiometricPreference(String userId, bool enabled) async {
    // GÜVENLİK YAMASI (Edge Case 2): Biyometrik tercih (Touch ID/Face ID)
    // donanıma ve cihaza özel bir ayardır. Bunu Firestore'a senkronize etmek,
    // diğer cihazlarda hatalara ve bypass senaryolarına yol açabilir.
    // Bu yüzden SADECE cihazın yerel veritabanında tutuyoruz.
    await _localHiveRepo.updateBiometricPreference(userId, enabled);
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    // Lokal Hive cache'de ara (aynı cihaz / offline).
    final localUser = await _localHiveRepo.getUserByEmail(email);
    if (localUser != null) return localUser;

    // FIX-2: Yeni cihaz veya lokal cache yok.
    // fetchSignInMethodsForEmail Firebase SDK'dan kaldırıldığı (gizlilik politikası) için
    // stub entity döndürüyoruz ve akışın devam etmesine izin veriyoruz.
    // Asıl e-posta doğrulaması sendSignInLinkToEmail adımında Firebase tarafından yapılır:
    //   - E-posta yoksa → FirebaseAuthException fırlatır → UI hata gösterir.
    //   - E-posta varsa  → Magic link gönderilir → akış tamamlanır.
    return UserEntity(
      id: '', // UID henüz bilinmiyor, yalnızca akışı açmak için
      name: '',
      email: email,
      pin: '',
      createdAt: DateTime.now(),
      biometricEnabled: false,
    );
  }

  @override
  Future<void> sendPinResetOtp(String email) async {
    try {
      // 1. Firebase üzerinden Şifre Sıfırlama e-postası gönder
      // Bu, Firebase'in kendi güvenli web arayüzünü (Şifre yenileme sayfası) açacak.
      // Kullanıcı buraya yeni PIN'ini girecek.
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Şifre sıfırlama e-postası gönderilemedi: ${e.toString()}');
    }
  }



  @override
  Future<void> updateUserPin(String userId, String currentPin, String newPin) async {
    try {
      // GÜVENLİK YAMASI: PIN değişikliği (State Inconsistency önleme)
      // PIN değişimi Firebase Auth ve yerel Hive'da eşzamanlı yapılmalıdır.
      // Cihaz çevrimdışıysa (veya oturum Firebase Auth'ta aktif değilse) yerel PIN
      // güncellenmemeli, aksi halde bulut-lokal şifre uyumsuzluğu oluşur.
      final user = _firebaseAuth.currentUser;
      if (user == null || user.uid != userId) {
        throw Exception(
          'Güvenlik nedeniyle PIN değişikliği işlemi çevrimdışı modda yapılamaz. Lütfen internete bağlanarak giriş yapın ve tekrar deneyin.',
        );
      }

      // 1. Firebase Auth şifresi güncelle
      try {
        await user.updatePassword(newPin);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login' && user.email != null) {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: currentPin,
          );
          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(newPin);
        } else {
          rethrow;
        }
      }

      // 2. Lokal Hive güncelle
      await _localHiveRepo.updateUserPin(userId, currentPin, newPin);
      await SecureStorageService.saveBiometricPin(userId, newPin);
    } catch (e) {
      throw Exception("PIN güncellenemedi: ${e.toString()}");
    }
  }

  /// Session kimliği (UUID) üretir ve hem lokale hem Firestore'a yazar.
  Future<UserEntity> _createAndSaveSession(UserEntity user) async {
    final sessionId = const Uuid().v4();
    final updatedUser = UserEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      pin: user.pin,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      biometricEnabled: user.biometricEnabled,
      activeSessionId: sessionId,
    );

    // Lokal güncelle
    await _localHiveRepo.updateUser(updatedUser);

    // Firestore güncelle
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('profile')
          .doc('info')
          .set({'activeSessionId': sessionId}, SetOptions(merge: true))
          .timeout(const Duration(seconds: 5));

      // Firestore'a erişim başarılıysa online damgasını vur
      await _localHiveRepo.updateLastOnlineSync(user.id);
    } catch (e) {
      debugPrint("Firestore activeSessionId update failed (offline?): $e");
    }

    return updatedUser;
  }
}
