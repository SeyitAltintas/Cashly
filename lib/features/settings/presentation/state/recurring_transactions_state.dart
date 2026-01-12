import 'package:flutter/foundation.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Tekrarlayan işlemler için ChangeNotifier state yöneticisi
class RecurringTransactionsState extends ChangeNotifier {
  List<Map<String, dynamic>> _tekrarlayanIslemler = [];
  List<Map<String, dynamic>> get tekrarlayanIslemler => _tekrarlayanIslemler;
  set tekrarlayanIslemler(List<Map<String, dynamic>> value) {
    _tekrarlayanIslemler = value;
    notifyListeners();
  }

  List<PaymentMethod> _odemeYontemleri = [];
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;
  set odemeYontemleri(List<PaymentMethod> value) {
    _odemeYontemleri = value;
  }

  void addIslem(Map<String, dynamic> islem) {
    _tekrarlayanIslemler.add(islem);
    notifyListeners();
  }

  void updateIslem(int index, Map<String, dynamic> islem) {
    _tekrarlayanIslemler[index] = islem;
    notifyListeners();
  }

  void removeIslemAt(int index) {
    _tekrarlayanIslemler.removeAt(index);
    notifyListeners();
  }
}
