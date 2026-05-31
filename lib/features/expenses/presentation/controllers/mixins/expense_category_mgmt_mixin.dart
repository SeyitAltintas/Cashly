import 'package:flutter/foundation.dart';

mixin ExpenseCategoryMgmtMixin on ChangeNotifier {

  // Kategori listesi
  List<Map<String, dynamic>> _catMgmtKategoriler = [];
  List<Map<String, dynamic>> get catMgmtKategoriler => _catMgmtKategoriler;
  void setCatMgmtKategoriler(List<Map<String, dynamic>> value) {
    _catMgmtKategoriler = value;
    notifyListeners();
  }

  // Seçilen ikon
  String _catMgmtSecilenIkon = 'category';
  String get catMgmtSecilenIkon => _catMgmtSecilenIkon;
  void setCatMgmtSecilenIkon(String value) {
    _catMgmtSecilenIkon = value;
    notifyListeners();
  }

  /// Kategori ekle
  void addCatMgmtKategori(String isim, String ikon) {
    _catMgmtKategoriler.add({'isim': isim, 'ikon': ikon});
    notifyListeners();
  }

  /// Kategori sil
  void removeCatMgmtKategoriAt(int index) {
    if (index >= 0 && index < _catMgmtKategoriler.length) {
      _catMgmtKategoriler.removeAt(index);
      notifyListeners();
    }
  }

  /// Kategorileri yeniden sırala
  void reorderCatMgmtKategoriler(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final kategori = _catMgmtKategoriler.removeAt(oldIndex);
    _catMgmtKategoriler.insert(newIndex, kategori);
    notifyListeners();
  }

  /// Varsayılana sıfırla
  void resetCatMgmtToDefault(List<Map<String, dynamic>> defaultCategories) {
    _catMgmtKategoriler = List.from(defaultCategories);
    notifyListeners();
  }
}
