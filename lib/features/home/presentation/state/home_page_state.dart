import 'dart:async';
import 'package:flutter/material.dart';
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
import '../../../../core/constants/icon_constants.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/services/asset_price_update_service.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';


/// AnaSayfa için ChangeNotifier state yöneticisi
/// Tüm veri state'lerini ve loading durumunu merkezi olarak yönetir
class HomePageState extends ChangeNotifier with SafeNotifierMixin {
  String? _userId;
  StreamSubscription? _expensesSubscription;
  StreamSubscription? _incomesSubscription;

  // Loading durumu
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Harcamalar (aktif ay stream'i)
  List<Map<String, dynamic>> _tumHarcamalar = [];
  List<Map<String, dynamic>> get tumHarcamalar => _tumHarcamalar;
  set tumHarcamalar(List<Map<String, dynamic>> value) {
    _tumHarcamalar = value;
    notifyListeners();
  }

  /// Tüm harcamalar (cache'den — Analiz sayfası için)
  List<Map<String, dynamic>> getAllExpensesFromCache(String userId) {
    return getIt<ExpenseRepository>().getExpenses(userId);
  }

  // Gelirler
  List<Income> _tumGelirler = [];
  List<Income> get tumGelirler => _tumGelirler;
  set tumGelirler(List<Income> value) {
    _tumGelirler = value;
    notifyListeners();
  }

  /// Tüm gelirler (cache'den — Analiz sayfası için)
  List<Income> getAllIncomesFromCache(String userId) {
    final raw = getIt<IncomeRepository>().getIncomes(userId);
    return raw.map((m) => Income.fromMap(m)).toList();
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
    if (_secilenAy != value) {
      _secilenAy = value;
      notifyListeners();
      if (_userId != null) {
        _startStreams(_userId!);
      }
    }
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

  // Harcama kategori ikonları
  Map<String, IconData> _kategoriIkonlari = {};
  Map<String, IconData> get kategoriIkonlari => _kategoriIkonlari;
  set kategoriIkonlari(Map<String, IconData> value) {
    _kategoriIkonlari = value;
    notifyListeners();
  }

  // Gelir kategori ikonları
  Map<String, IconData> _gelirKategoriIkonlari = {};
  Map<String, IconData> get gelirKategoriIkonlari => _gelirKategoriIkonlari;
  set gelirKategoriIkonlari(Map<String, IconData> value) {
    _gelirKategoriIkonlari = value;
    notifyListeners();
  }

  void loadData(String userId) {
    _userId = userId;
    final expenseRepo = getIt<ExpenseRepository>();
    final incomeRepo = getIt<IncomeRepository>();
    final assetRepo = getIt<AssetRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();
    final streakRepo = getIt<StreakRepository>();

    _startStreams(userId);

    _butceLimiti = expenseRepo.getBudget(userId);
    _categoryBudgets = expenseRepo.getCategoryBudgets(userId);

    // Harcama kategorilerini yükle
    final harcamaKategorileri = expenseRepo.getCategories(userId);
    _kategoriIkonlari = {};
    for (var kategori in harcamaKategorileri) {
      String isim = kategori['isim'];
      String ikonAdi = kategori['ikon'];
      _kategoriIkonlari[isim] = IconConstants.getHarcamaIkonu(ikonAdi);
    }

    // Gelir kategorilerini yükle
    final gelirKategorileri = incomeRepo.getCategories(userId);
    _gelirKategoriIkonlari = {};
    for (var kategori in gelirKategorileri) {
      String isim = kategori['isim'];
      String ikonAdi = kategori['ikon'];
      _gelirKategoriIkonlari[isim] = IconConstants.getGelirIkonu(ikonAdi);
    }

    // Varlıklar
    final varlikVerileri = assetRepo.getAssets(userId);
    _varliklar = varlikVerileri.map((map) => Asset.fromMap(map)).toList();

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

  void _startStreams(String userId) {
    _expensesSubscription?.cancel();
    _incomesSubscription?.cancel();

    final expenseRepo = getIt<ExpenseRepository>();
    final incomeRepo = getIt<IncomeRepository>();

    _expensesSubscription = expenseRepo
        .watchExpensesByMonth(userId, _secilenAy)
        .listen((expenses) {
          _tumHarcamalar = expenses;
          notifyListeners();
        });

    _incomesSubscription = incomeRepo
        .watchIncomesByMonth(userId, _secilenAy)
        .listen((incomesMap) {
          _tumGelirler = incomesMap.map((map) => Income.fromMap(map)).toList();
          notifyListeners();
        });
  }

  /// Zamanlanmış transferleri kontrol eder ve tarihi gelenleri uygular
  /// Başarısız olan transferlerin hata mesajı key'lerini liste olarak döndürür
  List<String> checkScheduledTransfers(String userId, BuildContext context) {
    if (_tumTransferler.isEmpty) return [];

    bool transferDegisti = false;
    List<String> basarisizTransferler = [];
    final currencyService = getIt<CurrencyService>();
    final pmRepo = getIt<PaymentMethodRepository>();

    for (int i = 0; i < _tumTransferler.length; i++) {
      final transfer = _tumTransferler[i];

      if (transfer.isPending) {
        final fromIndex = _tumOdemeYontemleri.indexWhere((pm) => pm.id == transfer.fromAccountId);
        final toIndex = _tumOdemeYontemleri.indexWhere((pm) => pm.id == transfer.toAccountId);

        if (fromIndex == -1) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.senderAccountNotFound);
          pmRepo.updateTransfer(userId, _tumTransferler[i].toMap());
          basarisizTransferler.add(context.l10n.senderAccountNotFound);
          transferDegisti = true;
          continue;
        }

        if (toIndex == -1) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.receiverAccountNotFound);
          pmRepo.updateTransfer(userId, _tumTransferler[i].toMap());
          basarisizTransferler.add(context.l10n.receiverAccountNotFound);
          transferDegisti = true;
          continue;
        }

        final fromPm = _tumOdemeYontemleri[fromIndex];
        final toPm = _tumOdemeYontemleri[toIndex];

        if (fromPm.isDeleted) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.accountDeleted(fromPm.name));
          pmRepo.updateTransfer(userId, _tumTransferler[i].toMap());
          basarisizTransferler.add(context.l10n.accountDeleted(fromPm.name));
          transferDegisti = true;
          continue;
        }

