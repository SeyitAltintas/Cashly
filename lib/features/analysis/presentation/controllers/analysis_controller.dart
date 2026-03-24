import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../income/data/models/income_model.dart';
import '../../../assets/data/models/asset_model.dart';

// ===== ISOLATE PAYLOAD & RESULT =====

class AnalysisComputePayload {
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Asset> varliklar;
  
  final int historyLimit;
  final DateTime selectedMonth;
  final DateTime todayDate;
  
  final Map<String, double> rates;
  final String currentCurrency;

  AnalysisComputePayload({
    required this.harcamalar,
    required this.gelirler,
    required this.varliklar,
    required this.historyLimit,
    required this.selectedMonth,
    required this.todayDate,
    required this.rates,
    required this.currentCurrency,
  });
}

class AnalysisComputeResult {
  final List<Map<String, dynamic>> currentExpenses;
  final double totalMonthlyExpense;
  final double previousMonthTotalExpense;
  final Map<String, double> expenseCategoryTotals;
  final Map<String, double> expensePaymentMethodTotals;
  final Map<DateTime, double> dailyExpenseTotals;

  final List<Income> currentIncomes;
  final double totalMonthlyIncome;
  final double previousMonthTotalIncome;
  final Map<String, double> incomeCategoryTotals;
  final Map<String, double> incomePaymentMethodTotals;
  final Set<String> regularIncomeCategories;
  final Map<DateTime, double> dailyIncomeTotals;

  final List<Asset> activeAssets;
  final double totalAssetValue;
  final double totalAssetPurchaseValue;
  final Map<String, double> assetTypeTotals;

  AnalysisComputeResult({
    required this.currentExpenses,
    required this.totalMonthlyExpense,
    required this.previousMonthTotalExpense,
    required this.expenseCategoryTotals,
    required this.expensePaymentMethodTotals,
    required this.dailyExpenseTotals,
    required this.currentIncomes,
    required this.totalMonthlyIncome,
    required this.previousMonthTotalIncome,
    required this.incomeCategoryTotals,
    required this.incomePaymentMethodTotals,
    required this.regularIncomeCategories,
    required this.dailyIncomeTotals,
    required this.activeAssets,
    required this.totalAssetValue,
    required this.totalAssetPurchaseValue,
    required this.assetTypeTotals,
  });
}

// ===== ISOLATE HELPER FUNCTIONS =====

double _isolateConvert(double amount, String sourceCurrency, String targetCurrency, Map<String, double> rates) {
  if (sourceCurrency == targetCurrency) return amount;
  final sourceRate = rates[sourceCurrency] ?? 0.0;
  final targetRate = rates[targetCurrency] ?? 0.0;
  if (sourceRate == 0.0 || targetRate == 0.0) return amount;
  final amountInUsd = amount / sourceRate;
  return amountInUsd * targetRate;
}

bool _isolateIsWithinLimit(DateTime date, int historyLimit, DateTime selectedMonth, DateTime todayDate) {
  if (historyLimit == -1) {
    return date.year == selectedMonth.year && date.month == selectedMonth.month;
  }
  final todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day);
  final tomorrow = todayStart.add(const Duration(days: 1));

  if (historyLimit == 30) {
    return date.year == todayDate.year && date.month == todayDate.month;
  } else if (historyLimit == 366) {
    return date.year == todayDate.year;
  } else {
    DateTime thresholdDate;
    if (historyLimit == 7) {
      thresholdDate = todayStart.subtract(const Duration(days: 7));
    } else if (historyLimit == 90) {
      thresholdDate = DateTime(todayDate.year, todayDate.month - 3, 1);
    } else if (historyLimit == 180) {
      thresholdDate = DateTime(todayDate.year, todayDate.month - 6, 1);
    } else if (historyLimit == 365) {
      thresholdDate = DateTime(todayDate.year - 1, todayDate.month, todayDate.day);
    } else {
      thresholdDate = todayStart.subtract(Duration(days: historyLimit));
    }
    return (date.isAfter(thresholdDate) || date.isAtSameMomentAs(thresholdDate)) && date.isBefore(tomorrow);
  }
}

