import 'package:flutter/foundation.dart';

/// Controller'lar kapatıldıktan sonra asenkron işlemlerin `notifyListeners`
/// çağırarak FlutterError fırlatmasını önleyen güvenli ChangeNotifier mixin'i.
///
/// Kullanım:
/// class MyController extends ChangeNotifier with SafeNotifierMixin { ... }
mixin SafeNotifierMixin on ChangeNotifier {
  bool _isDisposedSafe = false;

  bool get isDisposedSafe => _isDisposedSafe;

  @override
  void dispose() {
    _isDisposedSafe = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposedSafe) {
      super.notifyListeners();
    }
  }
}
