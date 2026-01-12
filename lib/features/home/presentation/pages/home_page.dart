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
import 'package:cashly/features/streak/data/services/streak_service.dart';
import '../state/home_page_state.dart';

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

    _homeState = HomePageState();
    _homeState.addListener(_onHomeStateChanged);

    _verileriOku();
    _seriKontrol();
  }

  void _onHomeStateChanged() {
    if (mounted) setState(() {});
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

    // Zamanlanmış transferleri kontrol et
    _zamanlanmisTransferleriKontrolEt();
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
            failureReason: 'Gönderen hesap silinmiş veya bulunamadı',
          );
          basarisizTransferler.add('Gönderen hesap bulunamadı');
          transferDegisti = true;
          continue;
        }

        // Edge Case 2: Alıcı hesap silinmiş veya bulunamadı
        if (toIndex == -1) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: 'Alıcı hesap silinmiş veya bulunamadı',
          );
          basarisizTransferler.add('Alıcı hesap bulunamadı');
          transferDegisti = true;
          continue;
        }

        final fromPm = tumOdemeYontemleri[fromIndex];
        final toPm = tumOdemeYontemleri[toIndex];

        // Edge Case 3: Gönderen hesap silinmiş (isDeleted = true)
        if (fromPm.isDeleted) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: 'Gönderen hesap (${fromPm.name}) silinmiş',
          );
          basarisizTransferler.add('${fromPm.name} silinmiş');
          transferDegisti = true;
          continue;
        }

        // Edge Case 4: Alıcı hesap silinmiş (isDeleted = true)
        if (toPm.isDeleted) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: 'Alıcı hesap (${toPm.name}) silinmiş',
          );
          basarisizTransferler.add('${toPm.name} silinmiş');
          transferDegisti = true;
          continue;
        }

        // Edge Case 5: Gönderen hesapta yetersiz bakiye (banka/nakit için)
        if (fromPm.type != 'kredi' && fromPm.balance < transfer.amount) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: '${fromPm.name} hesabında yetersiz bakiye',
          );
          basarisizTransferler.add('${fromPm.name}: yetersiz bakiye');
          transferDegisti = true;
          continue;
        }

        // Edge Case 6: Alıcı kredi kartında borç yok (ödeme yapacak borç yok)
        if (toPm.type == 'kredi' && toPm.balance <= 0) {
          tumTransferler[i] = transfer.copyWith(
            isFailed: true,
            failureReason: '${toPm.name} kredi kartında ödenecek borç yok',
          );
          basarisizTransferler.add('${toPm.name}: borç yok');
          transferDegisti = true;
          continue;
        }

        // Tüm kontroller geçti - transfer uygula
        double fromYeniBakiye = fromPm.type == 'kredi'
            ? fromPm.balance + transfer.amount
            : fromPm.balance - transfer.amount;
        tumOdemeYontemleri[fromIndex] = fromPm.copyWith(
          balance: fromYeniBakiye,
        );

        double toYeniBakiye = toPm.type == 'kredi'
            ? toPm.balance - transfer.amount
            : toPm.balance + transfer.amount;
        tumOdemeYontemleri[toIndex] = toPm.copyWith(balance: toYeniBakiye);

        // Transferi başarılı olarak işaretle
        tumTransferler[i] = transfer.copyWith(isExecuted: true);
        transferDegisti = true;
      }
    }

    if (transferDegisti) {
      _odemeYontemleriKaydet();
      _transferleriKaydet();

      // UI'ı güncelle
      if (mounted) {
        setState(() {});

        // Başarısız transfer varsa kullanıcıyı bilgilendir
        if (basarisizTransferler.isNotEmpty) {
          AppSnackBar.warning(
            context,
            'Bazı zamanlanmış transferler başarısız: ${basarisizTransferler.join(", ")}',
          );
        }
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
            asset.isDeleted = true;
            _homeState.varliklar = List.from(varliklar);
            _varliklariKaydet();
          },
          onEdit: (asset) {
            final index = varliklar.indexWhere((a) => a.id == asset.id);
            if (index != -1) {
              varliklar[index] = asset;
              _homeState.varliklar = List.from(varliklar);
            }
            _varliklariKaydet();
          },
          onRestore: (asset) {
            asset.isDeleted = false;
            _homeState.varliklar = List.from(varliklar);
            _varliklariKaydet();
          },
          onPermanentDelete: (asset) {
            varliklar.remove(asset);
            _homeState.varliklar = List.from(varliklar);
            _varliklariKaydet();
          },
          onEmptyBin: () {
            varliklar.removeWhere((a) => a.isDeleted);
            _homeState.varliklar = List.from(varliklar);
            _varliklariKaydet();
          },
          onAdd: (name, amount, quantity, category, type) {
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
            _homeState.varliklar = List.from(varliklar);
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
          userName: widget.authController.currentUser?.name,
          userProfileUrl: widget.authController.currentUser?.profileImage,
          onDelete: (pm) {
            final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
            if (i != -1) {
              tumOdemeYontemleri[i] = pm.copyWith(isDeleted: true);
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            }
            _odemeYontemleriKaydet();
          },
          onEdit: (pm) {
            final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
            if (i != -1) {
              tumOdemeYontemleri[i] = pm;
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            }
            _odemeYontemleriKaydet();
          },
          onRestore: (pm) {
            final i = tumOdemeYontemleri.indexWhere((p) => p.id == pm.id);
            if (i != -1) {
              tumOdemeYontemleri[i] = pm.copyWith(isDeleted: false);
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            }
            _odemeYontemleriKaydet();
          },
          onPermanentDelete: (pm) {
            tumOdemeYontemleri.removeWhere((p) => p.id == pm.id);
            _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            _odemeYontemleriKaydet();
          },
          onEmptyBin: () {
            tumOdemeYontemleri.removeWhere((p) => p.isDeleted);
            _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
            _odemeYontemleriKaydet();
          },
          onAdd: (name, type, lastFourDigits, balance, limit, colorIndex) {
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
            _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
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
          userId: widget.authController.currentUser?.id,
          paymentMethods: tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          transfers: tumTransferler,
          onTransfer: (fromId, toId, amount, date) {
            // Tarihi kontrol et - bugün mü yoksa ileri tarih mi?
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final transferDate = DateTime(date.year, date.month, date.day);
            final isScheduled = transferDate.isAfter(today);

            if (!isScheduled) {
              // Anında transfer - bakiyeleri hemen güncelle
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
              _homeState.tumOdemeYontemleri = List.from(tumOdemeYontemleri);
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
            _homeState.tumHarcamalar = harcamalar;
            _harcamalariKaydet();
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            _homeState.tumOdemeYontemleri = odemeYontemleri;
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
            _homeState.tumGelirler = gelirler;
            _gelirleriKaydet();
          },
          onOdemeYontemleriChanged: (odemeYontemleri) {
            _homeState.tumOdemeYontemleri = odemeYontemleri;
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
