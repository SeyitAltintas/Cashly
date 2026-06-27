import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/services/cloud_sync_service.dart';

import 'package:cashly/features/settings/presentation/pages/profile/profile_page.dart';

// Auth
import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';

// Features
import 'package:cashly/features/tools/presentation/pages/tools_page.dart';
import 'package:cashly/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/features/payment_methods/data/models/transfer_model.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/home/presentation/widgets/home_app_bar.dart';
import 'package:cashly/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/presentation/widgets/streak_celebration_dialog.dart';
import 'package:cashly/features/streak/presentation/widgets/streak_broken_dialog.dart';

// Repository imports
import 'package:cashly/features/streak/data/services/streak_service.dart';
import '../state/home_page_state.dart';
import 'package:cashly/core/widgets/shimmer_loading.dart';
import 'package:cashly/features/home/presentation/utils/home_navigation_helper.dart';

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

    // FPS Optimizasyonu: Sık kullanılan logoyu uygulama genelinde belleğe al.
    precacheImage(const AssetImage('assets/image/seffaflogo.png'), context);

    if (!_transferKontrolYapildi) {
      _transferKontrolYapildi = true;
      final userId = widget.authController.currentUser?.id;
      if (userId != null) {
        _homeState.checkScheduledTransfers(userId, context).then((basarisiz) {
          if (basarisiz.isNotEmpty && mounted) {
            AppSnackBar.warning(
              context,
              context.l10n.scheduledTransfersFailed(basarisiz.join(", ")),
            );
          }
        });
      }
    }
  }

  void _onHomeStateChanged() {
    // setState kaldırıldı, yerine ListenableBuilder kullanılıyor
  }

  // Bekleyen kutlama popup'ı için flag
  bool _pendingCelebration = false;
  int _pendingStreakCount = 0;
  dynamic _pendingNewRank; // RankTier?

  /// Rank/Seri kontrolü yapar ve günceller
  /// Rank atlarsa rank-up kutlaması, seri artarsa normal kutlama gösterir
  Future<void> _seriKontrol() async {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    final result = await StreakService.checkAndUpdateStreak(userId);
    if (mounted) {
      _homeState.streakData = result.data;

      if (result.streakBroken && result.previousStreak > 0) {
        // Seri kırıldı — özel uyarı popup'u göster
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            StreakBrokenDialog.show(context, result.previousStreak);
          }
        });
      } else if (result.rankedUp && result.newRank != null) {
        // Rank atladı — özel rank-up kutlaması
        _pendingCelebration = true;
        _pendingStreakCount = result.data.currentStreak;
        _pendingNewRank = result.newRank;
        _showCelebrationIfPending();
      } else if (result.streakIncreased && result.data.currentStreak > 0) {
        // Normal seri artışı kutlaması
        _pendingCelebration = true;
        _pendingStreakCount = result.data.currentStreak;
        _pendingNewRank = null;
        _showCelebrationIfPending();
      }
    }
  }

  /// Bekleyen kutlama varsa göster
  void _showCelebrationIfPending() {
    if (_pendingCelebration && mounted) {
      _pendingCelebration = false;
      final newRank = _pendingNewRank;
      final streakCount = _pendingStreakCount;
      _pendingNewRank = null;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          if (newRank != null) {
            StreakCelebrationDialog.showRankUp(context, streakCount, newRank);
          } else {
            StreakCelebrationDialog.show(context, streakCount);
          }
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

  Future<void> _verileriOku() async {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    // Cache'den anında yükle + stream'leri başlat (hızlı ilk görüntü)
    _homeState.loadData(userId);

    // Arka planda kategorileri/ayarları güncelle (CloudSyncService kendi timeout'unu yönetir)
    // Stream'ler zaten Firestore offline cache'ten anlık güncelleme yapıyor,
    // bu yüzden sync sonrası loadData() tekrar çağrılmıyor.
    try {
      await CloudSyncService.syncAllUserData(userId);
      if (mounted) {
        _homeState.refreshCategoriesAndSettings(userId);
        _homeState.updateAssetPrices(userId);
      }
    } catch (_) {
      // Offline veya hata: stream'ler mevcut cache'i göstermeye devam eder
      if (mounted) {
        _homeState.updateAssetPrices(userId);
      }
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
        extendBodyBehindAppBar: true,
        extendBody: true,
        // ValueListenableBuilder ile sadece AppBar değişikliklerinde rebuild
        appBar: _buildAppBarWithNotifier(),
        body: PageView(
          controller: _pageController,
          // setState yerine ValueNotifier kullanarak gereksiz rebuild'leri önle
          onPageChanged: (index) => _selectedIndexNotifier.value = index,
          children: [
            _buildToolsPage(),
            _buildDashboardPage(userName),
            ProfilSayfasi(
              authController: widget.authController,
              streakData: _streakData,
              onRefresh: _verileriOku,
              onNavigationReturn: _showCelebrationIfPending,
            ),
          ],
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
      onAssetsPressed: ({bool replace = false, DateTime? initialDate}) =>
          HomeNavigationHelper.navigateToAssets(
            context: context,
            state: _homeState,
            authController: widget.authController,
            onReturn: _showCelebrationIfPending,
            replace: replace,
            initialDate: initialDate,
          ),
      onAnalysisPressed: () => HomeNavigationHelper.navigateToAnalysis(
        context: context,
        state: _homeState,
        authController: widget.authController,
        onReturn: _showCelebrationIfPending,
        onDataRefresh: _verileriOku,
      ),
      onPaymentMethodsPressed: () =>
          HomeNavigationHelper.navigateToPaymentMethods(
            context: context,
            state: _homeState,
            authController: widget.authController,
            onReturn: _showCelebrationIfPending,
          ),
      onTransferPressed: () => HomeNavigationHelper.navigateToTransfer(
        context: context,
        state: _homeState,
        authController: widget.authController,
        onReturn: _showCelebrationIfPending,
      ),
      onExpensesPressed: ({bool replace = false, DateTime? initialDate}) =>
          HomeNavigationHelper.navigateToExpenses(
            context: context,
            state: _homeState,
            authController: widget.authController,
            onReturn: _showCelebrationIfPending,
            onDataRefresh: _verileriOku,
            replace: replace,
            initialDate: initialDate,
          ),
      onIncomesPressed: ({bool replace = false, DateTime? initialDate}) =>
          HomeNavigationHelper.navigateToIncomes(
            context: context,
            state: _homeState,
            authController: widget.authController,
            onReturn: _showCelebrationIfPending,
            onDataRefresh: _verileriOku,
            replace: replace,
            initialDate: initialDate,
          ),
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
    // FPS Optimizasyonu: Sadece Dashboard sayfası değiştiğinde bu bloğu yeniden çiz.
    return ListenableBuilder(
      listenable: _homeState,
      builder: (context, _) {
        if (_isLoading) return const DashboardPageSkeleton();

        return RefreshIndicator(
          onRefresh: _yenile,
          edgeOffset: 0.0,
          displacement: 80.0,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: DashboardPage(
            userName: userName,
            profileImage: widget.authController.currentUser?.profileImage,
            harcamalar: tumHarcamalar,
            gelirler: tumGelirler,
            varliklar: varliklar,
            odemeYontemleri: tumOdemeYontemleri,
            butceLimiti: butceLimiti,
            secilenAy: secilenAy,
            streakData: _streakData,
            transferler: tumTransferler,
            categoryBudgets: categoryBudgets,
            onAssetsPressed: ({bool replace = false, DateTime? initialDate}) =>
                HomeNavigationHelper.navigateToAssets(
                  context: context,
                  state: _homeState,
                  authController: widget.authController,
                  onReturn: _showCelebrationIfPending,
                  replace: replace,
                  initialDate: initialDate,
                ),
          ),
        );
      },
    );
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
