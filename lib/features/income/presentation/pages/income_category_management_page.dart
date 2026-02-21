import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/di/injection_container.dart';
import '../../../income/domain/repositories/income_repository.dart';
import 'package:cashly/core/utils/error_handler.dart';
import 'package:cashly/core/utils/validators.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import '../controllers/incomes_controller.dart';

/// Gelir kategorilerini yönetmek için sayfa
class GelirKategoriYonetimiSayfasi extends StatefulWidget {
  final String userId;
  final IncomesController? controller;

  const GelirKategoriYonetimiSayfasi({
    super.key,
    required this.userId,
    this.controller,
  });

  @override
  State<GelirKategoriYonetimiSayfasi> createState() =>
      _GelirKategoriYonetimiSayfasiState();
}

class _GelirKategoriYonetimiSayfasiState
    extends State<GelirKategoriYonetimiSayfasi> {
  // Controller veya yerel state
  IncomesController? _controller;
  List<Map<String, dynamic>> _localKategoriler = [];
  bool _localHasChanges = false;

  List<Map<String, dynamic>> get kategoriler =>
      _controller?.catMgmtKategoriler ?? _localKategoriler;
  bool get hasChanges => _controller?.catMgmtHasChanges ?? _localHasChanges;

  final Map<String, IconData> ikonSecenekleri = {
    'work': Icons.work,
    'laptop': Icons.laptop,
    'trending_up': Icons.trending_up,
    'home': Icons.home,
    'card_giftcard': Icons.card_giftcard,
    'category': Icons.category,
    'attach_money': Icons.attach_money,
    'account_balance': Icons.account_balance,
    'savings': Icons.savings,
    'monetization_on': Icons.monetization_on,
    'paid': Icons.paid,
    'currency_exchange': Icons.currency_exchange,
    'store': Icons.store,
    'business': Icons.business,
    'payments': Icons.payments,
    'local_atm': Icons.local_atm,
    'credit_card': Icons.credit_card,
    'receipt': Icons.receipt,
    'percent': Icons.percent,
    'timeline': Icons.timeline,
  };

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onStateChanged);
    kategorileriYukle();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onStateChanged);
    super.dispose();
  }

  // Sistem kategorileri (silinemez)
  static const List<String> sistemKategorileri = ['Tekrarlayan Gelirler'];

  void kategorileriYukle() {
    try {
      final incomeRepo = getIt<IncomeRepository>();
      final loadedCategories = incomeRepo.getCategories(widget.userId);

      if (_controller != null) {
        _controller!.setCatMgmtKategoriler(loadedCategories);
      } else {
        _localKategoriler = loadedCategories;
      }

      // Sistem kategorilerini kontrol et ve yoksa ekle
      for (final sistemKat in sistemKategorileri) {
        final varMi = kategoriler.any((k) => k['isim'] == sistemKat);
        if (!varMi) {
          if (_controller != null) {
            _controller!.addCatMgmtKategori(sistemKat, 'autorenew');
          } else {
            _localKategoriler.add({'isim': sistemKat, 'ikon': 'autorenew'});
          }
          incomeRepo.saveCategories(widget.userId, kategoriler);
        }
      }
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Gelir kategorileri yüklenirken hata', e);
    }
  }

  void kaydet() {
    try {
      getIt<IncomeRepository>().saveCategories(widget.userId, kategoriler);
      if (_controller != null) {
        _controller!.setCatMgmtHasChanges(true);
      } else {
        _localHasChanges = true;
      }
      ErrorHandler.showSuccessSnackBar(context, "Kategoriler kaydedildi ✅");
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Gelir kategorileri kaydedilirken hata', e);
    }
  }

  void kategoriEkle() {
    final TextEditingController isimController = TextEditingController();
    String secilenIkon = 'attach_money';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Yeni Kategori Ekle",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: isimController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Kategori adı",
                    prefixIcon: Icon(
                      ikonSecenekleri[secilenIkon],
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "İkon Seç",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ikonSecenekleri.entries.map((entry) {
                      final bool selected = entry.key == secilenIkon;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              secilenIkon = entry.key;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.secondary
                                        .withValues(alpha: 0.2)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.white24,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              entry.value,
                              color: selected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.54),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final validationError = Validators.validateRequired(
                        isimController.text.trim(),
                        fieldName: 'Kategori adı',
                      );
                      if (validationError != null) {
                        ErrorHandler.showErrorSnackBar(
                          context,
                          validationError,
                        );
                        return;
                      }
                      if (_controller != null) {
                        _controller!.addCatMgmtKategori(
                          isimController.text.trim(),
                          secilenIkon,
                        );
                      } else {
                        _localKategoriler.add({
                          'isim': isimController.text.trim(),
                          'ikon': secilenIkon,
                        });
                      }
                      kaydet();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Kategori Ekle",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void kategoriSil(int index) {
    final kategoriIsmi = kategoriler[index]['isim'];

    // Sistem kategorisi silinemez
    if (sistemKategorileri.contains(kategoriIsmi)) {
      AppSnackBar.warning(
        context,
        '"$kategoriIsmi" sistem kategorisidir ve silinemez',
      );
      return;
    }

    if (_controller != null) {
      _controller!.removeCatMgmtKategoriAt(index);
    } else {
      _localKategoriler.removeAt(index);
      setState(() {});
    }
    kaydet();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.incomeCategories),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, hasChanges),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: kategoriEkle,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gelir Kategorileri",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Gelir kategorilerinizi özelleştirin",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                "KATEGORİLER",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              kategoriler.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "Henüz kategori yok.",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.24),
                          ),
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: kategoriler.length,
                      onReorder: (oldIndex, newIndex) {
                        if (_controller != null) {
                          _controller!.reorderCatMgmtKategoriler(
                            oldIndex,
                            newIndex,
                          );
                        } else {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final kategori = _localKategoriler.removeAt(oldIndex);
                          _localKategoriler.insert(newIndex, kategori);
                          setState(() {});
                        }
                        kaydet();
                        AppSnackBar.success(
                          context,
                          'Kategori sırası güncellendi',
                          duration: const Duration(seconds: 1),
                        );
                      },
                      itemBuilder: (context, index) {
                        final kategori = kategoriler[index];
                        final IconData ikon =
                            ikonSecenekleri[kategori['ikon']] ?? Icons.category;

                        return Card(
                          key: Key('gelir_kategori_${kategori['isim']}_$index'),
                          color: Theme.of(context).colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              ikon,
                              color: PageThemeColors.getIconColor(index),
                            ),
                            title: Text(
                              kategori['isim'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => kategoriSil(index),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
