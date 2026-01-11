import 'package:flutter/foundation.dart';

/// Varlık ekleme formu state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
class AddAssetFormState extends ChangeNotifier {
  // Seçilen kategori (Döviz, Kripto, Hisse, Fiziksel)
  String _selectedCategory = 'Döviz';
  String get selectedCategory => _selectedCategory;
  set selectedCategory(String value) {
    if (_selectedCategory != value) {
      _selectedCategory = value;
      _selectedType = null; // Kategori değişince tür sıfırlanır
      notifyListeners();
    }
  }

  // Seçilen tür (USD, EUR, BTC, etc.)
  String? _selectedType;
  String? get selectedType => _selectedType;
  set selectedType(String? value) {
    if (_selectedType != value) {
      _selectedType = value;
      notifyListeners();
    }
  }

  // Özel ad (Diğer seçildiğinde)
  String _customName = '';
  String get customName => _customName;
  set customName(String value) {
    if (_customName != value) {
      _customName = value;
      notifyListeners();
    }
  }

  // Loading state (API fiyat çekerken)
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Alış tarihi
  DateTime? _purchaseDate;
  DateTime? get purchaseDate => _purchaseDate;
  set purchaseDate(DateTime? value) {
    if (_purchaseDate != value) {
      _purchaseDate = value;
      notifyListeners();
    }
  }

  // Hata mesajı
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// State'i başlangıç değerleri ile initialize et
  void initialize({
    String? editCategory,
    String? editType,
    String? editCustomName,
    DateTime? editPurchaseDate,
  }) {
    if (editCategory != null) _selectedCategory = editCategory;
    _selectedType = editType;
    _customName = editCustomName ?? '';
    _purchaseDate = editPurchaseDate;
  }
}
