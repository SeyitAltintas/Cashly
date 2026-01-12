import 'package:flutter/foundation.dart';
import '../../data/models/payment_method_model.dart';

/// Ödeme yöntemleri sayfası state yöneticisi
class PaymentMethodPageState extends ChangeNotifier {
  // Veri listeleri
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentMethod> _deletedPaymentMethods = [];
  List<PaymentMethod> _filteredMethods = [];

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<PaymentMethod> get deletedPaymentMethods => _deletedPaymentMethods;
  List<PaymentMethod> get filteredMethods => _filteredMethods;

  // Arama modu state'i
  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
      _filtrele();
    }
  }

  // Arama metni
  String _aramaMetni = '';
  String get aramaMetni => _aramaMetni;
  set aramaMetni(String value) {
    if (_aramaMetni != value) {
      _aramaMetni = value;
      _filtrele();
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

  // Başlangıç verilerini yükle
  void initData(
    List<PaymentMethod> methods,
    List<PaymentMethod> deletedMethods,
  ) {
    _paymentMethods = List.from(methods);
    _deletedPaymentMethods = List.from(deletedMethods);
    _filteredMethods = List.from(methods);
    _isLoading = false;
    notifyListeners();
  }

  // Listeleri güncelleme metodları
  void addMethod(PaymentMethod method) {
    _paymentMethods.add(method);
    _filtrele();
    notifyListeners();
  }

  void updateMethod(PaymentMethod method) {
    final index = _paymentMethods.indexWhere((p) => p.id == method.id);
    if (index != -1) {
      _paymentMethods[index] = method;
      _filtrele();
      notifyListeners();
    }
  }

  void moveToBin(PaymentMethod method) {
    _paymentMethods.removeWhere((p) => p.id == method.id);
    final deleted = method.copyWith(isDeleted: true);
    _deletedPaymentMethods.add(deleted);
    _filtrele();
    notifyListeners();
  }

  void restoreMethod(PaymentMethod method) {
    _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
    final restored = method.copyWith(isDeleted: false);
    _paymentMethods.add(restored);
    _filtrele();
    notifyListeners();
  }

  void permanentDelete(PaymentMethod method) {
    _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
    notifyListeners();
  }

  void emptyBin() {
    _deletedPaymentMethods.clear();
    notifyListeners();
  }

  // Bin syncing methods - used when returning from bin page
  void syncFromBin(List<PaymentMethod> updatedDeletedList) {
    // Find items that were restored (present in current deleted list but missing in updated deleted list)
    // Actually simplicity: just update deleted list and check if any restore happens?
    // Better: let bin page call restoreMethod/permanentDelete.
    // If bin page modifies the passed list directly (reference), we just need to notify listeners.
    // But better to have explicit calls.
    // For now assuming callback approach is used.
    _deletedPaymentMethods = List.from(updatedDeletedList);
    notifyListeners();
  }

  void _filtrele() {
    if (_aramaModu && _aramaMetni.isNotEmpty) {
      final text = _aramaMetni.toLowerCase();
      _filteredMethods = _paymentMethods.where((pm) {
        return pm.name.toLowerCase().contains(text) ||
            pm.typeDisplayName.toLowerCase().contains(text);
      }).toList();
    } else {
      _filteredMethods = List.from(_paymentMethods);
    }
    notifyListeners(); // _filtrele genellikle setter'lar içinde çağrılır, ama burada liste değişimi için de gerekli
  }

  /// Toplam bakiye hesapla
  double get totalBalance {
    return _filteredMethods
        .where((pm) => pm.type != 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
  }

  /// Toplam borç hesapla
  double get totalDebt {
    return _filteredMethods
        .where((pm) => pm.type == 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
  }

  /// Loading durumunu kapat
  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
