import 'package:flutter/material.dart';
import 'package:cashly/services/database_helper.dart';
import 'package:cashly/core/utils/error_handler.dart';
import 'package:cashly/core/utils/validators.dart';

/// Gelir kategorilerini yönetmek için sayfa
class GelirKategoriYonetimiSayfasi extends StatefulWidget {
  final String userId;

  const GelirKategoriYonetimiSayfasi({super.key, required this.userId});

  @override
  State<GelirKategoriYonetimiSayfasi> createState() =>
      _GelirKategoriYonetimiSayfasiState();
}

class _GelirKategoriYonetimiSayfasiState
    extends State<GelirKategoriYonetimiSayfasi> {
  List<Map<String, dynamic>> kategoriler = [];
  bool hasChanges = false;

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
    kategorileriYukle();
  }

  void kategorileriYukle() {
    try {
      setState(() {
        kategoriler = DatabaseHelper.gelirKategorileriGetir(widget.userId);
      });
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Gelir kategorileri yüklenirken hata', e);
    }
  }

  void kaydet() {
    try {
      DatabaseHelper.gelirKategorileriKaydet(widget.userId, kategoriler);
      setState(() {
        hasChanges = true;
      });
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
                      borderSide: BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white12),
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
                      setState(() {
                        kategoriler.add({
                          'isim': isimController.text.trim(),
                          'ikon': secilenIkon,
                        });
                      });
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
    setState(() {
      kategoriler.removeAt(index);
    });
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
          title: const Text("Gelir Kategorileri"),
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
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final kategori = kategoriler.removeAt(oldIndex);
                          kategoriler.insert(newIndex, kategori);
                        });
                        kaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Kategori sırası güncellendi',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                            duration: const Duration(seconds: 1),
                          ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white10),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                ikon,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            title: Text(
                              kategori['isim'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
