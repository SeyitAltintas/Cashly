import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/services/cloud_sync_service.dart';

import 'package:cashly/features/settings/presentation/pages/profile/profile_page.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:cashly/core/services/asset_price_update_service.dart';

// Auth
import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';

// Features
import 'package:cashly/features/tools/presentation/pages/tools_page.dart';
import 'package:cashly/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:cashly/features/expenses/presentation/pages/expenses_page.dart';
import 'package:cashly/features/income/presentation/pages/incomes_page.dart';
import 'package:cashly/features/assets/presentation/pages/assets_page.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';
import 'package:cashly/features/analysis/presentation/pages/analysis_page.dart';
import 'package:cashly/features/payment_methods/presentation/pages/payment_methods_page.dart';
import 'package:cashly/features/payment_methods/presentation/pages/transfer_page.dart';
import 'package:cashly/features/payment_methods/presentation/pages/payment_method_detail_page.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/features/payment_methods/data/models/transfer_model.dart';
import 'package:cashly/features/payment_methods/domain/transfer_schedule_policy.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/home/presentation/widgets/home_app_bar.dart';
import 'package:cashly/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/presentation/widgets/streak_celebration_dialog.dart';

// Repository imports
import 'package:cashly/features/assets/domain/repositories/asset_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/streak/data/services/streak_service.dart';
import 'package:cashly/core/widgets/error_boundary.dart';
import '../state/home_page_state.dart';
import 'package:cashly/core/widgets/skeleton_widget.dart';

/// Yeni 3 sekmeli ana navigasyon sayfası
/// Araçlar (0), Dashboard (1), Profil (2)
class AnaSayfa extends StatefulWidget {
  final AuthController authController;

  const AnaSayfa({super.key, required this.authController});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> with WidgetsBindingObserver {
  // Varsayılan: Dashboard (ortadaki sekme)
  // ValueNotifier ile sayfa index'i yönetimi - gereksiz rebuild'leri önler
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier(1);
  late PageController _pageController;

  // ChangeNotifier state yöneticisi
  late final HomePageState _homeState;

  /// Rate limiting: son Firestore refresh zamanı
  /// Kullanıcı arka arkaya pull-to-refresh yaparsa Firebase kotası korunur.
  DateTime? _lastCloudRefreshTime;
  static const _refreshCooldown = Duration(seconds: 60);

  // Getter'lar
  bool get _isLoading => _homeState.isLoading;
  List<Map<String, dynamic>> get tumHarcamalar => _homeState.tumHarcamalar;
  List<Income> get tumGelirler => _homeState.tumGelirler;
  List<Asset> get varliklar => _homeState.varliklar;
  List<PaymentMethod> get tumOdemeYontemleri => _homeState.tumOdemeYontemleri;
  List<Transfer> get tumTransferler => _homeState.tumTransferler;
  StreakData get _streakData => _homeState.streakData;
  double get butceLimiti => _homeState.butceLimiti;
  DateTime get secilenAy => _homeState.secilenAy;
  String? get varsayilanOdemeYontemiId => _homeState.varsayilanOdemeYontemiId;
  Map<String, double> get categoryBudgets => _homeState.categoryBudgets;
  Map<String, IconData> get kategoriIkonlari => _homeState.kategoriIkonlari;
  Map<String, IconData> get gelirKategoriIkonlari =>
      _homeState.gelirKategoriIkonlari;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _selectedIndexNotifier.value);

    _homeState = HomePageState();
    _homeState.addListener(_onHomeStateChanged);

