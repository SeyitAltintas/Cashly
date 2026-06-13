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
import '../../../../core/widgets/money_animation.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../../../core/widgets/app_floating_bottom_bar.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../helpers/expense_voice_callbacks.dart';
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

    _controller = getIt<ExpensesController>(param1: widget.userId ?? '');
    _controller.secilenAy = widget.secilenAy;

    initLazyLoading();
    _controller.loadData();

    // Kısa skeleton animasyonu için 300ms bekle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.stopLoading();
      }
    });
  }

  @override
  void didUpdateWidget(ExpensesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tumHarcamalar != oldWidget.tumHarcamalar ||
        widget.secilenAy != oldWidget.secilenAy) {
      if (widget.secilenAy != oldWidget.secilenAy) {
        _controller.secilenAy = widget.secilenAy;
      }
      _filtreleVeGoster();
    }
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
    _controller.filtreleVeGoster(
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
    HapticService.delete();

    // Eski değerleri geri alma için sakla
    final eskiSilindi = harcama['silindi'];
    final paymentMethodId = harcama['odemeYontemiId'];
    double? eskiBakiye;
    int? pmIndex;

    if (paymentMethodId != null) {
      pmIndex = _controller.tumOdemeYontemleri.indexWhere(
        (p) => p.id == paymentMethodId,
      );
      if (pmIndex != -1) {
        eskiBakiye = _controller.tumOdemeYontemleri[pmIndex].balance;
      }
    }

    try {
      // Doğrudan controller'ın kendi metodunu kullan — prop karışımı yok
      await _controller.harcamaSil(
        harcama: harcama,
        aramaMetni: tArama.text,
        onResetLazyLoading: resetLazyLoading,
      );

      if (!mounted) return;
      AppSnackBar.deleted(
        context,
        '${context.l10n.expense} ${context.l10n.movedToTrash} 🗑️',
        onUndo: () async {
          if (!mounted) return;
          try {
            await _controller.harcamaSilmeGeriAl(
              harcama: harcama,
              eskiSilindi: eskiSilindi,
              eskiBakiye: eskiBakiye,
              pmIndex: pmIndex,
              aramaMetni: tArama.text,
              onResetLazyLoading: resetLazyLoading,
            );
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

  Future<void> _handleExpenseEdit(
    Map<String, dynamic> harcama,
    Map<String, dynamic> updatedHarcama,
  ) async {
    // Doğrudan controller'ın clean metodunu kullan — prop karışımı yok
    await _controller.harcamaEkleVeyaDuzenle(
      name: updatedHarcama['isim'] ?? harcama['isim'],
      amount: double.tryParse(updatedHarcama['tutar'].toString()) ?? 0.0,
      category: updatedHarcama['kategori'] ?? harcama['kategori'],
      date:
          DateTime.tryParse(updatedHarcama['tarih'].toString()) ??
          DateTime.now(),
      paymentMethodId: updatedHarcama['odemeYontemiId'],
      duzenlenecekHarcama: harcama,
      eskiOdemeYontemiId: harcama['odemeYontemiId'],
      eskiTutar: double.tryParse(harcama['tutar'].toString()) ?? 0.0,
      aramaMetni: tArama.text,
      onResetLazyLoading: resetLazyLoading,
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
          paymentMethods: _controller.tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          defaultPaymentMethodId: widget.varsayilanOdemeYontemiId,
          initialDate: _controller.secilenAy,
          onSave: (
            name,
            amount,
            category,
            date,
            paymentMethodId,
            paraBirimi,
          ) async {
            try {
              // Doğrudan controller'ın clean metodunu kullan
              await _controller.harcamaEkleVeyaDuzenle(
                name: name,
                amount: amount,
                category: category,
                date: date,
                paymentMethodId: paymentMethodId,
                duzenlenecekHarcama: duzenlenecekHarcama,
                eskiOdemeYontemiId: eskiOdemeYontemiId,
                eskiTutar: eskiTutar,
                aramaMetni: tArama.text,
                onResetLazyLoading: resetLazyLoading,
              );

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
        extendBody: true,
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
            final isLoadingContext = context.select(
              (ExpensesController c) => c.isLoading,
            );
            final aramaModuContext = context.select(
              (ExpensesController c) => c.aramaModu,
            );
            final secilenAyContext = context.select(
              (ExpensesController c) => c.secilenAy,
            );
            final gosterilenHarcamalarContext = context.select(
              (ExpensesController c) => c.gosterilenHarcamalar,
            );

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
                                      subtitle:
                                          context.l10n.tryDifferentSearchTerm,
                                    )
                                  : EmptyStateWidget.noExpenses(context)
                            : ExpensesListView(
                                hasMoreItems: hasMoreItems,
                                scrollController: lazyScrollController,
                                onRefresh: () async {
                                  await _controller.loadData(isRefresh: true);
                                },
                                buildLoadingIndicator: buildLoadingIndicator,
                                onDelete: harcamaSil,
                                onEdit: _handleExpenseEdit,
                                kategoriIkonlari: widget.kategoriIkonlari,
                                tumOdemeYontemleri: widget.tumOdemeYontemleri,
                                gosterilenHarcamalar:
                                    gosterilenHarcamalarContext,
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
      ),
    );
  }

  void _showVoiceInput() {
    final callbacks = ExpenseVoiceCallbacks(
      tumHarcamalar: widget.tumHarcamalar,
      gosterilenHarcamalar: gosterilenHarcamalar,
      secilenAy: secilenAy,
      butceLimiti: widget.butceLimiti,
      userId: widget.userId ?? '',
      onHarcamalarChanged: widget.onHarcamalarChanged,
      onFiltrele: filtreleVeGoster,
      snackBarContext: context,
    );

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

          showExpenseAddedSnackBar(
            context,
            name,
            amount,
            CurrencyFormatter.format(amount),
            context.l10n.added,
            context.l10n.expense,
          );
        },
        onDeleteLastExpense: () async => callbacks.deleteLastExpense(),
        onGetMonthlyTotal: () => callbacks.monthlyTotal,
        onGetTopCategory: () => callbacks.topCategory,
        onGetWeeklyTotal: () => callbacks.weeklyTotal,
        onGetDailyTotal: () => callbacks.dailyTotal,
        onGetLastExpenses: () => callbacks.lastExpenses,
        onCheckBudget: () => callbacks.budgetStatus,
        onGetCategoryTotal: (kategori) => callbacks.categoryTotal(kategori),
        onAddFixedExpenses: () async => callbacks.addFixedExpenses(),
        onEditLastExpense: (yeniTutar) async =>
            callbacks.editLastExpense(yeniTutar),
        onGetDateRangeTotal: (baslangic, bitis) =>
            callbacks.dateRangeTotal(baslangic, bitis),
        onGetDateRangeCategoryTotal: (baslangic, bitis, kategori) =>
            callbacks.dateRangeCategoryTotal(baslangic, bitis, kategori),
      ),
    );
  }
}
