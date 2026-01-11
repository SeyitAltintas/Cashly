import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/income_model.dart';

/// Gelirler sayfası state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
class IncomePageState extends ChangeNotifier {
  // Arama modu state'i
  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
    }
  }

  // Loading state'i
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Seçilen ay state'i
  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;
  set secilenAy(DateTime value) {
    if (_secilenAy != value) {
      _secilenAy = value;
      notifyListeners();
    }
  }

  /// Filtrelenmiş gelirleri hesapla
  List<Income> filtrelenmisGelirler({
    required List<Income> tumGelirler,
    required String aramaMetni,
  }) {
    return tumGelirler.where((g) {
      if (g.isDeleted) return false;
      if (g.date.year != _secilenAy.year || g.date.month != _secilenAy.month) {
        return false;
      }
      if (aramaMetni.isEmpty) return true;
      return g.name.toLowerCase().contains(aramaMetni.toLowerCase()) ||
          g.category.toLowerCase().contains(aramaMetni.toLowerCase());
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Önceki aya git
  void oncekiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month - 1);
    notifyListeners();
  }

  /// Sonraki aya git
  void sonrakiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month + 1);
    notifyListeners();
  }

  /// Arama modunu toggle et
  void toggleAramaModu() {
    _aramaModu = !_aramaModu;
    notifyListeners();
  }

  /// Loading durumunu kapat
  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
