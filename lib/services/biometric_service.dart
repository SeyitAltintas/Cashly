import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biyometrik kimlik doğrulama servisi
/// Parmak izi ve yüz tanıma işlemlerini yönetir
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Cihazda biyometrik sensör olup olmadığını kontrol eder
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Cihazda biyometrik sensör VE kayıtlı biyometrik olup olmadığını kontrol eder
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Mevcut biyometrik türlerini getirir (parmak izi, yüz tanıma vb.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Biyometrik doğrulama yapar
  /// [reason] kullanıcıya gösterilecek açıklama
  Future<bool> authenticate({String? reason}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason ?? 'Giriş yapmak için kimliğinizi doğrulayın',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Biyometrik sensör türünü döndürür (ikon göstermek için)
  Future<BiometricType?> getPrimaryBiometricType() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else if (biometrics.contains(BiometricType.strong)) {
      return BiometricType.strong;
    }
    return null;
  }
}
