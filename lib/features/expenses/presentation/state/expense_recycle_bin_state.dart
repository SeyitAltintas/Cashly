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
  List<Map<String, dynamic>> tumHarcamalarHam = [];

  // Ödeme yöntemleri
  List<PaymentMethod> odemeYontemleri = [];

  /// Silinen harcamayı geri yükle
  void restoreHarcama(Map<String, dynamic> harcama) {
    var hedef = tumHarcamalarHam.firstWhere((element) => element == harcama);
    hedef['silindi'] = false;
    _silinenHarcamalar.remove(harcama);
    notifyListeners();
  }

  /// Harcamayı kalıcı sil
  void permanentDeleteHarcama(Map<String, dynamic> harcama) {
    tumHarcamalarHam.remove(harcama);
    _silinenHarcamalar.remove(harcama);
    notifyListeners();
  }

  /// Çöpü boşalt
  void emptyBin() {
    tumHarcamalarHam.removeWhere((element) => element['silindi'] == true);
    _silinenHarcamalar.clear();
    notifyListeners();
  }

  /// Tümünü geri yükle
  void restoreAll() {
    for (var harcama in _silinenHarcamalar) {
      var hedef = tumHarcamalarHam.firstWhere((element) => element == harcama);
      hedef['silindi'] = false;
    }
    _silinenHarcamalar.clear();
    notifyListeners();
  }
}
