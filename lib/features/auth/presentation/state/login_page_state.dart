import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';

/// Login sayfası için ChangeNotifier state yöneticisi
class LoginPageState extends ChangeNotifier {
  UserEntity? _targetUser;
  UserEntity? get targetUser => _targetUser;
  set targetUser(UserEntity? value) {
    _targetUser = value;
    notifyListeners();
  }

  bool _isLoadingUser = true;
  bool get isLoadingUser => _isLoadingUser;
  set isLoadingUser(bool value) {
    _isLoadingUser = value;
    notifyListeners();
  }

  bool _isGenericLogin = false;
  bool get isGenericLogin => _isGenericLogin;
  set isGenericLogin(bool value) {
    _isGenericLogin = value;
    notifyListeners();
  }

  bool _isBiometricAvailable = false;
  bool get isBiometricAvailable => _isBiometricAvailable;
  set isBiometricAvailable(bool value) {
    _isBiometricAvailable = value;
    notifyListeners();
  }

  void setLoginState({
    UserEntity? targetUser,
    bool? isLoadingUser,
    bool? isGenericLogin,
  }) {
    if (targetUser != null) _targetUser = targetUser;
    if (isLoadingUser != null) _isLoadingUser = isLoadingUser;
    if (isGenericLogin != null) _isGenericLogin = isGenericLogin;
    notifyListeners();
  }
}
