import 'package:flutter/foundation.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/domain/usecases/dashboard_usecases.dart';
import '../../../../core/services/currency_service.dart';
import '../../../income/data/models/income_model.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../payment_methods/data/models/transfer_model.dart';
import '../../../streak/data/models/streak_model.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';



// ===== ISOLATE PAYLOAD & RESULT =====

class DashboardComputePayload {
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Asset> varliklar;
  final List<PaymentMethod> odemeYontemleri;
  final List<Transfer> transferler;
  final DateTime secilenAy;
  final Map<String, double> rates;
  final String currentCurrency;

  DashboardComputePayload({
    required this.harcamalar,
    required this.gelirler,
    required this.varliklar,
    required this.odemeYontemleri,
    required this.transferler,
    required this.secilenAy,
    required this.rates,
    required this.currentCurrency,
  });
}

class DashboardComputeResult {
  final double totalBalanceFallback;
  final double totalCreditDebtFallback;
  final double monthlyExpense;
  final double monthlyIncome;
  final double totalAssets;
  final Map<String, double> categoryExpenses;
  final List<Map<String, dynamic>> recentTransactions;

  DashboardComputeResult({
    required this.totalBalanceFallback,
    required this.totalCreditDebtFallback,
    required this.monthlyExpense,
    required this.monthlyIncome,
    required this.totalAssets,
    required this.categoryExpenses,
    required this.recentTransactions,
  });
}

double _isolateConvert(
  double amount,
  String sourceCurrency,
  String targetCurrency,
  Map<String, double> rates,
) {
  if (sourceCurrency == targetCurrency) return amount;
  final sourceRate = rates[sourceCurrency] ?? 0.0;
  final targetRate = rates[targetCurrency] ?? 0.0;
  if (sourceRate == 0.0 || targetRate == 0.0) return amount;
  final amountInUsd = amount / sourceRate;
  return amountInUsd * targetRate;
}

DashboardComputeResult _calculateDashboardWorker(
  DashboardComputePayload payload,
) {
  final rates = payload.rates;
  final target = payload.currentCurrency;
  
  double totalBal = 0;
  double totalCred = 0;
  for (var pm in payload.odemeYontemleri) {
    if (pm.isDeleted) continue;
    if (pm.type == 'kredi') {
      if (pm.balance > 0) totalCred += _isolateConvert(pm.balance, pm.paraBirimi, target, rates);
    } else {
      totalBal += _isolateConvert(pm.balance, pm.paraBirimi, target, rates);
    }
  }

  double mExp = 0;
  final catExp = <String, double>{};
  for (var h in payload.harcamalar) {
    if (h['silindi'] == true) continue;
    DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
    if (tarih != null && tarih.year == payload.secilenAy.year && tarih.month == payload.secilenAy.month) {
      final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      final converted = _isolateConvert(tutar, pb, target, rates);
      mExp += converted;
      
      final kat = h['kategori']?.toString() ?? 'Diğer';
      catExp[kat] = (catExp[kat] ?? 0) + converted;
    }
  }

  double mInc = 0;
  for (var g in payload.gelirler) {
    if (g.isDeleted) continue;
    if (g.date.year == payload.secilenAy.year && g.date.month == payload.secilenAy.month) {
      mInc += _isolateConvert(g.amount, g.paraBirimi, target, rates);
    }
  }

  double tAssets = 0;
  for (var v in payload.varliklar) {
    if (v.isDeleted) continue;
    tAssets += _isolateConvert(v.amount, v.paraBirimi, target, rates);
  }

  List<Map<String, dynamic>> transactions = [];
  
  for (var h in payload.harcamalar) {
    if (h['silindi'] == true) continue;
    DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
    if (tarih != null) {
      final rawAmount = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      final amount = _isolateConvert(rawAmount, pb, target, rates);
      transactions.add({
        'type': 'expense',
        'name': h['isim'] ?? 'Expense',
        'amount': amount,
        'date': tarih,
        'category': h['kategori'] ?? 'Diğer',
      });
    }
  }

  for (var g in payload.gelirler) {
    if (g.isDeleted) continue;
    final amount = _isolateConvert(g.amount, g.paraBirimi, target, rates);
    transactions.add({
      'type': 'income',
      'name': g.name,
      'amount': amount,
      'date': g.date,
      'category': g.category,
    });
  }

  String getPaymentMethodName(String id) {
    for (var pm in payload.odemeYontemleri) {
      if (pm.id == id) return pm.name;
    }
    return 'Unknown';
  }

  for (var t in payload.transferler) {
    final fromName = getPaymentMethodName(t.fromAccountId);
    final toName = getPaymentMethodName(t.toAccountId);
    final amount = _isolateConvert(t.amount, t.paraBirimi, target, rates);
    transactions.add({
      'type': 'transfer',
      'name': '$fromName → $toName',
      'amount': amount,
      'date': t.date,
      'category': 'Transfer',
    });
  }

  transactions.sort((a, b) {
    DateTime dateA = a['date'];
    DateTime dateB = b['date'];
    return dateB.compareTo(dateA);
  });

  return DashboardComputeResult(
    totalBalanceFallback: totalBal,
    totalCreditDebtFallback: totalCred,
    monthlyExpense: mExp,
    monthlyIncome: mInc,
    totalAssets: tAssets,
    categoryExpenses: catExp,
    recentTransactions: transactions.take(5).toList(),
  );
}

