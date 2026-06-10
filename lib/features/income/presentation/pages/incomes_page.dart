// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../income/presentation/pages/add_income_page.dart';
import '../../../income/presentation/widgets/income_voice_input_sheet.dart';
import '../../../income/presentation/pages/income_recycle_bin_page.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../../../core/widgets/app_floating_bottom_bar.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';
import '../../../../core/utils/debouncer.dart';
import '../widgets/income_summary_card.dart';
import 'package:cashly/features/income/presentation/widgets/incomes_list_view.dart';
import 'package:cashly/features/income/presentation/widgets/incomes_app_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/services/currency_service.dart';
import '../controllers/incomes_controller.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/currency_formatter.dart';

class IncomesPage extends StatefulWidget {
  final List<Income> tumGelirler;
  final List<PaymentMethod> tumOdemeYontemleri;
  final Map<String, IconData> gelirKategoriIkonlari;
  final DateTime secilenAy;
  final String? userId;
  final Function(List<Income>) onGelirlerChanged;
  final Function(List<PaymentMethod>) onOdemeYontemleriChanged;
  final Function(DateTime)? onMonthChanged;

  const IncomesPage({
    super.key,
    required this.tumGelirler,
    required this.tumOdemeYontemleri,
    required this.gelirKategoriIkonlari,
    required this.secilenAy,
    required this.userId,
    required this.onGelirlerChanged,
    required this.onOdemeYontemleriChanged,
    this.onMonthChanged,
  });

  @override
  State<IncomesPage> createState() => _IncomesPageState();
}

