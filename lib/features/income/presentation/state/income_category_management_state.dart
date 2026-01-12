import 'package:flutter/foundation.dart';

/// Gelir kategori yönetimi için ChangeNotifier state yöneticisi
class IncomeCategoryManagementState extends ChangeNotifier {
  List<Map<String, dynamic>> _kategoriler = [];
  List<Map<String, dynamic>> get kategoriler => _kategoriler;
  set kategoriler(List<Map<String, dynamic>> value) {
    _kategoriler = value;
    notifyListeners();
  }

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;
  set hasChanges(bool value) {
    _hasChanges = value;
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
}
