// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/constants/card_color_constants.dart';
import 'package:cashly/core/widgets/skeleton_widget.dart';
import 'package:cashly/core/utils/amount_input_formatter.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../../data/models/payment_method_model.dart';
import 'add_payment_method_page.dart';
import '../widgets/payment_method_summary_card.dart';
import 'payment_method_recycle_bin_page.dart';
import '../../../../core/di/injection_container.dart';
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
  final Function(
    String name,
    String type,
    String? lastFourDigits,
    double balance,
    double? limit,
    int colorIndex,
  )
  onAdd;

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

  // Getter'lar
  bool get _aramaModu => _controller.aramaModu;
  bool get _isLoading => _controller.isLoading;

  List<PaymentMethod> get _filteredMethods => _controller.filteredMethods;
  List<PaymentMethod> get _deletedPaymentMethods =>
      _controller.deletedPaymentMethods;

  @override
  void initState() {
    super.initState();

    final authController = getIt<AuthController>();
    final userId = authController.currentUser?.id ?? '';
    _controller = getIt<PaymentMethodsController>(param1: userId);
    _controller.addListener(_onStateChanged);

    // Widget prop'larından veriyi controller'a yükle
    _controller.initData(widget.paymentMethods, widget.deletedPaymentMethods);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.stopLoading();
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
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
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _aramaController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  double get totalBalance => _controller.totalBalance;
  double get totalDebt => _controller.totalDebt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: _aramaModu
            ? TextField(
                controller: _aramaController,
                onChanged: (value) => _searchDebouncer.run(() => _filtrele()),
                autofocus: true,
                style: const TextStyle(color: Colors.white),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: context.l10n.trashBin,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentMethodRecycleBinPage(
                    deletedPaymentMethods: _deletedPaymentMethods,
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
              ).then((_) {
                if (mounted) setState(() {});
              });
            },
          ),
          IconButton(
            icon: Icon(
              _aramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              _controller.aramaModu = !_aramaModu;
              if (!_aramaModu) {
                _aramaController.clear();
                _controller.aramaMetni = '';
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const PaymentMethodsPageSkeleton()
          : RefreshIndicator(
              onRefresh: () async {
                // Verileri yeniden yükle
                _controller.refresh();
              },
              color: Theme.of(context).colorScheme.secondary,
              child: SingleChildScrollView(
                // RefreshIndicator çalışması için physics gerekli
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Toplam Özet Kartı - Kingmode Carousel
                    PaymentMethodSummaryCard(
                      totalBalance: totalBalance,
                      totalDebt: totalDebt,
                      userName: widget.userName ?? 'Kullanıcı',
                      userProfileUrl: widget.userProfileUrl,
                      paymentMethods: _filteredMethods,
                    ),
                    const SizedBox(height: 24),
                    _buildPaymentMethodsList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
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
                        );
                        await _controller.addMethod(newPm);
                        widget.onAdd(
                          name,
                          type,
                          lastFourDigits,
                          balance,
                          limit,
                          colorIndex,
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
          ).then((_) {
            if (mounted) setState(() {}); // Sayfadan dönünce state'i yenile
          });
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text(
          context.l10n.addCard,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    if (_filteredMethods.isEmpty) {
      return _aramaModu && _aramaController.text.isNotEmpty
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredMethods.length,
      // itemExtent: Sabit yükseklik belirterek scroll performansını artırır
      // Her kart 140px yükseklik + 16px bottom margin = 156px
      itemExtent: 156,
      itemBuilder: (context, index) {
        final pm = _filteredMethods[index];
        return _buildPaymentMethodCard(pm);
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod pm) {
    final colors = CardColorConstants
        .gradients[pm.colorIndex.clamp(0, CardColorConstants.count - 1)];

    // RepaintBoundary: Bu kartın repaint'ini izole eder
    return RepaintBoundary(
      child: Dismissible(
        key: Key(pm.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: ColorConstants.koyuKirmizi,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) async {
          try {
            await _controller.moveToBin(pm);
            widget.onDelete(pm);
          } catch (e) {
            if (!mounted) return;
            if (e is AppException) {
              ErrorHandler.handleAppException(context, e);
            }
          }
        },
        child: GestureDetector(
          onTap: () {
            // Detay sayfasına yönlendir (eğer callback tanımlıysa)
            if (widget.onCardTap != null) {
              widget.onCardTap!(pm);
            }
          },
          onLongPress: () {
            // Düzenleme sayfasına git
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPaymentMethodPage(
                  paymentMethod: pm,
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
                          final updatedPm = PaymentMethod(
                            id: pm.id,
                            name: name,
                            type: type,
                            lastFourDigits: lastFourDigits,
                            balance: balance,
                            limit: limit,
                            colorIndex: colorIndex,
                            createdAt: pm.createdAt,
                            isDeleted: false,
                          );
                          await _controller.updateMethod(updatedPm);
                          widget.onEdit(updatedPm);
                        } catch (e) {
                          if (!mounted) return;
                          if (e is AppException) {
                            ErrorHandler.handleAppException(context, e);
                          }
                        }
                      },
                ),
              ),
            ).then((_) {
              if (mounted) setState(() {}); // Sayfadan dönünce state'i yenile
            });
          },
          child: Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Üst satır
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.translateDbName(pm.typeDisplayName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        pm.type == 'nakit'
                            ? Icons.wallet
                            : pm.type == 'kredi'
                            ? Icons.credit_card
                            : Icons.account_balance,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ],
                  ),
                  // Kart numarası
                  if (pm.type != 'nakit' && pm.lastFourDigits != null)
                    Text(
                      '•••• •••• •••• ${pm.lastFourDigits}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  // Alt satır
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translateDbName(pm.name).toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                          if (pm.type == 'kredi' && pm.limit != null)
                            Text(
                              'Limit: ${AmountInputFormatter.formatInitialValue(pm.limit!).replaceAll(',00', '')} ₺',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            pm.type == 'kredi'
                                ? context.l10n.debt
                                : context.l10n.balanceLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${AmountInputFormatter.formatInitialValue(pm.balance)} ₺',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