        if (toPm.isDeleted) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.accountDeleted(toPm.name));
          pmRepo.updateTransfer(userId, _tumTransferler[i].toMap());
          basarisizTransferler.add(context.l10n.accountDeleted(toPm.name));
          transferDegisti = true;
          continue;
        }

        final convertedTransferAmountFrom = currencyService.convert(transfer.amount, transfer.paraBirimi, fromPm.paraBirimi);

        bool limitVeyaBakiyeAsildi = false;
        if (fromPm.type == 'kredi') {
          final kalanLimit = (fromPm.limit ?? 0) - fromPm.balance;
          if (convertedTransferAmountFrom > kalanLimit) limitVeyaBakiyeAsildi = true;
        } else {
          if (fromPm.balance < convertedTransferAmountFrom) limitVeyaBakiyeAsildi = true;
        }

        if (limitVeyaBakiyeAsildi) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.insufficientBalanceAccount(fromPm.name));
          pmRepo.updateTransfer(userId, _tumTransferler[i].toMap());
          basarisizTransferler.add(context.l10n.insufficientBalanceAccount(fromPm.name));
          transferDegisti = true;
          continue;
        }

        if (toPm.type == 'kredi' && toPm.balance <= 0) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.noDebtToPay(toPm.name));
          pmRepo.updateTransfer(userId, _tumTransferler[i].toMap());
          basarisizTransferler.add(context.l10n.noDebtToPay(toPm.name));
          transferDegisti = true;
          continue;
        }

        double fromYeniBakiye = fromPm.type == 'kredi' ? fromPm.balance + convertedTransferAmountFrom : fromPm.balance - convertedTransferAmountFrom;
        _tumOdemeYontemleri[fromIndex] = fromPm.copyWith(balance: fromYeniBakiye);
        pmRepo.updatePaymentMethod(userId, _tumOdemeYontemleri[fromIndex].toMap());

        final convertedTransferAmountTo = currencyService.convert(transfer.amount, transfer.paraBirimi, toPm.paraBirimi);
        double toYeniBakiye = toPm.type == 'kredi' ? toPm.balance - convertedTransferAmountTo : toPm.balance + convertedTransferAmountTo;
        _tumOdemeYontemleri[toIndex] = toPm.copyWith(balance: toYeniBakiye);
        pmRepo.updatePaymentMethod(userId, _tumOdemeYontemleri[toIndex].toMap());

        _tumTransferler[i] = transfer.copyWith(isExecuted: true);
        pmRepo.updateTransfer(userId, _tumTransferler[i].toMap());
        transferDegisti = true;
      }
    }

    if (transferDegisti) {
      notifyListeners();
    }
    
    return basarisizTransferler;
  }

  Future<void> updateAssetPrices(String userId) async {
    if (_varliklar.isEmpty) return;

    try {
      final priceUpdateService = AssetPriceUpdateService();
      final updatedAssets = await priceUpdateService.updateAllAssetPrices(_varliklar);
      _varliklar = updatedAssets;
      for (var asset in updatedAssets) {
        getIt<AssetRepository>().updateAsset(userId, asset.toMap());
      }
      notifyListeners();
    } catch (e) {
      // Sessizce geç, kullanıcıyı rahatsız etme
    }
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    _incomesSubscription?.cancel();
    super.dispose();
  }
}
