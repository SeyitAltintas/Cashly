import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/utils/validators.dart';
import 'package:cashly/core/utils/error_handler.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';

/// Gelir Ayarları Sayfası
/// Aylık gelir hedefi ve tekrarlayan gelir şablonlarını yönetir.
class GelirAyarlariSayfasi extends StatefulWidget {
  final String userId;
  const GelirAyarlariSayfasi({super.key, required this.userId});

  @override
  State<GelirAyarlariSayfasi> createState() => _GelirAyarlariSayfasiState();
}

class _GelirAyarlariSayfasiState extends State<GelirAyarlariSayfasi> {
  final TextEditingController _targetController = TextEditingController();
  List<Map<String, dynamic>> _templates = [];
  List<PaymentMethod> _odemeYontemleri = [];
  bool _isSaved = false;
  bool _categoryChanged = false;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _verileriYukle() {
    final incomeRepo = getIt<IncomeRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();

    final target = incomeRepo.getIncomeTarget(widget.userId);
    _targetController.text = target > 0 ? target.toStringAsFixed(0) : '';

    _templates = List<Map<String, dynamic>>.from(
      incomeRepo.getRecurringIncomeTemplates(widget.userId),
    );

    final pmVerileri = paymentRepo.getPaymentMethods(widget.userId);
    _odemeYontemleri = pmVerileri
        .map((m) => PaymentMethod.fromMap(m))
        .where((pm) => !pm.isDeleted)
        .toList();

    setState(() {});
  }

  void _hedefiKaydet() {
    final tutarText = _targetController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '');
    final validationError = Validators.validateAmount(tutarText, maxAmount: 10000000);

    if (validationError != null) {
      ErrorHandler.showErrorSnackBar(context, validationError);
      return;
    }

