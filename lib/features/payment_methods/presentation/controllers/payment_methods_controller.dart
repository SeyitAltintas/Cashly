import 'package:flutter/foundation.dart';
import '../../data/models/payment_method_model.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

/// Ödeme Yöntemleri Controller
/// Repository ile entegre, ChangeNotifier tabanlı state yönetimi sağlar.
/// Bu controller PaymentMethodPageState'in yerini alır.
class PaymentMethodsController extends ChangeNotifier {
  final PaymentMethodRepository _paymentMethodRepository;
  final String userId;

  PaymentMethodsController({
    required PaymentMethodRepository paymentMethodRepository,
    required this.userId,
  }) : _paymentMethodRepository = paymentMethodRepository;

  // ===== STATE =====

  // ===== FORM STATE (AddPaymentMethodFormState'ten taşındı) =====

  // Form: Seçilen tür (nakit, banka, kredi)
  String _formSelectedType = 'nakit';
  String get formSelectedType => _formSelectedType;
  void setFormType(String type) {
    if (_formSelectedType != type) {
      _formSelectedType = type;
      notifyListeners();
    }
  }

  // Form: Seçilen renk index'i
  int _formSelectedColorIndex = 0;
  int get formSelectedColorIndex => _formSelectedColorIndex;
  void setFormColorIndex(int index) {
    if (_formSelectedColorIndex != index) {
      _formSelectedColorIndex = index;
      notifyListeners();
    }
  }

  /// Form state'ini initialize et
  void initializeFormState({String? editType, int? editColorIndex}) {
    if (editType != null) _formSelectedType = editType;
    if (editColorIndex != null) _formSelectedColorIndex = editColorIndex;
    notifyListeners();
  }

  /// Form state'ini sıfırla
  void resetFormState() {
    _formSelectedType = 'nakit';
    _formSelectedColorIndex = 0;
    notifyListeners();
  }

  // ===== TRANSFER STATE (TransferPageState'ten taşındı) =====

  // Transfer: Gönderen hesap ID
  String? _transferFromAccountId;
  String? get transferFromAccountId => _transferFromAccountId;
  void setTransferFromAccount(String? accountId) {
    if (_transferFromAccountId != accountId) {
      _transferFromAccountId = accountId;
      notifyListeners();
    }
  }

  // Transfer: Alan hesap ID
  String? _transferToAccountId;
  String? get transferToAccountId => _transferToAccountId;
  void setTransferToAccount(String? accountId) {
    if (_transferToAccountId != accountId) {
      _transferToAccountId = accountId;
      notifyListeners();
    }
  }

  // Transfer: Seçilen tarih
  DateTime _transferSelectedDate = DateTime.now();
  DateTime get transferSelectedDate => _transferSelectedDate;
  void setTransferDate(DateTime date) {
    _transferSelectedDate = date;
    notifyListeners();
  }

  // Transfer: Başarı mesajı
  String? _transferSuccessMessage;
  String? get transferSuccessMessage => _transferSuccessMessage;
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

  /// Transfer formunu sıfırla
  void resetTransferForm() {
    _transferFromAccountId = null;
    _transferToAccountId = null;
    _transferSelectedDate = DateTime.now();
    notifyListeners();
  }

  /// Alias metodları (transfer_page.dart uyumu için)
  void setTransferFromAccountId(String? accountId) =>
      setTransferFromAccount(accountId);
  void setTransferToAccountId(String? accountId) =>
      setTransferToAccount(accountId);
  void setTransferSelectedDate(DateTime date) => setTransferDate(date);

  /// Ödeme yöntemi bakiyesini güncelle
  void updatePaymentMethodBalance(String accountId, double newBalance) {
    final index = _paymentMethods.indexWhere((pm) => pm.id == accountId);
    if (index != -1) {
      _paymentMethods[index] = _paymentMethods[index].copyWith(
        balance: newBalance,
      );
      notifyListeners();
    }
  }

  /// Transfer page için ödeme yöntemleri alias
  List<PaymentMethod> get odemeYontemleri => _paymentMethods;

  // ===== DETAIL PAGE STATE (PaymentMethodDetailState'ten taşındı) =====

  // Detail: Seçilen ay
  late int _detailSecilenAy = DateTime.now().month;
  int get detailSecilenAy => _detailSecilenAy;

  // Detail: Seçilen yıl
  late int _detailSecilenYil = DateTime.now().year;
  int get detailSecilenYil => _detailSecilenYil;

  /// Detail sayfası için ay seçimini güncelle
  void selectDetailMonth(int month, int year) {
    if (_detailSecilenAy != month || _detailSecilenYil != year) {
      _detailSecilenAy = month;
      _detailSecilenYil = year;
      notifyListeners();
    }
  }

  /// Detail sayfasını şu ana sıfırla
  void resetDetailMonth() {
    final now = DateTime.now();
    _detailSecilenAy = now.month;
    _detailSecilenYil = now.year;
    notifyListeners();
  }

