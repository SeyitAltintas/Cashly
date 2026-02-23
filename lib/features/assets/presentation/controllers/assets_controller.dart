import 'package:flutter/foundation.dart';
import '../../data/models/asset_model.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

/// Varlıklar Controller
/// Repository ile entegre, ChangeNotifier tabanlı state yönetimi sağlar.
/// Bu controller AssetPageState'in yerini alır.
class AssetsController extends ChangeNotifier {
  final AssetRepository _assetRepository;
  final String userId;

  AssetsController({
    required AssetRepository assetRepository,
    required this.userId,
  }) : _assetRepository = assetRepository;

  // ===== STATE =====

  // ===== FORM STATE (AddAssetFormState'ten taşındı) =====

  // Form: Seçilen kategori (Döviz, Kripto, Hisse, Fiziksel)
  String _formSelectedCategory = 'Döviz';
  String get formSelectedCategory => _formSelectedCategory;
  void setFormCategory(String category) {
    if (_formSelectedCategory != category) {
      _formSelectedCategory = category;
      _formSelectedType = null; // Kategori değişince tür sıfırlanır
      notifyListeners();
    }
  }

  // Form: Seçilen tür (USD, EUR, BTC, etc.)
  String? _formSelectedType;
  String? get formSelectedType => _formSelectedType;
  void setFormType(String? type) {
    if (_formSelectedType != type) {
      _formSelectedType = type;
      notifyListeners();
    }
  }

  // Form: Özel ad (Diğer seçildiğinde)
  String _formCustomName = '';
  String get formCustomName => _formCustomName;
  void setFormCustomName(String name) {
    if (_formCustomName != name) {
      _formCustomName = name;
      notifyListeners();
    }
  }

  // Form: Alış tarihi
  DateTime? _formPurchaseDate;
  DateTime? get formPurchaseDate => _formPurchaseDate;
  void setFormPurchaseDate(DateTime? date) {
    if (_formPurchaseDate != date) {
      _formPurchaseDate = date;
      notifyListeners();
    }
  }

  // Form: Loading state (API fiyat çekerken)
  bool _formIsLoading = false;
  bool get formIsLoading => _formIsLoading;
  void setFormLoading(bool loading) {
    if (_formIsLoading != loading) {
      _formIsLoading = loading;
      notifyListeners();
    }
  }

  // Form: Hata mesajı
  String? _formErrorMessage;
  String? get formErrorMessage => _formErrorMessage;
  void setFormError(String? message) {
    _formErrorMessage = message;
    notifyListeners();
  }

  void clearFormError() {
    if (_formErrorMessage != null) {
      _formErrorMessage = null;
      notifyListeners();
    }
  }

  /// Form state'ini initialize et
  void initializeFormState({
    String? editCategory,
    String? editType,
    String? editCustomName,
    DateTime? editPurchaseDate,
  }) {
    if (editCategory != null) _formSelectedCategory = editCategory;
    _formSelectedType = editType;
    _formCustomName = editCustomName ?? '';
    _formPurchaseDate = editPurchaseDate;
    notifyListeners();
  }

  /// Form state'ini sıfırla
  void resetFormState() {
    _formSelectedCategory = 'Döviz';
    _formSelectedType = null;
    _formCustomName = '';
    _formPurchaseDate = null;
    _formIsLoading = false;
    _formErrorMessage = null;
    notifyListeners();
  }