bool _isolateIsWithinPreviousLimit(DateTime date, int historyLimit, DateTime selectedMonth, DateTime todayDate) {
  if (historyLimit == -1) {
    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    return date.year == prevMonth.year && date.month == prevMonth.month;
  }
  final todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day);

  if (historyLimit == 30) {
    final prevMonth = DateTime(todayDate.year, todayDate.month - 1);
    return date.year == prevMonth.year && date.month == prevMonth.month;
  } else if (historyLimit == 366) {
    final prevYear = todayDate.year - 1;
    return date.year == prevYear;
  } else {
    DateTime currentThreshold;
    DateTime previousThreshold;
    if (historyLimit == 7) {
      currentThreshold = todayStart.subtract(const Duration(days: 7));
      previousThreshold = currentThreshold.subtract(const Duration(days: 7));
    } else if (historyLimit == 90) {
      currentThreshold = DateTime(todayDate.year, todayDate.month - 3, 1);
      previousThreshold = DateTime(todayDate.year, todayDate.month - 6, 1);
    } else if (historyLimit == 180) {
      currentThreshold = DateTime(todayDate.year, todayDate.month - 6, 1);
      previousThreshold = DateTime(todayDate.year, todayDate.month - 12, 1);
    } else if (historyLimit == 365) {
      currentThreshold = DateTime(todayDate.year - 1, todayDate.month, todayDate.day);
      previousThreshold = DateTime(todayDate.year - 2, todayDate.month, todayDate.day);
    } else {
      currentThreshold = todayStart.subtract(Duration(days: historyLimit));
      previousThreshold = currentThreshold.subtract(Duration(days: historyLimit));
    }
    return (date.isAfter(previousThreshold) || date.isAtSameMomentAs(previousThreshold)) && date.isBefore(currentThreshold);
  }
}

Future<AnalysisComputeResult> _calculateAnalysisWorker(AnalysisComputePayload payload) async {
  final rates = payload.rates;
  final targetCurrency = payload.currentCurrency;
  final todayDate = payload.todayDate;
  final historyLimit = payload.historyLimit;
  final selectedMonth = payload.selectedMonth;

  // 1. Current Expenses
  final currentExpenses = payload.harcamalar.where((h) {
    if (h['silindi'] == true) return false;
    DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
    if (tarih == null) return false;
    return _isolateIsWithinLimit(tarih, historyLimit, selectedMonth, todayDate);
  }).toList();

  double totalExp = 0.0;
  final catExpTotals = <String, double>{};
  final pmExpTotals = <String, double>{};
  final dailyExpTotals = <DateTime, double>{};

  for(var h in currentExpenses) {
    final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
    final pb = h['paraBirimi']?.toString() ?? 'TRY';
    final deger = _isolateConvert(tutar, pb, targetCurrency, rates);

    totalExp += deger;
    final kat = h['kategori']?.toString() ?? 'Diğer';
    catExpTotals[kat] = (catExpTotals[kat] ?? 0) + deger;
    final pmId = h['odemeYontemiId']?.toString() ?? 'nakit';
    pmExpTotals[pmId] = (pmExpTotals[pmId] ?? 0) + deger;

    DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
    if (tarih != null) {
      final dateOnly = DateTime(tarih.year, tarih.month, tarih.day);
      dailyExpTotals[dateOnly] = (dailyExpTotals[dateOnly] ?? 0) + deger;
    }
  }

  // Prev Expenses
  final prevHarcamalar = payload.harcamalar.where((h) {
    if (h['silindi'] == true) return false;
    DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
    if (tarih == null) return false;
    return _isolateIsWithinPreviousLimit(tarih, historyLimit, selectedMonth, todayDate);
  });
  double prevTotalExp = 0.0;
  for(var h in prevHarcamalar) {
    final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
    final pb = h['paraBirimi']?.toString() ?? 'TRY';
    prevTotalExp += _isolateConvert(tutar, pb, targetCurrency, rates);
  }

  // 2. Current Incomes
  final currentIncomes = payload.gelirler.where((g) {
    if (g.isDeleted) return false;
    return _isolateIsWithinLimit(g.date, historyLimit, selectedMonth, todayDate);
  }).toList();

  double totalInc = 0.0;
  final catIncTotals = <String, double>{};
  final pmIncTotals = <String, double>{};
  final dailyIncTotals = <DateTime, double>{};

  for(var g in currentIncomes) {
    final deger = _isolateConvert(g.amount, g.paraBirimi, targetCurrency, rates);
    totalInc += deger;
    final kat = g.category.isEmpty ? 'Diğer' : g.category;
    catIncTotals[kat] = (catIncTotals[kat] ?? 0) + deger;
    final pmId = (g.paymentMethodId == null || g.paymentMethodId!.isEmpty) ? 'unknown' : g.paymentMethodId!;
    pmIncTotals[pmId] = (pmIncTotals[pmId] ?? 0) + deger;

    final dateOnly = DateTime(g.date.year, g.date.month, g.date.day);
    dailyIncTotals[dateOnly] = (dailyIncTotals[dateOnly] ?? 0) + deger;
  }

  final prevGelirler = payload.gelirler.where((g) {
    if (g.isDeleted) return false;
    return _isolateIsWithinPreviousLimit(g.date, historyLimit, selectedMonth, todayDate);
  });
  double prevTotalInc = 0.0;
  for(var g in prevGelirler) {
    prevTotalInc += _isolateConvert(g.amount, g.paraBirimi, targetCurrency, rates);
  }

  final categoryMonths = <String, Set<String>>{};
  for (var g in payload.gelirler) {
    if (g.isDeleted) continue;
    final monthKey = "${g.date.year}-${g.date.month}";
    categoryMonths.putIfAbsent(g.category, () => <String>{});
    categoryMonths[g.category]!.add(monthKey);
  }
  final regIncomes = categoryMonths.entries.where((e) => e.value.length >= 2).map((e) => e.key).toSet();

  // 3. Assets
  final activeAssets = payload.varliklar.where((v) => !v.isDeleted).toList();
  double totalAssetValue = 0.0;
  double totalAssetPurchase = 0.0;
  final assetTypeTotals = <String, double>{};

  for(var v in activeAssets) {
    totalAssetValue += _isolateConvert(v.amount, v.paraBirimi, targetCurrency, rates);
    totalAssetPurchase += _isolateConvert(v.purchasePrice, v.paraBirimi, targetCurrency, rates);

    final tip = v.type ?? 'Diğer';
    assetTypeTotals[tip] = (assetTypeTotals[tip] ?? 0) + _isolateConvert(v.amount, v.paraBirimi, targetCurrency, rates);
  }

  return AnalysisComputeResult(
    currentExpenses: currentExpenses,
    totalMonthlyExpense: totalExp,
    previousMonthTotalExpense: prevTotalExp,
    expenseCategoryTotals: catExpTotals,
    expensePaymentMethodTotals: pmExpTotals,
    dailyExpenseTotals: dailyExpTotals,
    currentIncomes: currentIncomes,
    totalMonthlyIncome: totalInc,
    previousMonthTotalIncome: prevTotalInc,
    incomeCategoryTotals: catIncTotals,
    incomePaymentMethodTotals: pmIncTotals,
    regularIncomeCategories: regIncomes,
    dailyIncomeTotals: dailyIncTotals,
    activeAssets: activeAssets,
    totalAssetValue: totalAssetValue,
    totalAssetPurchaseValue: totalAssetPurchase,
    assetTypeTotals: assetTypeTotals,
  );
}

