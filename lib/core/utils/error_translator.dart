import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ErrorTranslator {
  /// Alınan Exception türünü analiz edip kullanıcı dostu bir Türkçe mesaja çevirir.
  static String translate(dynamic exception) {
    if (exception == null) {
      return 'Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }

    if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthError(exception);
    }

    if (exception is FirebaseException) {
      return _handleFirebaseError(exception);
    }

    if (exception is SocketException) {
      return 'İnternet bağlantınız koptu veya sunucuya ulaşılamıyor. Lütfen bağlantınızı kontrol edin.';
    }

    if (exception is FormatException) {
      return 'Beklenmeyen bir veri formatı alındı. İşlem tamamlanamadı.';
    }

    if (exception is PlatformException) {
      return 'Cihaz tabanlı bir sorun oluştu: ${exception.message}';
    }

    if (exception is ArgumentError) {
      return 'Geçersiz bir bilgi girdiniz. Lütfen alanları kontrol edin.';
    }

    // Özel Exception stringi
    final errorString = exception.toString();
    if (errorString.contains('SocketException') || errorString.contains('network_error')) {
      return 'İnternet bağlantınız koptu. Lütfen bağlantınızı kontrol edin.';
    }

    if (errorString.contains('permission-denied')) {
      return 'Bu işlemi gerçekleştirmek için yeterli yetkiniz bulunmuyor.';
    }

    // Çok teknik mesajları gizle ve sadece özet ver
    return 'Bir sorun oluştu. Daha fazla detay için Hata Kayıtları ekranına bakabilirsiniz.';
  }

  static String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresine ait bir kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz. Lütfen tekrar deneyin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi girdiniz.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı askıya alınmış.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemine şu an izin verilmiyor.';
      case 'weak-password':
        return 'Şifreniz çok zayıf. Lütfen daha güçlü bir şifre belirleyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızda bir sorun var. Lütfen kontrol edip tekrar deneyin.';
      default:
        return 'Kimlik doğrulama sırasında bir hata oluştu: ${e.message}';
    }
  }

  static String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bu veriye erişmek veya değiştirmek için yetkiniz bulunmuyor.';
      case 'unavailable':
        return 'Şu anda sunucuya ulaşılamıyor (Çevrimdışı olabilirsiniz).';
      case 'not-found':
        return 'Erişmeye çalıştığınız veri bulunamadı.';
      case 'already-exists':
        return 'Bu kayıt zaten mevcut.';
      case 'resource-exhausted':
        return 'Sistem yoğunluğu nedeniyle işlem yapılamadı, daha sonra tekrar deneyin.';
      case 'cancelled':
        return 'İşlem iptal edildi.';
      case 'deadline-exceeded':
        return 'İşlem zaman aşımına uğradı. Bağlantınız yavaş olabilir.';
      default:
        return 'Veritabanı işlemi sırasında bir sorun oluştu: ${e.message}';
    }
  }
}