  // ===== ANA STATE =====

  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
    }
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  String _secilenKategori = 'Tümü';
  String get secilenKategori => _secilenKategori;
  set secilenKategori(String value) {
    if (_secilenKategori != value) {
      _secilenKategori = value;
      notifyListeners();
    }
  }

  List<Asset> _assets = [];
  List<Asset> get assets => _assets;
  set assets(List<Asset> value) {
    _assets = value;
    notifyListeners();
  }

  List<Asset> _deletedAssets = [];
  List<Asset> get deletedAssets => _deletedAssets;

  List<Asset> _filtrelenmisVarliklar = [];
  List<Asset> get filtrelenmisVarliklar => _filtrelenmisVarliklar;

  double get toplamDeger {
    final cur = getIt<CurrencyService>();
    return _assets
        .where((a) => !a.isDeleted)
        .fold(
          0.0,
          (sum, a) =>
              sum + cur.convert(a.amount, a.paraBirimi, cur.currentCurrency),
        );
  }

  // ===== REPOSITORY İŞLEMLERİ =====

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final assetsData = _assetRepository.getAssets(userId);
      _assets = assetsData.map((m) => Asset.fromMap(m)).toList();

      final deletedData = _assetRepository.getDeletedAssets(userId);
      _deletedAssets = deletedData.map((m) => Asset.fromMap(m)).toList();

      filtrele('');
    } catch (e, s) {
      ErrorHandler.logError('AssetsController.loadData', e, s);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAssets() async {
    try {
      final data = _assets.map((a) => a.toMap()).toList();
      await _assetRepository.saveAssets(userId, data);
    } catch (e, s) {
      ErrorHandler.logError('AssetsController.saveAssets', e, s);
      throw DatabaseException.writeFailed(e);
    }
  }

  Future<void> saveDeletedAssets() async {
    try {
      final data = _deletedAssets.map((a) => a.toMap()).toList();
      await _assetRepository.saveDeletedAssets(userId, data);
    } catch (e, s) {
      ErrorHandler.logError('AssetsController.saveDeletedAssets', e, s);
      throw DatabaseException.writeFailed(e);
    }
  }

  // ===== FİLTRELEME =====

  void filtrele(String aramaMetni) {
    if (_aramaModu && aramaMetni.isNotEmpty) {
      String aranan = aramaMetni.toLowerCase();
      _filtrelenmisVarliklar = _assets.where((asset) {
        if (asset.isDeleted) return false;
        return asset.name.toLowerCase().contains(aranan) ||
            asset.category.toLowerCase().contains(aranan) ||
            (asset.type?.toLowerCase().contains(aranan) ?? false);
      }).toList();
    } else {
      _filtrelenmisVarliklar = _assets.where((a) => !a.isDeleted).toList();
    }
    notifyListeners();
  }

  void toggleAramaModu() {
    _aramaModu = !_aramaModu;
    notifyListeners();
  }

  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== CRUD İŞLEMLERİ =====

  void addAsset(Asset asset) {
    _assets.add(asset);
    filtrele('');
  }

  void deleteAsset(Asset asset) {
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      final deletedAsset = _assets[index].copyWith(isDeleted: true);
      _assets.removeAt(index);
      _deletedAssets.add(deletedAsset);
      filtrele('');
    }
  }

  void restoreAsset(Asset asset) {
    _deletedAssets.removeWhere((a) => a.id == asset.id);
    final restoredAsset = asset.copyWith(isDeleted: false);
    _assets.add(restoredAsset);
    filtrele('');
  }

  void permanentDeleteAsset(Asset asset) {
    _deletedAssets.removeWhere((a) => a.id == asset.id);
    notifyListeners();
  }

  void emptyBin() {
    _deletedAssets.clear();
    notifyListeners();
  }

  void restoreAll() {
    for (final asset in _deletedAssets) {
      _assets.add(asset.copyWith(isDeleted: false));
    }
    _deletedAssets.clear();
    filtrele('');
  }

  void updateAsset(Asset updatedAsset) {
    final index = _assets.indexWhere((a) => a.id == updatedAsset.id);
    if (index != -1) {
      _assets[index] = updatedAsset;
      filtrele('');
    }
  }

  /// Widget prop'larından veriyi yükle (geriye dönük uyumluluk)
  void setAssetsFromWidget(List<Asset> assets, List<Asset> deletedAssets) {
    _assets = List.from(assets);
    _deletedAssets = List.from(deletedAssets);
    _filtrelenmisVarliklar = List.from(_assets.where((a) => !a.isDeleted));
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