/// Dashboard Controller
/// Dashboard sayfası için ChangeNotifier tabanlı state yönetimi sağlar.
/// Finansal özet hesaplamalarını ve görüntüleme mantığını merkezi olarak yönetir.
/// Use Case entegrasyonu ile Clean Architecture prensiplerini destekler.
class DashboardController extends ChangeNotifier with SafeNotifierMixin {
  // ===== USE CASES =====
  late final GetFinancialSummary _getFinancialSummary;
  late final CalculateTotalBalance _calculateTotalBalance;
  late final CalculateTotalDebt _calculateTotalDebt;

  // ===== STATE =====

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _disposed = false;

  bool _isObscured = false;
  bool get isObscured => _isObscured;

  String _userName = '';
  String get userName => _userName;

  String? _userId;
  String? get userId => _userId;

  List<Map<String, dynamic>> _harcamalar = [];
  List<Map<String, dynamic>> get harcamalar => _harcamalar;

  List<Income> _gelirler = [];
  List<Income> get gelirler => _gelirler;

  List<Asset> _varliklar = [];
  List<Asset> get varliklar => _varliklar;

  List<PaymentMethod> _odemeYontemleri = [];
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;

  List<Transfer> _transferler = [];
  List<Transfer> get transferler => _transferler;

  double _butceLimiti = 0;
  double get butceLimiti {
    if (_butceLimiti <= 0) return 0;
    final service = getIt<CurrencyService>();
    return service.convert(_butceLimiti, 'TRY', service.currentCurrency);
  }

  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;

  StreakData _streakData = StreakData.empty();
  StreakData get streakData => _streakData;

  // Cached finansal özet (use case'den)
  FinancialSummary? _cachedSummary;

  DashboardComputeResult? _result;

  // ===== CONSTRUCTOR =====

  DashboardController() {
    _initUseCases();
    // Currency değiştiğinde dashboard'daki hesaplamaları yeniden tetiklemek için dinle
    if (getIt.isRegistered<CurrencyService>()) {
      getIt<CurrencyService>().addListener(_onCurrencyChanged);
    }
  }

  void _onCurrencyChanged() {
    refresh();
  }

  @override
  void dispose() {
    _disposed = true;
    if (getIt.isRegistered<CurrencyService>()) {
      getIt<CurrencyService>().removeListener(_onCurrencyChanged);
    }
    super.dispose();
  }

  void _initUseCases() {
    try {
      _getFinancialSummary = getIt<GetFinancialSummary>();
      _calculateTotalBalance = getIt<CalculateTotalBalance>();
      _calculateTotalDebt = getIt<CalculateTotalDebt>();
    } catch (e) {
      // DI henüz hazır değilse (test ortamı vb.)
      debugPrint('DashboardController: Use case init hatası - $e');
    }
  }

  // ===== HESAPLAMALAR =====

  /// Toplam bakiye (tüm ödeme yöntemlerinin toplamı)
  double get totalBalance {
    // Use Case varsa ve userId varsa use case kullan
    if (_userId != null) {
      try {
        return _calculateTotalBalance(
          CalculateTotalBalanceParams(userId: _userId!),
        );
      } catch (_) {
        // Fallback: yerel hesaplama
      }
    }

    return _result?.totalBalanceFallback ?? 0.0;
  }

  /// Toplam kredi kartı borcu
  double get totalCreditDebt {
    // Use Case varsa ve userId varsa use case kullan
    if (_userId != null) {
      try {
        return _calculateTotalDebt(CalculateTotalDebtParams(userId: _userId!));
      } catch (_) {
        // Fallback: yerel hesaplama
      }
    }

    return _result?.totalCreditDebtFallback ?? 0.0;
  }

  /// Aylık toplam harcama
  double get monthlyExpense => _result?.monthlyExpense ?? 0.0;

  /// Aylık toplam gelir
  double get monthlyIncome => _result?.monthlyIncome ?? 0.0;

  /// Net fark (gelir - gider)
  double get netDiff => monthlyIncome - monthlyExpense;

  /// Toplam varlık değeri
  double get totalAssets => _result?.totalAssets ?? 0.0;

