import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/voice_input_sheet.dart';
import '../../../../recycle_bin_page.dart';
import '../../../../services/database_helper.dart';
import '../../../../core/widgets/money_animation.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../services/haptic_service.dart';

class ExpensesPage extends StatefulWidget {
  final List<Map<String, dynamic>> tumHarcamalar;
  final List<PaymentMethod> tumOdemeYontemleri;
  final Map<String, IconData> kategoriIkonlari;
  final double butceLimiti;
  final DateTime secilenAy;
  final String? userId;
  final String? varsayilanOdemeYontemiId;
  final Function(List<Map<String, dynamic>>) onHarcamalarChanged;
  final Function(List<PaymentMethod>) onOdemeYontemleriChanged;

  const ExpensesPage({
    super.key,
    required this.tumHarcamalar,
    required this.tumOdemeYontemleri,
    required this.kategoriIkonlari,
    required this.butceLimiti,
    required this.secilenAy,
    required this.userId,
    this.varsayilanOdemeYontemiId,
    required this.onHarcamalarChanged,
    required this.onOdemeYontemleriChanged,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController tArama = TextEditingController();
  bool aramaModu = false;
  late DateTime secilenAy;
  List<Map<String, dynamic>> gosterilenHarcamalar = [];

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
    filtreleVeGoster();
  }

  void filtreleVeGoster() {
    String aramaMetni = tArama.text.toLowerCase();
    setState(() {
      gosterilenHarcamalar = widget.tumHarcamalar.where((h) {
        if (h['silindi'] == true) return false;
        DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
        if (tarih == null) return false;
        bool ayFiltrelendi =
            tarih.year == secilenAy.year && tarih.month == secilenAy.month;
        if (!ayFiltrelendi) return false;
        if (aramaMetni.isEmpty) return true;
        String isim = (h['isim'] ?? "").toString().toLowerCase();
        String kategori = (h['kategori'] ?? "").toString().toLowerCase();
        return isim.contains(aramaMetni) || kategori.contains(aramaMetni);
      }).toList();

      gosterilenHarcamalar.sort((a, b) {
        DateTime tarihA =
            DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
        DateTime tarihB =
            DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
        return tarihB.compareTo(tarihA);
      });
    });
  }

  double get toplamTutar {
    double toplam = 0;
    for (var h in gosterilenHarcamalar) {
      toplam += double.tryParse(h['tutar'].toString()) ?? 0;
    }
    return toplam;
  }

  Map<String, List<Map<String, dynamic>>> get gunlukGruplanmisHarcamalar {
    Map<String, List<Map<String, dynamic>>> gruplar = {};
    for (var h in gosterilenHarcamalar) {
      DateTime tarih =
          DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
      String tarihBasligi = tarihFormatla(tarih);
      if (!gruplar.containsKey(tarihBasligi)) {
        gruplar[tarihBasligi] = [];
      }
      gruplar[tarihBasligi]!.add(h);
    }
    return gruplar;
  }

  String tarihFormatla(DateTime tarih) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final oTarih = DateTime(tarih.year, tarih.month, tarih.day);
    final fark = bugun.difference(oTarih).inDays;

    if (fark == 0) return "Bugün";
    if (fark == 1) return "Dün";

    return "${oTarih.day} ${aylarListesi[oTarih.month - 1]}";
  }

  String get ayIsmi {
    return "${aylarListesi[secilenAy.month - 1]} ${secilenAy.year}";
  }

