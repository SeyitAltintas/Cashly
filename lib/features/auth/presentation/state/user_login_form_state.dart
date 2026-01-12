import 'package:flutter/foundation.dart';

/// User login form için ChangeNotifier state yöneticisi
class UserLoginFormState extends ChangeNotifier {
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // PIN görünürlük state'i
  bool _isPinVisible = false;
  bool get isPinVisible => _isPinVisible;

  // PIN hata mesajı
  String? _pinErrorMessage;
  String? get pinErrorMessage => _pinErrorMessage;

  /// Loading durumunu başlat (hata mesajını temizle)
  void startLoading() {
    _isLoading = true;
    _pinErrorMessage = null;
    notifyListeners();
  }

  /// Loading durumunu durdur
  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hata mesajını ayarla
  void setError(String? message) {
    _pinErrorMessage = message;
    notifyListeners();
  }

  /// Hata mesajını temizle
  void clearError() {
    if (_pinErrorMessage != null) {
      _pinErrorMessage = null;
      notifyListeners();
    }
  }

  /// PIN görünürlüğünü toggle et
  void togglePinVisibility() {
    _isPinVisible = !_isPinVisible;
    notifyListeners();
  }

  /// PIN login başlat
  void startPinLogin() {
    _isLoading = true;
    notifyListeners();
  }

  /// State'i sıfırla
  void reset() {
    _isLoading = false;
    _isPinVisible = false;
    _pinErrorMessage = null;
    notifyListeners();
  }
}
