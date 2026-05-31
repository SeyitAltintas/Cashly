import 'package:flutter/foundation.dart';

/// Form sayfasına (AddPaymentMethodPage) ait geçici UI state'i yönetir.
/// PaymentMethodsController bu mixin'i kullanarak SRP'ye uyum sağlar.
mixin PaymentMethodFormMixin on ChangeNotifier {
  String _formSelectedType = 'nakit';
  String get formSelectedType => _formSelectedType;

  int _formSelectedColorIndex = 0;
  int get formSelectedColorIndex => _formSelectedColorIndex;

  void setFormType(String type) {
    if (_formSelectedType != type) {
      _formSelectedType = type;
      notifyListeners();
    }
  }

  void setFormColorIndex(int index) {
    if (_formSelectedColorIndex != index) {
      _formSelectedColorIndex = index;
      notifyListeners();
    }
  }

  void initializeFormState({String? editType, int? editColorIndex}) {
    if (editType != null) _formSelectedType = editType;
    if (editColorIndex != null) _formSelectedColorIndex = editColorIndex;
    notifyListeners();
  }

  void resetFormState() {
    _formSelectedType = 'nakit';
    _formSelectedColorIndex = 0;
    notifyListeners();
  }
}
