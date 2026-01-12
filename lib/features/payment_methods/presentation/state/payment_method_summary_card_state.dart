import 'package:flutter/foundation.dart';

/// PaymentMethodSummaryCard için ChangeNotifier state yöneticisi
class PaymentMethodSummaryCardState extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  void setPage(int page) {
    if (_currentPage != page) {
      _currentPage = page;
      notifyListeners();
    }
  }
}
