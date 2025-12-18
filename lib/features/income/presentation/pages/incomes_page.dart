import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../income/presentation/widgets/add_income_sheet.dart';
import '../../../income/presentation/pages/income_recycle_bin_page.dart';

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

  void gelirSil(Income income) {
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
    final isDefaultTheme = context.watch<ThemeManager>().isDefaultTheme;
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
          if (!gelirAramaModu)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: "Çöp Kutusu",
              onPressed: () {
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
                  colors: isDefaultTheme
                      ? [
                          Colors.green.shade900.withValues(alpha: 0.5),
                          Colors.green.shade700.withValues(alpha: 0.3),
                        ]
                      : [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.15),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDefaultTheme
                      ? Colors.green.shade400.withValues(alpha: 0.4)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ay navigasyonu
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: isDefaultTheme
                                  ? Colors.green.shade300
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: oncekiAy,
                          ),
                          Text(
                            ayIsmi,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: isDefaultTheme
                                  ? Colors.green.shade300
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: sonrakiAy,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDefaultTheme
                              ? Colors.green.shade400.withValues(alpha: 0.2)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: isDefaultTheme
                              ? Colors.green.shade300
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toplam Gelir",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${toplamGelir.toStringAsFixed(2)} ₺",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDefaultTheme
                                  ? Colors.green.shade300
                                  : PageThemeColors.incomePrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Gelir listesi
          Expanded(
            child: gelirler.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          gelirAramaModu
                              ? Icons.search_off
                              : Icons.trending_up_outlined,
                          size: 60,
                          color: Colors.white12,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gelirAramaModu
                              ? "Sonuç bulunamadı."
                              : "$ayIsmi için gelir yok.",
                          style: const TextStyle(color: Colors.white24),
                        ),
                      ],
                    ),
                  )
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
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.gelirKategoriIkonlari[gelir.category] ??
                                    Icons.attach_money,
                                color: Colors.green.shade400,
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
                              "+${gelir.amount.toStringAsFixed(2)} ₺",
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
      floatingActionButton: FloatingActionButton(
        onPressed: yeniGelirEkle,
        backgroundColor: isDefaultTheme
            ? Colors.green.shade600
            : Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
