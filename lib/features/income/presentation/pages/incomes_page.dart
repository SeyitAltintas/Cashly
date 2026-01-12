import 'package:flutter/material.dart';
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
import '../widgets/income_summary_card.dart';
import '../widgets/income_list_item.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../state/income_page_state.dart';

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

  // State yönetimi için ChangeNotifier
  late final IncomePageState _pageState;

  // Getter'lar
  bool get gelirAramaModu => _pageState.aramaModu;
  bool get _isLoading => _pageState.isLoading;
  DateTime get secilenAy => _pageState.secilenAy;

  @override
  void initState() {
    super.initState();

    _pageState = IncomePageState();
    _pageState.secilenAy = widget.secilenAy;
    _pageState.tumGelirler = widget.tumGelirler;
    _pageState.tumOdemeYontemleri = widget.tumOdemeYontemleri;
    _pageState.addListener(_onStateChanged);

    initLazyLoading();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _pageState.stopLoading();
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
    _pageState.secilenAy = DateTime(secilenAy.year, secilenAy.month - 1, 1);
  }

  void sonrakiAy() {
    _pageState.secilenAy = DateTime(secilenAy.year, secilenAy.month + 1, 1);
  }

  void _ayYilSeciciAc() async {
    // Ortak MonthYearPicker widget'ını kullan
    final selectedDate = await MonthYearPicker.show(
      context,
      initialDate: secilenAy,
      accentColor: Colors.green,
    );

    if (selectedDate != null && mounted) {
      _pageState.secilenAy = selectedDate;
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

          _pageState.addIncome(yeniGelir);

          // Bakiye güncelleme - mevcut ödeme yöntemi seçimi yok
          // bu yüzden sadece geliri ekliyoruz

          // Callback'i çağır
          widget.onGelirlerChanged(widget.tumGelirler);

          // Bildirim göster
          AppSnackBar.success(
            context,
            '$name eklendi: ${amount.toStringAsFixed(0)} ₺',
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

    PaymentMethod? pm;
    if (pmIndex != null && pmIndex != -1) {
      pm = widget.tumOdemeYontemleri[pmIndex];
    }

    _pageState.deleteIncome(income, pm: pm, pmIndex: pmIndex);

    widget.onGelirlerChanged(widget.tumGelirler);
    widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

    // Geri Al özelliği ile SnackBar göster
    AppSnackBar.deleted(
      context,
      'Gelir çöp kutusuna taşındı 🗑️',
      onUndo: () {
        // Sayfa hala aktif mi kontrol et
        if (!mounted) return;

        // Silme işlemini geri al
        _pageState.undoDelete(
          income,
          wasDeleted: eskiIsDeleted,
          pm: pm,
          pmIndex: pmIndex,
          oldBalance: eskiBakiye,
        );
        widget.onGelirlerChanged(widget.tumGelirler);
        widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

        // Geri alındı bildirimi
        AppSnackBar.success(context, 'Gelir geri yüklendi ✅');
      },
    );
  }

  void gelirDuzenle(Income income) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIncomePage(
          incomeToEdit: income.toMap(),
          categories: widget.gelirKategoriIkonlari,
          paymentMethods: widget.tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          onSave: (name, amount, category, date, paymentMethodId) {
            _pageState.updateIncome(
              income: income,
              name: name,
              amount: amount,
              category: category,
              date: date,
              paymentMethodId: paymentMethodId,
            );

            widget.onGelirlerChanged(widget.tumGelirler);
            widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);
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
          paymentMethods: widget.tumOdemeYontemleri
              .where((pm) => !pm.isDeleted)
              .toList(),
          onSave: (name, amount, category, date, paymentMethodId) {
            _pageState.addIncomeWithPayment(
              name: name,
              amount: amount,
              category: category,
              date: date,
              paymentMethodId: paymentMethodId,
            );

            widget.onGelirlerChanged(widget.tumGelirler);
            widget.onOdemeYontemleriChanged(widget.tumOdemeYontemleri);

            AppSnackBar.success(
              context,
              'Gelir eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
            );
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
                _pageState.secilenAy = DateTime.now();
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
              _pageState.aramaModu = !gelirAramaModu;
              if (!gelirAramaModu) {
                tGelirArama.clear();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const IncomePageSkeleton()
          : Column(
              children: [
                // Özet Kartı
                if (!gelirAramaModu)
                  // Özet Kartı
                  if (!gelirAramaModu)
                    IncomeSummaryCard(
                      ayIsmi: ayIsmi,
                      toplamGelir: toplamGelir,
                      oncekiAy: oncekiAy,
                      sonrakiAy: sonrakiAy,
                      ayYilSeciciAc: _ayYilSeciciAc,
                      gelirSayisi: gelirler.length,
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
                      : RefreshIndicator(
                          onRefresh: () async {
                            // State'i yenile
                            _pageState.refresh();
                          },
                          color: Colors.green,
                          child: ListView.builder(
                            controller: lazyScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: gelirler.length + (hasMoreItems ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Son item ise ve daha fazla veri varsa loading göster
                              if (index >= gelirler.length) {
                                return buildLoadingIndicator();
                              }

                              final gelir = gelirler[index];
                              return IncomeListItem(
                                income: gelir,
                                categoryIcon: widget
                                    .gelirKategoriIkonlari[gelir.category],
                                itemIndex: index,
                                onDelete: () => gelirSil(gelir),
                                onTap: () => gelirDuzenle(gelir),
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
                      GelirCopKutusuSayfasi(userId: widget.userId ?? ''),
                ),
              ).then((_) {
                if (mounted) _pageState.refresh();
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
