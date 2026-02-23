import 'package:flutter/material.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

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

  List<Map<String, dynamic>> _gelirler = [];
  List<Map<String, dynamic>> get gelirler => _gelirler;

  List<Map<String, dynamic>> _varliklar = [];
  List<Map<String, dynamic>> get varliklar => _varliklar;

  List<PaymentMethod> _odemeYontemleri = [];
  List<PaymentMethod> get odemeYontemleri => _odemeYontemleri;

  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ===== VERİ YÖNETİMİ =====

  /// Verileri güncelle
  void updateData({
    required List<Map<String, dynamic>> harcamalar,
    required List<Map<String, dynamic>> gelirler,
    required List<Map<String, dynamic>> varliklar,
    required List<PaymentMethod> odemeYontemleri,
    required DateTime secilenAy,
  }) {
    _harcamalar = harcamalar;
    _gelirler = gelirler;
    _varliklar = varliklar;
    _odemeYontemleri = odemeYontemleri;
    _secilenAy = secilenAy;
    notifyListeners();
  }

  /// Loading durumunu güncelle
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Seçilen ayı güncelle
  void setSecilenAy(DateTime ay) {
    if (_secilenAy != ay) {
      _secilenAy = ay;
      notifyListeners();
    }
  }

  // ===== HARCAMA ANALİZİ =====

  /// Seçilen aya göre harcamaları filtrele
  List<Map<String, dynamic>> get monthlyExpenses {
    return _harcamalar.where((h) {
      if (h['silindi'] == true) return false;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      return tarih.year == _secilenAy.year && tarih.month == _secilenAy.month;
    }).toList();
  }

  /// Toplam aylık harcama
  double get totalMonthlyExpense {
    final cur = getIt<CurrencyService>();
    return monthlyExpenses.fold(0.0, (sum, h) {
      final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      return sum + cur.convert(tutar, pb, cur.currentCurrency);
    });
  }

  /// Kategori bazlı harcama toplamları
  Map<String, double> get expenseCategoryTotals {
    final cur = getIt<CurrencyService>();
    final totals = <String, double>{};
    for (var h in monthlyExpenses) {
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
    for (var h in monthlyExpenses) {
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

  /// Seçilen aya göre gelirleri filtrele
  List<Map<String, dynamic>> get monthlyIncomes {
    return _gelirler.where((g) {
      if (g['isDeleted'] == true) return false;
      DateTime? tarih;
      if (g['date'] is DateTime) {
        tarih = g['date'] as DateTime;
      } else {
        tarih = DateTime.tryParse(g['date'].toString());
      }
      if (tarih == null) return false;
      return tarih.year == _secilenAy.year && tarih.month == _secilenAy.month;
    }).toList();
  }

  /// Toplam aylık gelir
  double get totalMonthlyIncome {
    final cur = getIt<CurrencyService>();
    return monthlyIncomes.fold(0.0, (sum, g) {
      final amount = (g['amount'] as num?)?.toDouble() ?? 0;
      final pb = g['paraBirimi']?.toString() ?? 'TRY';
      return sum + cur.convert(amount, pb, cur.currentCurrency);
    });
  }

  /// Kategori bazlı gelir toplamları
  Map<String, double> get incomeCategoryTotals {
    final cur = getIt<CurrencyService>();
    final totals = <String, double>{};
    for (var g in monthlyIncomes) {
      final kategori = g['category']?.toString() ?? 'Diğer';
      final tutar = (g['amount'] as num?)?.toDouble() ?? 0;
      final pb = g['paraBirimi']?.toString() ?? 'TRY';
      totals[kategori] =
          (totals[kategori] ?? 0) + cur.convert(tutar, pb, cur.currentCurrency);
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
  List<Map<String, dynamic>> get activeAssets {
    return _varliklar.where((v) => v['isDeleted'] != true).toList();
  }

  /// Toplam varlık değeri
  double get totalAssetValue {
    final cur = getIt<CurrencyService>();
    return activeAssets.fold(0.0, (sum, v) {
      final am =
          (v['amount'] as num?)?.toDouble() ??
          0; // Wait, is it amount or currentValue? The previous code used currentValue but later it might be amount. Wait, let me check the previous code for activeAssets
      final val = (v['currentValue'] as num?)?.toDouble() ?? am;
      final pb = v['paraBirimi']?.toString() ?? 'TRY';
      return sum + cur.convert(val, pb, cur.currentCurrency);
    });
  }

  /// Varlık türü bazlı toplamlar
  Map<String, double> get assetTypeTotals {
    final cur = getIt<CurrencyService>();
    final totals = <String, double>{};
    for (var v in activeAssets) {
      final tip = v['type']?.toString() ?? 'Diğer';
      final am = (v['amount'] as num?)?.toDouble() ?? 0;
      final deger = (v['currentValue'] as num?)?.toDouble() ?? am;
      final pb = v['paraBirimi']?.toString() ?? 'TRY';
      totals[tip] =
          (totals[tip] ?? 0) + cur.convert(deger, pb, cur.currentCurrency);
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
