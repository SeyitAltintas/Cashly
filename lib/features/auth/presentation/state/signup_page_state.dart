import 'package:flutter/foundation.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';


/// Signup sayfası için ChangeNotifier state yöneticisi
class SignupPageState extends ChangeNotifier with SafeNotifierMixin {
  bool _isPinVisible = false;
  bool get isPinVisible => _isPinVisible;
  set isPinVisible(bool value) {
    _isPinVisible = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? _selectedSecurityQuestion;
  String? get selectedSecurityQuestion => _selectedSecurityQuestion;
  set selectedSecurityQuestion(String? value) {
    _selectedSecurityQuestion = value;
    notifyListeners();
  }
}
