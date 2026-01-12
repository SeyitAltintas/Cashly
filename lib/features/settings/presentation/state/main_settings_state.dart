import 'package:flutter/foundation.dart';

/// Main ayarlar sayfası için ChangeNotifier state yöneticisi
class MainSettingsState extends ChangeNotifier {
  bool _needsRefresh = false;
  bool get needsRefresh => _needsRefresh;
  set needsRefresh(bool value) {
    _needsRefresh = value;
    notifyListeners();
  }
}
