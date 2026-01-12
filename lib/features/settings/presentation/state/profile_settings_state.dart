import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Profil ayarları için ChangeNotifier state yöneticisi
class ProfileSettingsState extends ChangeNotifier {
  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;
  set currentUser(UserEntity? value) {
    _currentUser = value;
    notifyListeners();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isBiometricAvailable = false;
  bool get isBiometricAvailable => _isBiometricAvailable;
  set isBiometricAvailable(bool value) {
    _isBiometricAvailable = value;
    notifyListeners();
  }
}
