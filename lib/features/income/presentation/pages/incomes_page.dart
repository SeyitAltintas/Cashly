import 'package:flutter/material.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../income/presentation/widgets/add_income_sheet.dart';
import '../../../income/presentation/widgets/income_voice_input_sheet.dart';
import '../../../income/presentation/pages/income_recycle_bin_page.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../../../core/widgets/app_floating_bottom_bar.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';

class IncomesPage extends StatefulWidget {
  final List<Income> tumGelirler;
  final List<PaymentMethod> tumOdemeYontemleri;
  final Map<String, IconData> gelirKategoriIkonlari;
  final DateTime secilenAy;
  final String? userId;
  final Function(List<Income>) onGelirlerChanged;
  final Function(List<PaymentMethod>) onOdemeYontemleriChanged;

  const IncomesPage({
    super.key,
    required this.tumGelirler,
    required this.tumOdemeYontemleri,
    required this.gelirKategoriIkonlari,
    required this.secilenAy,
    required this.userId,
    required this.onGelirlerChanged,
    required this.onOdemeYontemleriChanged,
  });

  @override
  State<IncomesPage> createState() => _IncomesPageState();
}

class _IncomesPageState extends State<IncomesPage> with LazyLoadingMixin {
  final TextEditingController tGelirArama = TextEditingController();
  bool gelirAramaModu = false;
  late DateTime secilenAy;

  @override
  void initState() {
    super.initState();
    secilenAy = widget.secilenAy;
    initLazyLoading();
  }

  @override
  void dispose() {
    disposeLazyLoading();
    tGelirArama.dispose();
    super.dispose();
  }

  String get ayIsmi {
    return "${aylarListesi[secilenAy.month - 1]} ${secilenAy.year}";
  }