class _IncomesPageState extends State<IncomesPage> with LazyLoadingMixin {
  final TextEditingController tGelirArama = TextEditingController();
  // Debouncer - arama performansı için
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 300),
  );

  // Controller - DI'dan alınır
  late final IncomesController _controller;

  // Getter'lar
  bool get gelirAramaModu => _controller.aramaModu;
  DateTime get secilenAy => _controller.secilenAy;

  @override
  void initState() {
    super.initState();

    _controller = getIt<IncomesController>(param1: widget.userId ?? '');
    _controller.secilenAy = widget.secilenAy;

    // Widget prop'larından veriyi controller'a yükle
    _controller.setIncomesFromWidget(
      widget.tumGelirler,
      widget.tumOdemeYontemleri,
    );

    initLazyLoading();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.stopLoading();
    });
  }

  @override
  void didUpdateWidget(IncomesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tumGelirler != oldWidget.tumGelirler ||
        widget.secilenAy != oldWidget.secilenAy) {
      if (widget.secilenAy != oldWidget.secilenAy) {
        _controller.secilenAy = widget.secilenAy;
      }
      _controller.setIncomesFromWidget(
        widget.tumGelirler,
        widget.tumOdemeYontemleri,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    disposeLazyLoading();
    tGelirArama.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  String get ayIsmi {
    return "${context.getMonthName(secilenAy.month)} ${secilenAy.year}";
  }

  void oncekiAy() {
    _controller.secilenAy = DateTime(secilenAy.year, secilenAy.month - 1, 1);
    widget.onMonthChanged?.call(_controller.secilenAy);
  }

  void sonrakiAy() {
    _controller.secilenAy = DateTime(secilenAy.year, secilenAy.month + 1, 1);
    widget.onMonthChanged?.call(_controller.secilenAy);
  }

  void _ayYilSeciciAc() async {
    // Ortak MonthYearPicker widget'ını kullan
    final selectedDate = await MonthYearPicker.show(
      context,
      initialDate: secilenAy,
      accentColor: ColorConstants.yesil,
    );

    if (selectedDate != null && mounted) {
      _controller.secilenAy = selectedDate;
      widget.onMonthChanged?.call(selectedDate);
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

          _controller.addIncome(yeniGelir);

          // Bakiye güncelleme - mevcut ödeme yöntemi seçimi yok
          // bu yüzden sadece geliri ekliyoruz

          // Callback'i çağır
          widget.onGelirlerChanged(_controller.tumGelirler);

          // Bildirim göster
          AppSnackBar.success(
            context,
            '${context.l10n.income} ${context.l10n.added}: $name - ${CurrencyFormatter.format(amount)}',
          );
        },
      ),
    );
  }

  Future<void> gelirSil(Income income) async {
    HapticService.delete(); // Silme haptic feedback

    // Eski değerleri sakla (geri alma için)
    final eskiIsDeleted = income.isDeleted;
    final String? eskiPmId = income.paymentMethodId;
    double? eskiBakiye;
    int? pmIndex;

    if (eskiPmId != null) {
      pmIndex = _controller.tumOdemeYontemleri.indexWhere(
        (p) => p.id == eskiPmId,
      );
      if (pmIndex != -1) {
        eskiBakiye = _controller.tumOdemeYontemleri[pmIndex].balance;
      }
    }

    PaymentMethod? pm;
    if (pmIndex != null && pmIndex != -1) {
      pm = _controller.tumOdemeYontemleri[pmIndex];
    }

    try {
      final deleteFuture = _controller.deleteIncome(
        income,
        pm: pm,
        pmIndex: pmIndex,
      );

      widget.onGelirlerChanged(_controller.tumGelirler);
      widget.onOdemeYontemleriChanged(_controller.tumOdemeYontemleri);

      // Geri Al özelliği ile SnackBar göster
      if (!mounted) return;
      AppSnackBar.deleted(
        context,
        '${context.l10n.income} ${context.l10n.movedToTrash} 🗑️',
        onUndo: () async {
          // Sayfa hala aktif mi kontrol et
          if (!mounted) return;

          try {
            // Silme işlemini geri al
            await _controller.undoDelete(
              income,
              wasDeleted: eskiIsDeleted,
              pm: pm,
              pmIndex: pmIndex,
              oldBalance: eskiBakiye,
            );
            widget.onGelirlerChanged(_controller.tumGelirler);
            widget.onOdemeYontemleriChanged(_controller.tumOdemeYontemleri);

            // Geri alındı bildirimi
            if (mounted) {
              AppSnackBar.success(
                context,
                '${context.l10n.income} ${context.l10n.restored} ✅',
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

      // Hataları arka planda dinle
      await deleteFuture;
    } catch (e) {
      if (!mounted) return;
      if (e is AppException) {
        ErrorHandler.handleAppException(context, e);
      }
    }
  }

  void gelirDuzenle(Income income) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIncomePage(
          incomeToEdit: income.toMap(),
          categories: widget.gelirKategoriIkonlari,
          paymentMethods: _controller.tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
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
                  await _controller.updateIncome(
                    income: income,
                    name: name,
                    amount: amount,
                    category: category,
                    date: date,
                    paymentMethodId: paymentMethodId,
                    paraBirimi: paraBirimi,
                  );

                  widget.onGelirlerChanged(_controller.tumGelirler);
                  widget.onOdemeYontemleriChanged(
                    _controller.tumOdemeYontemleri,
                  );
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

  void yeniGelirEkle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIncomePage(
          categories: widget.gelirKategoriIkonlari,
          paymentMethods: _controller.tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
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
                  await _controller.addIncomeWithPayment(
                    name: name,
                    amount: amount,
                    category: category,
                    date: date,
                    paymentMethodId: paymentMethodId,
                    paraBirimi: paraBirimi,
                  );

                  widget.onGelirlerChanged(_controller.tumGelirler);
                  widget.onOdemeYontemleriChanged(
                    _controller.tumOdemeYontemleri,
                  );

                  if (!mounted) return;
                  AppSnackBar.success(
                    context,
                    '${context.l10n.income} ${context.l10n.added}: $name - ${CurrencyFormatter.format(amount)}',
                  );
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
    return ChangeNotifierProvider<IncomesController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: IncomesAppBar(
          searchController: tGelirArama,
          onSearchChanged: () {
            _searchDebouncer.run(() {
              _controller.filtreleVeGoster(aramaMetni: tGelirArama.text);
            });
          },
          onClearSearch: () {
            tGelirArama.clear();
            _controller.filtreleVeGoster();
          },
          onGoToToday: () {
            _controller.secilenAy = DateTime.now();
          },
        ),
        body: Builder(
          builder: (context) {
            final isLoadingContext = context.select(
              (IncomesController c) => c.isLoading,
            );
            final gelirAramaModuContext = context.select(
              (IncomesController c) => c.aramaModu,
            );
            final filteredGelirler = context.select(
              (IncomesController c) => c.filteredGelirler,
            );

            final cur = getIt<CurrencyService>();
            final hesaplananToplamGelir = filteredGelirler.fold(
              0.0,
              (sum, g) =>
                  sum +
                  cur.convert(g.amount, g.paraBirimi, cur.currentCurrency),
            );

            return isLoadingContext
                ? const IncomePageSkeleton()
                : Column(
                    children: [
                      // Özet Kartı
                      if (!gelirAramaModuContext)
                        IncomeSummaryCard(
                          ayIsmi: ayIsmi,
                          toplamGelir: hesaplananToplamGelir,
                          oncekiAy: oncekiAy,
                          sonrakiAy: sonrakiAy,
                          ayYilSeciciAc: _ayYilSeciciAc,
                          gelirSayisi: filteredGelirler.length,
                          gelirHedefi: context.select(
                            (IncomesController c) => c.incomeTarget,
                          ),
                        ),

                      // Gelir listesi
                      Expanded(
                        child: filteredGelirler.isEmpty
                            ? gelirAramaModuContext
                                  ? EmptyStateWidget(
                                      icon: Icons.search_off,
                                      title: context.l10n.noResultsFound,
                                      subtitle:
                                          context.l10n.tryDifferentSearchTerm,
                                    )
                                  : EmptyStateWidget.noIncomes(context)
                            : IncomesListView(
                                gelirler: filteredGelirler,
                                hasMoreItems: hasMoreItems,
                                scrollController: lazyScrollController,
                                onRefresh: () async {
                                  await _controller.loadData(isRefresh: true);
                                },
                                buildLoadingIndicator: buildLoadingIndicator,
                                onDelete: gelirSil,
                                onEdit: gelirDuzenle,
                                kategoriIkonlari: widget.gelirKategoriIkonlari,
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
                    builder: (context) => GelirCopKutusuSayfasi(
                      userId: widget.userId ?? '',
                      controller: _controller,
                    ),
                  ),
                ).then((_) {
                  if (mounted) _controller.refresh();
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
          centerButtonColor: ColorConstants.yesil,
          onCenterButtonTap: () {
            HapticService.lightImpact();
            yeniGelirEkle();
          },
        ),
      ),
    );
  }
}
