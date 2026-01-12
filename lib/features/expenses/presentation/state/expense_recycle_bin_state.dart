import 'package:flutter/foundation.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';

/// RecycleBinPage için ChangeNotifier state yöneticisi
/// Silinen harcamalar ve ödeme yöntemlerini merkezi olarak yönetir
class ExpenseRecycleBinState extends ChangeNotifier {
  // Silinen harcamalar
  List<Map<String, dynamic>> _silinenHarcamalar = [];
  List<Map<String, dynamic>> get silinenHarcamalar => _silinenHarcamalar;
  set silinenHarcamalar(List<Map<String, dynamic>> value) {
    _silinenHarcamalar = value;
    notifyListeners();
  }

  // Tüm harcamalar (ham)
  List<Map<String, dynamic>> _tumHarcamalarHam = [];
  List<Map<String, dynamic>> get tumHarcamalarHam => _tumHarcamalarHam;
  set tumHarcamalarHam(List<Map<String, dynamic>> value) {
    _tumHarcamalarHam = value;
  }

  // Ödeme yöntemleri
  List<PaymentMethod> _odemeYontemleri = [];
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;
  set odemeYontemleri(List<PaymentMethod> value) {
    _odemeYontemleri = value;
  }

  /// Silinen harcamayı geri yükle
  void restoreHarcama(Map<String, dynamic> harcama) {
    var hedef = _tumHarcamalarHam.firstWhere((element) => element == harcama);
    hedef['silindi'] = false;
    _silinenHarcamalar.remove(harcama);
    notifyListeners();
  }

  /// Harcamayı kalıcı sil
  void permanentDeleteHarcama(Map<String, dynamic> harcama) {
    _tumHarcamalarHam.remove(harcama);
    _silinenHarcamalar.remove(harcama);
    notifyListeners();
  }

  /// Çöpü boşalt
  void emptyBin() {
    _tumHarcamalarHam.removeWhere((element) => element['silindi'] == true);
    _silinenHarcamalar.clear();
    notifyListeners();
  }

  /// Tümünü geri yükle
  void restoreAll() {
    for (var harcama in _silinenHarcamalar) {
      var hedef = _tumHarcamalarHam.firstWhere((element) => element == harcama);
      hedef['silindi'] = false;
    }
    _silinenHarcamalar.clear();
    notifyListeners();
  }
}
