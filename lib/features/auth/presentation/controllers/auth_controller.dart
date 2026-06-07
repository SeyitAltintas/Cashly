import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/exceptions/session_expired_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_scheduler.dart';


class AuthController extends ChangeNotifier with SafeNotifierMixin {
  final AuthRepository _authRepository;
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;
  // EC-3: Subscription sakla, dispose'da cancel et (memory leak önleme)
  StreamSubscription<User?>? _authListenerSub;

  AuthController(this._authRepository) {
    _initAuthListener();
  }


  void _initAuthListener() {
    try {
      _authListenerSub = FirebaseAuth.instance.userChanges().listen((
        User? user,
      ) async {
        if (user == null && _currentUser != null) {
          debugPrint(
            'Bulut kaynaklı çıkış (Force Logout) algılandı, lokal oturum temizleniyor.',
          );
          await logout();
        }
      });
    } catch (e) {
      debugPrint(
        'Firebase Auth Listener başlatılamadı (Test ortamı olabilir): $e',
      );
    }
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuth() async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.getCurrentUser();
      if (_currentUser != null && getIt.isRegistered<NotificationScheduler>()) {
        await getIt<NotificationScheduler>().rescheduleAll();
      }
    } catch (e) {
      if (e is SessionExpiredException) {
        _currentUser = null; // Session expired, so clear current user
      }
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String userId, String pin) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authRepository.loginUser(userId, pin);
      if (user != null) {
        _currentUser = user;
        if (getIt.isRegistered<NotificationScheduler>()) {
          await getIt<NotificationScheduler>().rescheduleAll();
        }
        return true;
      } else {
        _error = "Hatalı PIN veya kullanıcı bulunamadı.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String pin) async {
    _setLoading(true);
    _error = null;
    try {
      final newUser = UserEntity(
        id: const Uuid().v4(),
        name: name,
        email: email,
        pin: pin,
        createdAt: DateTime.now(),
        biometricEnabled: false,
      );
      final registeredUser = await _authRepository.registerUser(newUser);
      _currentUser = registeredUser;
      if (getIt.isRegistered<NotificationScheduler>()) {
        await getIt<NotificationScheduler>().rescheduleAll();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _authListenerSub?.cancel(); // EC-3: Memory leak önleme
    super.dispose();
  }

  Future<void> logout() async {
    // 🚨 EDGE CASE FIX 4: Çoklu Hesap Çakışmasını (Privacy Leak) Önleme
    // Kullanıcı çıkış yaptığında, işletim sistemindeki tüm kişisel bildirimleri temizle
    if (getIt.isRegistered<NotificationService>()) {
      await getIt<NotificationService>().cancelAllNotifications();
    }
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<List<UserEntity>> getAllUsers() async {
    return await _authRepository.getAllUsers();
  }

  Future<bool> loginByEmail(String email, String pin) async {
    _setLoading(true);
    _error = null;

    try {
      final user = await _authRepository.loginByEmail(email, pin);

      if (user != null) {
        _currentUser = user;
        if (getIt.isRegistered<NotificationScheduler>()) {
          await getIt<NotificationScheduler>().rescheduleAll();
        }
        return true;
      } else {
        _error = "Hatalı e-posta veya PIN";
        return false;
      }
    } catch (e) {
      _error = "Giriş yapılamadı: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> getLastUserId() {
    return _authRepository.getLastUserId();
  }

  /// Biyometrik ile giriş yap
  Future<bool> loginWithBiometric(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authRepository.loginWithBiometric(userId);
      if (user != null) {
        _currentUser = user;
        if (getIt.isRegistered<NotificationScheduler>()) {
          await getIt<NotificationScheduler>().rescheduleAll();
        }
        return true;
      } else {
        _error = "Biyometrik giriş başarısız.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Biyometrik tercihini güncelle
  Future<void> setBiometricEnabled(String userId, bool enabled) async {
    try {
      await _authRepository.updateBiometricPreference(userId, enabled);
      // Mevcut kullanıcıyı güncelle
      if (_currentUser != null && _currentUser!.id == userId) {
        _currentUser = await _authRepository.getCurrentUser();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Kullanıcının biyometrik tercihi aktif mi?
  bool get isBiometricEnabled => _currentUser?.biometricEnabled ?? false;

  /// E-posta ile kullanıcı bul (Şifremi Unuttum için)
  Future<UserEntity?> getUserByEmail(String email) async {
    return await _authRepository.getUserByEmail(email);
  }

  /// OTP doğrulama kodu gönder (Şifremi Unuttum)
  Future<bool> sendPinResetOtp(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authRepository.sendPinResetOtp(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }



  /// Kullanıcının PIN'ini güncelle (Şifremi Unuttum için)
  Future<void> updateUserPin(String userId, String currentPin, String newPin) async {
    await _authRepository.updateUserPin(userId, currentPin, newPin);
    if (_currentUser != null && _currentUser!.id == userId) {
      _currentUser = await _authRepository.getCurrentUser();
      notifyListeners();
    }
  }
}
