import 'package:flutter/material.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../income/presentation/widgets/add_income_sheet.dart';
import '../../../income/presentation/widgets/income_voice_input_sheet.dart';
import '../../../income/presentation/pages/income_recycle_bin_page.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../services/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';

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

class _IncomesPageState extends State<IncomesPage> {
  final TextEditingController tGelirArama = TextEditingController();
  bool gelirAramaModu = false;
  late DateTime secilenAy;

  final List<String> aylarListesi = [
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
    secilenAy = widget.secilenAy;
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

  void _ayYilSeciciAc() {
    int secilenYil = secilenAy.year;
    int secilenAyIndex = secilenAy.month;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık çubuğu
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Tarih Seç",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Yıl seçici
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      setSheetState(() {
                        secilenYil--;
                      });
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      secilenYil.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      setSheetState(() {
                        secilenYil++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ay grid'i
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final ayNumarasi = index + 1;
                  final seciliMi = ayNumarasi == secilenAyIndex;
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {
                        secilenAyIndex = ayNumarasi;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: seciliMi
                            ? Colors.green
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        aylarListesi[index].substring(0, 3),
                        style: TextStyle(
                          color: seciliMi
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: seciliMi
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Uygula butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      secilenAy = DateTime(secilenYil, secilenAyIndex, 1);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Seçilen tarihe git",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    setState(() {
      income.isDeleted = true;

      // Bakiyeyi geri al
      if (income.paymentMethodId != null) {
        final pmIndex = widget.tumOdemeYontemleri.indexWhere(
          (p) => p.id == income.paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = widget.tumOdemeYontemleri[pmIndex];
          double yeniBakiye;
          if (pm.type == 'kredi') {
            yeniBakiye = pm.balance + income.amount;
          } else {
            yeniBakiye = pm.balance - income.amount;
          }
          widget.tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: yeniBakiye);
        }
      }
    });

    widget.onGelirlerChanged(widget.tumGelirler);
    widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Gelir çöp kutusuna taşındı 🗑️",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      ),
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
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
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
                      : EmptyStateWidget.noIncomes(onAdd: yeniGelirEkle)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: gelirler.length,
                    itemBuilder: (context, index) {
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
      // Modern floating bottom navigation bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
                spreadRadius: -5,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Sol: Çöp Kutusu
              _buildNavButton(
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
              // Orta: Gelir Ekle
              _buildCenterAddButton(
                onTap: () {
                  HapticService.lightImpact();
                  yeniGelirEkle();
                },
              ),
              // Sağ: Sesli Asistan (ileride aktif olacak)
              _buildNavButton(
                icon: Icons.mic,
                label: "Sesli Giriş",
                onTap: () {
                  HapticService.selectionClick();
                  _showVoiceInput();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade600.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
