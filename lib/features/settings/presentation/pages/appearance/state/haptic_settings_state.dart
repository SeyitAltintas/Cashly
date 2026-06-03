import 'package:flutter/foundation.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';


/// Haptic ayarları için ChangeNotifier state yöneticisi
class HapticSettingsState extends ChangeNotifier with SafeNotifierMixin {
  Map<String, bool> _settings = {};
  Map<String, bool> get settings => _settings;
  set settings(Map<String, bool> value) {
    _settings = value;
    notifyListeners();
  }

  bool _hasVibrator = false;
  bool get hasVibrator => _hasVibrator;
  set hasVibrator(bool value) {
    _hasVibrator = value;
    notifyListeners();
  }

  void updateSetting(String key, bool value) {
    _settings[key] = value;
    notifyListeners();
  }
}
