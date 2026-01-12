import 'package:flutter/foundation.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../assets/data/models/asset_model.dart';

/// Ödeme yöntemleri geri dönüşüm kutusu için state
class PaymentMethodRecycleBinState extends ChangeNotifier {
  List<PaymentMethod> _deletedPaymentMethods = [];
  List<PaymentMethod> get deletedPaymentMethods => _deletedPaymentMethods;

  set deletedPaymentMethods(List<PaymentMethod> value) {
    _deletedPaymentMethods = value;
    notifyListeners();
  }

  void removeMethod(PaymentMethod method) {
    _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
    notifyListeners();
  }

  void clearBin() {
    _deletedPaymentMethods.clear();
    notifyListeners();
  }

  void init(List<PaymentMethod> methods) {
    _deletedPaymentMethods = List.from(methods);
  }
}

/// Varlıklar geri dönüşüm kutusu için state
class AssetRecycleBinState extends ChangeNotifier {
  List<Asset> _deletedAssets = [];
  List<Asset> get deletedAssets => _deletedAssets;

  set deletedAssets(List<Asset> value) {
    _deletedAssets = value;
    notifyListeners();
  }

  void removeAsset(Asset asset) {
    _deletedAssets.remove(asset);
    notifyListeners();
  }

  void clearBin() {
    _deletedAssets.clear();
    notifyListeners();
  }

  void init(List<Asset> assets) {
    _deletedAssets = assets; // List reference or copy depends on usage
  }
}