  // ===== ANA STATE =====

  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
      _filtrele();
    }
  }

  String _aramaMetni = '';
  String get aramaMetni => _aramaMetni;
  set aramaMetni(String value) {
    if (_aramaMetni != value) {
      _aramaMetni = value;
      _filtrele();
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

  List<PaymentMethod> _paymentMethods = [];
  List<PaymentMethod> _deletedPaymentMethods = [];
  List<PaymentMethod> _filteredMethods = [];

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<PaymentMethod> get deletedPaymentMethods => _deletedPaymentMethods;
  List<PaymentMethod> get filteredMethods => _filteredMethods;

  double get totalBalance {
    final cur = getIt<CurrencyService>();
    return _filteredMethods
        .where((pm) => pm.type != 'kredi')
        .fold(
          0.0,
          (sum, pm) =>
              sum + cur.convert(pm.balance, pm.paraBirimi, cur.currentCurrency),
        );
  }

  double get totalDebt {
    final cur = getIt<CurrencyService>();
    return _filteredMethods
        .where((pm) => pm.type == 'kredi')
        .fold(
          0.0,
          (sum, pm) =>
              sum + cur.convert(pm.balance, pm.paraBirimi, cur.currentCurrency),
        );
  }

  // ===== REPOSITORY İŞLEMLERİ =====

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final methodsData = _paymentMethodRepository.getPaymentMethods(userId);
      _paymentMethods = methodsData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();

      final deletedData = _paymentMethodRepository.getDeletedPaymentMethods(
        userId,
      );
      _deletedPaymentMethods = deletedData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();

      _filteredMethods = List.from(_paymentMethods);
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.loadData', e, s);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePaymentMethods() async {
    try {
      final data = _paymentMethods.map((pm) => pm.toMap()).toList();
      await _paymentMethodRepository.savePaymentMethods(userId, data);
    } catch (e, s) {
      ErrorHandler.logError(
        'PaymentMethodsController.savePaymentMethods',
        e,
        s,
      );
      throw DatabaseException.writeFailed(e);
    }
  }

  Future<void> saveDeletedPaymentMethods() async {
    try {
      final data = _deletedPaymentMethods.map((pm) => pm.toMap()).toList();
      await _paymentMethodRepository.saveDeletedPaymentMethods(userId, data);
    } catch (e, s) {
      ErrorHandler.logError(
        'PaymentMethodsController.saveDeletedPaymentMethods',
        e,
        s,
      );
      throw DatabaseException.writeFailed(e);
    }
  }

  // ===== FİLTRELEME =====

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
    notifyListeners();
  }

  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== CRUD İŞLEMLERİ =====

  Future<void> addMethod(PaymentMethod method) async {
    try {
      _paymentMethods.add(method);
      await savePaymentMethods();
      _filtrele();
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.addMethod', e, s);
      rethrow;
    }
  }

  Future<void> updateMethod(PaymentMethod method) async {
    try {
      final index = _paymentMethods.indexWhere((p) => p.id == method.id);
      if (index != -1) {
        _paymentMethods[index] = method;
        await savePaymentMethods();
        _filtrele();
      }
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.updateMethod', e, s);
      rethrow;
    }
  }

  Future<void> moveToBin(PaymentMethod method) async {
    try {
      _paymentMethods.removeWhere((p) => p.id == method.id);
      final deleted = method.copyWith(isDeleted: true);
      _deletedPaymentMethods.add(deleted);

      await savePaymentMethods();
      await saveDeletedPaymentMethods();
      _filtrele();
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.moveToBin', e, s);
      rethrow;
    }
  }

  Future<void> restoreMethod(PaymentMethod method) async {
    try {
      _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
      final restored = method.copyWith(isDeleted: false);
      _paymentMethods.add(restored);

      await savePaymentMethods();
      await saveDeletedPaymentMethods();
      _filtrele();
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.restoreMethod', e, s);
      rethrow;
    }
  }

  Future<void> permanentDelete(PaymentMethod method) async {
    try {
      _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
      await saveDeletedPaymentMethods();
      notifyListeners();
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.permanentDelete', e, s);
      rethrow;
    }
  }

  Future<void> emptyBin() async {
    try {
      _deletedPaymentMethods.clear();
      await saveDeletedPaymentMethods();
      notifyListeners();
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.emptyBin', e, s);
      rethrow;
    }
  }

  Future<void> restoreAll() async {
    try {
      for (final method in _deletedPaymentMethods) {
        _paymentMethods.add(method.copyWith(isDeleted: false));
      }
      _deletedPaymentMethods.clear();

      await savePaymentMethods();
      await saveDeletedPaymentMethods();
      _filtrele();
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.restoreAll', e, s);
      rethrow;
    }
  }

  Future<void> updateBalance(String methodId, double amount) async {
    try {
      final index = _paymentMethods.indexWhere((p) => p.id == methodId);
      if (index != -1) {
        final pm = _paymentMethods[index];
        _paymentMethods[index] = pm.copyWith(balance: pm.balance + amount);
        await savePaymentMethods();
        notifyListeners();
      }
    } catch (e, s) {
      ErrorHandler.logError('PaymentMethodsController.updateBalance', e, s);
      rethrow;
    }
  }

  void syncFromBin(List<PaymentMethod> updatedDeletedList) {
    _deletedPaymentMethods = List.from(updatedDeletedList);
    notifyListeners();
  }

  /// Widget prop'larından veriyi yükle (geriye dönük uyumluluk)
  void initData(
    List<PaymentMethod> methods,
    List<PaymentMethod> deletedMethods,
  ) {
    _paymentMethods = List.from(methods);
    _deletedPaymentMethods = List.from(deletedMethods);
    _filteredMethods = List.from(_paymentMethods);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
