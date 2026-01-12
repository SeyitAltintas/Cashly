import 'package:flutter/foundation.dart';
import '../../data/models/payment_method_model.dart';
import '../../domain/repositories/payment_method_repository.dart';

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
    return _filteredMethods
        .where((pm) => pm.type != 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
  }

  double get totalDebt {
    return _filteredMethods
        .where((pm) => pm.type == 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePaymentMethods() async {
    final data = _paymentMethods.map((pm) => pm.toMap()).toList();
    await _paymentMethodRepository.savePaymentMethods(userId, data);
  }

  Future<void> saveDeletedPaymentMethods() async {
    final data = _deletedPaymentMethods.map((pm) => pm.toMap()).toList();
    await _paymentMethodRepository.saveDeletedPaymentMethods(userId, data);
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
    _paymentMethods.add(method);
    await savePaymentMethods();
    _filtrele();
  }

  Future<void> updateMethod(PaymentMethod method) async {
    final index = _paymentMethods.indexWhere((p) => p.id == method.id);
    if (index != -1) {
      _paymentMethods[index] = method;
      await savePaymentMethods();
      _filtrele();
    }
  }

  Future<void> moveToBin(PaymentMethod method) async {
    _paymentMethods.removeWhere((p) => p.id == method.id);
    final deleted = method.copyWith(isDeleted: true);
    _deletedPaymentMethods.add(deleted);

    await savePaymentMethods();
    await saveDeletedPaymentMethods();
    _filtrele();
  }

  Future<void> restoreMethod(PaymentMethod method) async {
    _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
    final restored = method.copyWith(isDeleted: false);
    _paymentMethods.add(restored);

    await savePaymentMethods();
    await saveDeletedPaymentMethods();
    _filtrele();
  }

  Future<void> permanentDelete(PaymentMethod method) async {
    _deletedPaymentMethods.removeWhere((p) => p.id == method.id);
    await saveDeletedPaymentMethods();
    notifyListeners();
  }

  Future<void> emptyBin() async {
    _deletedPaymentMethods.clear();
    await saveDeletedPaymentMethods();
    notifyListeners();
  }

  Future<void> restoreAll() async {
    for (final method in _deletedPaymentMethods) {
      _paymentMethods.add(method.copyWith(isDeleted: false));
    }
    _deletedPaymentMethods.clear();

    await savePaymentMethods();
    await saveDeletedPaymentMethods();
    _filtrele();
  }

  Future<void> updateBalance(String methodId, double amount) async {
    final index = _paymentMethods.indexWhere((p) => p.id == methodId);
    if (index != -1) {
      final pm = _paymentMethods[index];
      _paymentMethods[index] = pm.copyWith(balance: pm.balance + amount);
      await savePaymentMethods();
      notifyListeners();
    }
  }

  void syncFromBin(List<PaymentMethod> updatedDeletedList) {
    _deletedPaymentMethods = List.from(updatedDeletedList);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
