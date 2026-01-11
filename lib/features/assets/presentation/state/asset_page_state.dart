import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/asset_model.dart';

/// Varlıklar sayfası state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
class AssetPageState extends ChangeNotifier {
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

  // Seçilen kategori
  String _secilenKategori = 'Tümü';
  String get secilenKategori => _secilenKategori;
  set secilenKategori(String value) {
    if (_secilenKategori != value) {
      _secilenKategori = value;
      notifyListeners();
    }
  }

  /// Filtrelenmiş varlıkları hesapla
  List<Asset> filtrelenmisVarliklar({
    required List<Asset> tumVarliklar,
    required String aramaMetni,
  }) {
    return tumVarliklar.where((v) {
      if (v.isDeleted) return false;

      // Kategori filtresi
      if (_secilenKategori != 'Tümü' && v.type != _secilenKategori) {
        return false;
      }

      // Arama filtresi
      if (aramaMetni.isEmpty) return true;
      final typeLower = v.type?.toLowerCase() ?? '';
      return v.name.toLowerCase().contains(aramaMetni.toLowerCase()) ||
          typeLower.contains(aramaMetni.toLowerCase());
    }).toList();
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