/// Analysis Controller
/// Analiz sayfası için ChangeNotifier tabanlı state yönetimi sunar.
/// Performans için Caching (Memoization) ve Isolate kullanır.
class AnalysisController extends ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      _touchedIndex = -1;
      notifyListeners();
    }
  }

  int _touchedIndex = -1;
  int get touchedIndex => _touchedIndex;

  void setTouchedIndex(int value) {
    if (_touchedIndex != value) {
      _touchedIndex = value;
      notifyListeners();
    }
  }

  void resetTouchedIndex() {
    if (_touchedIndex != -1) {
      _touchedIndex = -1;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _harcamalar = [];
  List<Income> _gelirler = [];
  List<Asset> _varliklar = [];
  List<PaymentMethod> _odemeYontemleri = [];
  
  int _historyLimit = 30; 
  int get historyLimit => _historyLimit;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AnalysisComputeResult? _result;

  Future<void> updateData({
    required List<Map<String, dynamic>> harcamalar,
    required List<Income> gelirler,
    required List<Asset> varliklar,
    required List<PaymentMethod> odemeYontemleri,
    required DateTime secilenAy,
  }) async {
    _harcamalar = harcamalar;
    _gelirler = gelirler;
    _varliklar = varliklar;
    _odemeYontemleri = odemeYontemleri;

    if (_selectedMonth.year != secilenAy.year || _selectedMonth.month != secilenAy.month) {
      _selectedMonth = secilenAy;
      _historyLimit = -1;
    }
    
    await _recalculateData();
  }

  Future<void> setHistoryLimit(int limit) async {
    if (_historyLimit != limit) {
      _historyLimit = limit;
      _touchedIndex = -1;
      await _recalculateData();
    }
  }

  Future<void> setSelectedMonth(DateTime month) async {
    _selectedMonth = month;
    if (_historyLimit != -1) {
      _historyLimit = -1;
    }
    _touchedIndex = -1;
    await _recalculateData();
  }

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  bool _isDisposed = false;
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _recalculateData() async {
    setLoading(true);
    
    final cur = getIt<CurrencyService>();
    final payload = AnalysisComputePayload(
      harcamalar: _harcamalar,
      gelirler: _gelirler,
      varliklar: _varliklar,
      historyLimit: _historyLimit,
      selectedMonth: _selectedMonth,
      todayDate: DateTime.now(),
      rates: cur.rates,
      currentCurrency: cur.currentCurrency,
    );
    
    _result = await compute(_calculateAnalysisWorker, payload);

    if (!_isDisposed) {
      setLoading(false); // Notify listeners after compute
    }
  }

  void refresh() {
    _recalculateData();
  }

  // ===== MEMOIZED GETTERS =====

  // Harcamalar
  List<Map<String, dynamic>> get harcamalar => _harcamalar;
  List<Map<String, dynamic>> get currentExpenses => _result?.currentExpenses ?? [];
  double get totalMonthlyExpense => _result?.totalMonthlyExpense ?? 0.0;
  double get previousMonthTotalExpense => _result?.previousMonthTotalExpense ?? 0.0;
  Map<String, double> get expenseCategoryTotals => _result?.expenseCategoryTotals ?? {};
  Map<String, double> get expensePaymentMethodTotals => _result?.expensePaymentMethodTotals ?? {};
  
  MapEntry<String, double>? get topExpenseCategory {
    final totals = expenseCategoryTotals;
    if (totals.isEmpty) return null;
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b);
  }
  
  Map<DateTime, double> get dailyExpenseTotals => _result?.dailyExpenseTotals ?? {};

  // Gelirler
  List<Income> get gelirler => _gelirler;
  List<Income> get currentIncomes => _result?.currentIncomes ?? [];
  double get totalMonthlyIncome => _result?.totalMonthlyIncome ?? 0.0;
  double get previousMonthTotalIncome => _result?.previousMonthTotalIncome ?? 0.0;
  Map<String, double> get incomeCategoryTotals => _result?.incomeCategoryTotals ?? {};
  
  MapEntry<String, double>? get topIncomeCategory {
    final totals = incomeCategoryTotals;
    if (totals.isEmpty) return null;
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b);
  }
  
  Map<String, double> get incomePaymentMethodTotals => _result?.incomePaymentMethodTotals ?? {};
  Set<String> get regularIncomeCategories => _result?.regularIncomeCategories ?? {};
  Map<DateTime, double> get dailyIncomeTotals => _result?.dailyIncomeTotals ?? {};

  // Varlıklar
  List<Asset> get varliklar => _varliklar;
  List<Asset> get activeAssets => _result?.activeAssets ?? [];
  double get totalAssetValue => _result?.totalAssetValue ?? 0.0;
  double get totalAssetPurchaseValue => _result?.totalAssetPurchaseValue ?? 0.0;
  Map<String, double> get assetTypeTotals => _result?.assetTypeTotals ?? {};
  
  // Ödeme Yöntemleri
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;

  // ===== YARDIMCI METODLAR =====
  
  List<Color> getTabColors(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return [
          Colors.red.shade400, Colors.orange.shade400, Colors.amber.shade400,
          Colors.pink.shade400, Colors.deepOrange.shade400,
          Colors.redAccent.shade200, Colors.orangeAccent.shade200,
        ];
      case 1:
        return [
          Colors.green.shade400, Colors.teal.shade400, Colors.lime.shade400,
          Colors.lightGreen.shade400, Colors.greenAccent.shade400,
          Colors.tealAccent.shade400, Colors.cyan.shade400,
        ];
      case 2:
        return [
          Colors.blue.shade400, Colors.indigo.shade400, Colors.purple.shade400,
          Colors.deepPurple.shade400, Colors.blueAccent.shade200,
          Colors.indigoAccent.shade200, Colors.purpleAccent.shade200,
        ];
      default:
        return [Colors.grey.shade400];
    }
  }

  String getPaymentMethodName(String pmId) {
    if (pmId == 'nakit') return 'Nakit';
    final pm = _odemeYontemleri.where((p) => p.id == pmId).firstOrNull;
    return pm?.name ?? 'Bilinmeyen';
  }
}
