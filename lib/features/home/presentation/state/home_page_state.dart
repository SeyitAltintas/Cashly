import 'package:flutter/foundation.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../assets/domain/repositories/asset_repository.dart';
import '../../../payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../streak/domain/repositories/streak_repository.dart';
import '../../../income/data/models/income_model.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../payment_methods/data/models/transfer_model.dart';
import '../../../streak/data/models/streak_model.dart';
import '../../../../core/di/injection_container.dart';

/// AnaSayfa için ChangeNotifier state yöneticisi
/// Tüm veri state'lerini ve loading durumunu merkezi olarak yönetir
class HomePageState extends ChangeNotifier {
  // Loading durumu
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Harcamalar
  List<Map<String, dynamic>> _tumHarcamalar = [];
  List<Map<String, dynamic>> get tumHarcamalar => _tumHarcamalar;
  set tumHarcamalar(List<Map<String, dynamic>> value) {
    _tumHarcamalar = value;
    notifyListeners();
  }

  // Gelirler
  List<Income> _tumGelirler = [];
  List<Income> get tumGelirler => _tumGelirler;
  set tumGelirler(List<Income> value) {
    _tumGelirler = value;
    notifyListeners();
  }

  // Varlıklar
  List<Asset> _varliklar = [];
  List<Asset> get varliklar => _varliklar;
  set varliklar(List<Asset> value) {
    _varliklar = value;
    notifyListeners();
  }

  // Ödeme yöntemleri
  List<PaymentMethod> _tumOdemeYontemleri = [];
  List<PaymentMethod> get tumOdemeYontemleri => _tumOdemeYontemleri;
  set tumOdemeYontemleri(List<PaymentMethod> value) {
    _tumOdemeYontemleri = value;
    notifyListeners();
  }

  // Transferler
  List<Transfer> _tumTransferler = [];
  List<Transfer> get tumTransferler => _tumTransferler;
  set tumTransferler(List<Transfer> value) {
    _tumTransferler = value;
    notifyListeners();
  }

  // Streak verisi
  StreakData _streakData = StreakData.empty();
  StreakData get streakData => _streakData;
  set streakData(StreakData value) {
    _streakData = value;
    notifyListeners();
  }

  // Bütçe limiti
  double _butceLimiti = 8000.0;
  double get butceLimiti => _butceLimiti;
  set butceLimiti(double value) {
    if (_butceLimiti != value) {
      _butceLimiti = value;
      notifyListeners();
    }
  }

  // Seçilen ay
  DateTime _secilenAy = DateTime.now();
  DateTime get secilenAy => _secilenAy;
  set secilenAy(DateTime value) {
    _secilenAy = value;
    notifyListeners();
  }

  // Varsayılan ödeme yöntemi
  String? _varsayilanOdemeYontemiId;
  String? get varsayilanOdemeYontemiId => _varsayilanOdemeYontemiId;
  set varsayilanOdemeYontemiId(String? value) {
    _varsayilanOdemeYontemiId = value;
    notifyListeners();
  }

  // Kategori bazlı bütçe limitleri
  Map<String, double> _categoryBudgets = {};
  Map<String, double> get categoryBudgets => _categoryBudgets;
  set categoryBudgets(Map<String, double> value) {
    _categoryBudgets = value;
    notifyListeners();
  }

  /// Tüm verileri yükler
  void loadData(String userId) {
    final expenseRepo = getIt<ExpenseRepository>();
    final incomeRepo = getIt<IncomeRepository>();
    final assetRepo = getIt<AssetRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();
    final streakRepo = getIt<StreakRepository>();

    // Harcamalar
    _tumHarcamalar = expenseRepo.getExpenses(userId);
    _butceLimiti = expenseRepo.getBudget(userId);
    _categoryBudgets = expenseRepo.getCategoryBudgets(userId);

    // Varlıklar
    final varlikVerileri = assetRepo.getAssets(userId);
    _varliklar = varlikVerileri.map((map) => Asset.fromMap(map)).toList();

    // Gelirler
    final gelirVerileri = incomeRepo.getIncomes(userId);
    _tumGelirler = gelirVerileri.map((map) => Income.fromMap(map)).toList();

    // Ödeme yöntemleri
    final odemeVerileri = paymentRepo.getPaymentMethods(userId);
    _tumOdemeYontemleri = odemeVerileri
        .map((map) => PaymentMethod.fromMap(map))
        .toList();

    // Transferler
    final transferVerileri = paymentRepo.getTransfers(userId);
    _tumTransferler = transferVerileri
        .map((map) => Transfer.fromMap(map))
        .toList();

    _varsayilanOdemeYontemiId = paymentRepo.getDefaultPaymentMethod(userId);

    // Streak verisi
    _streakData = streakRepo.getStreakData(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// State'i bildirim olmadan günceller (batch update için)
  void updateWithoutNotify({
    List<Map<String, dynamic>>? harcamalar,
    List<Income>? gelirler,
    List<Asset>? assets,
    List<PaymentMethod>? odemeYontemleri,
    List<Transfer>? transferler,
    StreakData? streak,
  }) {
    if (harcamalar != null) _tumHarcamalar = harcamalar;
    if (gelirler != null) _tumGelirler = gelirler;
    if (assets != null) _varliklar = assets;
    if (odemeYontemleri != null) _tumOdemeYontemleri = odemeYontemleri;
    if (transferler != null) _tumTransferler = transferler;
    if (streak != null) _streakData = streak;
  }

  /// Tüm değişiklikleri bildir
  void notifyAll() => notifyListeners();
}
