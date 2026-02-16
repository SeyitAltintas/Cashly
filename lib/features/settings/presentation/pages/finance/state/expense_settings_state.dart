import 'package:flutter/foundation.dart';
import '../../../../../payment_methods/data/models/payment_method_model.dart';

/// Harcama ayarları için ChangeNotifier state yöneticisi
class ExpenseSettingsState extends ChangeNotifier {
  bool _categoryChanged = false;
  bool get categoryChanged => _categoryChanged;
  set categoryChanged(bool value) {
    _categoryChanged = value;
    notifyListeners();
  }

  bool _isSaved = false;
  bool get isSaved => _isSaved;
  set isSaved(bool value) {
    _isSaved = value;
    notifyListeners();
  }

  String savedAmount = "";

  String? _savedMessage;
  String? get savedMessage => _savedMessage;
  set savedMessage(String? value) {
    _savedMessage = value;
    notifyListeners();
  }

  List<PaymentMethod> _odemeYontemleri = [];
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;
  set odemeYontemleri(List<PaymentMethod> value) {
    _odemeYontemleri = value;
    notifyListeners();
  }

  String? _varsayilanOdemeYontemiId;
  String? get varsayilanOdemeYontemiId => _varsayilanOdemeYontemiId;
  set varsayilanOdemeYontemiId(String? value) {
    _varsayilanOdemeYontemiId = value;
    notifyListeners();
  }
}