  void oncekiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month - 1, 1);
      filtreleVeGoster();
    });
  }

  void sonrakiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month + 1, 1);
      filtreleVeGoster();
    });
  }

  void harcamaSil(Map<String, dynamic> harcama) {
    HapticService.mediumImpact(); // Haptic feedback
    setState(() {
      harcama['silindi'] = true;

      // Ödeme yönteminin bakiyesini geri ekle
      final paymentMethodId = harcama['odemeYontemiId'];
      if (paymentMethodId != null) {
        final pmIndex = widget.tumOdemeYontemleri.indexWhere(
          (p) => p.id == paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = widget.tumOdemeYontemleri[pmIndex];
          final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
          double newBalance;
          if (pm.type == 'kredi') {
            newBalance = pm.balance - amount;
          } else {
            newBalance = pm.balance + amount;
          }
          widget.tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
        }
      }

      filtreleVeGoster();
    });

    widget.onHarcamalarChanged(widget.tumHarcamalar);
    widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Harcama çöp kutusuna taşındı 🗑️",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorConstants.koyuKirmizi,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void pencereAc({Map<String, dynamic>? duzenlenecekHarcama}) {
    final eskiTutar = duzenlenecekHarcama != null
        ? double.tryParse(duzenlenecekHarcama['tutar'].toString()) ?? 0.0
        : 0.0;
    final eskiOdemeYontemiId = duzenlenecekHarcama?['odemeYontemiId'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(
        expenseToEdit: duzenlenecekHarcama,
        categories: widget.kategoriIkonlari,
        paymentMethods: widget.tumOdemeYontemleri
            .where((pm) => !pm.isDeleted)
            .toList(),
        defaultPaymentMethodId: widget.varsayilanOdemeYontemiId,
        onSave: (name, amount, category, date, paymentMethodId) {
          setState(() {
            void updateBalance(String? pmId, double amountChange) {
              if (pmId == null) return;
              final pmIndex = widget.tumOdemeYontemleri.indexWhere(
                (p) => p.id == pmId,
              );
              if (pmIndex == -1) return;

              final pm = widget.tumOdemeYontemleri[pmIndex];
              double newBalance;
              if (pm.type == 'kredi') {
                newBalance = pm.balance + amountChange;
              } else {
                newBalance = pm.balance - amountChange;
              }
              widget.tumOdemeYontemleri[pmIndex] = pm.copyWith(
                balance: newBalance,
              );
            }

            if (duzenlenecekHarcama != null) {
              if (eskiOdemeYontemiId != null) {
                updateBalance(eskiOdemeYontemiId, -eskiTutar);
              }
              if (paymentMethodId != null) {
                updateBalance(paymentMethodId, amount);
              }

              int index = widget.tumHarcamalar.indexOf(duzenlenecekHarcama);
              if (index != -1) {
                widget.tumHarcamalar[index] = {
                  "isim": name,
                  "tutar": amount,
                  "kategori": category,
                  "tarih": date.toString(),
                  "silindi": false,
                  "odemeYontemiId": paymentMethodId,
                };
              }
            } else {
              if (paymentMethodId != null) {
                updateBalance(paymentMethodId, amount);
              }

              widget.tumHarcamalar.add({
                "isim": name,
                "tutar": amount,
                "kategori": category,
                "tarih": date.toString(),
                "silindi": false,
                "odemeYontemiId": paymentMethodId,
              });
            }

            widget.tumHarcamalar.sort((a, b) {
              DateTime tarihA =
                  DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
              DateTime tarihB =
                  DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
              return tarihB.compareTo(tarihA);
            });

            filtreleVeGoster();
          });

          widget.onHarcamalarChanged(widget.tumHarcamalar);
          widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

          if (duzenlenecekHarcama == null) {
            if (context.read<ThemeManager>().isMoneyAnimationEnabled) {
              MoneyAnimationOverlay.show(context);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime simdi = DateTime.now();
    bool buAyMi =
        (secilenAy.year == simdi.year && secilenAy.month == simdi.month);

    Map<String, List<Map<String, dynamic>>> gruplar =
        gunlukGruplanmisHarcamalar;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: aramaModu
            ? TextField(
                controller: tArama,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Harcama ara...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
                onChanged: (val) => filtreleVeGoster(),
              )
            : const Text("Harcamalarım"),
        actions: [
          if (!aramaModu && !buAyMi)
            TextButton(
              onPressed: () {
                setState(() {
                  secilenAy = DateTime.now();
                  filtreleVeGoster();
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
          if (!aramaModu) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: "Çöp Kutusu",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CopKutusuSayfasi(userId: widget.userId ?? ''),
                  ),
                ).then((_) {
                  filtreleVeGoster();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              tooltip: "Sesli Giriş",
              onPressed: _showVoiceInput,
            ),
          ],
          IconButton(
            icon: Icon(
              aramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                aramaModu = !aramaModu;
                if (!aramaModu) {
                  tArama.clear();
                  filtreleVeGoster();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!aramaModu) ...[
            ExpenseSummaryCard(
              ayIsmi: ayIsmi,
              toplamTutar: toplamTutar,
              butceLimiti: widget.butceLimiti,
              oncekiAy: oncekiAy,
              sonrakiAy: sonrakiAy,
              ayYilSeciciAc: () {},
            ),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: gosterilenHarcamalar.isEmpty
                ? aramaModu
                      ? const EmptyStateWidget(
                          icon: Icons.search_off,
                          title: 'Sonuç bulunamadı',
                          subtitle: 'Farklı bir arama terimi deneyin',
                        )
                      : EmptyStateWidget.noExpenses(onAdd: pencereAc)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    itemCount: gruplar.keys.length,
                    itemBuilder: (context, index) {
                      String gunBasligi = gruplar.keys.elementAt(index);
                      List<Map<String, dynamic>> harcamalar =
                          gruplar[gunBasligi]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              bottom: 5,
                              top: 10,
                            ),
                            child: Text(
                              gunBasligi.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.54),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...harcamalar.map((harcama) {
                            return ExpenseListItem(
                              harcama: harcama,
                              categoryIcon:
                                  widget.kategoriIkonlari[harcama['kategori']],
                              paymentMethods: widget.tumOdemeYontemleri,
                              itemIndex: gosterilenHarcamalar.indexOf(harcama),
                              onDelete: () => harcamaSil(harcama),
                              onTap: () =>
                                  pencereAc(duzenlenecekHarcama: harcama),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pencereAc,
        backgroundColor: context.watch<ThemeManager>().isDefaultTheme
            ? ColorConstants.koyuKirmizi
            : Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showVoiceInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceInputSheet(
        categoryIcons: widget.kategoriIkonlari,
        userId: widget.userId,
        onConfirm: (name, amount, category, date) {
          setState(() {
            widget.tumHarcamalar.add({
              "isim": name,
              "tutar": amount,
              "kategori": category,
              "tarih": date.toString(),
              "silindi": false,
            });

            widget.tumHarcamalar.sort((a, b) {
              DateTime tarihA =
                  DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
              DateTime tarihB =
                  DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
              return tarihB.compareTo(tarihA);
            });

            filtreleVeGoster();
          });
          widget.onHarcamalarChanged(widget.tumHarcamalar);

          if (context.read<ThemeManager>().isMoneyAnimationEnabled) {
            MoneyAnimationOverlay.show(context);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Harcama eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
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
        onDeleteLastExpense: () async {
          final buAyHarcamalari = widget.tumHarcamalar.where((h) {
            if (h['silindi'] == true) return false;
            DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
            if (tarih == null) return false;
            return tarih.year == secilenAy.year &&
                tarih.month == secilenAy.month;
          }).toList();

          if (buAyHarcamalari.isEmpty) return null;

          buAyHarcamalari.sort((a, b) {
            DateTime tarihA =
                DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
            DateTime tarihB =
                DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
            return tarihB.compareTo(tarihA);
          });

          final sonHarcama = buAyHarcamalari.first;
          setState(() {
            sonHarcama['silindi'] = true;
            filtreleVeGoster();
          });
          widget.onHarcamalarChanged(widget.tumHarcamalar);

          return sonHarcama;
        },
        onGetMonthlyTotal: () => toplamTutar,
        onGetTopCategory: () {
          Map<String, double> kategoriToplamlari = {};
          for (var h in gosterilenHarcamalar) {
            String kat = h['kategori'] ?? "Diğer";
            double tutar = double.tryParse(h['tutar'].toString()) ?? 0;
            kategoriToplamlari[kat] = (kategoriToplamlari[kat] ?? 0) + tutar;
          }
          if (kategoriToplamlari.isEmpty) return null;
          String? enCokKategori;
          double enYuksekTutar = 0;
          kategoriToplamlari.forEach((kategori, tutar) {
            if (tutar > enYuksekTutar) {
              enYuksekTutar = tutar;
              enCokKategori = kategori;
            }
          });
          if (enCokKategori == null || enYuksekTutar == 0) return null;
          return {'kategori': enCokKategori, 'tutar': enYuksekTutar};
        },
        onGetWeeklyTotal: () {
          final now = DateTime.now();
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          double haftalikToplam = 0;
          for (var h in widget.tumHarcamalar) {
            if (h['silindi'] == true) continue;
            DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
            if (tarih != null &&
                tarih.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                tarih.isBefore(now.add(const Duration(days: 1)))) {
              haftalikToplam += (h['tutar'] as num?)?.toDouble() ?? 0;
            }
          }
          return haftalikToplam;
        },
        onGetDailyTotal: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          double gunlukToplam = 0;
          for (var h in widget.tumHarcamalar) {
            if (h['silindi'] == true) continue;
            DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
            if (tarih != null) {
              final harcamaTarihi = DateTime(
                tarih.year,
                tarih.month,
                tarih.day,
              );
              if (harcamaTarihi.isAtSameMomentAs(today)) {
                gunlukToplam += (h['tutar'] as num?)?.toDouble() ?? 0;
              }
            }
          }
          return gunlukToplam;
        },
        onGetLastExpenses: () {
          final buAyHarcamalari = widget.tumHarcamalar.where((h) {
            if (h['silindi'] == true) return false;
            DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
            if (tarih == null) return false;
            return tarih.year == secilenAy.year &&
                tarih.month == secilenAy.month;
          }).toList();
          buAyHarcamalari.sort((a, b) {
            DateTime tarihA =
                DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
            DateTime tarihB =
                DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
            return tarihB.compareTo(tarihA);
          });
          return buAyHarcamalari.take(5).toList();
        },
        onCheckBudget: () {
          double kalanLimit = widget.butceLimiti - toplamTutar;
          double asilanMiktar = toplamTutar - widget.butceLimiti;
          return {
            'kalanLimit': kalanLimit > 0 ? kalanLimit : 0,
            'asilanMiktar': asilanMiktar,
            'butceLimiti': widget.butceLimiti,
          };
        },
        onGetCategoryTotal: (String kategori) {
          double toplam = 0;
          for (var h in gosterilenHarcamalar) {
            if (h['kategori'] == kategori) {
              toplam += double.tryParse(h['tutar'].toString()) ?? 0;
            }
          }
          return toplam;
        },
        onAddFixedExpenses: () async {
          final sabitGiderler = DatabaseHelper.sabitGiderSablonlariGetir(
            widget.userId ?? '',
          );
          if (sabitGiderler.isEmpty) {
            return {'adet': 0, 'toplam': 0.0};
          }
          DateTime simdiT = DateTime.now();
          double toplam = 0;
          for (var sablon in sabitGiderler) {
            double tutar = (sablon['tutar'] as num?)?.toDouble() ?? 0;
            toplam += tutar;
            widget.tumHarcamalar.add({
              'isim': sablon['isim'],
              'tutar': tutar,
              'kategori': 'Sabit Giderler',
              'tarih': simdiT.toString(),
              'silindi': false,
            });
          }
          widget.onHarcamalarChanged(widget.tumHarcamalar);
          setState(() {
            filtreleVeGoster();
          });
          return {'adet': sabitGiderler.length, 'toplam': toplam};
        },
        onEditLastExpense: (double yeniTutar) async {
          final buAyHarcamalari = widget.tumHarcamalar.where((h) {
            if (h['silindi'] == true) return false;
            DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
            if (tarih == null) return false;
            return tarih.year == secilenAy.year &&
                tarih.month == secilenAy.month;
          }).toList();
          if (buAyHarcamalari.isEmpty) return null;
          buAyHarcamalari.sort((a, b) {
            DateTime tarihA =
                DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
            DateTime tarihB =
                DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
            return tarihB.compareTo(tarihA);
          });
          final sonHarcama = buAyHarcamalari.first;
          final eskiTutar = (sonHarcama['tutar'] as num?)?.toDouble() ?? 0;
          final isim = sonHarcama['isim'] ?? 'Harcama';
          if (yeniTutar == 0) {
            sonHarcama['silindi'] = true;
          } else {
            sonHarcama['tutar'] = yeniTutar;
          }
          widget.onHarcamalarChanged(widget.tumHarcamalar);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                filtreleVeGoster();
              });
            }
          });
          return {
            'isim': isim,
            'eskiTutar': eskiTutar,
            'yeniTutar': yeniTutar,
            'silindi': yeniTutar == 0,
          };
        },
        onGetDateRangeTotal: (DateTime baslangic, DateTime bitis) {
          double toplam = 0;
          final baslangicGun = DateTime(
            baslangic.year,
            baslangic.month,
            baslangic.day,
          );
          final bitisGun = DateTime(bitis.year, bitis.month, bitis.day);
          for (var h in widget.tumHarcamalar) {
            if (h['silindi'] == true) continue;
            DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
            if (tarih != null) {
              final harcamaTarihi = DateTime(
                tarih.year,
                tarih.month,
                tarih.day,
              );
              if ((harcamaTarihi.isAtSameMomentAs(baslangicGun) ||
                      harcamaTarihi.isAfter(baslangicGun)) &&
                  (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                      harcamaTarihi.isBefore(bitisGun))) {
                toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
              }
            }
          }
          return toplam;
        },
        onGetDateRangeCategoryTotal:
            (DateTime baslangic, DateTime bitis, String kategori) {
              double toplam = 0;
              final baslangicGun = DateTime(
                baslangic.year,
                baslangic.month,
                baslangic.day,
              );
              final bitisGun = DateTime(bitis.year, bitis.month, bitis.day);
              for (var h in widget.tumHarcamalar) {
                if (h['silindi'] == true) continue;
                if (h['kategori'] != kategori) continue;
                DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
                if (tarih != null) {
                  final harcamaTarihi = DateTime(
                    tarih.year,
                    tarih.month,
                    tarih.day,
                  );
                  if ((harcamaTarihi.isAtSameMomentAs(baslangicGun) ||
                          harcamaTarihi.isAfter(baslangicGun)) &&
                      (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                          harcamaTarihi.isBefore(bitisGun))) {
                    toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
                  }
                }
              }
              return toplam;
            },
      ),
    );
  }
}
