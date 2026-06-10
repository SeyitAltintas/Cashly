import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/di/injection_container.dart';
import '../../../income/domain/repositories/income_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashly/core/utils/error_handler.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/mixins/lazy_loading_mixin.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/currency_service.dart';
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
  final List<Income> _localTumGelirler = [];

  List<Income> get silinenGelirler =>
      _controller?.binSilinenGelirler ?? _localSilinenGelirler;
  List<Income> get tumGelirler => _controller?.tumGelirler ?? _localTumGelirler;

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

  Future<void> verileriYukle() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('incomes')
          .where('isDeleted', isEqualTo: true)
          .get();

      final List<Income> silinen = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        return Income.fromMap(data);
      }).toList();

      // Optimistic UI ile yerelde silinmiş ama henüz Firestore'a yansımamış olabilecek kartları ekle
      if (_controller != null) {
        final localDeleted = _controller!.tumGelirler
            .where((g) => g.isDeleted)
            .toList();
        for (var local in localDeleted) {
          if (!silinen.any((s) => s.id == local.id)) {
            silinen.add(local);
          }
        }

        // Yeniden eskiye doğru sırala
        silinen.sort((a, b) => b.date.compareTo(a.date));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller!.setBinSilinenGelirler(silinen);
        });
      } else {
        _localSilinenGelirler = silinen;
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Silinen gelirler yüklenirken hata', e);
    }
  }

  // kaydet() metodu iptal edildi, tekil işlemler kullanılıyor

  Future<void> copuBosalt() async {
    if (silinenGelirler.isEmpty) return;

    bool? onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          context.l10n.emptyTrashBin,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          context.l10n.confirmEmptyTrashBin,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.yesDelete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (onay == true) {
      final silinenlerKopya = List<Income>.from(silinenGelirler);
      if (_controller != null) {
        await _controller!.binEmptyBin();
      } else {
        _localTumGelirler.removeWhere((g) => g.isDeleted);
        _localSilinenGelirler.clear();
        setState(() {});
        for (var gelir in silinenlerKopya) {
          await getIt<IncomeRepository>().deleteIncome(widget.userId, gelir.id);
        }
      }
      if (mounted) {
        AppSnackBar.deleted(context, context.l10n.trashBinEmptied);
      }
    }
  }

  Future<void> geliriGeriYukle(Income gelir) async {
    if (_controller != null) {
      await _controller!.binRestoreGelir(gelir);
    } else {
      int index = _localTumGelirler.indexWhere((g) => g.id == gelir.id);
      if (index != -1) {
        _localTumGelirler[index] = gelir.copyWith(isDeleted: false);
      }
      _localSilinenGelirler.removeWhere((g) => g.id == gelir.id);
      setState(() {});
      await getIt<IncomeRepository>().updateIncome(
        widget.userId,
        gelir.copyWith(isDeleted: false).toMap(),
      );
    }
    if (mounted) {
      AppSnackBar.success(context, context.l10n.incomeRestored);
    }
  }

  Future<void> geliriKaliciSil(Income gelir) async {
    if (_controller != null) {
      await _controller!.binPermanentDeleteGelir(gelir);
    } else {
      _localTumGelirler.removeWhere((g) => g.id == gelir.id);
      _localSilinenGelirler.removeWhere((g) => g.id == gelir.id);
      setState(() {});
      await getIt<IncomeRepository>().deleteIncome(widget.userId, gelir.id);
    }
    if (mounted) {
      AppSnackBar.deleted(context, context.l10n.incomePermanentlyDeleted);
    }
  }

  /// Tüm silinen gelirleri geri yükler
  Future<void> tumunuGeriYukle() async {
    if (silinenGelirler.isEmpty) return;

    bool? onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          context.l10n.restoreAll,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          context.l10n.confirmRestoreAllIncomes(silinenGelirler.length),
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.yesRestore,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (onay == true) {
      final silinenlerKopya = List<Income>.from(silinenGelirler);
      if (_controller != null) {
        await _controller!.binRestoreAll();
      } else {
        for (var gelir in _localSilinenGelirler) {
          int index = _localTumGelirler.indexWhere((g) => g.id == gelir.id);
          if (index != -1) {
            _localTumGelirler[index] = gelir.copyWith(isDeleted: false);
          }
        }
        _localSilinenGelirler.clear();
        setState(() {});
        for (var gelir in silinenlerKopya) {
          await getIt<IncomeRepository>().updateIncome(
            widget.userId,
            gelir.copyWith(isDeleted: false).toMap(),
          );
        }
      }
      if (mounted) {
        AppSnackBar.success(context, context.l10n.allIncomesRestored);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.incomeRecycleBin),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (silinenGelirler.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.green),
              tooltip: context.l10n.restoreAll,
              onPressed: tumunuGeriYukle,
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: context.l10n.emptyTrashBin,
            onPressed: copuBosalt,
          ),
        ],
      ),
      body: silinenGelirler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 60,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.noDeletedIncomes,
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
                final cur = getIt<CurrencyService>();
                final convertedAmount = cur.convert(
                  gelir.amount,
                  gelir.paraBirimi,
                  cur.currentCurrency,
                );

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
                      "${CurrencyFormatter.format(convertedAmount)} • ${gelir.date.day} ${context.getMonthName(gelir.date.month)} ${gelir.date.year}",
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
                          tooltip: context.l10n.restoreItem,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: ColorConstants.kirmiziVurgu,
                          ),
                          onPressed: () => geliriKaliciSil(gelir),
                          tooltip: context.l10n.deletePermanently,
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
