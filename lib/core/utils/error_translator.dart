import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class ErrorTranslator {
  /// Alınan Exception türünü analiz edip kullanıcı dostu bir mesaja çevirir.
  /// BuildContext verilirse uygulamanın l10n dillerini kullanır, verilmezse Türkçe (varsayılan) döner.
  static String translate(dynamic exception, {BuildContext? context}) {
    if (exception == null) {
      return context?.l10n.errUnknown ?? 'Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }

    if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthError(exception, context);
    }

    if (exception is FirebaseException) {
      return _handleFirebaseError(exception, context);
    }

    if (exception is SocketException) {
      return context?.l10n.errNetworkOffline ?? 'İnternet bağlantınız koptu veya sunucuya ulaşılamıyor. Lütfen bağlantınızı kontrol edin.';
    }

    if (exception is FormatException) {
      return context?.l10n.errDataFormat ?? 'Beklenmeyen bir veri formatı alındı. İşlem tamamlanamadı.';
    }

    if (exception is PlatformException) {
      if (context != null) {
        return context.l10n.errDeviceIssue(exception.message ?? '');
      }
      return 'Cihaz tabanlı bir sorun oluştu: ';
    }

    if (exception is ArgumentError) {
      return context?.l10n.errInvalidInput ?? 'Geçersiz bir bilgi girdiniz. Lütfen alanları kontrol edin.';
    }

    // Özel Exception stringi
    final errorString = exception.toString();
    if (errorString.contains('SocketException') || errorString.contains('network_error')) {
      return context?.l10n.errNetworkOffline ?? 'İnternet bağlantınız koptu. Lütfen bağlantınızı kontrol edin.';
    }

    if (errorString.contains('permission-denied')) {
      return context?.l10n.errPermissionDenied ?? 'Bu işlemi gerçekleştirmek için yeterli yetkiniz bulunmuyor.';
    }

    // Çok teknik mesajları gizle ve sadece özet ver
    return context?.l10n.errFallbackSummary ?? 'Bir sorun oluştu. Daha fazla detay için Hata Kayıtları ekranına bakabilirsiniz.';
  }

  static String _handleFirebaseAuthError(FirebaseAuthException e, BuildContext? context) {
    switch (e.code) {
      case 'user-not-found':
        return context?.l10n.errAuthUserNotFound ?? 'Bu e-posta adresine ait bir kullanıcı bulunamadı.';
      case 'wrong-password':
        return context?.l10n.errAuthWrongPassword ?? 'Hatalı şifre girdiniz. Lütfen tekrar deneyin.';
      case 'email-already-in-use':
        return context?.l10n.errAuthEmailInUse ?? 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return context?.l10n.errAuthInvalidEmail ?? 'Geçersiz bir e-posta adresi girdiniz.';
      case 'user-disabled':
        return context?.l10n.errAuthUserDisabled ?? 'Bu kullanıcı hesabı askıya alınmış.';
      case 'operation-not-allowed':
        return context?.l10n.errAuthNotAllowed ?? 'Bu giriş yöntemine şu an izin verilmiyor.';
      case 'weak-password':
        return context?.l10n.errAuthWeakPassword ?? 'Şifreniz çok zayıf. Lütfen daha güçlü bir şifre belirleyin.';
      case 'network-request-failed':
        return context?.l10n.errAuthNetwork ?? 'İnternet bağlantınızda bir sorun var. Lütfen kontrol edip tekrar deneyin.';
      default:
        if (context != null) return context.l10n.errAuthDefault(e.message ?? '');
        return 'Kimlik doğrulama sırasında bir hata oluştu: ';
    }
  }

  static String _handleFirebaseError(FirebaseException e, BuildContext? context) {
    switch (e.code) {
      case 'permission-denied':
        return context?.l10n.errPermissionDenied ?? 'Bu veriye erişmek veya değiştirmek için yetkiniz bulunmuyor.';
      case 'unavailable':
        return context?.l10n.errDbUnavailable ?? 'Şu anda sunucuya ulaşılamıyor (Çevrimdışı olabilirsiniz).';
      case 'not-found':
        return context?.l10n.errDbNotFound ?? 'Erişmeye çalıştığınız veri bulunamadı.';
      case 'already-exists':
        return context?.l10n.errDbAlreadyExists ?? 'Bu kayıt zaten mevcut.';
      case 'resource-exhausted':
        return context?.l10n.errDbResourceExhausted ?? 'Sistem yoğunluğu nedeniyle işlem yapılamadı, daha sonra tekrar deneyin.';
      case 'cancelled':
        return context?.l10n.errDbCancelled ?? 'İşlem iptal edildi.';
      case 'deadline-exceeded':
        return context?.l10n.errDbDeadlineExceeded ?? 'İşlem zaman aşımına uğradı. Bağlantınız yavaş olabilir.';
      default:
        if (context != null) return context.l10n.errDbDefault(e.message ?? '');
        return 'Veritabanı işlemi sırasında bir sorun oluştu: ';
    }
  }
}
