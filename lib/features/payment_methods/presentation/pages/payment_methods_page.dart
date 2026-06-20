// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/shimmer_loading.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../../data/models/payment_method_model.dart';
import '../../data/models/transfer_model.dart';
import '../../../income/data/models/income_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/injection_container.dart';
import 'package:cashly/core/constants/color_constants.dart';
import '../widgets/realistic_payment_card.dart';
import 'payment_method_recycle_bin_page.dart';
import 'add_payment_method_page.dart';
import 'payment_method_detail_page.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

import '../controllers/payment_methods_controller.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';

class PaymentMethodsPage extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final List<PaymentMethod> deletedPaymentMethods;
  final Function(PaymentMethod) onDelete;
  final Function(PaymentMethod) onEdit;
  final Function(PaymentMethod) onRestore;
  final Function(PaymentMethod) onPermanentDelete;
  final VoidCallback onEmptyBin;
  final Function(PaymentMethod)? onCardTap;
  final String? userName;
  final String? userProfileUrl;
  final Function(PaymentMethod) onAdd;
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Transfer> transferler;

  const PaymentMethodsPage({
    super.key,
    required this.paymentMethods,
    required this.deletedPaymentMethods,
    required this.onDelete,
    required this.onEdit,
    required this.onRestore,
    required this.onPermanentDelete,
    required this.onEmptyBin,
    required this.onAdd,
    required this.harcamalar,
    required this.gelirler,
    required this.transferler,
    this.onCardTap,
    this.userName,
    this.userProfileUrl,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final TextEditingController _aramaController = TextEditingController();
  // Debouncer - arama performansı için
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 300),
  );

  // Controller - DI'dan alınır
  late final PaymentMethodsController _controller;

  @override
  void initState() {
    super.initState();

    final authController = getIt<AuthController>();
    final userId = authController.currentUser?.id ?? '';
    _controller = getIt<PaymentMethodsController>(param1: userId);

    // Widget prop'larından veriyi controller'a yükle
    _controller.initData(widget.paymentMethods, widget.deletedPaymentMethods);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.stopLoading();
    });
  }

  @override
  void didUpdateWidget(covariant PaymentMethodsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paymentMethods != oldWidget.paymentMethods) {
      _controller.initData(widget.paymentMethods, widget.deletedPaymentMethods);
    }
  }

  void _filtrele() {
    _controller.aramaMetni = _aramaController.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    _aramaController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PaymentMethodsController>.value(
      value: _controller,
      child: Builder(
        builder: (context) {
          final aramaModu = context.select(
            (PaymentMethodsController c) => c.aramaModu,
          );
          final isLoading = context.select(
            (PaymentMethodsController c) => c.isLoading,
          );
          final filteredMethods = context.select(
            (PaymentMethodsController c) => c.filteredMethods,
          );
          final deletedPaymentMethods = context.select(
            (PaymentMethodsController c) => c.deletedPaymentMethods,
          );

          return Scaffold(
            appBar: AppBar(
              title: aramaModu
                  ? TextField(
                      controller: _aramaController,
                      onChanged: (value) =>
                          _searchDebouncer.run(() => _filtrele()),
                      autofocus: true,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchPaymentMethod,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Text(context.l10n.myPaymentMethods),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip: context.l10n.trashBin,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentMethodRecycleBinPage(
                          deletedPaymentMethods: deletedPaymentMethods,
                          onRestore: (pm) async {
                            try {
                              await _controller.restoreMethod(pm);
                              widget.onRestore(pm);
                            } catch (e) {
                              if (!mounted) return;
                              if (e is AppException) {
                                ErrorHandler.handleAppException(context, e);
                              }
                            }
                          },
                          onPermanentDelete: (pm) async {
                            try {
                              await _controller.permanentDelete(pm);
                              widget.onPermanentDelete(pm);
                            } catch (e) {
                              if (!mounted) return;
                              if (e is AppException) {
                                ErrorHandler.handleAppException(context, e);
                              }
                            }
                          },
                          onEmptyBin: () async {
                            try {
                              await _controller.emptyBin();
                              widget.onEmptyBin();
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
                  },
                ),
                IconButton(
                  icon: Icon(
                    aramaModu ? Icons.close : Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    _controller.aramaModu = !aramaModu;
                    if (!aramaModu) {
                      _aramaController.clear();
                      _controller.aramaMetni = '';
                    }
                  },
                ),
              ],
            ),
            body: isLoading
                ? const PaymentMethodsPageSkeleton()
                : RefreshIndicator(
                    onRefresh: () async {
                      // Verileri yeniden yükle
                      _controller.refresh();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    child: SingleChildScrollView(
                      // RefreshIndicator çalışması için physics gerekli
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Toplam Özet Kartı - Kingmode Carousel
                          _buildPaymentMethodsList(filteredMethods, aramaModu),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodsList(
    List<PaymentMethod> filteredMethods,
    bool aramaModu,
  ) {
    if (filteredMethods.isEmpty) {
      return aramaModu && _aramaController.text.isNotEmpty
          ? EmptyStateWidget(
              icon: Icons.search_off,
              title: context.l10n.noResultsFound,
              subtitle: context.l10n.tryDifferentSearchTerm,
            )
          : EmptyStateWidget(
              icon: Icons.credit_card_off,
              title: context.l10n.noPaymentMethodYet,
              subtitle: context.l10n.startByAddingFirstPaymentMethod,
              iconColor: Colors.orange,
            );
    }

    return PaymentMethodSlider(
      methods: filteredMethods,
      harcamalar: widget.harcamalar,
      gelirler: widget.gelirler,
      transferler: widget.transferler,
      controller: _controller,
      onDelete: widget.onDelete,
      onEdit: widget.onEdit,
      onCardTap:
          widget.onCardTap ??
          (pm) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentMethodDetailPage(
                  paymentMethod: pm,
                  harcamalar: widget.harcamalar,
                  gelirler: widget.gelirler,
                  transferler: widget.transferler,
                  tumOdemeYontemleri: _controller.paymentMethods,
                  controller: _controller,
                  onDelete: (deletedPm) {
                    widget.onDelete(deletedPm);
                  },
                  onEdit: (editedPm) {
                    widget.onEdit(editedPm);
                  },
                ),
              ),
            );
          },
      onAddCard: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPaymentMethodPage(
              onSave:
                  (
                    name,
                    type,
                    lastFourDigits,
                    balance,
                    limit,
                    colorIndex,
                  ) async {
                    try {
                      final newPm = PaymentMethod(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        type: type,
                        lastFourDigits: lastFourDigits,
                        balance: balance,
                        limit: limit,
                        colorIndex: colorIndex,
                        createdAt: DateTime.now(),
                        isDeleted: false,
                        paraBirimi: getIt<CurrencyService>().currentCurrency,
                      );
                      await _controller.addMethod(newPm);
                      widget.onAdd(newPm);
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
      },
    );
  }
}

/// Ödeme yöntemi kartı — ayrı StatelessWidget olarak izole edildi.
/// [RepaintBoundary] ile repaint izolasyonu ve her rebuild'de yeni nesne
/// oluşturma maliyeti önlendi.

class PaymentMethodSlider extends StatefulWidget {
  final List<PaymentMethod> methods;
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Transfer> transferler;
  final PaymentMethodsController controller;
  final Function(PaymentMethod) onDelete;
  final Function(PaymentMethod) onEdit;
  final Function(PaymentMethod)? onCardTap;
  final VoidCallback onAddCard;

  const PaymentMethodSlider({
    super.key,
    required this.methods,
    required this.harcamalar,
    required this.gelirler,
    required this.transferler,
    required this.controller,
    required this.onDelete,
    required this.onEdit,
    required this.onAddCard,
    this.onCardTap,
  });

  @override
  State<PaymentMethodSlider> createState() => _PaymentMethodSliderState();
}

class _PaymentMethodSliderState extends State<PaymentMethodSlider> {
  int _currentIndex = 0;
  late PageController _pageController;

  Widget _buildCardAnalysis(PaymentMethod pm) {
    final now = DateTime.now();
    double totalIncome = 0;
    double totalExpense = 0;
    final cur = getIt<CurrencyService>();

    for (var g in widget.gelirler) {
      if (g.paymentMethodId == pm.id &&
          g.date.month == now.month &&
          g.date.year == now.year) {
        totalIncome += cur.convert(g.amount, g.paraBirimi, cur.currentCurrency);
      }
    }
    for (var h in widget.harcamalar) {
      final date = DateTime.tryParse(h['tarih']?.toString() ?? '');
      if (h['odemeYontemiId'] == pm.id &&
          date != null &&
          date.month == now.month &&
          date.year == now.year) {
        final amount = (h['tutar'] as num?)?.toDouble() ?? 0;
        // Harcamanın kendi para birimini kullan (örn. USD girilmiş harcama TL'ye çevrilir)
        final expenseCurrency =
            h['paraBirimi']?.toString() ?? cur.currentCurrency;
        totalExpense += cur.convert(
          amount,
          expenseCurrency,
          cur.currentCurrency,
        );
      }
    }

    final total = totalIncome + totalExpense;
    final incomeRatio = total > 0 ? totalIncome / total : 0.5;
    final expenseRatio = total > 0 ? totalExpense / total : 0.5;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bu Ayki Durum',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gelir',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(totalIncome),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.yesil,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Gider',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(totalExpense),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.kirmiziVurgu,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    Expanded(
                      flex: (incomeRatio * 100).toInt(),
                      child: Container(height: 8, color: ColorConstants.yesil),
                    ),
                    Expanded(
                      flex: (expenseRatio * 100).toInt(),
                      child: Container(
                        height: 8,
                        color: ColorConstants.kirmiziVurgu,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(PaymentMethod pm) {
    final cur = getIt<CurrencyService>();
    final List<Map<String, dynamic>> recent = [];

    for (var g in widget.gelirler) {
      if (g.paymentMethodId == pm.id) {
        recent.add({
          'title': g.name,
          'amount': g.amount,
          'date': g.date,
          'type': 'gelir',
          'currency': g.paraBirimi,
        });
      }
    }
    for (var h in widget.harcamalar) {
      if (h['odemeYontemiId'] == pm.id && h['silindi'] != true) {
        final date = DateTime.tryParse(h['tarih']?.toString() ?? '');
        if (date != null) {
          recent.add({
            'title': h['isim'] ?? 'Harcama',
            'amount': (h['tutar'] as num?)?.toDouble() ?? 0.0,
            'date': date,
            'type': 'gider',
            'currency': cur.currentCurrency,
          });
        }
      }
    }

    recent.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
    final top3 = recent.take(3).toList();

    if (top3.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Son Islemler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ...top3.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          t['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        (t['type'] == 'gelir' ? '+' : '-') +
                            CurrencyFormatter.format(
                              cur.convert(
                                t['amount'] as double,
                                t['currency'] as String,
                                cur.currentCurrency,
                              ),
                            ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: t['type'] == 'gelir'
                              ? ColorConstants.yesil
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const isObscured = false; // or read from DashboardController if needed

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.methods.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.methods.length) {
                return GestureDetector(
                  onTap: widget.onAddCard,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                        style: BorderStyle.none,
                      ),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.05),
                    ),
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                        borderRadius: 20,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Yeni Kart Ekle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return RealisticPaymentCard(
                pm: widget.methods[index],
                onCardTap: widget.onCardTap,
                isObscured: isObscured,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.methods.length + 1,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        if (_currentIndex < widget.methods.length) ...[
          _buildCardAnalysis(widget.methods[_currentIndex]),
          _buildRecentTransactions(widget.methods[_currentIndex]),
        ],
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    const double dashWidth = 8.0;
    const double dashSpace = 6.0;
    double distance = 0.0;

    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
