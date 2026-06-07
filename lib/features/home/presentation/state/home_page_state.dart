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
import '../../../../core/services/batch_service.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';


/// AnaSayfa için ChangeNotifier state yöneticisi
/// Tüm veri state'lerini ve loading durumunu merkezi olarak yönetir
class HomePageState extends ChangeNotifier with SafeNotifierMixin {
  String? _userId;
  StreamSubscription? _expensesSubscription;
  StreamSubscription? _incomesSubscription;
  StreamSubscription? _assetsSubscription;
  StreamSubscription? _paymentMethodsSubscription;
  StreamSubscription? _transfersSubscription;

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
        // Sadece aylık stream'ler (expenses/incomes) yeniden başlatılır.
        // Statik stream'ler (assets/payment/transfers) ay değişiminden etkilenmez.
        _startMonthlyStreams(_userId!);
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
    try {
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
        String isim = kategori['isim']?.toString() ?? 'Bilinmeyen';
        String ikonAdi = kategori['ikon']?.toString() ?? 'diger';
        _kategoriIkonlari[isim] = IconConstants.getHarcamaIkonu(ikonAdi);
      }

      // Gelir kategorilerini yükle
      final gelirKategorileri = incomeRepo.getCategories(userId);
      _gelirKategoriIkonlari = {};
      for (var kategori in gelirKategorileri) {
        String isim = kategori['isim']?.toString() ?? 'Bilinmeyen';
        String ikonAdi = kategori['ikon']?.toString() ?? 'diger';
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
    } catch (e, stack) {
      debugPrint('HomePageState loadData Edge Case Hatası: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshCategoriesAndSettings(String userId) {
    try {
      final expenseRepo = getIt<ExpenseRepository>();
      final incomeRepo = getIt<IncomeRepository>();
      
      _butceLimiti = expenseRepo.getBudget(userId);
      _categoryBudgets = expenseRepo.getCategoryBudgets(userId);

      final harcamaKategorileri = expenseRepo.getCategories(userId);
      _kategoriIkonlari = {};
      for (var kategori in harcamaKategorileri) {
        String isim = kategori['isim']?.toString() ?? 'Bilinmeyen';
        String ikonAdi = kategori['ikon']?.toString() ?? 'diger';
        _kategoriIkonlari[isim] = IconConstants.getHarcamaIkonu(ikonAdi);
      }

      final gelirKategorileri = incomeRepo.getCategories(userId);
      _gelirKategoriIkonlari = {};
      for (var kategori in gelirKategorileri) {
        String isim = kategori['isim']?.toString() ?? 'Bilinmeyen';
        String ikonAdi = kategori['ikon']?.toString() ?? 'diger';
        _gelirKategoriIkonlari[isim] = IconConstants.getGelirIkonu(ikonAdi);
      }
      
      notifyListeners();
    } catch (e, stack) {
      debugPrint('HomePageState refreshCategoriesAndSettings Edge Case Hatası: $e\n$stack');
    }
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
    _startMonthlyStreams(userId);
    _startStaticStreams(userId);
  }

  /// Aylık filtreli stream'ler (ay değişince yeniden başlatılır)
  void _startMonthlyStreams(String userId) {
    _expensesSubscription?.cancel();
    _incomesSubscription?.cancel();

    // EC-10: Ay değiştiğinde, eski ayın verilerinin yeni ay yüklenene kadar ekranda kalmasını (Data Bleeding) engelle.
    _tumHarcamalar = [];
    _tumGelirler = [];
    notifyListeners();

    final expenseRepo = getIt<ExpenseRepository>();
    final incomeRepo = getIt<IncomeRepository>();

    _expensesSubscription = expenseRepo
        .watchExpensesByMonth(userId, _secilenAy)
        .listen(
          (expenses) {
            _tumHarcamalar = expenses;
            notifyListeners();
          },
          onError: (e, s) => _logStreamError('watchExpensesByMonth', e, s),
          cancelOnError: false,
        );

    _incomesSubscription = incomeRepo
        .watchIncomesByMonth(userId, _secilenAy)
        .listen(
          (incomesMap) {
            _tumGelirler = incomesMap.map((map) => Income.fromMap(map)).toList();
            notifyListeners();
          },
          onError: (e, s) => _logStreamError('watchIncomesByMonth', e, s),
          cancelOnError: false,
        );
  }

  /// Statik stream'ler — aya bağlı değil, sadece bir kez başlatılır
  void _startStaticStreams(String userId) {
    _assetsSubscription?.cancel();
    _paymentMethodsSubscription?.cancel();
    _transfersSubscription?.cancel();

    final assetRepo = getIt<AssetRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();

    _assetsSubscription = assetRepo
        .watchAssets(userId)
        .listen(
          (assetsMap) {
            _varliklar = assetsMap.map((map) => Asset.fromMap(map)).toList();
            notifyListeners();
          },
          onError: (e, s) => _logStreamError('watchAssets', e, s),
          cancelOnError: false,
        );

    _paymentMethodsSubscription = paymentRepo
        .watchPaymentMethods(userId)
        .listen(
          (methodsMap) {
            _tumOdemeYontemleri = methodsMap.map((map) => PaymentMethod.fromMap(map)).toList();
            notifyListeners();
          },
          onError: (e, s) => _logStreamError('watchPaymentMethods', e, s),
          cancelOnError: false,
        );

    _transfersSubscription = paymentRepo
        .watchTransfers(userId)
        .listen(
          (transfersMap) {
            _tumTransferler = transfersMap.map((map) => Transfer.fromMap(map)).toList();
            notifyListeners();
          },
          onError: (e, s) => _logStreamError('watchTransfers', e, s),
          cancelOnError: false,
        );
  }

  void _logStreamError(String streamName, Object error, StackTrace stackTrace) {
    debugPrint('HomePageState: $streamName stream hatası (veri korundu): $error');
    // Stream ölmez (cancelOnError: false), son veri UI'da kalmaya devam eder.
  }

  /// Zamanlanmış transferleri kontrol eder ve tarihi gelenleri uygular
  /// Başarısız olan transferlerin hata mesajı key'lerini liste olarak döndürür
  Future<List<String>> checkScheduledTransfers(String userId, BuildContext context) async {
    if (_tumTransferler.isEmpty) return [];

    bool transferDegisti = false;
    List<String> basarisizTransferler = [];
    final currencyService = getIt<CurrencyService>();
    final pmRepo = getIt<PaymentMethodRepository>();
    final batchService = getIt<BatchService>();
    final List<BatchOperation> operations = [];

    for (int i = 0; i < _tumTransferler.length; i++) {
      final transfer = _tumTransferler[i];

      if (transfer.isPending) {
        final fromIndex = _tumOdemeYontemleri.indexWhere((pm) => pm.id == transfer.fromAccountId);
        final toIndex = _tumOdemeYontemleri.indexWhere((pm) => pm.id == transfer.toAccountId);

        if (fromIndex == -1) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.senderAccountNotFound);
          operations.add(pmRepo.getUpdateTransferOperation(userId, _tumTransferler[i].toMap()));
          basarisizTransferler.add(context.l10n.senderAccountNotFound);
          transferDegisti = true;
          continue;
        }

        if (toIndex == -1) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.receiverAccountNotFound);
          operations.add(pmRepo.getUpdateTransferOperation(userId, _tumTransferler[i].toMap()));
          basarisizTransferler.add(context.l10n.receiverAccountNotFound);
          transferDegisti = true;
          continue;
        }

