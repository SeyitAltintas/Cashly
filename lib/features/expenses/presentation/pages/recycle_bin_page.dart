import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/mixins/lazy_loading_mixin.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/currency_service.dart';
import '../controllers/expenses_controller.dart';

class CopKutusuSayfasi extends StatefulWidget {
  final String userId;
  final ExpensesController? controller;

  const CopKutusuSayfasi({super.key, required this.userId, this.controller});

  @override
  State<CopKutusuSayfasi> createState() => _CopKutusuSayfasiState();
}

class _CopKutusuSayfasiState extends State<CopKutusuSayfasi>
    with LazyLoadingMixin {
  // Controller veya yerel state
  ExpensesController? _controller;
  List<Map<String, dynamic>> _localSilinenHarcamalar = [];
  final List<Map<String, dynamic>> _localTumHarcamalarHam = [];
  final List<PaymentMethod> _localOdemeYontemleri = [];

  // Getter'lar
  List<Map<String, dynamic>> get silinenHarcamalar =>
      _controller?.binSilinenHarcamalar ?? _localSilinenHarcamalar;
  List<Map<String, dynamic>> get tumHarcamalarHam =>
      _controller?.tumHarcamalar ?? _localTumHarcamalarHam;
  List<PaymentMethod> get odemeYontemleri =>
      _controller?.tumOdemeYontemleri ?? _localOdemeYontemleri;

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
          .collection('expenses')
          .where('silindi', isEqualTo: true)
          .get();

      final List<Map<String, dynamic>> silinen = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['tarih'] is Timestamp) {
          data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();

      // Optimistic UI ile yerelde silinmiş ama henüz Firestore'a yansımamış olabilecek kartları ekle
      if (_controller != null) {
        final localDeleted = _controller!.tumHarcamalar.where((h) => h['silindi'] == true).toList();
        for (var local in localDeleted) {
          if (!silinen.any((s) => s['id'] == local['id'])) {
            silinen.add(local);
          }
        }
        
        // Yeniden eskiye doğru sırala
        silinen.sort((a, b) {
           DateTime dateA = DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
           DateTime dateB = DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
           return dateB.compareTo(dateA);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller!.setBinSilinenHarcamalar(silinen);
        });
      } else {
        _localSilinenHarcamalar = silinen;
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Error loading deleted expenses: $e");
    }
  }

  Future<void> copuBosalt() async {
    if (silinenHarcamalar.isEmpty) return;

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
      final silinenlerKopya = List<Map<String, dynamic>>.from(silinenHarcamalar);
      if (_controller != null) {
        await _controller!.binEmptyBin();
      } else {
        _localTumHarcamalarHam.removeWhere((e) => e['silindi'] == true);
        _localSilinenHarcamalar.clear();
        setState(() {});
        for (var harcama in silinenlerKopya) {
          await getIt<ExpenseRepository>().deleteExpense(widget.userId, harcama['id']);
        }
      }
      if (mounted) {
        AppSnackBar.deleted(context, context.l10n.trashBinEmptied);
      }
    }
  }

  Future<void> harcamayiGeriYukle(Map<String, dynamic> harcama) async {
    if (_controller != null) {
      await _controller!.binRestoreHarcama(harcama);
    } else {
      harcama['silindi'] = false;
      _localSilinenHarcamalar.remove(harcama);
      setState(() {});
      await getIt<ExpenseRepository>().updateExpense(widget.userId, harcama);
    }
    // Payment methods have been updated locally, they will be synced when their balances change

    if (mounted) {
      AppSnackBar.success(context, context.l10n.expenseRestored);
    }
  }

  Future<void> harcamayiKaliciSil(Map<String, dynamic> harcama) async {
    if (_controller != null) {
      await _controller!.binPermanentDeleteHarcama(harcama);
    } else {
      _localTumHarcamalarHam.remove(harcama);
      _localSilinenHarcamalar.remove(harcama);
      setState(() {});
      await getIt<ExpenseRepository>().deleteExpense(widget.userId, harcama['id']);
    }
    if (mounted) {
      AppSnackBar.deleted(context, context.l10n.expensePermanentlyDeleted);
    }
  }

  /// Tüm silinen harcamaları geri yükler
  Future<void> tumunuGeriYukle() async {
    if (silinenHarcamalar.isEmpty) return;

    bool? onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          context.l10n.restoreAll,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          context.l10n.confirmRestoreAllExpenses(silinenHarcamalar.length),
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
      final silinenlerKopya = List<Map<String, dynamic>>.from(silinenHarcamalar);
      // State metoduyla tüm harcamaları geri yükle (bakiye güncelleme dahil)
      if (_controller != null) {
        await _controller!.binRestoreAll();
      } else {
        for (var harcama in List.from(_localSilinenHarcamalar)) {
          harcama['silindi'] = false;
        }
        _localSilinenHarcamalar.clear();
        setState(() {});
        
        for (var harcama in silinenlerKopya) {
            await getIt<ExpenseRepository>().updateExpense(widget.userId, harcama);
        }
      }
      // Payment methods have been updated locally, they will be synced when their balances change

      if (mounted) {
        AppSnackBar.success(context, context.l10n.allExpensesRestored);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.recycleBin),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (silinenHarcamalar.isNotEmpty)
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
      body: silinenHarcamalar.isEmpty
          ? Center(
              child: Text(
                context.l10n.noDeletedExpenses,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                ),
              ),
            )
          : ListView.builder(
              controller: lazyScrollController,
              padding: const EdgeInsets.all(10),
              itemCount: silinenHarcamalar.length + (hasMoreItems ? 1 : 0),
              itemBuilder: (context, index) {
                // Son item ise ve daha fazla veri varsa loading göster
                if (index >= silinenHarcamalar.length) {
                  return buildLoadingIndicator();
                }
                final harcama = silinenHarcamalar[index];
                DateTime tarih =
                    DateTime.tryParse(harcama['tarih'].toString()) ??
                    DateTime.now();
                final tutar = (harcama['tutar'] as num).toDouble();
                final pb = harcama['paraBirimi']?.toString() ?? 'TRY';
                final cur = getIt<CurrencyService>();
                final convertedAmount = cur.convert(
                  tutar,
                  pb,
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
                    leading: const Icon(
                      Icons.money_off,
                      color: ColorConstants.kirmiziVurgu,
                    ),
                    title: Text(
                      harcama['isim'] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${CurrencyFormatter.format(convertedAmount)} • ${tarih.day}.${tarih.month}.${tarih.year}",
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
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => harcamayiGeriYukle(harcama),
                          tooltip: context.l10n.restoreItem,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: ColorConstants.kirmiziVurgu,
                          ),
                          onPressed: () => harcamayiKaliciSil(harcama),
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
