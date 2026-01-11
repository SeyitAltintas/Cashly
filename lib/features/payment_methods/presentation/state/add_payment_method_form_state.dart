import 'package:flutter/foundation.dart';

/// Ödeme yöntemi ekleme formu state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
class AddPaymentMethodFormState extends ChangeNotifier {
  // Seçilen tür (nakit, banka, kredi)
  String _selectedType = 'nakit';
  String get selectedType => _selectedType;
  set selectedType(String value) {
    if (_selectedType != value) {
      _selectedType = value;
      notifyListeners();
    }
  }

  // Seçilen renk index'i
  int _selectedColorIndex = 0;
  int get selectedColorIndex => _selectedColorIndex;
  set selectedColorIndex(int value) {
    if (_selectedColorIndex != value) {
      _selectedColorIndex = value;
      notifyListeners();
    }
  }

  /// State'i başlangıç değerleri ile initialize et
  void initialize({String? editType, int? editColorIndex}) {
    if (editType != null) _selectedType = editType;
    if (editColorIndex != null) _selectedColorIndex = editColorIndex;
  }
}
