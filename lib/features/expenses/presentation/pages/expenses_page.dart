// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/expenses/presentation/widgets/expenses_list_view.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';
import 'package:cashly/features/expenses/presentation/widgets/expenses_app_bar.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../widgets/expense_summary_card.dart';
import 'add_expense_page.dart';
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
import '../controllers/expenses_controller.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/currency_service.dart';

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
  final Function(DateTime)? onMonthChanged;

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
    this.onMonthChanged,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> with LazyLoadingMixin {
  final TextEditingController tArama = TextEditingController();

  // Debouncer - arama performansı için
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 300),
  );

  // Controller - DI'dan alınır
  late final ExpensesController _controller;

  // Getter'lar
  bool get aramaModu => _controller.aramaModu;
  DateTime get secilenAy => _controller.secilenAy;
  List<Map<String, dynamic>> get gosterilenHarcamalar =>
      _controller.gosterilenHarcamalar;

  @override
  void initState() {
    super.initState();

    // Controller'ı DI'dan al
    _controller = getIt<ExpensesController>(param1: widget.userId ?? '');
    _controller.secilenAy = widget.secilenAy;

    initLazyLoading();
    _filtreleVeGoster();

    // Kısa skeleton animasyonu için 300ms bekle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.stopLoading();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    disposeLazyLoading();
    tArama.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _filtreleVeGoster() {
    _controller.filtreleVeGosterLegacy(
      tumHarcamalar: widget.tumHarcamalar,
      aramaMetni: tArama.text,
      onResetLazyLoading: resetLazyLoading,
    );
  }

  // Geriye uyumluluk için eski metod adı
  void filtreleVeGoster() => _filtreleVeGoster();

  double get toplamTutar {
    final cur = getIt<CurrencyService>();
    double toplam = 0;
    for (var h in gosterilenHarcamalar) {
      final tutar = double.tryParse(h['tutar'].toString()) ?? 0;
      final pb = h['paraBirimi']?.toString() ?? 'TRY';
      toplam += cur.convert(tutar, pb, cur.currentCurrency);
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

    if (fark == 0) return context.l10n.todayLabel;
    if (fark == 1) return context.l10n.yesterdayLabel;

    return "${oTarih.day} ${context.getMonthName(oTarih.month)}";
  }

  String get ayIsmi {
    return "${context.getMonthName(secilenAy.month)} ${secilenAy.year}";
  }

  void oncekiAy() {
    _controller.secilenAy = DateTime(secilenAy.year, secilenAy.month - 1, 1);
    widget.onMonthChanged?.call(_controller.secilenAy);
    filtreleVeGoster();
  }

  void sonrakiAy() {
    _controller.secilenAy = DateTime(secilenAy.year, secilenAy.month + 1, 1);
    widget.onMonthChanged?.call(_controller.secilenAy);
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
      _controller.secilenAy = selectedDate;
      widget.onMonthChanged?.call(selectedDate);
      filtreleVeGoster();
    }
  }

  Future<void> harcamaSil(Map<String, dynamic> harcama) async {
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

    try {
      await _controller.harcamaSilLegacy(
        harcama: harcama,
        tumHarcamalar: widget.tumHarcamalar,
        tumOdemeYontemleri: widget.tumOdemeYontemleri,
        aramaMetni: tArama.text,
        onResetLazyLoading: resetLazyLoading,
      );

      widget.onHarcamalarChanged(widget.tumHarcamalar);
      widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

      // Geri Al özelliği ile SnackBar göster
      if (!mounted) return;
      AppSnackBar.deleted(
        context,
        '${context.l10n.expense} ${context.l10n.movedToTrash} 🗑️',
        onUndo: () async {
          // Sayfa hala aktif mi kontrol et
          if (!mounted) return;

          try {
            // Silme işlemini geri al
            await _controller.harcamaSilmeGeriAlLegacy(
              harcama: harcama,
              tumHarcamalar: widget.tumHarcamalar,
              tumOdemeYontemleri: widget.tumOdemeYontemleri,
              eskiSilindi: eskiSilindi,
              eskiBakiye: eskiBakiye,
              pmIndex: pmIndex,
              aramaMetni: tArama.text,
              onResetLazyLoading: resetLazyLoading,
            );
            widget.onHarcamalarChanged(widget.tumHarcamalar);
            widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

            // Geri alındı bildirimi
            if (mounted) {
              AppSnackBar.success(
                context,
                '${context.l10n.expense} ${context.l10n.restored} ✅',
              );
            }
          } catch (e) {
            if (!mounted) return;
            if (e is AppException) {
              ErrorHandler.handleAppException(context, e);
            }
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      if (e is AppException) {
        ErrorHandler.handleAppException(context, e);
      }
    }
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
          initialDate: widget.secilenAy,
          onSave:
              (
                name,
                amount,
                category,
                date,
                paymentMethodId,
                paraBirimi,
              ) async {
                try {
                  await _controller.harcamaEkleVeyaDuzenleLegacy(
                    tumHarcamalar: widget.tumHarcamalar,
                    tumOdemeYontemleri: widget.tumOdemeYontemleri,
                    name: name,
                    amount: amount,
                    category: category,
                    date: date,
                    paymentMethodId: paymentMethodId,
                    paraBirimi: paraBirimi,
                    duzenlenecekHarcama: duzenlenecekHarcama,
                    eskiOdemeYontemiId: eskiOdemeYontemiId,
                    eskiTutar: eskiTutar,
                    aramaMetni: tArama.text,
                    onResetLazyLoading: resetLazyLoading,
                  );

                  widget.onHarcamalarChanged(widget.tumHarcamalar);
                  widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

                  if (duzenlenecekHarcama == null) {
                    if (!mounted) return;
                    if (context.read<ThemeManager>().isMoneyAnimationEnabled) {
                      MoneyAnimationOverlay.show(context);
                    }
                  }
                } catch (e) {
                  if (!mounted) return;
                  if (e is AppException) {
                    ErrorHandler.handleAppException(context, e);
                  }
                }
              },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpensesController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ExpensesAppBar(
          searchController: tArama,
          onSearchChanged: filtreleVeGoster,
          onClearSearch: () {
            tArama.clear();
            filtreleVeGoster();
          },
          onGoToToday: () {
            _controller.secilenAy = DateTime.now();
            filtreleVeGoster();
          },
        ),
        body: Builder(
          builder: (context) {
            final isLoadingContext = context.select((ExpensesController c) => c.isLoading);
            final aramaModuContext = context.select((ExpensesController c) => c.aramaModu);
            final secilenAyContext = context.select((ExpensesController c) => c.secilenAy);
            final gosterilenHarcamalarContext = context.select((ExpensesController c) => c.gosterilenHarcamalar);
            
            Map<String, List<Map<String, dynamic>>> gruplar = gunlukGruplanmisHarcamalar;

            return isLoadingContext
                ? const ExpensesPageSkeleton()
                : Column(
                    children: [
                      if (!aramaModuContext) ...[
                        ExpenseSummaryCard(
                          ayIsmi: ayIsmi,
                          toplamTutar: toplamTutar,
                          butceLimiti: widget.butceLimiti,
                          oncekiAy: oncekiAy,
                          sonrakiAy: sonrakiAy,
                          ayYilSeciciAc: _ayYilSeciciAc,
                          secilenAy: secilenAyContext,
                          harcamalar: widget.tumHarcamalar,
                        ),
                        const SizedBox(height: 10),
                      ],
                      Expanded(
                        child: gosterilenHarcamalarContext.isEmpty
                            ? aramaModuContext
                            ? EmptyStateWidget(
                                icon: Icons.search_off,
                                title: context.l10n.noResultsFound,
                                subtitle: context.l10n.tryDifferentSearchTerm,
                              )
                            : EmptyStateWidget.noExpenses(context)
                      : ExpensesListView(
                          gruplar: gruplar,
                          hasMoreItems: hasMoreItems,
                          scrollController: lazyScrollController,
                          onRefresh: () async {
                            filtreleVeGoster();
                          },
                          buildLoadingIndicator: buildLoadingIndicator,
                          onDelete: harcamaSil,
                          onEdit: (harcama, updatedHarcama) async {
                            final index = gosterilenHarcamalarContext.indexOf(harcama);
                            if (index != -1) {
                              gosterilenHarcamalarContext[index] = updatedHarcama;
                            }

                            await _controller.harcamaEkleVeyaDuzenleLegacy(
                              tumHarcamalar: widget.tumHarcamalar,
                              tumOdemeYontemleri: widget.tumOdemeYontemleri,
                              name: updatedHarcama['isim'] ?? harcama['isim'],
                              amount: double.tryParse(updatedHarcama['tutar'].toString()) ?? 0.0,
                              category: updatedHarcama['kategori'] ?? harcama['kategori'],
                              date: DateTime.tryParse(updatedHarcama['tarih'].toString()) ?? DateTime.now(),
                              paymentMethodId: updatedHarcama['odemeYontemiId'],
                              paraBirimi: updatedHarcama['paraBirimi'],
                              duzenlenecekHarcama: harcama,
                              eskiOdemeYontemiId: harcama['odemeYontemiId'],
                              eskiTutar: double.tryParse(harcama['tutar'].toString()) ?? 0.0,
                              aramaMetni: tArama.text,
                              onResetLazyLoading: resetLazyLoading,
                            );

                            widget.onHarcamalarChanged(widget.tumHarcamalar);
                            widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);
                            
                            if (mounted) filtreleVeGoster();
                          },
                          kategoriIkonlari: widget.kategoriIkonlari,
                          tumOdemeYontemleri: widget.tumOdemeYontemleri,
                          gosterilenHarcamalar: gosterilenHarcamalarContext,
                        ),
                      ),
                    ],
                  );
          },
        ),
      // Modern floating bottom navigation bar - Ortak widget kullanımı
      bottomNavigationBar: AppFloatingBottomBar(
        items: [
          BottomBarItem(
            icon: Icons.delete_outline,
            label: context.l10n.trashBin,
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
            label: context.l10n.voiceInput,
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
    ));
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
          widget.onHarcamalarChanged(widget.tumHarcamalar);

          if (context.read<ThemeManager>().isMoneyAnimationEnabled) {
            MoneyAnimationOverlay.show(context);
          }

          AppSnackBar.success(
            context,
            '${context.l10n.expense} ${context.l10n.added}: $name - ${CurrencyFormatter.format(amount)}',
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
          sonHarcama['silindi'] = true;
          filtreleVeGoster();
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
          filtreleVeGoster();
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
              filtreleVeGoster();
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
          final cur = getIt<CurrencyService>();
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
                final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
                final pb = h['paraBirimi']?.toString() ?? 'TRY';
                toplam += cur.convert(tutar, pb, cur.currentCurrency);
              }
            }
          }
          return toplam;
        },
        onGetDateRangeCategoryTotal:
            (DateTime baslangic, DateTime bitis, String kategori) {
              final cur = getIt<CurrencyService>();
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
                    final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
                    final pb = h['paraBirimi']?.toString() ?? 'TRY';
                    toplam += cur.convert(tutar, pb, cur.currentCurrency);
                  }
                }
              }
              return toplam;
            },
      ),
    );
  }
}
