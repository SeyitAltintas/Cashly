import 'package:flutter/foundation.dart';

/// PaymentMethodDetailPage için ChangeNotifier state yöneticisi
class PaymentMethodDetailState extends ChangeNotifier {
  late int _secilenAy;
  int get secilenAy => _secilenAy;

  late int _secilenYil;
  int get secilenYil => _secilenYil;

  PaymentMethodDetailState() {
    final now = DateTime.now();
    _secilenAy = now.month;
    _secilenYil = now.year;
  }

  /// Ay seçimini güncelle
  void selectMonth(int month, int year) {
    if (_secilenAy != month || _secilenYil != year) {
      _secilenAy = month;
      _secilenYil = year;
      notifyListeners();
    }
  }
}
