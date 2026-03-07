import 'package:flutter/material.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../income/data/models/income_model.dart';
import '../../../assets/data/models/asset_model.dart';

/// Analysis Controller
/// Analiz sayfası için ChangeNotifier tabanlı state yönetimi sağlar.
/// Grafik etkileşimleri, tab yönetimi ve analiz hesaplamalarını merkezi olarak yönetir.
class AnalysisController extends ChangeNotifier {
  // ===== TAB STATE =====

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      _touchedIndex = -1; // Tab değiştiğinde touched index'i sıfırla
      notifyListeners();
    }
  }

  // ===== GRAFIK ETKİLEŞİM STATE =====

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

  // ===== VERİ STATE =====

  List<Map<String, dynamic>> _harcamalar = [];
  List<Map<String, dynamic>> get harcamalar => _harcamalar;

  List<Income> _gelirler = [];
  List<Income> get gelirler => _gelirler;

  List<Asset> _varliklar = [];
  List<Asset> get varliklar => _varliklar;

  List<PaymentMethod> _odemeYontemleri = [];
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;

  int _historyLimit = 30; // 7, 30, 90, 180, 365, -1 for Month Selection
  int get historyLimit => _historyLimit;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ===== VERİ YÖNETİMİ =====

  /// Verileri güncelle
  void updateData({
    required List<Map<String, dynamic>> harcamalar,
    required List<Income> gelirler,
    required List<Asset> varliklar,
    required List<PaymentMethod> odemeYontemleri,
    required DateTime secilenAy,
  }) {
    _harcamalar = harcamalar;
    _gelirler = gelirler;
    _varliklar = varliklar;
    _odemeYontemleri = odemeYontemleri;

    // Eğer anasayfadan farklı bir ay geldiyse (ya da ilk yükleme) ve historyLimit -1 listesinde değilsek
    // UI güncellemelerinde anasayfadaki seçimi dikkate alıp "Özel Ay" filtresine geçirmeliyiz
    if (_selectedMonth.year != secilenAy.year ||
        _selectedMonth.month != secilenAy.month) {
      _selectedMonth = secilenAy;
      _historyLimit = -1; // Ay seçim moduna atla
    }

    notifyListeners();
  }

  void setHistoryLimit(int limit) {
    if (_historyLimit != limit) {
      _historyLimit = limit;
      _touchedIndex = -1;
      notifyListeners();
    }
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    if (_historyLimit != -1) {
      _historyLimit = -1;
    }
    _touchedIndex = -1;
    notifyListeners();
  }

  bool _isWithinLimit(DateTime date) {
    if (_historyLimit == -1) {
      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final tomorrow = todayStart.add(const Duration(days: 1));

    if (_historyLimit == 30) {
      // Bu Ay (This Calendar Month) - tüm ayı dahil et
      return date.year == today.year && date.month == today.month;
    } else if (_historyLimit == 366) {
      // Bu Yıl (This Calendar Year) - tüm yılı dahil et
      return date.year == today.year;
    } else {
      // 7 (Son 7 Gün), 90 (Son 3 Ay), 180 (Son 6 Ay), 365 (Son 1 Yıl)
      DateTime thresholdDate;
      if (_historyLimit == 7) {
        thresholdDate = todayStart.subtract(const Duration(days: 7));
      } else if (_historyLimit == 90) {
        thresholdDate = DateTime(today.year, today.month - 3, today.day);
      } else if (_historyLimit == 180) {
        thresholdDate = DateTime(today.year, today.month - 6, today.day);
      } else if (_historyLimit == 365) {
        thresholdDate = DateTime(today.year - 1, today.month, today.day);
      } else {
        thresholdDate = todayStart.subtract(Duration(days: _historyLimit));
      }
      return (date.isAfter(thresholdDate) ||
              date.isAtSameMomentAs(thresholdDate)) &&
          date.isBefore(tomorrow);
    }
  }

  bool _isWithinPreviousLimit(DateTime date) {
    if (_historyLimit == -1) {
      final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      return date.year == prevMonth.year && date.month == prevMonth.month;
    }

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    if (_historyLimit == 30) {
      // Önceki Ay (Previous Calendar Month)
      final prevMonth = DateTime(today.year, today.month - 1);
      return date.year == prevMonth.year && date.month == prevMonth.month;
    } else if (_historyLimit == 366) {
      // Önceki Yıl (Previous Calendar Year)
      final prevYear = today.year - 1;
      return date.year == prevYear;
    } else {
      DateTime currentThreshold;
      DateTime previousThreshold;
      if (_historyLimit == 7) {
        currentThreshold = todayStart.subtract(const Duration(days: 7));
        previousThreshold = currentThreshold.subtract(const Duration(days: 7));
      } else if (_historyLimit == 90) {
        currentThreshold = DateTime(today.year, today.month - 3, today.day);
        previousThreshold = DateTime(today.year, today.month - 6, today.day);
      } else if (_historyLimit == 180) {
        currentThreshold = DateTime(today.year, today.month - 6, today.day);
        previousThreshold = DateTime(today.year, today.month - 12, today.day);
      } else if (_historyLimit == 365) {
        currentThreshold = DateTime(today.year - 1, today.month, today.day);
        previousThreshold = DateTime(today.year - 2, today.month, today.day);
      } else {
        currentThreshold = todayStart.subtract(Duration(days: _historyLimit));
        previousThreshold = currentThreshold.subtract(
          Duration(days: _historyLimit),
        );
      }

      return (date.isAfter(previousThreshold) ||
              date.isAtSameMomentAs(previousThreshold)) &&
          date.isBefore(currentThreshold);
    }
  }

  /// Loading durumunu güncelle
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Seçilen ayı Legacy olarak tutmuyoruz artık. Gerekirse eklenebilir.

  // ===== HARCAMA ANALİZİ =====

  /// Seçilen limitlere göre harcamaları filtrele
  List<Map<String, dynamic>> get currentExpenses {
    return _harcamalar.where((h) {
      if (h['silindi'] == true) return false;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      return _isWithinLimit(tarih);
    }).toList();
  }

  /// Toplam filtreli harcama
  double get totalMonthlyExpense {
    final cur = getIt<CurrencyService>();
    return currentExpenses.fold(0.0, (sum, h) {
      final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      return sum + cur.convert(tutar, pb, cur.currentCurrency);
    });
  }

  /// Bir önceki dönemin toplam harcaması
  double get previousMonthTotalExpense {
    final cur = getIt<CurrencyService>();

    final prevHarcamalar = _harcamalar.where((h) {
      if (h['silindi'] == true) return false;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      return _isWithinPreviousLimit(tarih);
    });

    return prevHarcamalar.fold(0.0, (sum, h) {
      final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      return sum + cur.convert(tutar, pb, cur.currentCurrency);
    });
  }

  /// Kategori bazlı harcama toplamları
  Map<String, double> get expenseCategoryTotals {
    final cur = getIt<CurrencyService>();
    final totals = <String, double>{};
    for (var h in currentExpenses) {
      final kategori = h['kategori']?.toString() ?? 'Diğer';
      final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      final deger = cur.convert(tutar, pb, cur.currentCurrency);
      totals[kategori] = (totals[kategori] ?? 0) + deger;
    }
    return totals;
  }

  /// Ödeme yöntemi bazlı harcama toplamları
  Map<String, double> get expensePaymentMethodTotals {
    final cur = getIt<CurrencyService>();
    final totals = <String, double>{};
    for (var h in currentExpenses) {
      final pmId = h['odemeYontemiId']?.toString() ?? 'nakit';
      final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      totals[pmId] =
          (totals[pmId] ?? 0) + cur.convert(tutar, pb, cur.currentCurrency);
    }
    return totals;
  }

  /// En çok harcama yapılan kategori
  MapEntry<String, double>? get topExpenseCategory {
    if (expenseCategoryTotals.isEmpty) return null;
    return expenseCategoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
  }

  // ===== GELİR ANALİZİ =====

  /// Seçilen limite göre gelirleri filtrele
  List<Income> get currentIncomes {
    return _gelirler.where((g) {
      if (g.isDeleted) return false;
      return _isWithinLimit(g.date);
    }).toList();
  }

  /// Toplam filtreli gelir
  double get totalMonthlyIncome {
    final cur = getIt<CurrencyService>();
    return currentIncomes.fold(0.0, (sum, g) {
      return sum + cur.convert(g.amount, g.paraBirimi, cur.currentCurrency);
    });
  }

  /// Bir önceki dönemin toplam geliri
  double get previousMonthTotalIncome {
    final cur = getIt<CurrencyService>();

    final prevGelirler = _gelirler.where((g) {
      if (g.isDeleted) return false;
      return _isWithinPreviousLimit(g.date);
    });

    return prevGelirler.fold(0.0, (sum, g) {
      return sum + cur.convert(g.amount, g.paraBirimi, cur.currentCurrency);
    });
  }

  /// Kategori bazlı gelir toplamları
  Map<String, double> get incomeCategoryTotals {
    final cur = getIt<CurrencyService>();
    final totals = <String, double>{};
    for (var g in currentIncomes) {
      final kategori = g.category.isEmpty ? 'Diğer' : g.category;
      totals[kategori] =
          (totals[kategori] ?? 0) +
          cur.convert(g.amount, g.paraBirimi, cur.currentCurrency);
    }
    return totals;
  }

  /// En çok gelir elde edilen kategori
  MapEntry<String, double>? get topIncomeCategory {
    if (incomeCategoryTotals.isEmpty) return null;
    return incomeCategoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
  }

  // ===== VARLIK ANALİZİ =====

  /// Aktif varlıkları getir
  List<Asset> get activeAssets {
    return _varliklar.where((v) => !v.isDeleted).toList();
  }

  /// Toplam varlık değeri
  double get totalAssetValue {
    final cur = getIt<CurrencyService>();
    return activeAssets.fold(0.0, (sum, v) {
      return sum + cur.convert(v.amount, v.paraBirimi, cur.currentCurrency);
    });
  }

  /// Varlık türü bazlı toplamlar
  Map<String, double> get assetTypeTotals {
    final cur = getIt<CurrencyService>();
    final totals = <String, double>{};
    for (var v in activeAssets) {
      final tip = v.type ?? 'Diğer';
      totals[tip] =
          (totals[tip] ?? 0) +
          cur.convert(v.amount, v.paraBirimi, cur.currentCurrency);
    }
    return totals;
  }

  // ===== YARDİMCİ METODLAR =====

  /// Tab için renkleri getir
  List<Color> getTabColors(int tabIndex) {
    switch (tabIndex) {
      case 0: // Harcama
        return [
          Colors.red.shade400,
          Colors.orange.shade400,
          Colors.amber.shade400,
          Colors.pink.shade400,
          Colors.deepOrange.shade400,
          Colors.redAccent.shade200,
          Colors.orangeAccent.shade200,
        ];
      case 1: // Gelir
        return [
          Colors.green.shade400,
          Colors.teal.shade400,
          Colors.lime.shade400,
          Colors.lightGreen.shade400,
          Colors.greenAccent.shade400,
          Colors.tealAccent.shade400,
          Colors.cyan.shade400,
        ];
      case 2: // Varlık
        return [
          Colors.blue.shade400,
          Colors.indigo.shade400,
          Colors.purple.shade400,
          Colors.deepPurple.shade400,
          Colors.blueAccent.shade200,
          Colors.indigoAccent.shade200,
          Colors.purpleAccent.shade200,
        ];
      default:
        return [Colors.grey.shade400];
    }
  }

  /// Ödeme yöntemi adını getir
  String getPaymentMethodName(String pmId) {
    if (pmId == 'nakit') return 'Nakit';
    final pm = _odemeYontemleri.where((p) => p.id == pmId).firstOrNull;
    return pm?.name ?? 'Bilinmeyen';
  }

  /// State'i yenile
  void refresh() {
    notifyListeners();
  }
}
