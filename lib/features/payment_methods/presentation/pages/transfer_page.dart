import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/transfer_model.dart';
import '../../domain/transfer_schedule_policy.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../controllers/payment_methods_controller.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/widgets/balance_warning_dialog.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/constants/color_constants.dart';

class TransferPage extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final List<Transfer> transfers;
  final String? userId;
  final PaymentMethodsController? controller;
  final Function(String fromId, String toId, double amount, DateTime date)
  onTransfer;
  final Function(Transfer transfer)? onDeleteTransfer;

  const TransferPage({
    super.key,
    required this.paymentMethods,
    required this.transfers,
    required this.onTransfer,
    this.userId,
    this.controller,
    this.onDeleteTransfer,
  });

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  // Sabitlenen Ana Renk
  final Color _primaryColor = const Color.fromARGB(255, 0, 123, 110);

  // Controller veya yerel state
  PaymentMethodsController? _controller;
  String? _localFromAccountId;
  String? _localToAccountId;
  DateTime _localSelectedDate = DateTime.now();
  String? _localSuccessMessage;
  List<PaymentMethod> _localPaymentMethods = [];

  // Getter'lar
  String? get _fromAccountId =>
      _controller?.transferFromAccountId ?? _localFromAccountId;
  String? get _toAccountId =>
      _controller?.transferToAccountId ?? _localToAccountId;
  DateTime get _selectedDate =>
      _controller?.transferSelectedDate ?? _localSelectedDate;
  String? get _successMessage =>
      _controller?.transferSuccessMessage ?? _localSuccessMessage;
  List<PaymentMethod> get _paymentMethods =>
      _controller?.odemeYontemleri ?? _localPaymentMethods;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onFormStateChanged);

    // Widget'tan kopyala (derin kopya)
    if (_controller == null) {
      _localPaymentMethods = widget.paymentMethods
          .map((pm) => pm.copyWith())
          .toList();
    }
  }

  void _onFormStateChanged() {
    if (mounted) setState(() {});
  }

  /// Seçilen tarih ve saat şu andan ileri mi?
  bool get _isScheduled {
    return TransferSchedulePolicy.isScheduled(selectedDate: _selectedDate);
  }

  // İşlem geçmişi için ScrollController
  final ScrollController _historyScrollController = ScrollController();

  @override
  void dispose() {
    _amountController.dispose();
    _historyScrollController.dispose();
    _controller?.removeListener(_onFormStateChanged);
    super.dispose();
  }

  Future<void> _save() async {
    // Haptic Feedback (Sadece titreşim, animasyon yok)
    HapticService.mediumImpact();

    // Önceki mesajı temizle (yeni deneme yapılıyorsa)
    if (_successMessage != null) {
      if (_controller != null) {
        _controller!.setTransferSuccessMessage(null);
      } else {
        _localSuccessMessage = null;
        setState(() {});
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAccountId == null || _toAccountId == null) {
      ErrorHandler.showErrorSnackBar(
        context,
        context.l10n.pleaseSelectAccounts,
      );
      return;
    }

    if (_fromAccountId == _toAccountId) {
      ErrorHandler.showErrorSnackBar(
        context,
        context.l10n.cannotTransferToSameAccount,
      );
      return;
    }

    final double? amount = AmountInputFormatter.parseFormattedAmount(
      _amountController.text,
    );

    if (amount == null || amount <= 0) {
      ErrorHandler.showErrorSnackBar(context, context.l10n.enterValidAmount);
      return;
    }

    // Hedef hesap kredi kartıysa, borç kontrolü (lokal listeden)
    final fromAccount = _findPaymentMethod(_fromAccountId);
    final toAccount = _findPaymentMethod(_toAccountId);

    if (fromAccount == null || toAccount == null) {
      ErrorHandler.showErrorSnackBar(
        context,
        context.l10n.pleaseSelectAccounts,
      );
      return;
    }

    if (toAccount.type == 'kredi') {
      final borcMiktari = toAccount.balance;
      final cur = getIt<CurrencyService>();
      final convertedAmountToTo = cur.convert(
        amount,
        cur.currentCurrency,
        toAccount.paraBirimi,
      );

      // Borç yoksa kredi kartına transfer yapılamaz
      if (borcMiktari <= 0) {
        ErrorHandler.showErrorSnackBar(
          context,
          context.l10n.noDebtOnCreditCard,
        );
        return;
      }

      // Transfer edilen miktar borçtan fazla olamaz
      if (convertedAmountToTo > borcMiktari) {
        ErrorHandler.showErrorSnackBar(
          context,
          context.l10n.creditCardDebtLimit(() {
            return CurrencyFormatter.format(
              cur.convert(
                borcMiktari,
                toAccount.paraBirimi,
                cur.currentCurrency,
              ),
            );
          }()),
        );
        return;
      }
    }

    // Gönderen hesap kontrolü (Negatif bakiye veya Limit aşımı)
    final cur = getIt<CurrencyService>();
    final convertedAmountToFrom = cur.convert(
      amount,
      cur.currentCurrency,
      fromAccount.paraBirimi,
    );

    if (!_isScheduled) {
      bool limitVeyaBakiyeAsildi = false;
      double guncelBakiyeVeyaKalanLimit = 0;

      if (fromAccount.type == 'kredi') {
        final kalanLimit = (fromAccount.limit ?? 0) - fromAccount.balance;
        if (convertedAmountToFrom > kalanLimit) {
          limitVeyaBakiyeAsildi = true;
          guncelBakiyeVeyaKalanLimit = kalanLimit;
        }
      } else {
        if (convertedAmountToFrom > fromAccount.balance) {
          limitVeyaBakiyeAsildi = true;
          guncelBakiyeVeyaKalanLimit = fromAccount.balance;
        }
      }

      if (limitVeyaBakiyeAsildi) {
        final onay = await BalanceWarningDialog.show(
          context: context,
          paymentType: fromAccount.type,
          currentBalance: guncelBakiyeVeyaKalanLimit,
          expenseAmount: convertedAmountToFrom,
        );

        if (onay != true) return;
      }
    }

    if (!mounted) return;

    // Transfer işlemini gerçekleştir (callback)
    widget.onTransfer(_fromAccountId!, _toAccountId!, amount, _selectedDate);

    // Lokal bakiyeleri güncelle (sadece bugün veya geçmiş tarih için)
    if (!_isScheduled) {
      final cur = getIt<CurrencyService>();
      final convertedToFrom = cur.convert(
        amount,
        cur.currentCurrency,
        fromAccount.paraBirimi,
      );
      final convertedToTo = cur.convert(
        amount,
        cur.currentCurrency,
        toAccount.paraBirimi,
      );

      double newFromBalance;
      if (fromAccount.type == 'kredi') {
        newFromBalance = fromAccount.balance + convertedToFrom;
      } else {
        newFromBalance = fromAccount.balance - convertedToFrom;
      }

      double newToBalance;
      if (toAccount.type == 'kredi') {
        newToBalance = toAccount.balance - convertedToTo;
      } else {
        newToBalance = toAccount.balance + convertedToTo;
      }

      if (_controller != null) {
        _controller!.updatePaymentMethodBalance(fromAccount.id, newFromBalance);
        _controller!.updatePaymentMethodBalance(toAccount.id, newToBalance);
      } else {
        final fromIdx = _localPaymentMethods.indexWhere(
          (pm) => pm.id == fromAccount.id,
        );
        if (fromIdx != -1) {
          _localPaymentMethods[fromIdx] = _localPaymentMethods[fromIdx]
              .copyWith(balance: newFromBalance);
        }
        final toIdx = _localPaymentMethods.indexWhere(
          (pm) => pm.id == toAccount.id,
        );
        if (toIdx != -1) {
          _localPaymentMethods[toIdx] = _localPaymentMethods[toIdx].copyWith(
            balance: newToBalance,
          );
        }
        setState(() {});
      }
    }

    // Bilgi mesajı oluştur
    final fromAccountName = fromAccount.name;
    final toAccountName = toAccount.name;
    final formattedAmount = () {
      final cur = getIt<CurrencyService>();
      return CurrencyFormatter.format(
        cur.convert(amount, fromAccount.paraBirimi, cur.currentCurrency),
      );
    }();

    // Zamanlanmış transfer için farklı mesaj
    if (_isScheduled) {
      final appLocale = Localizations.localeOf(context).languageCode == 'tr'
          ? 'tr_TR'
          : 'en_US';
      final formattedDate = DateFormat(
        'd MMMM yyyy HH:mm',
        appLocale,
      ).format(_selectedDate);
      final msg = context.l10n.scheduledTransferMessage(
        fromAccountName,
        toAccountName,
        formattedAmount,
        formattedDate,
      );
      if (_controller != null) {
        _controller!.setTransferSuccessMessage(msg);
      } else {
        _localSuccessMessage = msg;
        setState(() {});
      }
    } else {
      final appLocale2 = Localizations.localeOf(context).languageCode == 'tr'
          ? 'tr_TR'
          : 'en_US';
      final formattedTime = DateFormat(
        'HH:mm',
        appLocale2,
      ).format(_selectedDate);
      final msg = context.l10n.completedTransferMessage(
        fromAccountName,
        toAccountName,
        formattedAmount,
        formattedTime,
      );
      if (_controller != null) {
        _controller!.setTransferSuccessMessage(msg);
      } else {
        _localSuccessMessage = msg;
        setState(() {});
      }
    }

    // Formu sıfırla
    _amountController.clear();
    if (_controller != null) {
      _controller!.resetTransferForm();
    } else {
      _localFromAccountId = null;
      _localToAccountId = null;
      _localSelectedDate = DateTime.now();
      setState(() {});
    }

    // Klavye açıksa kapat
    FocusScope.of(context).unfocus();

    // 5 saniye sonra başarı mesajını kaldır
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _successMessage != null) {
        if (_controller != null) {
          _controller!.setTransferSuccessMessage(null);
        } else {
          _localSuccessMessage = null;
          setState(() {});
        }
      }
    });

    // İşlem geçmişini başa kaydır (animasyonlu)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _historyScrollController.hasClients) {
        _historyScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _pickDate() async {
    HapticService.lightImpact();

    // MonthYearPicker kullanımı (Tarih ve Saat seçimi)
    final DateTime? picked = await MonthYearPicker.show(
      context,
      initialDate: _selectedDate,
      accentColor: _primaryColor,
      mode: PickerMode.dateTime,
    );

    if (picked != null && picked != _selectedDate) {
      if (_controller != null) {
        _controller!.setTransferSelectedDate(picked);
      } else {
        _localSelectedDate = picked;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.transferPageTitle,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ===== SABİT ÜST KISIM =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),

                  // 1. Tutar Alanı (kompakt)
                  _buildAmountField(textColor),

                  const SizedBox(height: 24),

                  // 2. Hesap Seçimi
                  _buildAccountSelection(textColor, isDark),

                  const SizedBox(height: 20),

                  // 3. Tarih Seçimi
                  _buildDateSelector(textColor, isDark),

                  const SizedBox(height: 16),

                  // 4. İleri Tarih Bilgisi
                  if (_isScheduled) ...[
                    _buildScheduledInfo(textColor, isDark),
                    const SizedBox(height: 12),
                  ],

                  // 5. Aksiyon Butonu
                  _buildActionButton(),

                  // 6. Başarı Mesajı
                  if (_successMessage != null) _buildSuccessMessage(isDark),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ayırıcı çizgi
            if (widget.transfers.isNotEmpty)
              Divider(
                color: textColor.withValues(alpha: 0.1),
                thickness: 1,
                height: 1,
              ),

            // ===== KAYDIRILAB İLİR İŞLEM GEÇMİŞİ =====
            if (widget.transfers.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildScrollableTransferHistory(textColor, isDark),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Kaydırılabilir işlem geçmişi
  Widget _buildScrollableTransferHistory(Color textColor, bool isDark) {
    // Tüm transferleri kopyala ve tarihe göre azalan (yeniden eskiye) sırala
    final sortedTransfers = List<Transfer>.from(widget.transfers)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Ayarlardan limit değerini oku
    int historyLimit = 30; // Varsayılan 30 Gün (Bu Ay)
    if (widget.userId != null) {
      try {
        historyLimit = getIt<SettingsRepository>().getTransferHistoryLimit(
          widget.userId!,
        );
      } catch (e) {
        // Hata durumunda varsayılanı kullan
      }
    }

    // Eski limit değeri farklı geldiyse 30'a (Bu Ay) ayarla
    if (![7, 30, 90, 180, 366, 365, -1].contains(historyLimit)) {
      historyLimit = 30;
    }

    // Seçilen tarihe göre filtrele
    List<Transfer> recentTransfers;
    if (historyLimit == -1) {
      recentTransfers = sortedTransfers;
    } else {
      final now = DateTime.now();
      DateTime thresholdDate;
      if (historyLimit == 30) {
        thresholdDate = DateTime(now.year, now.month, 1);
      } else if (historyLimit == 366) {
        thresholdDate = DateTime(now.year, 1, 1);
      } else {
        thresholdDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: historyLimit));
      }
      recentTransfers = sortedTransfers
          .where((t) => t.date.isAfter(thresholdDate))
          .toList();
    }

    // Bekleyen, başarısız ve tamamlanan transferleri ayır
    final pendingTransfers = recentTransfers
        .where((t) => t.isScheduled && !t.isExecuted && !t.isFailed)
        .toList();
    final failedTransfers = recentTransfers.where((t) => t.isFailed).toList();
    // Tamamlanan: Ya açıkça isExecuted=true olan VEYA eski transferler (isScheduled=false, yani anlık yapılmış)
    final completedTransfers = recentTransfers
        .where((t) => !t.isFailed && (t.isExecuted || !t.isScheduled))
        .toList();

    return ListView(
      controller: _historyScrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        // Başlık
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 20,
              color: textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.transactionHistory,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            if (widget.userId != null)
              _buildHistoryLimitSelector(textColor, isDark, historyLimit),
          ],
        ),
        const SizedBox(height: 16),

        // Bekleyen transferler
        if (pendingTransfers.isNotEmpty) ...[
          _buildStatusLabel(
            context.l10n.pendingTransfers(pendingTransfers.length),
            ColorConstants.turuncuVurgu,
          ),
          const SizedBox(height: 8),
          ...pendingTransfers.map(
            (t) => _buildTransferItem(t, textColor, isDark, status: 'pending'),
          ),
          const SizedBox(height: 16),
        ],

        // Başarısız transferler
        if (failedTransfers.isNotEmpty) ...[
          _buildStatusLabel(
            context.l10n.failedTransfers(failedTransfers.length),
            ColorConstants.kirmiziVurgu,
          ),
          const SizedBox(height: 8),
          ...failedTransfers.map(
            (t) => _buildTransferItem(t, textColor, isDark, status: 'failed'),
          ),
          const SizedBox(height: 16),
        ],

        // Tamamlanan transferler
        if (completedTransfers.isNotEmpty) ...[
          _buildStatusLabel(
            context.l10n.completedTransfersLabel(completedTransfers.length),
            ColorConstants.yesil,
          ),
          const SizedBox(height: 8),
          ...completedTransfers.map(
            (t) =>
                _buildTransferItem(t, textColor, isDark, status: 'completed'),
          ),
        ],

        // Boş durum
        if (recentTransfers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.noTransferHistory,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Status etiketi widget'ı
  Widget _buildStatusLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAmountField(Color textColor) {
    return Column(
      children: [
        Text(
          context.l10n.amountToSend,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicWidth(
          child: TextFormField(
            controller: _amountController,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            inputFormatters: [AmountInputFormatter()],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.enterAmountHint;
              }
              final amount = AmountInputFormatter.parseFormattedAmount(value);

              if (amount == null) {
                return context.l10n.enterValidAmount;
              }
              if (amount <= 0) {
                return context.l10n.amountMustBeGreaterThanZero;
              }
              if (amount > 100000000) {
                return context.l10n.maximumAmountExceeded;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "0",
              hintStyle: TextStyle(
                color: textColor.withValues(alpha: 0.2),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Builder(
                builder: (ctx) {
                  final cur = getIt<CurrencyService>();
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      cur.currentSymbol,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  );
                },
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelection(Color textColor, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Bağlantı Çizgisi
        Positioned(
          left: 24,
          top: 40,
          bottom: 40,
          child: Container(width: 2, color: textColor.withValues(alpha: 0.1)),
        ),
        Column(
          children: [
            // Gönderen
            _buildAccountTile(
              label: context.l10n.sender,
              value: _fromAccountId,
              hint: context.l10n.selectAccount,
              icon: Icons.upload_rounded,
              onChanged: (val) {
                if (_controller != null) {
                  _controller!.setTransferFromAccountId(val);
                } else {
                  _localFromAccountId = val;
                  setState(() {});
                }
                HapticService.selectionClick();
              },
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            // Alan
            _buildAccountTile(
              label: context.l10n.receiver,
              value: _toAccountId,
              hint: context.l10n.selectAccount,
              icon: Icons.download_rounded,
              onChanged: (val) {
                if (_controller != null) {
                  _controller!.setTransferToAccountId(val);
                } else {
                  _localToAccountId = val;
                  setState(() {});
                }
                HapticService.selectionClick();
              },
              textColor: textColor,
              isDark: isDark,
            ),
          ],
        ),
        // Ortadaki Transfer İkonu
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: textColor.withValues(alpha: 0.1)),
          ),
          child: Icon(
            Icons.arrow_downward_rounded,
            size: 16,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTile({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
    required Color textColor,
    required bool isDark,
  }) {
    // Seçili hesabı bul (varsa) - lokal listeden
    final selectedAccount = _findPaymentMethod(value);
    final dropdownValue = selectedAccount == null ? null : value;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: textColor.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.3),
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more_rounded, size: 20),
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.fontFamily,
                  ),
                  items: _paymentMethods.map((pm) {
                    return DropdownMenuItem<String>(
                      value: pm.id,
                      child: Row(
                        children: [
                          Text(pm.name),
                          const Spacer(),
                          AmountText(
                            () {
                              final cur = getIt<CurrencyService>();
                              return CurrencyFormatter.format(
                                cur.convert(
                                  pm.balance,
                                  pm.paraBirimi,
                                  cur.currentCurrency,
                                ),
                              );
                            }(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
              // Eğer bu ALAN hesap ise ve Kredi Kartı ise "Tümünü Öde" göster
              if (label == context.l10n.receiver &&
                  selectedAccount != null &&
                  selectedAccount.type == 'kredi' &&
                  selectedAccount.balance > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: InkWell(
                    onTap: () {
                      _amountController.text = selectedAccount.balance
                          .toStringAsFixed(0);
                      HapticService.lightImpact();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(
                        context.l10n.payAllDebt(() {
                          final cur = getIt<CurrencyService>();
                          return CurrencyFormatter.format(
                            cur.convert(
                              selectedAccount.balance,
                              selectedAccount.paraBirimi,
                              cur.currentCurrency,
                            ),
                          );
                        }()),
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(Color textColor, bool isDark) {
    return Center(
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: textColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              // Tarih ve saat gösterimi
              Builder(
                builder: (ctx) {
                  final loc = Localizations.localeOf(ctx).languageCode == 'tr'
                      ? 'tr_TR'
                      : 'en_US';
                  return Text(
                    DateFormat('d MMM yyyy • HH:mm', loc).format(_selectedDate),
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// İleri tarih bilgi kutusu
  PaymentMethod? _findPaymentMethod(String? id) {
    if (id == null) return null;
    for (final method in _paymentMethods) {
      if (method.id == id) return method;
    }
    return null;
  }

  Widget _buildScheduledInfo(Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.turuncuVurgu.withValues(
          alpha: isDark ? 0.15 : 0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.turuncuVurgu.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: ColorConstants.turuncuVurgu,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              (() {
                final loc = Localizations.localeOf(context).languageCode == 'tr'
                    ? 'tr_TR'
                    : 'en_US';
                return context.l10n.scheduledTransferInfo(
                  DateFormat('d MMMM yyyy', loc).format(_selectedDate),
                  DateFormat('HH:mm', loc).format(_selectedDate),
                );
              })(),
              style: const TextStyle(
                color: ColorConstants.turuncuVurgu,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _save,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isScheduled) ...[
              const Icon(Icons.schedule_rounded, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              _isScheduled
                  ? context.l10n.scheduleTransferButton
                  : context.l10n.makeTransferButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: AnimatedOpacity(
        opacity: _successMessage != null ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorConstants.yesil.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorConstants.yesil.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstants.yesil.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: ColorConstants.yesil,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _successMessage!,
                  style: TextStyle(
                    color: isDark
                        ? ColorConstants.yesil.withValues(alpha: 0.7)
                        : ColorConstants.yesil,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tekil transfer öğesi
  /// status: 'pending', 'failed', 'completed'
  Widget _buildTransferItem(
    Transfer transfer,
    Color textColor,
    bool isDark, {
    required String status,
  }) {
    // Hesap isimlerini bul
    String fromName = context.l10n.unknownAccount;
    String toName = context.l10n.unknownAccount;

    for (var pm in widget.paymentMethods) {
      if (pm.id == transfer.fromAccountId) fromName = pm.name;
      if (pm.id == transfer.toAccountId) toName = pm.name;
    }

    // Status'a göre renk ve ikon belirle
    Color accentColor;
    IconData statusIcon;
    switch (status) {
      case 'pending':
        accentColor = ColorConstants.turuncuVurgu;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'failed':
        accentColor = ColorConstants.kirmiziVurgu;
        statusIcon = Icons.error_outline_rounded;
        break;
      default:
        accentColor = _primaryColor;
        statusIcon = Icons.check_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withValues(alpha: 0.08)
            : accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // İkon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),

          // İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hesaplar
                Text(
                  '$fromName → $toName',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                // Tarih, saat veya hata mesajı
                Text(
                  status == 'failed' && transfer.failureReason != null
                      ? transfer.failureReason!
                      : (() {
                          final loc =
                              Localizations.localeOf(context).languageCode ==
                                  'tr'
                              ? 'tr_TR'
                              : 'en_US';
                          return DateFormat(
                            'd MMM yyyy • HH:mm',
                            loc,
                          ).format(transfer.date);
                        })(),
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'failed'
                        ? ColorConstants.kirmiziVurgu
                        : textColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Tutar
          Builder(
            builder: (ctx) {
              final cur = getIt<CurrencyService>();
              final converted = cur.convert(
                transfer.amount,
                transfer.paraBirimi,
                cur.currentCurrency,
              );
              return AmountText(
                CurrencyFormatter.format(converted),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              );
            },
          ),
          // İptal Butonu (Sadece Bekleyen Transferler)
          if (status == 'pending' && widget.onDeleteTransfer != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(context.l10n.cancelTransfer),
                    content: Text(context.l10n.cancelTransferConfirmation),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(context.l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.onDeleteTransfer!(transfer);
                        },
                        child: Text(
                          context.l10n.delete,
                          style: const TextStyle(
                            color: ColorConstants.kirmiziVurgu,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: ColorConstants.kirmiziVurgu,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryLimitSelector(
    Color textColor,
    bool isDark,
    int currentLimit,
  ) {
    if (widget.userId == null) return const SizedBox.shrink();

    final limits = [7, 30, 90, 180, 366, 365];
    if (!limits.contains(currentLimit) && currentLimit != -1) {
      currentLimit = 30;
    }

    String getLimitLabel(int limit) {
      switch (limit) {
        case 7:
          return context.l10n.thisWeek;
        case 30:
          return context.l10n.thisMonth;
        case 90:
          return context.l10n.last3Months;
        case 180:
          return context.l10n.last6Months;
        case 366:
          return context.l10n.thisYear;
        case 365:
          return context.l10n.last1Year;
        case -1:
          return context.l10n.allTransactions;
        default:
          return context.l10n.thisMonth;
      }
    }

    return PopupMenuButton<int>(
      initialValue: currentLimit,
      tooltip: '',
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (int value) async {
        if (value != currentLimit) {
          HapticService.selectionClick();
          await getIt<SettingsRepository>().saveTransferHistoryLimit(
            widget.userId!,
            value,
          );
          if (mounted) setState(() {});
        }
      },
      itemBuilder: (BuildContext context) {
        return limits.map((limit) {
          final isSelected = limit == currentLimit;
          return PopupMenuItem<int>(
            value: limit,
            height: 40,
            child: Row(
              children: [
                Text(
                  getLimitLabel(limit),
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? _primaryColor : textColor,
                    fontSize: 14,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(Icons.check, color: _primaryColor, size: 18),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getLimitLabel(currentLimit),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: textColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
