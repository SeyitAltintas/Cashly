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

  /// Silinen harcamayı geri yükle (bakiye güncelleme ile)
  void restoreHarcama(Map<String, dynamic> harcama) {
    var hedef = tumHarcamalarHam.firstWhere((element) => element == harcama);
    hedef['silindi'] = false;
    _silinenHarcamalar.remove(harcama);

    // Ödeme yönteminin bakiyesini güncelle
    final paymentMethodId = harcama['odemeYontemiId'];
    if (paymentMethodId != null) {
      final pmIndex = odemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        final pm = odemeYontemleri[pmIndex];
        final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
        double newBalance;
        if (pm.type == 'kredi') {
          newBalance = pm.balance + amount;
        } else {
          newBalance = pm.balance - amount;
        }
        odemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
      }
    }
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

  /// Tümünü geri yükle (bakiye güncelleme ile)
  void restoreAll() {
    for (var harcama in List.from(_silinenHarcamalar)) {
      var hedef = tumHarcamalarHam.firstWhere((element) => element == harcama);
      hedef['silindi'] = false;

      // Ödeme yönteminin bakiyesini güncelle
      final paymentMethodId = harcama['odemeYontemiId'];
      if (paymentMethodId != null) {
        final pmIndex = odemeYontemleri.indexWhere(
          (p) => p.id == paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = odemeYontemleri[pmIndex];
          final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
          double newBalance;
          if (pm.type == 'kredi') {
            newBalance = pm.balance + amount;
          } else {
            newBalance = pm.balance - amount;
          }
          odemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
        }
      }
    }
    _silinenHarcamalar.clear();
    notifyListeners();
  }
}
