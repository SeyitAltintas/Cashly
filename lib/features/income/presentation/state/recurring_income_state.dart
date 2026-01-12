import 'package:flutter/foundation.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Tekrarlayan gelirler için ChangeNotifier state yöneticisi
class RecurringIncomeState extends ChangeNotifier {
  List<Map<String, dynamic>> _tekrarlayanGelirler = [];
  List<Map<String, dynamic>> get tekrarlayanGelirler => _tekrarlayanGelirler;
  set tekrarlayanGelirler(List<Map<String, dynamic>> value) {
    _tekrarlayanGelirler = value;
    notifyListeners();
  }

  List<PaymentMethod> _odemeYontemleri = [];
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;
  set odemeYontemleri(List<PaymentMethod> value) {
    _odemeYontemleri = value;
  }

  void addGelir(Map<String, dynamic> gelir) {
    _tekrarlayanGelirler.add(gelir);
    notifyListeners();
  }

  void updateGelir(int index, Map<String, dynamic> gelir) {
    _tekrarlayanGelirler[index] = gelir;
    notifyListeners();
  }

  void removeGelirAt(int index) {
    _tekrarlayanGelirler.removeAt(index);
    notifyListeners();
  }
}
