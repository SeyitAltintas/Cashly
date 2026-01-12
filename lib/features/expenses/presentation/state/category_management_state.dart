import 'package:flutter/foundation.dart';

/// Kategori yönetimi için ChangeNotifier state yöneticisi
class CategoryManagementState extends ChangeNotifier {
  List<Map<String, dynamic>> _kategoriler = [];
  List<Map<String, dynamic>> get kategoriler => _kategoriler;
  set kategoriler(List<Map<String, dynamic>> value) {
    _kategoriler = value;
    notifyListeners();
  }

  String _secilenIkon = 'category';
  String get secilenIkon => _secilenIkon;
  set secilenIkon(String value) {
    _secilenIkon = value;
    notifyListeners();
  }

  void addKategori(String isim, String ikon) {
    _kategoriler.add({'isim': isim, 'ikon': ikon});
    notifyListeners();
  }

  void removeKategoriAt(int index) {
    _kategoriler.removeAt(index);
    notifyListeners();
  }

  void reorderKategoriler(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final kategori = _kategoriler.removeAt(oldIndex);
    _kategoriler.insert(newIndex, kategori);
    notifyListeners();
  }

  void resetToDefault(List<Map<String, dynamic>> defaultCategories) {
    _kategoriler = List.from(defaultCategories);
    notifyListeners();
  }
}
