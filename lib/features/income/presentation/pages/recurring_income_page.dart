import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../../../payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/currency_service.dart';
import '../controllers/incomes_controller.dart';

/// Tekrarlayan Gelirler yönetim sayfası (maaş, kira geliri vb.)
class RecurringIncomePage extends StatefulWidget {
  final String userId;
  final IncomesController? controller;

  const RecurringIncomePage({super.key, required this.userId, this.controller});

  @override
  State<RecurringIncomePage> createState() => _RecurringIncomePageState();
}

class _RecurringIncomePageState extends State<RecurringIncomePage> {
  // Controller veya yerel state
  IncomesController? _controller;
  List<Map<String, dynamic>> _localTekrarlayanGelirler = [];
  List<PaymentMethod> _localOdemeYontemleri = [];

  List<Map<String, dynamic>> get _tekrarlayanGelirler =>
      _controller?.tekrarlayanGelirler ?? _localTekrarlayanGelirler;
  List<PaymentMethod> get _odemeYontemleri =>
      _controller?.tumOdemeYontemleri.where((pm) => !pm.isDeleted).toList() ??
      _localOdemeYontemleri;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onStateChanged);
    _verileriYukle();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onStateChanged);
    super.dispose();
  }

  void _verileriYukle() {
    final incomeRepo = getIt<IncomeRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();

    final gelirler = incomeRepo.getRecurringIncomes(widget.userId);
    final pmVerileri = paymentRepo.getPaymentMethods(widget.userId);
    final pmList = pmVerileri
        .map((m) => PaymentMethod.fromMap(m))
        .where((pm) => !pm.isDeleted)
        .toList();

    if (_controller != null) {
      _controller!.setTekrarlayanGelirler(gelirler);
      // Ödeme yöntemleri controller'dan alınıyor
    } else {
      _localTekrarlayanGelirler = gelirler;
      _localOdemeYontemleri = pmList;
      setState(() {});
    }
  }

  void _kaydet() {
    try {
      getIt<IncomeRepository>().saveRecurringIncomes(
        widget.userId,
        _tekrarlayanGelirler,
      );
    } catch (e) {
      if (!mounted) return;
      if (e is AppException) {
        ErrorHandler.handleAppException(context, e);
      } else {
        ErrorHandler.showErrorSnackBar(context, context.l10n.errorWhileSaving);
      }
    }
  }

  void _gelirEkle() {
    _bottomSheetGoster();
  }

  void _gelirDuzenle(int index) {
    _bottomSheetGoster(gelir: _tekrarlayanGelirler[index], index: index);
  }

  void _bottomSheetGoster({Map<String, dynamic>? gelir, int? index}) {
    final isimController = TextEditingController(text: gelir?['isim'] ?? '');
    final tutarController = TextEditingController(
      text: gelir?['tutar']?.toString() ?? '',
    );
    int secilenGun = gelir?['gun'] ?? 1;
    String? secilenOdemeYontemiId = gelir?['odemeYontemiId'];
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gelir == null
                        ? context.l10n.newRecurringIncome
                        : context.l10n.editIncome,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // İsim
                  TextFormField(
                    controller: isimController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.incomeNamePlaceholder,
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.label_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.incomeNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tutar
                  TextFormField(
                    controller: tutarController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText:
                          'Tutar (${getIt<CurrencyService>().currentSymbol})',
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.currency_lira,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.amountRequired;
                      }
                      final tutar = double.tryParse(value.replaceAll(',', '.'));
                      if (tutar == null || tutar <= 0) {
                        return context.l10n.enterValidAmount;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gün Seçimi
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.everyMonthOn,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: secilenGun,
                            dropdownColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            items: List.generate(28, (i) => i + 1)
                                .map(
                                  (gun) => DropdownMenuItem(
                                    value: gun,
                                    child: Text(
                                      context.l10n.dayOfMonth(gun),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setSheetState(() {
                                  secilenGun = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ödeme Yöntemi (Hangi hesaba yatacak)
                  DropdownButtonFormField<String>(
                    initialValue: secilenOdemeYontemiId,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    decoration: InputDecoration(
                      labelText: context.l10n.selectAccount,
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    items: _odemeYontemleri
                        .map(
                          (pm) => DropdownMenuItem(
                            value: pm.id,
                            child: Text(
                              pm.lastFourDigits != null
                                  ? '${pm.name} ****${pm.lastFourDigits}'
                                  : pm.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setSheetState(() {
                        secilenOdemeYontemiId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return context.l10n.selectPaymentMethod;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final yeniGelir = {
                            'id':
                                gelir?['id'] ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            'isim': isimController.text.trim(),
                            'tutar': double.parse(
                              tutarController.text.replaceAll(',', '.'),
                            ),
                            'kategori': 'Tekrarlayan Gelirler',
                            'gun': secilenGun,
                            'odemeYontemiId': secilenOdemeYontemiId,
                            'sonIslemTarihi': gelir?['sonIslemTarihi'],
                          };

                          if (index != null) {
                            if (_controller != null) {
                              _controller!.updateTekrarlayanGelir(
                                index,
                                yeniGelir,
                              );
                            } else {
                              _localTekrarlayanGelirler[index] = yeniGelir;
                            }
                          } else {
                            if (_controller != null) {
                              _controller!.addTekrarlayanGelir(yeniGelir);
                            } else {
                              _localTekrarlayanGelirler.add(yeniGelir);
                            }
                          }
                          _kaydet();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                index != null
                                    ? context.l10n.incomeUpdated
                                    : context.l10n.incomeAdded,
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                        }
                      },
                      child: Text(
                        gelir == null ? context.l10n.add : context.l10n.update,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getOdemeYontemiAdi(String? id) {
    if (id == null) return context.l10n.notSpecified;
    final pm = _odemeYontemleri.firstWhere(
      (p) => p.id == id,
      orElse: () => PaymentMethod(
        id: '',
        name: context.l10n.unknown,
        type: 'banka',
        balance: 0,
        createdAt: DateTime.now(),
      ),
    );
    return pm.lastFourDigits != null
        ? '${pm.name} ****${pm.lastFourDigits}'
        : pm.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.recurringIncomesTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gelirEkle,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bilgi Kartı
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.recurringIncomeInfo,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),

          // Liste
          Expanded(
            child: _tekrarlayanGelirler.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.noRecurringIncomes,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.tapPlusToAdd,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tekrarlayanGelirler.length,
                    itemBuilder: (context, index) {
                      final gelir = _tekrarlayanGelirler[index];
                      return _buildGelirKarti(gelir, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGelirKarti(Map<String, dynamic> gelir, int index) {
    final gun = gelir['gun'] ?? 1;
    final tutar = (gelir['tutar'] as num?)?.toDouble() ?? 0;
    final odemeYontemi = _getOdemeYontemiAdi(gelir['odemeYontemiId']);

    return Dismissible(
      key: Key(gelir['id']?.toString() ?? index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ColorConstants.kirmiziVurgu,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              context.l10n.deleteIncome,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              context.l10n.deleteIncomeConfirm(gelir['isim'] ?? ''),
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  context.l10n.delete,
                  style: const TextStyle(color: ColorConstants.kirmiziVurgu),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (_controller != null) {
          _controller!.removeTekrarlayanGelirAt(index);
        } else {
          _localTekrarlayanGelirler.removeAt(index);
        }
        _kaydet();
      },
      child: GestureDetector(
        onTap: () => _gelirDuzenle(index),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gelir['isim'] ?? context.l10n.unnamed,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.everyMonthDayOf(gun, odemeYontemi),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                () {
                  final pb = gelir['paraBirimi']?.toString() ?? 'TRY';
                  final cur = getIt<CurrencyService>();
                  final converted = cur.convert(tutar, pb, cur.currentCurrency);
                  return '+${CurrencyFormatter.format(converted)}';
                }(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
