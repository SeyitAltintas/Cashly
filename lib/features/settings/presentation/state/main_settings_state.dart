import 'package:flutter/foundation.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';

/// Main ayarlar sayfası için ChangeNotifier state yöneticisi
class MainSettingsState extends ChangeNotifier with SafeNotifierMixin {
  bool _needsRefresh = false;
  bool get needsRefresh => _needsRefresh;
  set needsRefresh(bool value) {
    _needsRefresh = value;
    notifyListeners();
  }
}
