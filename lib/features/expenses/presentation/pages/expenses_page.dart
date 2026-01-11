import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/icon_constants.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/expense_summary_card.dart';
import 'add_expense_page.dart';
import 'expense_detail_page.dart';
import '../widgets/voice_input_sheet.dart';
import 'recycle_bin_page.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/widgets/money_animation.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../../../core/widgets/app_floating_bottom_bar.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../helpers/expense_calculation_helper.dart';
import '../state/expense_page_state.dart';

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

class _ExpensesPageState extends State<ExpensesPage> with LazyLoadingMixin {
  final TextEditingController tArama = TextEditingController();

  // State yönetimi için ChangeNotifier
  late final ExpensePageState _pageState;

  // Getter'lar - state'e kolay erişim
  bool get aramaModu => _pageState.aramaModu;
  bool get _isLoading => _pageState.isLoading;
  DateTime get secilenAy => _pageState.secilenAy;
  List<Map<String, dynamic>> get gosterilenHarcamalar =>
      _pageState.gosterilenHarcamalar;

  @override
  void initState() {
    super.initState();

    // State notifier'u başlat
    _pageState = ExpensePageState();
    _pageState.secilenAy = widget.secilenAy;

    initLazyLoading();
    _filtreleVeGoster();

    // State değişikliklerini dinle ve UI'yı güncelle
    _pageState.addListener(_onStateChanged);

    // Kısa skeleton animasyonu için 300ms bekle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pageState.stopLoading();
      }
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageState.removeListener(_onStateChanged);
    _pageState.dispose();
    disposeLazyLoading();
    tArama.dispose();
    super.dispose();
  }

  void _filtreleVeGoster() {
    _pageState.filtreleVeGoster(
      tumHarcamalar: widget.tumHarcamalar,
      aramaMetni: tArama.text,
      onResetLazyLoading: resetLazyLoading,
    );
  }

  // Geriye uyumluluk için eski metod adı
  void filtreleVeGoster() => _filtreleVeGoster();

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
    _pageState.secilenAy = DateTime(secilenAy.year, secilenAy.month - 1, 1);
    filtreleVeGoster();
  }

  void sonrakiAy() {
    _pageState.secilenAy = DateTime(secilenAy.year, secilenAy.month + 1, 1);
    filtreleVeGoster();
  }

  void _ayYilSeciciAc() async {
    // Ortak MonthYearPicker widget'ını kullan
    final selectedDate = await MonthYearPicker.show(
      context,
      initialDate: secilenAy,
      accentColor: ColorConstants.kirmiziVurgu,
    );

    if (selectedDate != null && mounted) {
      _pageState.secilenAy = selectedDate;
      filtreleVeGoster();
    }
  }

  void harcamaSil(Map<String, dynamic> harcama) {
    HapticService.delete(); // Silme haptic feedback

    // Eski değerleri sakla (geri alma için)
    final eskiSilindi = harcama['silindi'];
    final paymentMethodId = harcama['odemeYontemiId'];
    double? eskiBakiye;
    int? pmIndex;

    if (paymentMethodId != null) {
      pmIndex = widget.tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        eskiBakiye = widget.tumOdemeYontemleri[pmIndex].balance;
      }
    }

    setState(() {
      harcama['silindi'] = true;

      // Ödeme yönteminin bakiyesini geri ekle
      if (pmIndex != null && pmIndex != -1) {
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

      filtreleVeGoster();
    });

    widget.onHarcamalarChanged(widget.tumHarcamalar);
    widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

    // Geri Al özelliği ile SnackBar göster
    AppSnackBar.deleted(
      context,
      'Harcama çöp kutusuna taşındı 🗑️',
      onUndo: () {
        // Sayfa hala aktif mi kontrol et
        if (!mounted) return;

        // Silme işlemini geri al
        setState(() {
          harcama['silindi'] = eskiSilindi ?? false;
          if (pmIndex != null && pmIndex != -1 && eskiBakiye != null) {
            widget.tumOdemeYontemleri[pmIndex] = widget
                .tumOdemeYontemleri[pmIndex]
                .copyWith(balance: eskiBakiye);
          }
          filtreleVeGoster();
        });
        widget.onHarcamalarChanged(widget.tumHarcamalar);
        widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

        // Geri alındı bildirimi
        AppSnackBar.success(context, 'Harcama geri yüklendi ✅');
      },
    );
  }

  void pencereAc({Map<String, dynamic>? duzenlenecekHarcama}) {
    final eskiTutar = duzenlenecekHarcama != null
        ? double.tryParse(duzenlenecekHarcama['tutar'].toString()) ?? 0.0
        : 0.0;
    final eskiOdemeYontemiId = duzenlenecekHarcama?['odemeYontemiId'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpensePage(
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
                _pageState.secilenAy = DateTime.now();
                filtreleVeGoster();
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
              aramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              _pageState.aramaModu = !aramaModu;
              if (!aramaModu) {
                tArama.clear();
                filtreleVeGoster();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const ExpensesPageSkeleton()
          : Column(
              children: [
                if (!aramaModu) ...[
                  ExpenseSummaryCard(
                    ayIsmi: ayIsmi,
                    toplamTutar: toplamTutar,
                    butceLimiti: widget.butceLimiti,
                    oncekiAy: oncekiAy,
                    sonrakiAy: sonrakiAy,
                    ayYilSeciciAc: _ayYilSeciciAc,
                    secilenAy: secilenAy,
                    harcamalar: widget.tumHarcamalar,
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
                            : EmptyStateWidget.noExpenses()
                      : RefreshIndicator(
                          onRefresh: () async {
                            // Verileri yeniden filtrele ve göster
                            filtreleVeGoster();
                          },
                          color: ColorConstants.kirmiziVurgu,
                          child: ListView.builder(
                            controller: lazyScrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            itemCount:
                                gruplar.keys.length + (hasMoreItems ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Son item ise ve daha fazla veri varsa loading göster
                              if (index >= gruplar.keys.length) {
                                return buildLoadingIndicator();
                              }

                              String gunBasligi = gruplar.keys.elementAt(index);
                              List<Map<String, dynamic>> harcamalar =
                                  gruplar[gunBasligi]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tarih başlığı kaldırıldı (Kart içinde gösteriliyor)
                                  /*
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
                            */
                                  ...harcamalar.map((harcama) {
                                    return ExpenseListItem(
                                      harcama: harcama,
                                      categoryIcon:
                                          widget
                                              .kategoriIkonlari[harcama['kategori']] ??
                                          IconConstants.getIconFromCategoryName(
                                            harcama['kategori'],
                                          ),
                                      paymentMethods: widget.tumOdemeYontemleri,
                                      itemIndex: gosterilenHarcamalar.indexOf(
                                        harcama,
                                      ),
                                      onDelete: () => harcamaSil(harcama),
                                      onTap: () {
                                        HapticService.selectionClick();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => ExpenseDetailPage(
                                              harcama: harcama,
                                              categoryIcon:
                                                  widget
                                                      .kategoriIkonlari[harcama['kategori']] ??
                                                  IconConstants.getIconFromCategoryName(
                                                    harcama['kategori'],
                                                  ),
                                              paymentMethods:
                                                  widget.tumOdemeYontemleri,
                                              kategoriIkonlari:
                                                  widget.kategoriIkonlari,
                                              onEdit: (updatedHarcama) {
                                                setState(() {
                                                  final index =
                                                      gosterilenHarcamalar
                                                          .indexOf(harcama);
                                                  if (index != -1) {
                                                    gosterilenHarcamalar[index] =
                                                        updatedHarcama;
                                                  }
                                                });
                                                widget.onHarcamalarChanged(
                                                  widget.tumHarcamalar,
                                                );
                                              },
                                              onDelete: (deletedHarcama) {
                                                harcamaSil(deletedHarcama);
                                              },
                                            ),
                                          ),
                                        ).then((_) {
                                          if (mounted) filtreleVeGoster();
                                        });
                                      },
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
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
                      CopKutusuSayfasi(userId: widget.userId ?? ''),
                ),
              ).then((_) {
                filtreleVeGoster();
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
        centerButtonColor: ColorConstants.kirmiziVurgu,
        onCenterButtonTap: () {
          HapticService.lightImpact();
          pencereAc();
        },
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

          AppSnackBar.success(
            context,
            'Harcama eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
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
          final helper = ExpenseCalculationHelper(
            tumHarcamalar: widget.tumHarcamalar,
            gosterilenHarcamalar: gosterilenHarcamalar,
            secilenAy: secilenAy,
            butceLimiti: widget.butceLimiti,
          );
          return helper.getTopCategory();
        },
        onGetWeeklyTotal: () {
          final helper = ExpenseCalculationHelper(
            tumHarcamalar: widget.tumHarcamalar,
            gosterilenHarcamalar: gosterilenHarcamalar,
            secilenAy: secilenAy,
            butceLimiti: widget.butceLimiti,
          );
          return helper.getWeeklyTotal();
        },
        onGetDailyTotal: () {
          final helper = ExpenseCalculationHelper(
            tumHarcamalar: widget.tumHarcamalar,
            gosterilenHarcamalar: gosterilenHarcamalar,
            secilenAy: secilenAy,
            butceLimiti: widget.butceLimiti,
          );
          return helper.getDailyTotal();
        },
        onGetLastExpenses: () {
          final helper = ExpenseCalculationHelper(
            tumHarcamalar: widget.tumHarcamalar,
            gosterilenHarcamalar: gosterilenHarcamalar,
            secilenAy: secilenAy,
            butceLimiti: widget.butceLimiti,
          );
          return helper.getLastExpenses();
        },
        onCheckBudget: () {
          final helper = ExpenseCalculationHelper(
            tumHarcamalar: widget.tumHarcamalar,
            gosterilenHarcamalar: gosterilenHarcamalar,
            secilenAy: secilenAy,
            butceLimiti: widget.butceLimiti,
          );
          return helper.checkBudget();
        },
        onGetCategoryTotal: (String kategori) {
          final helper = ExpenseCalculationHelper(
            tumHarcamalar: widget.tumHarcamalar,
            gosterilenHarcamalar: gosterilenHarcamalar,
            secilenAy: secilenAy,
            butceLimiti: widget.butceLimiti,
          );
          return helper.getCategoryTotal(kategori);
        },
        onAddFixedExpenses: () async {
          final expenseRepo = getIt<ExpenseRepository>();
          final sabitGiderler = expenseRepo.getFixedExpenseTemplates(
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
