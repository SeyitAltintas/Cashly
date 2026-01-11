import 'package:flutter/foundation.dart';

/// Harcama ekleme formu state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
class AddExpenseFormState extends ChangeNotifier {
  // Seçilen tarih
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    if (_selectedDate != value) {
      _selectedDate = value;
      notifyListeners();
    }
  }

  // Seçilen kategori
  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;
  set selectedCategory(String value) {
    if (_selectedCategory != value) {
      _selectedCategory = value;
      notifyListeners();
    }
  }

  // Seçilen ödeme yöntemi
  String? _selectedPaymentMethodId;
  String? get selectedPaymentMethodId => _selectedPaymentMethodId;
  set selectedPaymentMethodId(String? value) {
    if (_selectedPaymentMethodId != value) {
      _selectedPaymentMethodId = value;
      notifyListeners();
    }
  }

  /// State'i başlangıç değerleri ile initialize et
  void initialize({
    required String defaultCategory,
    String? defaultPaymentMethodId,
    DateTime? editDate,
    String? editCategory,
    String? editPaymentMethodId,
  }) {
    _selectedCategory = editCategory ?? defaultCategory;
    _selectedPaymentMethodId = editPaymentMethodId ?? defaultPaymentMethodId;
    if (editDate != null) {
      _selectedDate = editDate;
    }
  }
}
