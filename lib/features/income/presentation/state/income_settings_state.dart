import 'package:flutter/foundation.dart';

/// Gelir ayarları için ChangeNotifier state yöneticisi
class IncomeSettingsState extends ChangeNotifier {
  bool _categoryChanged = false;
  bool get categoryChanged => _categoryChanged;
  set categoryChanged(bool value) {
    _categoryChanged = value;
    notifyListeners();
  }
}
