import 'package:flutter/foundation.dart';

/// Detay sayfasına (PaymentMethodDetailPage) ait ay/yıl seçim state'ini yönetir.
/// PaymentMethodsController bu mixin'i kullanarak SRP'ye uyum sağlar.
mixin PaymentMethodDetailMixin on ChangeNotifier {
  int _detailSecilenAy = DateTime.now().month;
  int get detailSecilenAy => _detailSecilenAy;

  int _detailSecilenYil = DateTime.now().year;
  int get detailSecilenYil => _detailSecilenYil;

  void selectDetailMonth(int month, int year) {
    if (_detailSecilenAy != month || _detailSecilenYil != year) {
      _detailSecilenAy = month;
      _detailSecilenYil = year;
      notifyListeners();
    }
  }

  void resetDetailMonth() {
    final now = DateTime.now();
    _detailSecilenAy = now.month;
    _detailSecilenYil = now.year;
    notifyListeners();
  }
}
