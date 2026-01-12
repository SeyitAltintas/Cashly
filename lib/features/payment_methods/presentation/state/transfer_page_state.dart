import 'package:flutter/foundation.dart';
import '../../data/models/payment_method_model.dart';

/// TransferPage için ChangeNotifier state yöneticisi
/// Hesap seçimleri, tarih ve başarı mesajını merkezi olarak yönetir
class TransferPageState extends ChangeNotifier {
  // Gönderen hesap ID
  String? _fromAccountId;
  String? get fromAccountId => _fromAccountId;
  set fromAccountId(String? value) {
    if (_fromAccountId != value) {
      _fromAccountId = value;
      notifyListeners();
    }
  }

  // Alan hesap ID
  String? _toAccountId;
  String? get toAccountId => _toAccountId;
  set toAccountId(String? value) {
    if (_toAccountId != value) {
      _toAccountId = value;
      notifyListeners();
    }
  }

  // Seçilen tarih
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  // Başarı mesajı
  String? _successMessage;
  String? get successMessage => _successMessage;
  set successMessage(String? value) {
    _successMessage = value;
    notifyListeners();
  }

  // Lokal ödeme yöntemleri listesi
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  set paymentMethods(List<PaymentMethod> value) {
    _paymentMethods = value;
    notifyListeners();
  }

  /// Ödeme yöntemlerini başlat
  void initPaymentMethods(List<PaymentMethod> methods) {
    _paymentMethods = methods.map((pm) => pm.copyWith()).toList();
  }

  /// Formu sıfırla
  void resetForm() {
    _fromAccountId = null;
    _toAccountId = null;
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  /// Hesap bakiyesini güncelle
  void updateAccountBalance(String accountId, double newBalance) {
    final index = _paymentMethods.indexWhere((pm) => pm.id == accountId);
    if (index != -1) {
      _paymentMethods[index] = _paymentMethods[index].copyWith(
        balance: newBalance,
      );
      notifyListeners();
    }
  }

  /// Başarı mesajını temizle
  void clearSuccessMessage() {
    if (_successMessage != null) {
      _successMessage = null;
      notifyListeners();
    }
  }
}