    _verileriOku();
    _seriKontrol();
  }

  bool _transferKontrolYapildi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Localization ancak didChangeDependencies'te hazır olur
    // initState'te context.l10n kullanılamaz (Flutter 3.41+)
    if (!_transferKontrolYapildi) {
      _transferKontrolYapildi = true;
      _zamanlanmisTransferleriKontrolEt();
    }
  }

  void _onHomeStateChanged() {
    // setState kaldırıldı, yerine ListenableBuilder kullanılıyor
  }

  // Bekleyen kutlama popup'ı için flag
  bool _pendingCelebration = false;
  int _pendingStreakCount = 0;

  /// Seri kontrolü yapar ve günceller
  /// Seri artarsa kutlama dialog'u gösterir
  Future<void> _seriKontrol() async {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    final result = await StreakService.checkAndUpdateStreak(userId);
    if (mounted) {
      _homeState.streakData = result.data;

      // Seri arttıysa kutlama için işaretle
      if (result.streakIncreased && result.data.currentStreak > 0) {
        _pendingCelebration = true;
        _pendingStreakCount = result.data.currentStreak;
        // Popup'ı göster
        _showCelebrationIfPending();
      }
    }
  }

  /// Bekleyen kutlama varsa göster
  void _showCelebrationIfPending() {
    if (_pendingCelebration && mounted) {
      _pendingCelebration = false;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          StreakCelebrationDialog.show(context, _pendingStreakCount);
        }
      });
    }
  }

  /// Uygulama ön plana geldiğinde veya route değiştiğinde çağrılır
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldiğinde bekleyen kutlamayı kontrol et
      _showCelebrationIfPending();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _selectedIndexNotifier.dispose();
    _homeState.removeListener(_onHomeStateChanged);
    _homeState.dispose();
    super.dispose();
  }

  /// Tüm verileri repository'lerden okur
  void _verileriOku() {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    _homeState.loadData(userId);

    // Varlık fiyatlarını arka planda güncelle
    _updateAssetPrices();
  }

  /// Zamanlanmış transferleri kontrol eder ve tarihi gelenleri uygular
  /// Edge case'ler: yetersiz bakiye, silinmiş hesap
  void _zamanlanmisTransferleriKontrolEt() {
    bool transferDegisti = false;
    List<String> basarisizTransferler = [];

    for (int i = 0; i < tumTransferler.length; i++) {
      final transfer = tumTransferler[i];

      // Bekleyen zamanlanmış transfer mi?
      if (transfer.isPending) {
        // Gönderen hesabı kontrol et
        final fromIndex = tumOdemeYontemleri.indexWhere(
          (pm) => pm.id == transfer.fromAccountId,
        );

        // Alıcı hesabı kontrol et
        final toIndex = tumOdemeYontemleri.indexWhere(
          (pm) => pm.id == transfer.toAccountId,
        );

        // Edge Case 1: Gönderen hesap silinmiş veya bulunamadı
        if (fromIndex == -1) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: context.l10n.senderAccountNotFound,
          );
          getIt<PaymentMethodRepository>().updateTransfer(
            widget.authController.currentUser!.id,
            tumTransferler[i].toMap(),
          );
          basarisizTransferler.add(context.l10n.senderAccountNotFound);
          transferDegisti = true;
          continue;
        }

        // Edge Case 2: Alıcı hesap silinmiş veya bulunamadı
        if (toIndex == -1) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: context.l10n.receiverAccountNotFound,
          );
          getIt<PaymentMethodRepository>().updateTransfer(
            widget.authController.currentUser!.id,
            tumTransferler[i].toMap(),
          );
          basarisizTransferler.add(context.l10n.receiverAccountNotFound);
          transferDegisti = true;
          continue;
        }

        final fromPm = tumOdemeYontemleri[fromIndex];
        final toPm = tumOdemeYontemleri[toIndex];

        // Edge Case 3: Gönderen hesap silinmiş (isDeleted = true)
        if (fromPm.isDeleted) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: context.l10n.accountDeleted(fromPm.name),
          );
          getIt<PaymentMethodRepository>().updateTransfer(
            widget.authController.currentUser!.id,
            tumTransferler[i].toMap(),
          );
          basarisizTransferler.add(context.l10n.accountDeleted(fromPm.name));
          transferDegisti = true;
          continue;
        }

        // Edge Case 4: Alıcı hesap silinmiş (isDeleted = true)
        if (toPm.isDeleted) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: context.l10n.accountDeleted(toPm.name),
          );
          getIt<PaymentMethodRepository>().updateTransfer(
            widget.authController.currentUser!.id,
            tumTransferler[i].toMap(),
          );
          basarisizTransferler.add(context.l10n.accountDeleted(toPm.name));
          transferDegisti = true;
          continue;
        }

        // Edge Case 5: Gönderen hesap kontrolü (Yetersiz bakiye veya Limit aşımı)
        final cur = getIt<CurrencyService>();
        final convertedTransferAmountFrom = cur.convert(
          transfer.amount,
          transfer.paraBirimi,
          fromPm.paraBirimi,
        );

        bool limitVeyaBakiyeAsildi = false;
        if (fromPm.type == 'kredi') {
          final kalanLimit = (fromPm.limit ?? 0) - fromPm.balance;
          if (convertedTransferAmountFrom > kalanLimit) {
            limitVeyaBakiyeAsildi = true;
          }
        } else {
          if (fromPm.balance < convertedTransferAmountFrom) {
            limitVeyaBakiyeAsildi = true;
          }
        }

        if (limitVeyaBakiyeAsildi) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: context.l10n.insufficientBalanceAccount(fromPm.name),
          );
          getIt<PaymentMethodRepository>().updateTransfer(
            widget.authController.currentUser!.id,
            tumTransferler[i].toMap(),
          );
          basarisizTransferler.add(
            context.l10n.insufficientBalanceAccount(fromPm.name),
          );
          transferDegisti = true;
          continue;
        }

        // Edge Case 6: Alıcı kredi kartında borç yok (ödeme yapacak borç yok)
        if (toPm.type == 'kredi' && toPm.balance <= 0) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: context.l10n.noDebtToPay(toPm.name),
          );
          getIt<PaymentMethodRepository>().updateTransfer(
            widget.authController.currentUser!.id,
            tumTransferler[i].toMap(),
          );
          basarisizTransferler.add(context.l10n.noDebtToPay(toPm.name));
          transferDegisti = true;
          continue;
        }

        // Tüm kontroller geçti - transfer uygula
        double fromYeniBakiye = fromPm.type == 'kredi'
            ? fromPm.balance + convertedTransferAmountFrom
            : fromPm.balance - convertedTransferAmountFrom;
        tumOdemeYontemleri[fromIndex] = fromPm.copyWith(
          balance: fromYeniBakiye,
        );
        getIt<PaymentMethodRepository>().updatePaymentMethod(
          widget.authController.currentUser!.id,
          tumOdemeYontemleri[fromIndex].toMap(),
        );

        final convertedTransferAmountTo = cur.convert(
          transfer.amount,
          transfer.paraBirimi,
          toPm.paraBirimi,
        );
        double toYeniBakiye = toPm.type == 'kredi'
            ? toPm.balance - convertedTransferAmountTo
            : toPm.balance + convertedTransferAmountTo;
        tumOdemeYontemleri[toIndex] = toPm.copyWith(balance: toYeniBakiye);
        getIt<PaymentMethodRepository>().updatePaymentMethod(
          widget.authController.currentUser!.id,
          tumOdemeYontemleri[toIndex].toMap(),
        );

        // Transferi başarılı olarak işaretle
        tumTransferler[i] = transfer.copyWith(isExecuted: true);
        getIt<PaymentMethodRepository>().updateTransfer(
          widget.authController.currentUser!.id,
          tumTransferler[i].toMap(),
        );
        transferDegisti = true;
      }
    }

    if (transferDegisti) {
      // _odemeYontemleriKaydet(); // İptal edildi
      // _transferleriKaydet(); // İptal edildi

      // UI'ı güncelle - ChangeNotifier ile
      _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
      _homeState.tumTransferler = List.from(tumTransferler);

      // Başarısız transfer varsa kullanıcıyı bilgilendir
      if (basarisizTransferler.isNotEmpty && mounted) {
        AppSnackBar.warning(
          context,
          context.l10n.scheduledTransfersFailed(
            basarisizTransferler.join(", "),
          ),
        );
      }
    }
  }

  /// Varlık fiyatlarını güncel API verilerine göre günceller
  Future<void> _updateAssetPrices() async {
    // Güncellenecek varlık yoksa çık
    if (varliklar.isEmpty) {
      return;
    }

    try {
      final priceUpdateService = AssetPriceUpdateService();
      final updatedAssets = await priceUpdateService.updateAllAssetPrices(
        varliklar,
      );

      if (mounted) {
        _homeState.varliklar = updatedAssets;
        for (var asset in updatedAssets) {
          getIt<AssetRepository>().updateAsset(
            widget.authController.currentUser!.id,
            asset.toMap(),
          );
        }
      }
    } catch (e) {
      // Sessizce geç, kullanıcıyı rahatsız etme
    }
  }

  // ===== KAYIT METODLARI =====

  // _harcamalariKaydet iptal edildi, tekil işlemler yapılıyor

  // _gelirleriKaydet iptal edildi, tekil işlemler yapılıyor

  // _varliklariKaydet iptal edildi, tekil işlemler yapılıyor

  // _odemeYontemleriKaydet iptal edildi, tekil işlemler yapılıyor

  // _transferleriKaydet iptal edildi, tekil işlemler yapılıyor

  @override
  Widget build(BuildContext context) {
    final userName =
        widget.authController.currentUser?.name ?? context.l10n.user;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndexNotifier.value != 1) {
          _pageController.jumpToPage(1);
          _selectedIndexNotifier.value = 1;
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // ValueListenableBuilder ile sadece AppBar değişikliklerinde rebuild
        appBar: _buildAppBarWithNotifier(),
        body: ListenableBuilder(
          listenable: _homeState,
          builder: (context, _) {
            return PageView(
              controller: _pageController,
              // setState yerine ValueNotifier kullanarak gereksiz rebuild'leri önle
              onPageChanged: (index) => _selectedIndexNotifier.value = index,
              children: [
                _buildToolsPage(),
                _buildDashboardPage(userName),
                ProfilSayfasi(
                  authController: widget.authController,
                  onRefresh: _verileriOku,
                  onNavigationReturn: _showCelebrationIfPending,
                ),
              ],
            );
          },
        ),
        // ValueListenableBuilder ile sadece navigation değişikliklerinde rebuild
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _selectedIndexNotifier,
          builder: (context, selectedIndex, _) {
            return HomeBottomNav(
              selectedIndex: selectedIndex,
              onPageChanged: (index) => _pageController.jumpToPage(index),
            );
          },
        ),
      ),
    );
  }

  /// AppBar için ValueListenableBuilder wrapper
  /// Sadece sayfa değişikliğinde rebuild olur
  PreferredSizeWidget _buildAppBarWithNotifier() {
    // M3 uyumlu: çocuk AppBar'ın kendi preferredSize'ını kullan
    return _DynamicAppBar(selectedIndexNotifier: _selectedIndexNotifier);
  }

  Widget _buildToolsPage() {
    return ToolsPage(
      onAssetsPressed: _navigateToAssets,
      onAnalysisPressed: _navigateToAnalysis,
      onPaymentMethodsPressed: _navigateToPaymentMethods,
      onTransferPressed: _navigateToTransfer,
      onExpensesPressed: _navigateToExpenses,
      onIncomesPressed: _navigateToIncomes,
    );
  }

  /// Pull-to-refresh: Firebase'den guncel veri ceker
  /// Rate limiting + offline fallback + quota koruma icerir.
  Future<void> _yenile() async {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final lastRefresh = _lastCloudRefreshTime;

    // --- RATE LIMIT: 60 saniye cooldown ---
    if (lastRefresh != null && now.difference(lastRefresh) < _refreshCooldown) {
      final saniyeKaldi =
          (_refreshCooldown - now.difference(lastRefresh)).inSeconds;
      if (mounted) {
        AppSnackBar.info(context, context.l10n.canRefreshIn(saniyeKaldi));
      }
      return;
    }

    // --- FIRESTORE SYNC ---
    try {
      await CloudSyncService.syncAllUserData(
        userId,
      ).timeout(const Duration(seconds: 15));

      _lastCloudRefreshTime = DateTime.now();

      // Cache guncellendi, UI'yi yeniden oku
      _verileriOku();

      if (mounted) {
        AppSnackBar.success(
          context,
          context.l10n.allDataUpToDate,
          duration: const Duration(seconds: 2),
        );
      }
    } on TimeoutException {
      // --- OFFLINE / COK YAVAS ---
      // Mevcut cache korunur, kullaniciya bilgi verilir
      _verileriOku(); // cache'deki veriyi goster
      if (mounted) {
        AppSnackBar.warning(context, context.l10n.offlineDataShown);
      }
    } catch (e) {
      // Diger hatalar (permission-denied vb.)
      _verileriOku();
      if (mounted) {
        AppSnackBar.warning(context, context.l10n.dataRefreshFailed);
      }
    }
  }

  Widget _buildDashboardPage(String userName) {
    if (_isLoading) return const DashboardPageSkeleton();

    // Mor-mavi ton (varsayılan tema için)
    const refreshColor = Color(0xFF6C63FF);

    return RefreshIndicator(
      onRefresh: _yenile,
      color: refreshColor,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: DashboardPage(
        userName: userName,
        harcamalar: tumHarcamalar,
        gelirler: tumGelirler,
        varliklar: varliklar,
        odemeYontemleri: tumOdemeYontemleri,
        butceLimiti: butceLimiti,
        secilenAy: secilenAy,
        streakData: _streakData,
        transferler: tumTransferler,
        categoryBudgets: categoryBudgets,
        onAssetsPressed: _navigateToAssets,
      ),
    );
  }

  // ===== NAVİGASYON METODLARI =====

  void _navigateToAssets({bool replace = false, DateTime? initialDate}) {
    final route = MaterialPageRoute(
      builder: (context) => PageErrorBoundary(
        pageName: context.l10n.assets,
        child: AssetsPage(
          assets: varliklar.where((a) => !a.isDeleted).toList(),
          deletedAssets: varliklar.where((a) => a.isDeleted).toList(),
          initialDate: initialDate ?? secilenAy,
          onDelete: (asset) {
            final index = varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              final deletedAsset = varliklar[index].copyWith(isDeleted: true);
              varliklar[index] = deletedAsset;
              getIt<AssetRepository>().updateAsset(
                widget.authController.currentUser!.id,
                deletedAsset.toMap(),
              );
            }
            _homeState.varliklar = List.from(varliklar);
          },
          onEdit: (asset) {
            final index = varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              varliklar[index] = asset;
              getIt<AssetRepository>().updateAsset(
                widget.authController.currentUser!.id,
                asset.toMap(),
              );
            }
            _homeState.varliklar = List.from(varliklar);
          },
          onRestore: (asset) {
            final index = varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              final restoredAsset = varliklar[index].copyWith(isDeleted: false);
              varliklar[index] = restoredAsset;
              getIt<AssetRepository>().updateAsset(
                widget.authController.currentUser!.id,
                restoredAsset.toMap(),
              );
            }
            _homeState.varliklar = List.from(varliklar);
          },
          onPermanentDelete: (asset) {
            varliklar.removeWhere((a) => a.id == asset.id);
            _homeState.varliklar = List.from(varliklar);
            getIt<AssetRepository>().deleteAsset(
              widget.authController.currentUser!.id,
              asset.id,
            );
          },
          onEmptyBin: () {
            final deletedAssets = varliklar.where((a) => a.isDeleted).toList();
            for (var asset in deletedAssets) {
              getIt<AssetRepository>().deleteAsset(
                widget.authController.currentUser!.id,
                asset.id,
              );
            }
            varliklar.removeWhere((a) => a.isDeleted);
            _homeState.varliklar = List.from(varliklar);
          },
          onAdd: (name, amount, quantity, category, type) {
            final newAsset = Asset(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              amount: amount,
              quantity: quantity,
              category: category,
              type: type,
              lastUpdated: DateTime.now(),
              isDeleted: false,
            );
            varliklar.add(newAsset);
            _homeState.varliklar = List.from(varliklar);
            getIt<AssetRepository>().addAsset(
              widget.authController.currentUser!.id,
              newAsset.toMap(),
            );
          },
        ),
      ),
    );

    final future = replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);

    future.then((_) => _showCelebrationIfPending());
  }

  void _navigateToAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageErrorBoundary(
          pageName: context.l10n.analysis,
          child: AnalysisPage(
            expenses: tumHarcamalar,
            assets: varliklar,
            incomes: tumGelirler,
            selectedDate: secilenAy,
            userId: widget.authController.currentUser?.id ?? '',
            userName:
                widget.authController.currentUser?.name ?? context.l10n.user,
            paymentMethods: tumOdemeYontemleri,
            categoryBudgets: categoryBudgets,
            totalBudget: butceLimiti,
            expenseCategoryIcons: kategoriIkonlari,
            incomeCategoryIcons: gelirKategoriIkonlari,
            onAddExpensePressed: (DateTime date) {
              _navigateToExpenses(replace: true, initialDate: date);
            },
            onAddIncomePressed: (DateTime date) {
              _navigateToIncomes(replace: true, initialDate: date);
            },
            onAddAssetPressed: (DateTime date) {
              _navigateToAssets(replace: true, initialDate: date);
            },
          ),
        ),
      ),
    ).then((_) => _showCelebrationIfPending());
  }

  void _navigateToPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageErrorBoundary(
          pageName: context.l10n.paymentMethods,
          child: PaymentMethodsPage(
            paymentMethods: tumOdemeYontemleri
                .where((p) => !p.isDeleted)
                .toList(),
            deletedPaymentMethods: tumOdemeYontemleri
                .where((p) => p.isDeleted)
                .toList(),
            userName: widget.authController.currentUser?.name,
            userProfileUrl: widget.authController.currentUser?.profileImage,
            onDelete: (pm) {
              final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) {
                final deletedPm = pm.copyWith(isDeleted: true);
                tumOdemeYontemleri[i] = deletedPm;
                _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  widget.authController.currentUser!.id,
                  deletedPm.toMap(),
                );
              }
            },
            onEdit: (pm) {
              final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) {
                tumOdemeYontemleri[i] = pm;
                _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  widget.authController.currentUser!.id,
                  pm.toMap(),
                );
              }
            },
            onRestore: (pm) {
              final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) {
                final restoredPm = pm.copyWith(isDeleted: false);
                tumOdemeYontemleri[i] = restoredPm;
                _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  widget.authController.currentUser!.id,
                  restoredPm.toMap(),
                );
              }
            },
            onPermanentDelete: (pm) {
              tumOdemeYontemleri.removeWhere((p) => p.id == pm.id);
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
              getIt<PaymentMethodRepository>().deletePaymentMethod(
                widget.authController.currentUser!.id,
                pm.id,
              );
            },
            onEmptyBin: () {
              final deletedMethods = tumOdemeYontemleri
                  .where((p) => p.isDeleted)
                  .toList();
              for (var delPm in deletedMethods) {
                getIt<PaymentMethodRepository>().deletePaymentMethod(
                  widget.authController.currentUser!.id,
                  delPm.id,
                );
              }
              tumOdemeYontemleri.removeWhere((p) => p.isDeleted);
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            },
            onAdd: (name, type, lastFourDigits, balance, limit, colorIndex) {
              final newPm = PaymentMethod(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                type: type,
                lastFourDigits: lastFourDigits,
                balance: balance,
                limit: limit,
                colorIndex: colorIndex,
                createdAt: DateTime.now(),
                isDeleted: false,
              );
              tumOdemeYontemleri.add(newPm);
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
              getIt<PaymentMethodRepository>().addPaymentMethod(
                widget.authController.currentUser!.id,
                newPm.toMap(),
              );
            },
            onCardTap: (pm) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentMethodDetailPage(
                    paymentMethod: pm,
                    harcamalar: tumHarcamalar,
                    gelirler: tumGelirler,
                    transferler: tumTransferler,
                    tumOdemeYontemleri: tumOdemeYontemleri,
                  ),
                ),
              ).then((_) => _showCelebrationIfPending());
            },
          ),
        ),
      ),
    ).then((_) => _showCelebrationIfPending());
  }

  void _navigateToTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferPage(
          userId: widget.authController.currentUser?.id,
          paymentMethods: tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          transfers: tumTransferler,
          onTransfer: (fromId, toId, amount, date) {
            // Tarihi kontrol et - bugün mü yoksa ileri tarih mi?
            final isScheduled = TransferSchedulePolicy.isScheduled(
              selectedDate: date,
            );

            if (!isScheduled) {
              // Anında transfer - bakiyeleri hemen güncelle
              final cur = getIt<CurrencyService>();

              final fromIndex = tumOdemeYontemleri.indexWhere(
                (pm) => pm.id == fromId,
              );
              if (fromIndex != -1) {
                final fromPm = tumOdemeYontemleri[fromIndex];
                final convertedFromAmount = cur.convert(
                  amount,
                  cur.currentCurrency,
                  fromPm.paraBirimi,
                );

                double yeniBakiye = fromPm.type == 'kredi'
                    ? fromPm.balance + convertedFromAmount
                    : fromPm.balance - convertedFromAmount;
                tumOdemeYontemleri[fromIndex] = fromPm.copyWith(
                  balance: yeniBakiye,
                );
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  widget.authController.currentUser!.id,
                  tumOdemeYontemleri[fromIndex].toMap(),
                );
              }
              final toIndex = tumOdemeYontemleri.indexWhere(
                (pm) => pm.id == toId,
              );
              if (toIndex != -1) {
                final toPm = tumOdemeYontemleri[toIndex];
                final convertedToAmount = cur.convert(
                  amount,
                  cur.currentCurrency,
                  toPm.paraBirimi,
                );

                double yeniBakiye = toPm.type == 'kredi'
                    ? toPm.balance - convertedToAmount
                    : toPm.balance + convertedToAmount;
                tumOdemeYontemleri[toIndex] = toPm.copyWith(
                  balance: yeniBakiye,
                );
                getIt<PaymentMethodRepository>().updatePaymentMethod(
                  widget.authController.currentUser!.id,
                  tumOdemeYontemleri[toIndex].toMap(),
                );
              }
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            }
            // İleri tarihli transfer - bakiye değişmez, zamanlanmış olarak kaydedilir

            // Transfer kaydını oluştur
            final newTransfer = Transfer(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              fromAccountId: fromId,
              toAccountId: toId,
              amount: amount,
              date: date,
              isScheduled: isScheduled,
              isExecuted: !isScheduled, // Anında transfer zaten uygulandı
              paraBirimi: getIt<CurrencyService>().currentCurrency,
            );
            tumTransferler.insert(0, newTransfer);
            getIt<PaymentMethodRepository>().addTransfer(
              widget.authController.currentUser!.id,
              newTransfer.toMap(),
            );
          },
        ),
      ),
    ).then((_) => _showCelebrationIfPending());
  }

  void _navigateToExpenses({bool replace = false, DateTime? initialDate}) {
    final route = MaterialPageRoute(
      builder: (context) => PageErrorBoundary(
        pageName: context.l10n.expenses,
        child: ExpensesPage(
          tumHarcamalar: tumHarcamalar,
          tumOdemeYontemleri: tumOdemeYontemleri,
          kategoriIkonlari: kategoriIkonlari,
          butceLimiti: butceLimiti,
          secilenAy: initialDate ?? secilenAy,
          userId: widget.authController.currentUser?.id,
          varsayilanOdemeYontemiId: varsayilanOdemeYontemiId,
          onHarcamalarChanged: (harcamalar) {
            _homeState.tumHarcamalar = harcamalar;
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            _homeState.tumOdemeYontemleri = odemeYontemleri;
          },
          onMonthChanged: (DateTime newMonth) {
            _homeState.secilenAy = newMonth;
          },
        ),
      ),
    );

    final future = replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);

    future.then((_) {
      _verileriOku();
      _showCelebrationIfPending();
    });
  }

  void _navigateToIncomes({bool replace = false, DateTime? initialDate}) {
    final route = MaterialPageRoute(
      builder: (context) => PageErrorBoundary(
        pageName: context.l10n.incomes,
        child: IncomesPage(
          tumGelirler: tumGelirler,
          tumOdemeYontemleri: tumOdemeYontemleri,
          gelirKategoriIkonlari: gelirKategoriIkonlari,
          secilenAy: initialDate ?? secilenAy,
          userId: widget.authController.currentUser?.id,
          onGelirlerChanged: (gelirler) {
            _homeState.tumGelirler = gelirler;
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            _homeState.tumOdemeYontemleri = odemeYontemleri;
          },
          onMonthChanged: (DateTime newMonth) {
            _homeState.secilenAy = newMonth;
          },
        ),
      ),
    );

    final future = replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(context, route);

    future.then((_) {
      _verileriOku();
      _showCelebrationIfPending();
    });
  }
}

/// M3 uyumlu dinamik AppBar
/// PreferredSize ile sabit yükseklik yerine, çocuk AppBar'ın kendi yüksekliğini kullanır
class _DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<int> selectedIndexNotifier;

  const _DynamicAppBar({required this.selectedIndexNotifier});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexNotifier,
      builder: (context, selectedIndex, _) {
        if (selectedIndex == 0) return const ToolsAppBar();
        if (selectedIndex == 1) return const DashboardAppBar();
        return const ProfileAppBar();
      },
    );
  }
}
