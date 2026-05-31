import 'package:flutter/foundation.dart';

mixin ExpenseFormMixin on ChangeNotifier {

  // Form: Seçilen tarih
  DateTime _formSelectedDate = DateTime.now();
  DateTime get formSelectedDate => _formSelectedDate;
  void setFormDate(DateTime date) {
    if (_formSelectedDate != date) {
      _formSelectedDate = date;
      notifyListeners();
    }
  }

  // Form: Seçilen kategori
  String _formSelectedCategory = '';
  String get formSelectedCategory => _formSelectedCategory;
  void setFormCategory(String category) {
    if (_formSelectedCategory != category) {
      _formSelectedCategory = category;
      notifyListeners();
    }
  }

  // Form: Seçilen ödeme yöntemi
  String? _formSelectedPaymentMethodId;
  String? get formSelectedPaymentMethodId => _formSelectedPaymentMethodId;
  void setFormPaymentMethod(String? paymentMethodId) {
    if (_formSelectedPaymentMethodId != paymentMethodId) {
      _formSelectedPaymentMethodId = paymentMethodId;
      notifyListeners();
    }
  }

  /// Form state'ini initialize et
  void initializeFormState({
    required String defaultCategory,
    String? defaultPaymentMethodId,
    DateTime? editDate,
    String? editCategory,
    String? editPaymentMethodId,
  }) {
    _formSelectedCategory = editCategory ?? defaultCategory;
    _formSelectedPaymentMethodId =
        editPaymentMethodId ?? defaultPaymentMethodId;
    if (editDate != null) {
      _formSelectedDate = editDate;
    } else {
      _formSelectedDate = DateTime.now();
    }
    notifyListeners();
  }

  /// Form state'ini sıfırla
  void resetFormState() {
    _formSelectedDate = DateTime.now();
    _formSelectedCategory = '';
    _formSelectedPaymentMethodId = null;
    notifyListeners();
  }
}
