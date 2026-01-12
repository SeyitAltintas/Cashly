import 'package:flutter/foundation.dart';
import '../../data/models/income_model.dart';

/// Gelir çöp kutusu için ChangeNotifier state yöneticisi
class IncomeRecycleBinState extends ChangeNotifier {
  List<Income> _silinenGelirler = [];
  List<Income> get silinenGelirler => _silinenGelirler;
  set silinenGelirler(List<Income> value) {
    _silinenGelirler = value;
    notifyListeners();
  }

  List<Income> _tumGelirler = [];
  List<Income> get tumGelirler => _tumGelirler;
  set tumGelirler(List<Income> value) {
    _tumGelirler = value;
  }

  void restoreGelir(Income gelir) {
    int index = _tumGelirler.indexWhere((g) => g.id == gelir.id);
    if (index != -1) {
      _tumGelirler[index] = gelir.copyWith(isDeleted: false);
    }
    _silinenGelirler.removeWhere((g) => g.id == gelir.id);
    notifyListeners();
  }

  void permanentDeleteGelir(Income gelir) {
    _tumGelirler.removeWhere((g) => g.id == gelir.id);
    _silinenGelirler.removeWhere((g) => g.id == gelir.id);
    notifyListeners();
  }

  void emptyBin() {
    _tumGelirler.removeWhere((g) => g.isDeleted);
    _silinenGelirler.clear();
    notifyListeners();
  }

  void restoreAll() {
    for (var gelir in _silinenGelirler) {
      int index = _tumGelirler.indexWhere((g) => g.id == gelir.id);
      if (index != -1) {
        _tumGelirler[index] = gelir.copyWith(isDeleted: false);
      }
    }
    _silinenGelirler.clear();
    notifyListeners();
  }
}
