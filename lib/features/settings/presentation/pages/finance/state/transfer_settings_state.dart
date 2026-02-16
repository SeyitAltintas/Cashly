import 'package:flutter/foundation.dart';

/// Transfer ayarları için ChangeNotifier state yöneticisi
class TransferSettingsState extends ChangeNotifier {
  int _savedLimit = 10;
  int get savedLimit => _savedLimit;
  set savedLimit(int value) {
    _savedLimit = value;
    notifyListeners();
  }

  int _tempLimit = 10;
  int get tempLimit => _tempLimit;
  set tempLimit(int value) {
    _tempLimit = value;
    notifyListeners();
  }

  bool _hasChanged = false;
  bool get hasChanged => _hasChanged;
  set hasChanged(bool value) {
    _hasChanged = value;
    notifyListeners();
  }
}
