import 'package:flutter/foundation.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';


/// Analiz sayfası için ChangeNotifier state yöneticisi
class AnalysisPageState extends ChangeNotifier with SafeNotifierMixin {
  int _touchedIndex = -1;
  int get touchedIndex => _touchedIndex;

  set touchedIndex(int value) {
    if (_touchedIndex != value) {
      _touchedIndex = value;
      notifyListeners();
    }
  }

  void resetTouchedIndex() {
    if (_touchedIndex != -1) {
      _touchedIndex = -1;
      notifyListeners();
    }
  }
}