    final yeniHedef = double.tryParse(tutarText);
    if (yeniHedef != null) {
      try {
        getIt<IncomeRepository>().saveIncomeTarget(widget.userId, yeniHedef);
        _categoryChanged = true;
        setState(() => _isSaved = true);
        AppSnackBar.success(context, 'Gelir hedefi güncellendi ✓',
            duration: const Duration(seconds: 2));
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _isSaved = false);
        });
      } catch (e) {
        ErrorHandler.handleDatabaseError(context, e);
      }
    }
  }

  void _sablonKaydet() {
    try {
      getIt<IncomeRepository>()
          .saveRecurringIncomeTemplates(widget.userId, _templates);
      _categoryChanged = true;
    } catch (e) {
      if (mounted) ErrorHandler.handleDatabaseError(context, e);
    }
  }

  void _sablonEkle() => _bottomSheetGoster();

  void _sablonDuzenle(int index) =>
      _bottomSheetGoster(sablon: _templates[index], index: index);

  void _bottomSheetGoster({Map<String, dynamic>? sablon, int? index}) {
    final isimCtrl = TextEditingController(text: sablon?['isim'] ?? '');
    final tutarCtrl = TextEditingController(
        text: sablon?['tutar']?.toString() ?? '');
    int secilenGun = sablon?['gun'] ?? 1;
    String secilenKategori = sablon?['kategori'] ?? 'Maaş';
    String? secilenOdemeYontemiId = sablon?['odemeYontemiId'];
    final formKey = GlobalKey<FormState>();

    final kategoriler = ['Maaş', 'Serbest Çalışma', 'Kira Geliri', 'Diğer'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sablon == null
                          ? 'Yeni Tekrarlayan Gelir'
                          : 'Geliri Düzenle',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // İsim
                    TextFormField(
                      controller: isimCtrl,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      decoration: _inputDecoration(context, 'İsim',
                          Icons.label_outline),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'İsim gerekli' : null,
                    ),
                    const SizedBox(height: 16),

                    // Tutar
                    TextFormField(
                      controller: tutarCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      decoration: _inputDecoration(
                          context, 'Tutar (₺)', Icons.currency_lira),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Tutar gerekli';
                        }
                        final t =
                            double.tryParse(v.replaceAll(',', '.'));
                        if (t == null || t <= 0) return 'Geçerli tutar girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kategori
                    DropdownButtonFormField<String>(
                      initialValue: secilenKategori,
                      dropdownColor:
                          Theme.of(context).colorScheme.surface,
                      decoration: _inputDecoration(
                          context, 'Kategori', Icons.category_outlined),
                      items: kategoriler
                          .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(k,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setSheetState(() => secilenKategori = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gün
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Her ayın',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: secilenGun,
                              dropdownColor:
                                  Theme.of(context).colorScheme.surface,
                              items: List.generate(28, (i) => i + 1)
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(
                                          '$g. günü',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setSheetState(() => secilenGun = v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Ödeme Yöntemi
                    if (_odemeYontemleri.isNotEmpty)
                      DropdownButtonFormField<String>(
                        initialValue: secilenOdemeYontemiId,
                        dropdownColor:
                            Theme.of(context).colorScheme.surface,
                        decoration: _inputDecoration(context,
                            'Ödeme Yöntemi', Icons.account_balance_wallet),
                        items: _odemeYontemleri
                            .map((pm) => DropdownMenuItem(
                                  value: pm.id,
                                  child: Text(
                                    pm.lastFourDigits != null
                                        ? '${pm.name} ****${pm.lastFourDigits}'
                                        : pm.name,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setSheetState(() => secilenOdemeYontemiId = v),
                      ),
                    const SizedBox(height: 24),

                    // Kaydet Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final yeni = {
                              'id': sablon?['id'] ??
                                  'ri_${DateTime.now().millisecondsSinceEpoch}',
                              'isim': isimCtrl.text.trim(),
                              'tutar': double.parse(
                                  tutarCtrl.text.replaceAll(',', '.')),
                              'gun': secilenGun,
                              'kategori': secilenKategori,
                              'odemeYontemiId': secilenOdemeYontemiId,
                            };
                            setState(() {
                              if (index != null) {
                                _templates[index] = yeni;
                              } else {
                                _templates.add(yeni);
                              }
                            });
                            _sablonKaydet();
                            Navigator.pop(context);
                            AppSnackBar.success(
                              context,
                              index != null
                                  ? 'Gelir güncellendi ✓'
                                  : 'Gelir eklendi ✓',
                              duration: const Duration(seconds: 1),
                            );
                          }
                        },
                        child: Text(
                          sablon == null ? 'Ekle' : 'Güncelle',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.6)),
      prefixIcon: Icon(icon,
          color: Theme.of(context).colorScheme.secondary),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.5))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _categoryChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gelir Ayarları'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _categoryChanged),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 32),

              // ===== AYLIK GELİR HEDEFİ =====
              _buildSectionTitle(context, 'Aylık Gelir Hedefi',
                  Icons.trending_up_rounded),
              const SizedBox(height: 12),
              _buildIncomeTargetSection(context),

              const SizedBox(height: 30),

              // ===== TEKRARlAYAN GELİRLER =====
              _buildSectionTitle(
                  context, 'Tekrarlayan Gelirler', Icons.repeat_rounded),
              const SizedBox(height: 8),
              _buildInfoBox(context,
                  'Maaş, kira gibi düzenli gelirlerinizi buraya ekleyin. Hatırlatma ve planlama için kullanılır.'),
              const SizedBox(height: 12),
              _buildTemplatesList(context),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _sablonEkle,
                  icon: const Icon(Icons.add),
                  label: const Text('Tekrarlayan Gelir Ekle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gelir Ayarları',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aylık gelir hedefinizi ve tekrarlayan gelirlerinizi yönetin.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.54),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .secondary
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .secondary
              .withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 16,
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  fontSize: 13,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTargetSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ne kadar gelir kazanmayı hedefliyorsunuz?',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3),
                    ),
                    prefixIcon: Icon(Icons.currency_lira,
                        color: Colors.green.shade400),
                    suffixText: '/ ay',
                    suffixStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _hedefiKaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isSaved ? '✓' : 'Kaydet',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList(BuildContext context) {
    if (_templates.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.repeat,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              'Henüz tekrarlayan gelir yok',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_templates.length, (index) {
        final sablon = _templates[index];
        final tutar = (sablon['tutar'] as num?)?.toDouble() ?? 0;
        final gun = sablon['gun'] ?? 1;
        final kategori = sablon['kategori'] ?? '';

        return Dismissible(
          key: Key(sablon['id']?.toString() ?? index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor:
                    Theme.of(context).colorScheme.surface,
                title: const Text('Geliri Sil'),
                content: Text(
                    '${sablon['isim']} silinecek. Emin misiniz?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(context.l10n.cancel)),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sil',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            setState(() => _templates.removeAt(index));
            _sablonKaydet();
          },
          child: GestureDetector(
            onTap: () => _sablonDuzenle(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.repeat,
                        color: Colors.green.shade400),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sablon['isim'] ?? '',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Her ayın $gun. günü • $kategori',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₺${tutar.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
