import 'package:flutter/foundation.dart';
import '../../../income/data/models/income_model.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../payment_methods/data/models/transfer_model.dart';
import '../../../streak/data/models/streak_model.dart';

/// Dashboard Controller
/// Dashboard sayfası için ChangeNotifier tabanlı state yönetimi sağlar.
/// Finansal özet hesaplamalarını ve görüntüleme mantığını merkezi olarak yönetir.
class DashboardController extends ChangeNotifier {
  // ===== STATE =====

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userName = '';
  String get userName => _userName;

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
  double get butceLimiti => _butceLimiti;

  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;

  StreakData _streakData = StreakData.empty();
  StreakData get streakData => _streakData;

  // ===== HESAPLAMALAR =====

  /// Saate göre selamlama mesajı
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return "İyi geceler";
    if (hour < 12) return "Günaydın";
    if (hour < 18) return "İyi günler";
    return "İyi akşamlar";
  }

  /// Toplam bakiye (tüm ödeme yöntemlerinin toplamı)
  double get totalBalance {
    double total = 0;
    for (var pm in _odemeYontemleri) {
      if (pm.isDeleted) continue;
      if (pm.type == 'kredi') continue; // Kredi kartı bakiyeyi olumsuz etkiler
      total += pm.balance;
    }
    return total;
  }

  /// Toplam kredi kartı borcu
  double get totalCreditDebt {
    double total = 0;
    for (var pm in _odemeYontemleri) {
      if (pm.isDeleted) continue;
      if (pm.type == 'kredi' && pm.balance > 0) {
        total += pm.balance;
      }
    }
    return total;
  }

  /// Aylık toplam harcama
  double get monthlyExpense {
    double total = 0;
    for (var h in _harcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null &&
          tarih.year == _secilenAy.year &&
          tarih.month == _secilenAy.month) {
        total += (h['tutar'] as num?)?.toDouble() ?? 0;
      }
    }
    return total;
  }

  /// Aylık toplam gelir
  double get monthlyIncome {
    double total = 0;
    for (var g in _gelirler) {
      if (g.isDeleted) continue;
      if (g.date.year == _secilenAy.year && g.date.month == _secilenAy.month) {
        total += g.amount;
      }
    }
    return total;
  }

  /// Net fark (gelir - gider)
  double get netDiff => monthlyIncome - monthlyExpense;

  /// Toplam varlık değeri
  double get totalAssets {
    double total = 0;
    for (var v in _varliklar) {
      if (v.isDeleted) continue;
      total += v.amount; // Asset modelinde amount = güncel değer
    }
    return total;
  }

  /// Bütçe kullanım yüzdesi
  double get budgetUsagePercentage {
    if (_butceLimiti <= 0) return 0;
    return (monthlyExpense / _butceLimiti * 100).clamp(0, 100);
  }

  /// Bütçe aşıldı mı?
  bool get isBudgetExceeded =>
      _butceLimiti > 0 && monthlyExpense > _butceLimiti;

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
    notifyListeners();
  }

  /// Seçilen ayı güncelle
  void setSecilenAy(DateTime ay) {
    if (_secilenAy != ay) {
      _secilenAy = ay;
      notifyListeners();
    }
  }

  /// Loading durumunu güncelle
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
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
    notifyListeners();
  }

  /// Gelirleri güncelle
  void setGelirler(List<Income> value) {
    _gelirler = value;
    notifyListeners();
  }

  /// Varlıkları güncelle
  void setVarliklar(List<Asset> value) {
    _varliklar = value;
    notifyListeners();
  }

  /// Ödeme yöntemlerini güncelle
  void setOdemeYontemleri(List<PaymentMethod> value) {
    _odemeYontemleri = value;
    notifyListeners();
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
    notifyListeners();
  }
}
