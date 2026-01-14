import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/di/injection_container.dart';
import '../../../income/domain/repositories/income_repository.dart';
import 'package:cashly/core/utils/error_handler.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/mixins/lazy_loading_mixin.dart';
import '../../data/models/income_model.dart';
import '../controllers/incomes_controller.dart';

class GelirCopKutusuSayfasi extends StatefulWidget {
  final String userId;
  final IncomesController? controller;

  const GelirCopKutusuSayfasi({
    super.key,
    required this.userId,
    this.controller,
  });

  @override
  State<GelirCopKutusuSayfasi> createState() => _GelirCopKutusuSayfasiState();
}

class _GelirCopKutusuSayfasiState extends State<GelirCopKutusuSayfasi>
    with LazyLoadingMixin {
  // Controller veya yerel state
  IncomesController? _controller;
  List<Income> _localSilinenGelirler = [];
  List<Income> _localTumGelirler = [];

  List<Income> get silinenGelirler =>
      _controller?.binSilinenGelirler ?? _localSilinenGelirler;
  List<Income> get tumGelirler => _controller?.tumGelirler ?? _localTumGelirler;

  final List<String> _months = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onStateChanged);
    initLazyLoading();
    verileriYukle();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onStateChanged);
    disposeLazyLoading();
    super.dispose();
  }

  void verileriYukle() {
    try {
      final incomeRepo = getIt<IncomeRepository>();
      List<Map<String, dynamic>> gelirVerileri = incomeRepo.getIncomes(
        widget.userId,
      );
      final gelirler = gelirVerileri.map((map) => Income.fromMap(map)).toList();
      final silinen = gelirler.where((g) => g.isDeleted).toList();

      if (_controller != null) {
        _controller!.setBinSilinenGelirler(silinen);
      } else {
        _localTumGelirler = gelirler;
        _localSilinenGelirler = silinen;
        setState(() {});
      }
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Silinen gelirler yüklenirken hata', e);
    }
  }

  void kaydet() {
    try {
      List<Map<String, dynamic>> gelirMapleri = tumGelirler
          .map((income) => income.toMap())
          .toList();
      getIt<IncomeRepository>().saveIncomes(widget.userId, gelirMapleri);
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Gelirler kaydedilirken hata', e);
    }
  }

  Future<void> copuBosalt() async {
    if (silinenGelirler.isEmpty) return;

    bool? onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Çöpü Boşalt", style: TextStyle(color: Colors.white)),
        content: Text(
          "Tüm silinen gelirler kalıcı olarak yok edilecek. Emin misin?",
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Evet, Sil",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (onay == true) {
      if (_controller != null) {
        _controller!.binEmptyBin();
      } else {
        _localTumGelirler.removeWhere((g) => g.isDeleted);
        _localSilinenGelirler.clear();
        setState(() {});
      }
      kaydet();
      if (mounted) {
        AppSnackBar.deleted(context, 'Çöp kutusu temizlendi.');
      }
    }
  }

  Future<void> geliriGeriYukle(Income gelir) async {
    if (_controller != null) {
      _controller!.binRestoreGelir(gelir);
    } else {
      int index = _localTumGelirler.indexWhere((g) => g.id == gelir.id);
      if (index != -1) {
        _localTumGelirler[index] = gelir.copyWith(isDeleted: false);
      }
      _localSilinenGelirler.removeWhere((g) => g.id == gelir.id);
      setState(() {});
    }
    kaydet();
    if (mounted) {
      AppSnackBar.success(context, 'Gelir geri yüklendi ♻️');
    }
  }

  Future<void> geliriKaliciSil(Income gelir) async {
    if (_controller != null) {
      _controller!.binPermanentDeleteGelir(gelir);
    } else {
      _localTumGelirler.removeWhere((g) => g.id == gelir.id);
      _localSilinenGelirler.removeWhere((g) => g.id == gelir.id);
      setState(() {});
    }
    kaydet();
    if (mounted) {
      AppSnackBar.deleted(context, 'Gelir kalıcı olarak silindi 🗑️');
    }
  }

  /// Tüm silinen gelirleri geri yükler
  Future<void> tumunuGeriYukle() async {
    if (silinenGelirler.isEmpty) return;

    bool? onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          "Tümünü Geri Yükle",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "${silinenGelirler.length} gelir geri yüklenecek. Onaylıyor musun?",
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Evet, Geri Yükle",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (onay == true) {
      if (_controller != null) {
        _controller!.binRestoreAll();
      } else {
        for (var gelir in _localSilinenGelirler) {
          int index = _localTumGelirler.indexWhere((g) => g.id == gelir.id);
          if (index != -1) {
            _localTumGelirler[index] = gelir.copyWith(isDeleted: false);
          }
        }
        _localSilinenGelirler.clear();
        setState(() {});
      }
      kaydet();
      if (mounted) {
        AppSnackBar.success(context, 'Tüm gelirler geri yüklendi ♻️');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gelir Çöp Kutusu"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (silinenGelirler.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.green),
              tooltip: "Tümünü Geri Yükle",
              onPressed: tumunuGeriYukle,
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: "Çöpü Boşalt",
            onPressed: copuBosalt,
          ),
        ],
      ),
      body: silinenGelirler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline,
                    size: 60,
                    color: Colors.white12,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Silinen gelir yok.",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: lazyScrollController,
              padding: const EdgeInsets.all(10),
              itemCount: silinenGelirler.length + (hasMoreItems ? 1 : 0),
              itemBuilder: (context, index) {
                // Son item ise ve daha fazla veri varsa loading göster
                if (index >= silinenGelirler.length) {
                  return buildLoadingIndicator();
                }
                final gelir = silinenGelirler[index];

                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Colors.green.shade400,
                      ),
                    ),
                    title: Text(
                      gelir.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${gelir.amount.toStringAsFixed(2)} ₺ • ${gelir.date.day} ${_months[gelir.date.month - 1]} ${gelir.date.year}",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.restore,
                            color: Colors.green.shade400,
                          ),
                          onPressed: () => geliriGeriYukle(gelir),
                          tooltip: "Geri Yükle",
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: ColorConstants.kirmiziVurgu,
                          ),
                          onPressed: () => geliriKaliciSil(gelir),
                          tooltip: "Kalıcı Sil",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
