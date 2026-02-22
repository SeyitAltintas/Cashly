import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/transfer_model.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../controllers/payment_methods_controller.dart';

class TransferPage extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final List<Transfer> transfers;
  final String? userId;
  final PaymentMethodsController? controller;
  final Function(String fromId, String toId, double amount, DateTime date)
  onTransfer;

  const TransferPage({
    super.key,
    required this.paymentMethods,
    required this.transfers,
    required this.onTransfer,
    this.userId,
    this.controller,
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
    final now = DateTime.now();
    // Dakika hassasiyetinde karşılaştırma (saniye ve milisaniyeyi sıfırla)
    final nowMinutes = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final selectedMinutes = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedDate.hour,
      _selectedDate.minute,
    );
    return selectedMinutes.isAfter(nowMinutes);
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

  void _save() {
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

    final double? amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      ErrorHandler.showErrorSnackBar(context, context.l10n.enterValidAmount);
      return;
    }

    // Hedef hesap kredi kartıysa, borç kontrolü (lokal listeden)
    final toIndex = _paymentMethods.indexWhere((pm) => pm.id == _toAccountId);
    final toAccount = _paymentMethods[toIndex];

    if (toAccount.type == 'kredi') {
      final borcMiktari = toAccount.balance;

      // Borç yoksa kredi kartına transfer yapılamaz
      if (borcMiktari <= 0) {
        ErrorHandler.showErrorSnackBar(
          context,
          context.l10n.noDebtOnCreditCard,
        );
        return;
      }

      // Transfer edilen miktar borçtan fazla olamaz
      if (amount > borcMiktari) {
        ErrorHandler.showErrorSnackBar(
          context,
          context.l10n.creditCardDebtLimit(
            CurrencyFormatter.format(borcMiktari),
          ),
        );
        return;
      }
    }

    // Gönderen hesabı bul
    final fromIndex = _paymentMethods.indexWhere(
      (pm) => pm.id == _fromAccountId,
    );
    final fromAccount = _paymentMethods[fromIndex];

    // Transfer işlemini gerçekleştir (callback)
    widget.onTransfer(_fromAccountId!, _toAccountId!, amount, _selectedDate);

    // Lokal bakiyeleri güncelle (sadece bugün veya geçmiş tarih için)
    // Lokal bakiyeleri güncelle (sadece bugün veya geçmiş tarih için)
    if (!_isScheduled) {
      double newFromBalance;
      if (fromAccount.type == 'kredi') {
        newFromBalance = fromAccount.balance + amount;
      } else {
        newFromBalance = fromAccount.balance - amount;
      }

      double newToBalance;
      if (toAccount.type == 'kredi') {
        newToBalance = toAccount.balance - amount;
      } else {
        newToBalance = toAccount.balance + amount;
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
    final formattedAmount = CurrencyFormatter.format(amount);

    // Zamanlanmış transfer için farklı mesaj
    if (_isScheduled) {
      final formattedDate = DateFormat(
        'd MMMM yyyy HH:mm',
        'tr_TR',
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
      final formattedTime = DateFormat('HH:mm', 'tr_TR').format(_selectedDate);
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
      minimumDate: DateTime(2026, 1, 1), // 2026 Öncesi görünmemeli
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
    int historyLimit = 20; // Varsayılan
    if (widget.userId != null) {
      try {
        historyLimit = getIt<SettingsRepository>().getTransferHistoryLimit(
          widget.userId!,
        );
      } catch (e) {
        // Hata durumunda varsayılanı kullan
      }
    }

    // -1 ise tümünü göster, değilse limit kadar
    final recentTransfers = historyLimit == -1
        ? sortedTransfers
        : sortedTransfers.take(historyLimit).toList();

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
          ],
        ),
        const SizedBox(height: 16),

        // Bekleyen transferler
        if (pendingTransfers.isNotEmpty) ...[
          _buildStatusLabel(
            context.l10n.pendingTransfers(pendingTransfers.length),
            Colors.orange,
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
            Colors.red,
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
            Colors.green,
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
  Widget _buildStatusLabel(String text, MaterialColor color) {
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
          color: color.shade700,
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
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            // Sadece rakam girişine izin ver
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // Otomatik binlik ayraç ekleme
            onChanged: (value) {
              _formatAmountWithThousandSeparator(value);
            },
            validator: (value) {
              // Edge case: Boş değer
              if (value == null || value.isEmpty) {
                return context.l10n.enterAmountHint;
              }
              // Nokta ve virgülleri temizle
              final cleanValue = value.replaceAll('.', '').replaceAll(',', '');
              final amount = double.tryParse(cleanValue);

              // Edge case: Geçersiz sayı
              if (amount == null) {
                return context.l10n.enterValidAmount;
              }
              // Edge case: Sıfır veya negatif
              if (amount <= 0) {
                return context.l10n.amountMustBeGreaterThanZero;
              }
              // Edge case: Çok büyük değer (100 milyon TL üzeri)
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
              prefixIcon: Icon(
                Icons.currency_lira,
                size: 36,
                color: _primaryColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  /// Tutar için binlik ayraç (nokta) ekler
  /// Edge cases: Boş değer, çok uzun sayı, önde sıfır
  void _formatAmountWithThousandSeparator(String value) {
    // Sadece rakamları al
    String digitsOnly = value.replaceAll('.', '');

    // Edge case: Boş değer
    if (digitsOnly.isEmpty) {
      return;
    }

    // Edge case: Öndeki sıfırları temizle (tek sıfır hariç)
    digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    if (digitsOnly.isEmpty) {
      digitsOnly = '0';
    }

    // Edge case: Çok uzun sayı (12 haneden fazla engelle)
    if (digitsOnly.length > 12) {
      digitsOnly = digitsOnly.substring(0, 12);
    }

    // Binlik ayraç ekle
    final formatted = _addThousandSeparators(digitsOnly);

    // Cursor pozisyonunu koru
    if (_amountController.text != formatted) {
      final cursorPosition = _amountController.selection.baseOffset;
      final oldLength = _amountController.text.length;

      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: cursorPosition + (formatted.length - oldLength),
        ),
      );
    }
  }

  /// Sayıya binlik ayraç (nokta) ekler
  String _addThousandSeparators(String value) {
    if (value.isEmpty) return value;

    final buffer = StringBuffer();
    final length = value.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
    }

    return buffer.toString();
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
    final selectedAccount = value != null
        ? _paymentMethods.firstWhere((pm) => pm.id == value)
        : null;

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
                  value: value,
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
                          Text(
                            CurrencyFormatter.format(pm.balance),
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
                        context.l10n.payAllDebt(
                          CurrencyFormatter.format(selectedAccount.balance),
                        ),
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
              Text(
                DateFormat('d MMM yyyy • HH:mm', 'tr_TR').format(_selectedDate),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// İleri tarih bilgi kutusu
  Widget _buildScheduledInfo(Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.scheduledTransferInfo(
                DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate),
                DateFormat('HH:mm', 'tr_TR').format(_selectedDate),
              ),
              style: TextStyle(
                color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
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
          foregroundColor: Colors.white,
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
            color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _successMessage!,
                  style: TextStyle(
                    color: isDark
                        ? Colors.green.shade300
                        : Colors.green.shade800,
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
        accentColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'failed':
        accentColor = Colors.red;
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
                      : DateFormat(
                          'd MMM yyyy • HH:mm',
                          'tr_TR',
                        ).format(transfer.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'failed'
                        ? Colors.red.shade700
                        : textColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Tutar
          Text(
            CurrencyFormatter.format(transfer.amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