  List<Income> get filtrelenmisGelirler {
    String aramaMetni = tGelirArama.text.toLowerCase();
    return widget.tumGelirler.where((g) {
      if (g.isDeleted) return false;
      if (g.date.year != secilenAy.year || g.date.month != secilenAy.month) {
        return false;
      }
      if (aramaMetni.isEmpty) return true;
      return g.name.toLowerCase().contains(aramaMetni) ||
          g.category.toLowerCase().contains(aramaMetni);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double get toplamGelir {
    double toplam = 0;
    for (var g in filtrelenmisGelirler) {
      toplam += g.amount;
    }
    return toplam;
  }

  void oncekiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month - 1, 1);
    });
  }

  void sonrakiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month + 1, 1);
    });
  }

  void _ayYilSeciciAc() async {
    // Ortak MonthYearPicker widget'ını kullan
    final selectedDate = await MonthYearPicker.show(
      context,
      initialDate: secilenAy,
      accentColor: Colors.green,
    );

    if (selectedDate != null && mounted) {
      setState(() {
        secilenAy = selectedDate;
      });
    }
  }

  void _showVoiceInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncomeVoiceInputSheet(
        categoryIcons: widget.gelirKategoriIkonlari,
        userId: widget.userId,
        onConfirm: (name, amount, category, date) {
          // Gelir oluştur ve listeye ekle
          final yeniGelir = Income(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            amount: amount,
            category: category,
            date: date,
          );

          setState(() {
            widget.tumGelirler.add(yeniGelir);
          });

          // Bakiye güncelleme - mevcut ödeme yöntemi seçimi yok
          // bu yüzden sadece geliri ekliyoruz

          // Callback'i çağır
          widget.onGelirlerChanged(widget.tumGelirler);

          // Bildirim göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$name eklendi: ${amount.toStringAsFixed(0)} ₺',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(12),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void gelirSil(Income income) {
    HapticService.delete(); // Silme haptic feedback

    // Eski değerleri sakla (geri alma için)
    final eskiIsDeleted = income.isDeleted;
    final String? eskiPmId = income.paymentMethodId;
    double? eskiBakiye;
    int? pmIndex;

    if (eskiPmId != null) {
      pmIndex = widget.tumOdemeYontemleri.indexWhere((p) => p.id == eskiPmId);
      if (pmIndex != -1) {
        eskiBakiye = widget.tumOdemeYontemleri[pmIndex].balance;
      }
    }

    setState(() {
      income.isDeleted = true;

      // Bakiyeyi geri al
      if (income.paymentMethodId != null && pmIndex != null && pmIndex != -1) {
        final pm = widget.tumOdemeYontemleri[pmIndex];
        double yeniBakiye;
        if (pm.type == 'kredi') {
          yeniBakiye = pm.balance + income.amount;
        } else {
          yeniBakiye = pm.balance - income.amount;
        }
        widget.tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: yeniBakiye);
      }
    });

    widget.onGelirlerChanged(widget.tumGelirler);
    widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

    // Geri Al özelliği ile SnackBar göster
    AppSnackBar.deleted(
      context,
      'Gelir çöp kutusuna taşındı 🗑️',
      onUndo: () {
        // Silme işlemini geri al
        setState(() {
          income.isDeleted = eskiIsDeleted;
          if (eskiPmId != null &&
              pmIndex != null &&
              pmIndex != -1 &&
              eskiBakiye != null) {
            widget.tumOdemeYontemleri[pmIndex] = widget
                .tumOdemeYontemleri[pmIndex]
                .copyWith(balance: eskiBakiye);
          }
        });
        widget.onGelirlerChanged(widget.tumGelirler);
        widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

        // Geri alındı bildirimi
        AppSnackBar.success(context, 'Gelir geri yüklendi ✅');
      },
    );
  }

  void gelirDuzenle(Income income) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIncomeSheet(
        incomeToEdit: income.toMap(),
        categories: widget.gelirKategoriIkonlari,
        paymentMethods: widget.tumOdemeYontemleri
            .where((pm) => !pm.isDeleted)
            .toList(),
        onSave: (name, amount, category, date, paymentMethodId) {
          setState(() {
            // 1. Eski bakiyeyi geri al
            if (income.paymentMethodId != null) {
              final eskiPmIndex = widget.tumOdemeYontemleri.indexWhere(
                (p) => p.id == income.paymentMethodId,
              );
              if (eskiPmIndex != -1) {
                final pm = widget.tumOdemeYontemleri[eskiPmIndex];
                double yeniBakiye;
                if (pm.type == 'kredi') {
                  yeniBakiye = pm.balance + income.amount;
                } else {
                  yeniBakiye = pm.balance - income.amount;
                }
                widget.tumOdemeYontemleri[eskiPmIndex] = pm.copyWith(
                  balance: yeniBakiye,
                );
              }
            }

            // 2. Yeni bakiyeyi ekle
            if (paymentMethodId != null) {
              final yeniPmIndex = widget.tumOdemeYontemleri.indexWhere(
                (p) => p.id == paymentMethodId,
              );
              if (yeniPmIndex != -1) {
                final pm = widget.tumOdemeYontemleri[yeniPmIndex];
                double yeniBakiye;
                if (pm.type == 'kredi') {
                  yeniBakiye = pm.balance - amount;
                } else {
                  yeniBakiye = pm.balance + amount;
                }
                widget.tumOdemeYontemleri[yeniPmIndex] = pm.copyWith(
                  balance: yeniBakiye,
                );
              }
            }

            // 3. Geliri güncelle
            int index = widget.tumGelirler.indexOf(income);
            if (index != -1) {
              widget.tumGelirler[index] = Income(
                id: income.id,
                name: name,
                amount: amount,
                category: category,
                date: date,
                paymentMethodId: paymentMethodId,
                isDeleted: false,
              );
            }
          });

          widget.onGelirlerChanged(widget.tumGelirler);
          widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);
        },
      ),
    );
  }

  void yeniGelirEkle() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIncomeSheet(
        categories: widget.gelirKategoriIkonlari,
        paymentMethods: widget.tumOdemeYontemleri
            .where((pm) => !pm.isDeleted)
            .toList(),
        onSave: (name, amount, category, date, paymentMethodId) {
          setState(() {
            widget.tumGelirler.insert(
              0,
              Income(
                id: DateTime.now().toString(),
                name: name,
                amount: amount,
                category: category,
                date: date,
                paymentMethodId: paymentMethodId,
              ),
            );

            // Bakiyeyi güncelle
            if (paymentMethodId != null) {
              final pmIndex = widget.tumOdemeYontemleri.indexWhere(
                (p) => p.id == paymentMethodId,
              );
              if (pmIndex != -1) {
                final pm = widget.tumOdemeYontemleri[pmIndex];
                double yeniBakiye;
                if (pm.type == 'kredi') {
                  yeniBakiye = pm.balance - amount;
                } else {
                  yeniBakiye = pm.balance + amount;
                }
                widget.tumOdemeYontemleri[pmIndex] = pm.copyWith(
                  balance: yeniBakiye,
                );
              }
            }
          });

          widget.onGelirlerChanged(widget.tumGelirler);
          widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gelir eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime simdi = DateTime.now();
    bool buAyMi =
        (secilenAy.year == simdi.year && secilenAy.month == simdi.month);
    final gelirler = filtrelenmisGelirler;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: gelirAramaModu
            ? TextField(
                controller: tGelirArama,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Gelir ara...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
                onChanged: (val) => setState(() {}),
              )
            : const Text("Gelirlerim"),
        actions: [
          if (!gelirAramaModu && !buAyMi)
            TextButton(
              onPressed: () {
                setState(() {
                  secilenAy = DateTime.now();
                });
              },
              child: Text(
                "Bugüne git",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),

          IconButton(
            icon: Icon(
              gelirAramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                gelirAramaModu = !gelirAramaModu;
                if (!gelirAramaModu) {
                  tGelirArama.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Özet Kartı
          if (!gelirAramaModu)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400.withValues(alpha: 0.25),
                    Colors.green.shade400.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.shade400.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  // Ay seçici satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          size: 18,
                        ),
                        onPressed: oncekiAy,
                      ),
                      GestureDetector(
                        onTap: _ayYilSeciciAc,
                        child: Row(
                          children: [
                            Text(
                              ayIsmi.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          size: 18,
                        ),
                        onPressed: sonrakiAy,
                      ),
                    ],
                  ),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 10),
                  // Toplam gelir satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toplam Gelir",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(toplamGelir),
                            style: TextStyle(
                              color: Colors.green.shade300,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: Colors.green.shade300,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Gelir sayısı bilgisi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.green.shade300,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Bu ay ${gelirler.length} gelir kaydı",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Gelir listesi
          Expanded(
            child: gelirler.isEmpty
                ? gelirAramaModu
                      ? const EmptyStateWidget(
                          icon: Icons.search_off,
                          title: 'Sonuç bulunamadı',
                          subtitle: 'Farklı bir arama terimi deneyin',
                        )
                      : EmptyStateWidget.noIncomes()
                : ListView.builder(
                    controller: lazyScrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: gelirler.length + (hasMoreItems ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Son item ise ve daha fazla veri varsa loading göster
                      if (index >= gelirler.length) {
                        return buildLoadingIndicator();
                      }

                      final gelir = gelirler[index];
                      return Dismissible(
                        key: Key(gelir.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) => gelirSil(gelir),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.08),
                            ),
                          ),
                          child: ListTile(
                            onTap: () => gelirDuzenle(gelir),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: PageThemeColors.getIconColor(
                                  index,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.gelirKategoriIkonlari[gelir.category] ??
                                    Icons.attach_money,
                                color: PageThemeColors.getIconColor(index),
                              ),
                            ),
                            title: Text(
                              gelir.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "${gelir.date.day}/${gelir.date.month}/${gelir.date.year} • ${gelir.category}",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              "+${CurrencyFormatter.formatWithoutSymbol(gelir.amount)} ₺",
                              style: TextStyle(
                                color: Colors.green.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Modern floating bottom navigation bar - Ortak widget kullanımı
      bottomNavigationBar: AppFloatingBottomBar(
        items: [
          BottomBarItem(
            icon: Icons.delete_outline,
            label: "Çöp Kutusu",
            onTap: () {
              HapticService.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GelirCopKutusuSayfasi(userId: widget.userId ?? ''),
                ),
              ).then((_) {
                setState(() {});
              });
            },
          ),
          BottomBarItem(
            icon: Icons.mic,
            label: "Sesli Giriş",
            onTap: () {
              HapticService.selectionClick();
              _showVoiceInput();
            },
          ),
        ],
        centerButtonColor: Colors.green.shade600,
        onCenterButtonTap: () {
          HapticService.lightImpact();
          yeniGelirEkle();
        },
      ),
    );
  }
}