  /// Son işlemler listesi (isolate üzerinden)
  List<Map<String, dynamic>> get recentTransactions => _result?.recentTransactions ?? [];

  /// Bütçe kullanım yüzdesi
  double get budgetUsagePercentage {
    final limit = butceLimiti;
    if (limit <= 0) return 0;
    return (monthlyExpense / limit * 100).clamp(0, 100);
  }

  /// Bütçe aşıldı mı?
  bool get isBudgetExceeded {
    final limit = butceLimiti;
    return limit > 0 && monthlyExpense > limit;
  }

  /// Kategori bazlı bütçe limitleri
  Map<String, double> _categoryBudgets = {};
  Map<String, double> get categoryBudgets {
    final service = getIt<CurrencyService>();
    final target = service.currentCurrency;
    return _categoryBudgets.map(
      (key, value) => MapEntry(key, service.convert(value, 'TRY', target)),
    );
  }

  /// Kategori bazlı aylık harcamalar
  Map<String, double> get categoryExpenses => _result?.categoryExpenses ?? {};

  /// Kategori bütçelerini güncelle
  void setCategoryBudgets(Map<String, double> value) {
    _categoryBudgets = value;
    notifyListeners();
  }

  /// Finansal özet (Use Case ile)
  FinancialSummary? getFinancialSummary() {
    if (_userId == null) return null;

    try {
      _cachedSummary = _getFinancialSummary(
        GetFinancialSummaryParams(userId: _userId!),
      );
      return _cachedSummary;
    } catch (e) {
      debugPrint('DashboardController: Finansal özet hatası - $e');
      return null;
    }
  }

  // ===== VERİ YÖNETİMİ =====

  /// Tüm verileri güncelle
  void updateData({
    required String userName,
    required List<Map<String, dynamic>> harcamalar,
    required List<Income> gelirler,
    required List<Asset> varliklar,
    required List<PaymentMethod> odemeYontemleri,
    required List<Transfer> transferler,
    required double butceLimiti,
    required DateTime secilenAy,
    required StreakData streakData,
    String? userId,
  }) {
    _userName = userName;
    _harcamalar = harcamalar;
    _gelirler = gelirler;
    _varliklar = varliklar;
    _odemeYontemleri = odemeYontemleri;
    _transferler = transferler;
    _butceLimiti = butceLimiti;
    _secilenAy = secilenAy;
    _streakData = streakData;
    _userId = userId;
    _cachedSummary = null; // Cache'i temizle
    _recalculateData();
  }

  /// User ID'yi ayarla (Use Case entegrasyonu için)
  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _cachedSummary = null;
      notifyListeners();
    }
  }

  /// Seçilen ayı güncelle
  void setSecilenAy(DateTime ay) {
    if (_secilenAy != ay) {
      _secilenAy = ay;
      _recalculateData();
    }
  }

  /// Loading durumunu güncelle
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Tutarları gizle/göster
  void toggleObscured() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

  /// Kullanıcı adını güncelle
  void setUserName(String value) {
    if (_userName != value) {
      _userName = value;
      notifyListeners();
    }
  }

  /// Harcamaları güncelle
  void setHarcamalar(List<Map<String, dynamic>> value) {
    _harcamalar = value;
    _recalculateData();
  }

  /// Gelirleri güncelle
  void setGelirler(List<Income> value) {
    _gelirler = value;
    _recalculateData();
  }

  /// Varlıkları güncelle
  void setVarliklar(List<Asset> value) {
    _varliklar = value;
    _recalculateData();
  }

  /// Ödeme yöntemlerini güncelle
  void setOdemeYontemleri(List<PaymentMethod> value) {
    _odemeYontemleri = value;
    _recalculateData();
  }

  /// Transferleri güncelle
  void setTransferler(List<Transfer> value) {
    _transferler = value;
    notifyListeners();
  }

  /// Bütçe limitini güncelle
  void setButceLimiti(double value) {
    if (_butceLimiti != value) {
      _butceLimiti = value;
      notifyListeners();
    }
  }

  /// Streak verisini güncelle
  void setStreakData(StreakData value) {
    _streakData = value;
    notifyListeners();
  }

  /// State'i yenile
  void refresh() {
    _cachedSummary = null;
    _recalculateData();
  }

  void _recalculateData() {
    final service = getIt<CurrencyService>();
    final payload = DashboardComputePayload(
      harcamalar: _harcamalar,
      gelirler: _gelirler,
      varliklar: _varliklar,
      odemeYontemleri: _odemeYontemleri,
      transferler: _transferler,
      secilenAy: _secilenAy,
      rates: service.rates,
      currentCurrency: service.currentCurrency,
    );
    
    _result = _calculateDashboardWorker(payload);
    if (!_disposed) notifyListeners();
  }
}
