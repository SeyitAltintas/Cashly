import 'package:flutter/foundation.dart';

/// Transfer sayfasına (TransferPage) ait geçici UI state'i yönetir.
/// PaymentMethodsController bu mixin'i kullanarak SRP'ye uyum sağlar.
mixin PaymentMethodTransferMixin on ChangeNotifier {
  String? _transferFromAccountId;
  String? get transferFromAccountId => _transferFromAccountId;

  String? _transferToAccountId;
  String? get transferToAccountId => _transferToAccountId;

  DateTime _transferSelectedDate = DateTime.now();
  DateTime get transferSelectedDate => _transferSelectedDate;

  String? _transferSuccessMessage;
  String? get transferSuccessMessage => _transferSuccessMessage;

  void setTransferFromAccount(String? accountId) {
    if (_transferFromAccountId != accountId) {
      _transferFromAccountId = accountId;
      notifyListeners();
    }
  }

  void setTransferToAccount(String? accountId) {
    if (_transferToAccountId != accountId) {
      _transferToAccountId = accountId;
      notifyListeners();
    }
  }

  void setTransferDate(DateTime date) {
    _transferSelectedDate = date;
    notifyListeners();
  }

  void setTransferSuccessMessage(String? message) {
    _transferSuccessMessage = message;
    notifyListeners();
  }

  void clearTransferSuccessMessage() {
    if (_transferSuccessMessage != null) {
      _transferSuccessMessage = null;
      notifyListeners();
    }
  }

  void resetTransferForm() {
    _transferFromAccountId = null;
    _transferToAccountId = null;
    _transferSelectedDate = DateTime.now();
    notifyListeners();
  }

  // Alias'lar — transfer_page.dart uyumu için
  void setTransferFromAccountId(String? accountId) =>
      setTransferFromAccount(accountId);
  void setTransferToAccountId(String? accountId) =>
      setTransferToAccount(accountId);
  void setTransferSelectedDate(DateTime date) => setTransferDate(date);
}
