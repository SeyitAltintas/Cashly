import 'package:flutter/material.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';

import 'package:cashly/features/settings/presentation/pages/profile_page.dart';
import 'package:cashly/core/di/injection_container.dart';
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
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/home/presentation/widgets/home_app_bar.dart';
import 'package:cashly/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';
import 'package:cashly/features/streak/presentation/widgets/streak_celebration_dialog.dart';

// Repository imports
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/features/assets/domain/repositories/asset_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/streak/domain/repositories/streak_repository.dart';
import 'package:cashly/features/streak/data/services/streak_service.dart';

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
  bool _isLoading = true;

  // Veri state'leri
  List<Map<String, dynamic>> tumHarcamalar = [];
  List<Income> tumGelirler = [];
  List<Asset> varliklar = [];
  List<PaymentMethod> tumOdemeYontemleri = [];
  List<Transfer> tumTransferler = [];
  double butceLimiti = 8000.0;
  DateTime secilenAy = DateTime.now();
  String? varsayilanOdemeYontemiId;

  // Seri verisi
  StreakData _streakData = StreakData.empty();

  // Kategori ikonları
  static const Map<String, IconData> kategoriIkonlari = {
    'Yiyecek': Icons.restaurant,
    'Ulaşım': Icons.directions_car,
    'Eğlence': Icons.movie,
    'Sağlık': Icons.local_hospital,
    'Giyim': Icons.shopping_bag,
    'Eğitim': Icons.school,
    'Faturalar': Icons.receipt,
    'Sabit Giderler': Icons.repeat,
    'Diğer': Icons.category,
  };

  static const Map<String, IconData> gelirKategoriIkonlari = {
    'Maaş': Icons.work,
    'Freelance': Icons.laptop,
    'Yatırım': Icons.trending_up,
    'Kira': Icons.home,
    'Hediye': Icons.card_giftcard,
    'Diğer': Icons.attach_money,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _selectedIndexNotifier.value);
    _verileriOku();
    _seriKontrol();
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
      setState(() => _streakData = result.data);

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
    super.dispose();
  }

  /// Tüm verileri repository'lerden okur
  void _verileriOku() {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    // Repository'leri DI'dan al
    final expenseRepo = getIt<ExpenseRepository>();
    final incomeRepo = getIt<IncomeRepository>();
    final assetRepo = getIt<AssetRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();
    final streakRepo = getIt<StreakRepository>();

    // Harcamalar
    tumHarcamalar = expenseRepo.getExpenses(userId);
    butceLimiti = expenseRepo.getBudget(userId);

    // Varliklar
    final varlikVerileri = assetRepo.getAssets(userId);
    varliklar = varlikVerileri.map((map) => Asset.fromMap(map)).toList();

    // Gelirler
    final gelirVerileri = incomeRepo.getIncomes(userId);
    tumGelirler = gelirVerileri.map((map) => Income.fromMap(map)).toList();

    // Ödeme yöntemleri
    final odemeVerileri = paymentRepo.getPaymentMethods(userId);
    tumOdemeYontemleri = odemeVerileri
        .map((map) => PaymentMethod.fromMap(map))
        .toList();

    // Transferler
    final transferVerileri = paymentRepo.getTransfers(userId);
    tumTransferler = transferVerileri
        .map((map) => Transfer.fromMap(map))
        .toList();

    varsayilanOdemeYontemiId = paymentRepo.getDefaultPaymentMethod(userId);

    // Streak verisi
    _streakData = streakRepo.getStreakData(userId);

    setState(() => _isLoading = false);

    // Varlık fiyatlarını arka planda güncelle
    _updateAssetPrices();

    // Zamanlanmış transferleri kontrol et
    _zamanlanmisTransferleriKontrolEt();
  }

  /// Zamanlanmış transferleri kontrol eder ve tarihi gelenleri uygular
  void _zamanlanmisTransferleriKontrolEt() {
    bool transferUygulandi = false;

    for (int i = 0; i < tumTransferler.length; i++) {
      final transfer = tumTransferler[i];

      // Bekleyen zamanlanmış transfer mi?
      if (transfer.isPending) {
        // Bu transferi uygula
        final fromIndex = tumOdemeYontemleri.indexWhere(
          (pm) => pm.id == transfer.fromAccountId,
        );
        if (fromIndex != -1) {
          final fromPm = tumOdemeYontemleri[fromIndex];
          double yeniBakiye = fromPm.type == 'kredi'
              ? fromPm.balance + transfer.amount
              : fromPm.balance - transfer.amount;
          tumOdemeYontemleri[fromIndex] = fromPm.copyWith(balance: yeniBakiye);
        }

        final toIndex = tumOdemeYontemleri.indexWhere(
          (pm) => pm.id == transfer.toAccountId,
        );
        if (toIndex != -1) {
          final toPm = tumOdemeYontemleri[toIndex];
          double yeniBakiye = toPm.type == 'kredi'
              ? toPm.balance - transfer.amount
              : toPm.balance + transfer.amount;
          tumOdemeYontemleri[toIndex] = toPm.copyWith(balance: yeniBakiye);
        }

        // Transferi uygulandı olarak işaretle
        tumTransferler[i] = transfer.copyWith(isExecuted: true);
        transferUygulandi = true;
      }
    }

    if (transferUygulandi) {
      _odemeYontemleriKaydet();
      _transferleriKaydet();
      // UI'ı güncelle
      if (mounted) {
        setState(() {});
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
        setState(() => varliklar = updatedAssets);
        _varliklariKaydet();
      }
    } catch (e) {
      // Sessizce geç, kullanıcıyı rahatsız etme
    }
  }

  // ===== KAYIT METODLARI =====

  void _harcamalariKaydet() {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;
    getIt<ExpenseRepository>().saveExpenses(userId, tumHarcamalar);
  }

  void _gelirleriKaydet() {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;
    getIt<IncomeRepository>().saveIncomes(
      userId,
      tumGelirler.map((g) => g.toMap()).toList(),
    );
  }

  void _varliklariKaydet() {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;
    getIt<AssetRepository>().saveAssets(
      userId,
      varliklar.map((a) => a.toMap()).toList(),
    );
  }

  void _odemeYontemleriKaydet() {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;
    getIt<PaymentMethodRepository>().savePaymentMethods(
      userId,
      tumOdemeYontemleri.map((pm) => pm.toMap()).toList(),
    );
  }

  void _transferleriKaydet() {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;
    getIt<PaymentMethodRepository>().saveTransfers(
      userId,
      tumTransferler.map((t) => t.toMap()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.authController.currentUser?.name ?? 'Kullanıcı';

    return Scaffold(
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
    );
  }

  /// AppBar için ValueListenableBuilder wrapper
  /// Sadece sayfa değişikliğinde rebuild olur
  PreferredSizeWidget _buildAppBarWithNotifier() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedIndexNotifier,
        builder: (context, selectedIndex, _) {
          if (selectedIndex == 0) return const ToolsAppBar();
          if (selectedIndex == 1) return const DashboardAppBar();
          return const ProfileAppBar();
        },
      ),
    );
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

  /// Pull-to-refresh için verileri yeniden okur
  Future<void> _yenile() async {
    _verileriOku();
    // Animasyonun düzgün görünmesi için kısa bir bekleme
    await Future.delayed(const Duration(milliseconds: 500));

    // Kullanıcıya verilerin güncellendiğini bildir
    if (mounted) {
      AppSnackBar.info(context, 'Tüm veriler güncel');
    }
  }

  Widget _buildDashboardPage(String userName) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

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
      ),
    );
  }

  // ===== NAVİGASYON METODLARI =====

  void _navigateToAssets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetsPage(
          assets: varliklar.where((a) => !a.isDeleted).toList(),
          deletedAssets: varliklar.where((a) => a.isDeleted).toList(),
          onDelete: (asset) {
            setState(() => asset.isDeleted = true);
            _varliklariKaydet();
          },
          onEdit: (asset) {
            setState(() {
              final index = varliklar.indexWhere((a) => a.id == asset.id);
              if (index != -1) varliklar[index] = asset;
            });
            _varliklariKaydet();
          },
          onRestore: (asset) {
            setState(() => asset.isDeleted = false);
            _varliklariKaydet();
          },
          onPermanentDelete: (asset) {
            setState(() => varliklar.remove(asset));
            _varliklariKaydet();
          },
          onEmptyBin: () {
            setState(() => varliklar.removeWhere((a) => a.isDeleted));
            _varliklariKaydet();
          },
          onAdd: (name, amount, quantity, category, type) {
            setState(() {
              varliklar.add(
                Asset(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  amount: amount,
                  quantity: quantity,
                  category: category,
                  type: type,
                  lastUpdated: DateTime.now(),
                  isDeleted: false,
                ),
              );
            });
            _varliklariKaydet();
          },
        ),
      ),
    ).then((_) => _showCelebrationIfPending());
  }

  void _navigateToAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisPage(
          expenses: tumHarcamalar,
          assets: varliklar,
          incomes: tumGelirler,
          selectedDate: secilenAy,
          userId: widget.authController.currentUser?.id ?? '',
          userName: widget.authController.currentUser?.name ?? 'Kullanici',
          paymentMethods: tumOdemeYontemleri,
        ),
      ),
    ).then((_) => _showCelebrationIfPending());
  }

  void _navigateToPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodsPage(
          paymentMethods: tumOdemeYontemleri
              .where((p) => !p.isDeleted)
              .toList(),
          deletedPaymentMethods: tumOdemeYontemleri
              .where((p) => p.isDeleted)
              .toList(),
          onDelete: (pm) {
            setState(() {
              final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) tumOdemeYontemleri[i] = pm.copyWith(isDeleted: true);
            });
            _odemeYontemleriKaydet();
          },
          onEdit: (pm) {
            setState(() {
              final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) tumOdemeYontemleri[i] = pm;
            });
            _odemeYontemleriKaydet();
          },
          onRestore: (pm) {
            setState(() {
              final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
              if (i != -1) {
                tumOdemeYontemleri[i] = pm.copyWith(isDeleted: false);
              }
            });
            _odemeYontemleriKaydet();
          },
          onPermanentDelete: (pm) {
            setState(
              () => tumOdemeYontemleri.removeWhere((p) => p.id == pm.id),
            );
            _odemeYontemleriKaydet();
          },
          onEmptyBin: () {
            setState(() => tumOdemeYontemleri.removeWhere((p) => p.isDeleted));
            _odemeYontemleriKaydet();
          },
          onAdd: (name, type, lastFourDigits, balance, limit, colorIndex) {
            setState(() {
              tumOdemeYontemleri.add(
                PaymentMethod(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  type: type,
                  lastFourDigits: lastFourDigits,
                  balance: balance,
                  limit: limit,
                  colorIndex: colorIndex,
                  createdAt: DateTime.now(),
                  isDeleted: false,
                ),
              );
            });
            _odemeYontemleriKaydet();
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
    ).then((_) => _showCelebrationIfPending());
  }

  void _navigateToTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferPage(
          paymentMethods: tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          onTransfer: (fromId, toId, amount, date) {
            // Tarihi kontrol et - bugün mü yoksa ileri tarih mi?
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final transferDate = DateTime(date.year, date.month, date.day);
            final isScheduled = transferDate.isAfter(today);

            if (!isScheduled) {
              // Anında transfer - bakiyeleri hemen güncelle
              setState(() {
                final fromIndex = tumOdemeYontemleri.indexWhere(
                  (pm) => pm.id == fromId,
                );
                if (fromIndex != -1) {
                  final fromPm = tumOdemeYontemleri[fromIndex];
                  double yeniBakiye = fromPm.type == 'kredi'
                      ? fromPm.balance + amount
                      : fromPm.balance - amount;
                  tumOdemeYontemleri[fromIndex] = fromPm.copyWith(
                    balance: yeniBakiye,
                  );
                }
                final toIndex = tumOdemeYontemleri.indexWhere(
                  (pm) => pm.id == toId,
                );
                if (toIndex != -1) {
                  final toPm = tumOdemeYontemleri[toIndex];
                  double yeniBakiye = toPm.type == 'kredi'
                      ? toPm.balance - amount
                      : toPm.balance + amount;
                  tumOdemeYontemleri[toIndex] = toPm.copyWith(
                    balance: yeniBakiye,
                  );
                }
              });
              _odemeYontemleriKaydet();
            }
            // İleri tarihli transfer - bakiye değişmez, zamanlanmış olarak kaydedilir

            // Transfer kaydını oluştur
            tumTransferler.insert(
              0,
              Transfer(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                fromAccountId: fromId,
                toAccountId: toId,
                amount: amount,
                date: date,
                isScheduled: isScheduled,
                isExecuted: !isScheduled, // Anında transfer zaten uygulandı
              ),
            );
            _transferleriKaydet();
          },
        ),
      ),
    ).then((_) => _showCelebrationIfPending());
  }

  void _navigateToExpenses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpensesPage(
          tumHarcamalar: tumHarcamalar,
          tumOdemeYontemleri: tumOdemeYontemleri,
          kategoriIkonlari: kategoriIkonlari,
          butceLimiti: butceLimiti,
          secilenAy: secilenAy,
          userId: widget.authController.currentUser?.id,
          varsayilanOdemeYontemiId: varsayilanOdemeYontemiId,
          onHarcamalarChanged: (harcamalar) {
            setState(() => tumHarcamalar = harcamalar);
            _harcamalariKaydet();
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            setState(() => tumOdemeYontemleri = odemeYontemleri);
            _odemeYontemleriKaydet();
          },
        ),
      ),
    ).then((_) {
      _verileriOku();
      _showCelebrationIfPending();
    });
  }

  void _navigateToIncomes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomesPage(
          tumGelirler: tumGelirler,
          tumOdemeYontemleri: tumOdemeYontemleri,
          gelirKategoriIkonlari: gelirKategoriIkonlari,
          secilenAy: secilenAy,
          userId: widget.authController.currentUser?.id,
          onGelirlerChanged: (gelirler) {
            setState(() => tumGelirler = gelirler);
            _gelirleriKaydet();
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            setState(() => tumOdemeYontemleri = odemeYontemleri);
            _odemeYontemleriKaydet();
          },
        ),
      ),
    ).then((_) {
      _verileriOku();
      _showCelebrationIfPending();
    });
  }
}
