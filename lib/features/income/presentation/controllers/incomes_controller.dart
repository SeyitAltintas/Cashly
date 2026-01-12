import 'package:flutter/foundation.dart';
import '../../data/models/income_model.dart';
import '../../domain/repositories/income_repository.dart';
import '../../../payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Gelirler Controller
/// Repository ile entegre, ChangeNotifier tabanlı state yönetimi sağlar.
/// Bu controller IncomePageState'in yerini alır.
class IncomesController extends ChangeNotifier {
  final IncomeRepository _incomeRepository;
  final PaymentMethodRepository _paymentMethodRepository;
  final String userId;

  IncomesController({
    required IncomeRepository incomeRepository,
    required PaymentMethodRepository paymentMethodRepository,
    required this.userId,
  }) : _incomeRepository = incomeRepository,
       _paymentMethodRepository = paymentMethodRepository;

  // ===== STATE =====

  bool _aramaModu = false;
  bool get aramaModu => _aramaModu;
  set aramaModu(bool value) {
    if (_aramaModu != value) {
      _aramaModu = value;
      notifyListeners();
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

  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;
  set secilenAy(DateTime value) {
    if (_secilenAy != value) {
      _secilenAy = value;
      notifyListeners();
    }
  }

  List<Income> _tumGelirler = [];
  List<Income> get tumGelirler => _tumGelirler;

  List<Map<String, dynamic>> _kategoriler = [];
  List<Map<String, dynamic>> get kategoriler => _kategoriler;

  List<PaymentMethod> _tumOdemeYontemleri = [];
  List<PaymentMethod> get tumOdemeYontemleri => _tumOdemeYontemleri;

  List<Income> get filteredGelirler {
    return _tumGelirler.where((g) {
      if (g.isDeleted) return false;
      return g.date.year == _secilenAy.year && g.date.month == _secilenAy.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double get toplamTutar {
    return filteredGelirler.fold(0.0, (sum, g) => sum + g.amount);
  }

  // ===== REPOSITORY İŞLEMLERİ =====

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final incomesData = _incomeRepository.getIncomes(userId);
      _tumGelirler = incomesData.map((m) => Income.fromMap(m)).toList();

      _kategoriler = _incomeRepository.getCategories(userId);

      final pmData = _paymentMethodRepository.getPaymentMethods(userId);
      _tumOdemeYontemleri = pmData
          .map((m) => PaymentMethod.fromMap(m))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveIncomes() async {
    final data = _tumGelirler.map((g) => g.toMap()).toList();
    await _incomeRepository.saveIncomes(userId, data);
  }

  Future<void> savePaymentMethods() async {
    final pmData = _tumOdemeYontemleri.map((pm) => pm.toMap()).toList();
    await _paymentMethodRepository.savePaymentMethods(userId, pmData);
  }

  // ===== AY GEÇİŞLERİ =====

  void oncekiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month - 1);
    notifyListeners();
  }

  void sonrakiAy() {
    _secilenAy = DateTime(_secilenAy.year, _secilenAy.month + 1);
    notifyListeners();
  }

  void toggleAramaModu() {
    _aramaModu = !_aramaModu;
    notifyListeners();
  }

  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== CRUD İŞLEMLERİ =====

  Future<void> addIncome(Income gelir) async {
    _tumGelirler.insert(0, gelir);

    if (gelir.paymentMethodId != null) {
      _updateBalance(gelir.paymentMethodId!, gelir.amount, isIncome: true);
    }

    await saveIncomes();
    await savePaymentMethods();
    notifyListeners();
  }

  Future<void> deleteIncome(
    Income income, {
    PaymentMethod? pm,
    int? pmIndex,
  }) async {
    final index = _tumGelirler.indexWhere((g) => g.id == income.id);
    if (index != -1) {
      _tumGelirler[index] = income.copyWith(isDeleted: true);

      if (income.paymentMethodId != null) {
        _updateBalance(income.paymentMethodId!, income.amount, isIncome: false);
      }

      await saveIncomes();
      await savePaymentMethods();
      notifyListeners();
    }
  }

  Future<void> undoDelete(
    Income income, {
    bool? wasDeleted,
    double? oldBalance,
    int? pmIndex,
    PaymentMethod? pm,
  }) async {
    final index = _tumGelirler.indexWhere((g) => g.id == income.id);
    if (index != -1) {
      _tumGelirler[index] = income.copyWith(isDeleted: wasDeleted ?? false);

      if (pmIndex != null && pmIndex != -1 && oldBalance != null) {
        _tumOdemeYontemleri[pmIndex] = _tumOdemeYontemleri[pmIndex].copyWith(
          balance: oldBalance,
        );
      }

      await saveIncomes();
      await savePaymentMethods();
      notifyListeners();
    }
  }

  Future<void> updateIncome({
    required Income income,
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
  }) async {
    if (income.paymentMethodId != null) {
      _updateBalance(income.paymentMethodId!, income.amount, isIncome: false);
    }

    if (paymentMethodId != null) {
      _updateBalance(paymentMethodId, amount, isIncome: true);
    }

    final index = _tumGelirler.indexWhere((g) => g.id == income.id);
    if (index != -1) {
      _tumGelirler[index] = Income(
        id: income.id,
        name: name,
        amount: amount,
        category: category,
        date: date,
        paymentMethodId: paymentMethodId,
        isDeleted: false,
      );
    }

    await saveIncomes();
    await savePaymentMethods();
    notifyListeners();
  }

  Future<void> addIncomeWithPayment({
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? paymentMethodId,
  }) async {
    final newIncome = Income(
      id: DateTime.now().toString(),
      name: name,
      amount: amount,
      category: category,
      date: date,
      paymentMethodId: paymentMethodId,
    );

    await addIncome(newIncome);
  }

  void _updateBalance(String pmId, double amount, {required bool isIncome}) {
    final pmIndex = _tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
    if (pmIndex == -1) return;

    final pm = _tumOdemeYontemleri[pmIndex];
    double newBalance;

    if (isIncome) {
      newBalance = pm.type == 'kredi'
          ? pm.balance - amount
          : pm.balance + amount;
    } else {
      newBalance = pm.type == 'kredi'
          ? pm.balance + amount
          : pm.balance - amount;
    }

    _tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
  }

  void setPaymentMethods(List<PaymentMethod> methods) {
    _tumOdemeYontemleri = methods;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
