import 'package:flutter/foundation.dart';
import '../../data/models/asset_model.dart';

/// Varlıklar sayfası state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
class AssetPageState extends ChangeNotifier {
  // Varlık listeleri (referanslar)
  List<Asset> assets = [];
  List<Asset> deletedAssets = [];
  List<Asset> filtrelenmisVarliklar = [];

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

  /// Varlık ekle
  void addAsset(Asset asset) {
    assets.add(asset);
    filtrele('');
  }

  /// Varlık sil (soft delete)
  void deleteAsset(Asset asset) {
    asset.isDeleted = true;
    deletedAssets.add(asset);
    assets.removeWhere((a) => a.id == asset.id);
    filtrele('');
  }

  /// Varlık geri yükle
  void restoreAsset(Asset asset) {
    deletedAssets.removeWhere((a) => a.id == asset.id);
    asset.isDeleted = false;
    assets.add(asset);
    filtrele('');
  }

  /// Kalıcı sil
  void permanentDeleteAsset(Asset asset) {
    deletedAssets.removeWhere((a) => a.id == asset.id);
    notifyListeners();
  }

  /// Çöp kutusunu boşalt
  void emptyBin() {
    deletedAssets.clear();
    notifyListeners();
  }

  /// Varlık güncelle
  void updateAsset(Asset updatedAsset) {
    final index = assets.indexWhere((a) => a.id == updatedAsset.id);
    if (index != -1) {
      assets[index] = updatedAsset;
      filtrele('');
    }
  }

  /// Filtreleme yap
  void filtrele(String aramaMetni) {
    if (_aramaModu && aramaMetni.isNotEmpty) {
      String aranan = aramaMetni.toLowerCase();
      filtrelenmisVarliklar = assets.where((asset) {
        return asset.name.toLowerCase().contains(aranan) ||
            asset.category.toLowerCase().contains(aranan) ||
            (asset.type?.toLowerCase().contains(aranan) ?? false);
      }).toList();
    } else {
      filtrelenmisVarliklar = List.from(assets);
    }
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
