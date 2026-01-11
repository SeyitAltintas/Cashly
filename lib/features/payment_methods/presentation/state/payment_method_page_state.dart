import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/payment_method_model.dart';

/// Ödeme yöntemleri sayfası state yöneticisi
/// ChangeNotifier kullanarak granular rebuild sağlar
class PaymentMethodPageState extends ChangeNotifier {
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

  // Seçilen tür filtresi
  String _secilenTur = 'Tümü';
  String get secilenTur => _secilenTur;
  set secilenTur(String value) {
    if (_secilenTur != value) {
      _secilenTur = value;
      notifyListeners();
    }
  }

  /// Filtrelenmiş ödeme yöntemlerini hesapla
  List<PaymentMethod> filtrelenmisOdemeYontemleri({
    required List<PaymentMethod> tumOdemeYontemleri,
    required String aramaMetni,
  }) {
    return tumOdemeYontemleri.where((pm) {
      if (pm.isDeleted) return false;

      // Tür filtresi
      if (_secilenTur != 'Tümü' && pm.type != _secilenTur) {
        return false;
      }

      // Arama filtresi
      if (aramaMetni.isEmpty) return true;
      return pm.name.toLowerCase().contains(aramaMetni.toLowerCase()) ||
          pm.type.toLowerCase().contains(aramaMetni.toLowerCase());
    }).toList();
  }

  /// Toplam bakiye hesapla
  double toplamBakiye(List<PaymentMethod> odemeYontemleri) {
    return odemeYontemleri
        .where((pm) => !pm.isDeleted && pm.type != 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
  }

  /// Toplam borç hesapla
  double toplamBorc(List<PaymentMethod> odemeYontemleri) {
    return odemeYontemleri
        .where((pm) => !pm.isDeleted && pm.type == 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
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
