import 'package:flutter/foundation.dart';

/// Generic login form için ChangeNotifier state yöneticisi
class LoginFormState extends ChangeNotifier {
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // PIN görünürlük state'i
  bool _isPinVisible = false;
  bool get isPinVisible => _isPinVisible;

  /// Loading durumunu başlat
  void startLoading() {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
  }

  /// Loading durumunu durdur
  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// PIN görünürlüğünü toggle et
  void togglePinVisibility() {
    _isPinVisible = !_isPinVisible;
    notifyListeners();
  }

  /// State'i sıfırla
  void reset() {
    _isLoading = false;
    _isPinVisible = false;
    notifyListeners();
  }
}