        final fromPm = _tumOdemeYontemleri[fromIndex];
        final toPm = _tumOdemeYontemleri[toIndex];

        if (fromPm.isDeleted) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.accountDeleted(fromPm.name));
          operations.add(pmRepo.getUpdateTransferOperation(userId, _tumTransferler[i].toMap()));
          basarisizTransferler.add(context.l10n.accountDeleted(fromPm.name));
          transferDegisti = true;
          continue;
        }

        if (toPm.isDeleted) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.accountDeleted(toPm.name));
          operations.add(pmRepo.getUpdateTransferOperation(userId, _tumTransferler[i].toMap()));
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
          operations.add(pmRepo.getUpdateTransferOperation(userId, _tumTransferler[i].toMap()));
          basarisizTransferler.add(context.l10n.insufficientBalanceAccount(fromPm.name));
          transferDegisti = true;
          continue;
        }

        if (toPm.type == 'kredi' && toPm.balance <= 0) {
          _tumTransferler[i] = transfer.copyWith(isFailed: true, failureReason: context.l10n.noDebtToPay(toPm.name));
          operations.add(pmRepo.getUpdateTransferOperation(userId, _tumTransferler[i].toMap()));
          basarisizTransferler.add(context.l10n.noDebtToPay(toPm.name));
          transferDegisti = true;
          continue;
        }

        double fromYeniBakiye = fromPm.type == 'kredi' ? fromPm.balance + convertedTransferAmountFrom : fromPm.balance - convertedTransferAmountFrom;
        _tumOdemeYontemleri[fromIndex] = fromPm.copyWith(balance: fromYeniBakiye);
        operations.add(pmRepo.getUpdatePaymentMethodOperation(userId, _tumOdemeYontemleri[fromIndex].toMap()));

        final convertedTransferAmountTo = currencyService.convert(transfer.amount, transfer.paraBirimi, toPm.paraBirimi);
        double toYeniBakiye = toPm.type == 'kredi' ? toPm.balance - convertedTransferAmountTo : toPm.balance + convertedTransferAmountTo;
        _tumOdemeYontemleri[toIndex] = toPm.copyWith(balance: toYeniBakiye);
        operations.add(pmRepo.getUpdatePaymentMethodOperation(userId, _tumOdemeYontemleri[toIndex].toMap()));

        _tumTransferler[i] = transfer.copyWith(isExecuted: true);
        operations.add(pmRepo.getUpdateTransferOperation(userId, _tumTransferler[i].toMap()));
        transferDegisti = true;
      }
    }

    if (operations.isNotEmpty) {
      try {
        await batchService.commit(operations);
        if (transferDegisti) {
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Toplu transfer güncellemeleri işlenirken hata: $e');
        // GÜVENLİK/KARARLILIK YAMASI: Optimistic Update Rollback
        // Batch commit başarısız olursa, bellek içi `_tumOdemeYontemleri` ve `_tumTransferler` 
        // dizileri bozuk halde kalır ve UI sahte bakiye gösterir. 
        // Hata durumunda, yerel cache'den verileri yeniden yükleyip UI'ı geri alıyoruz.
        _tumOdemeYontemleri = List.from(pmRepo.getPaymentMethods(userId).map((pm) => PaymentMethod.fromMap(pm)));
        _tumTransferler = List.from(pmRepo.getTransfers(userId).map((t) => Transfer.fromMap(t)));
        notifyListeners();
      }
    } else {
      if (transferDegisti) {
        notifyListeners();
      }
    }
    
    return basarisizTransferler;
  }

  Future<void> updateAssetPrices(String userId) async {
    if (_varliklar.isEmpty) return;

    try {
      final priceUpdateService = AssetPriceUpdateService();
      final updatedAssets = await priceUpdateService.updateAllAssetPrices(_varliklar);
      
      bool anyChanged = false;
      for (var newAsset in updatedAssets) {
        final oldAsset = _varliklar.firstWhere((a) => a.id == newAsset.id, orElse: () => newAsset);
        // Sadece fiyatı gerçekten değişenleri Firestore'a yaz
        // Offline'da gereksiz yazmaları ve fatura şişmesini engeller
        if (newAsset.amount != oldAsset.amount) {
          anyChanged = true;
          getIt<AssetRepository>().updateAsset(userId, newAsset.toMap());
        }
      }
      
      // Eğer değişiklik olduysa, Stream zaten dinleyiciyi tetikleyecektir.
      // Ancak lokal durumu da güncelleyelim.
      if (anyChanged) {
        _varliklar = updatedAssets;
      }
    } catch (e) {
      // Sessizce geç, kullanıcıyı rahatsız etme
    }
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    _incomesSubscription?.cancel();
    _assetsSubscription?.cancel();
    _paymentMethodsSubscription?.cancel();
    _transfersSubscription?.cancel();
    super.dispose();
  }
}
