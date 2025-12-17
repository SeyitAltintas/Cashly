import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../services/database_helper.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Tekrarlayan İşlemler yönetim sayfası
class RecurringTransactionsPage extends StatefulWidget {
  final String userId;

  const RecurringTransactionsPage({super.key, required this.userId});

  @override
  State<RecurringTransactionsPage> createState() =>
      _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState extends State<RecurringTransactionsPage> {
  List<Map<String, dynamic>> _tekrarlayanIslemler = [];
  List<PaymentMethod> _odemeYontemleri = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    final islemler = DatabaseHelper.sabitGiderSablonlariGetir(widget.userId);
    final pmVerileri = DatabaseHelper.odemeYontemleriGetir(widget.userId);
    final pmList = pmVerileri
        .map((m) => PaymentMethod.fromMap(m))
        .where((pm) => !pm.isDeleted)
        .toList();

    setState(() {
      _tekrarlayanIslemler = islemler;
      _odemeYontemleri = pmList;
    });
  }

  void _kaydet() {
    DatabaseHelper.sabitGiderSablonlariKaydet(
      widget.userId,
      _tekrarlayanIslemler,
    );
  }

  void _islemEkle() {
    _bottomSheetGoster();
  }

  void _islemDuzenle(int index) {
    _bottomSheetGoster(islem: _tekrarlayanIslemler[index], index: index);
  }

  void _bottomSheetGoster({Map<String, dynamic>? islem, int? index}) {
    final isimController = TextEditingController(text: islem?['isim'] ?? '');
    final tutarController = TextEditingController(
      text: islem?['tutar']?.toString() ?? '',
    );
    int secilenGun = islem?['gun'] ?? 1;
    String? secilenOdemeYontemiId = islem?['odemeYontemiId'];
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
                    islem == null ? 'Yeni Tekrarlayan İşlem' : 'İşlemi Düzenle',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                      labelText: 'İşlem Adı',
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.label_outline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'İşlem adı gerekli';
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
                      labelText: 'Tutar (₺)',
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.currency_lira,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tutar gerekli';
                      }
                      final tutar = double.tryParse(value.replaceAll(',', '.'));
                      if (tutar == null || tutar <= 0) {
                        return 'Geçerli bir tutar girin';
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
                          'Her ayın:',
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
                          ).colorScheme.secondary.withValues(alpha: 0.1),
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
                                      '$gun. günü',
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

                  // Ödeme Yöntemi
                  DropdownButtonFormField<String>(
                    initialValue: secilenOdemeYontemiId,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    decoration: InputDecoration(
                      labelText: 'Ödeme Yöntemi',
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                        return 'Ödeme yöntemi seçin';
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
                        backgroundColor:
                            context.watch<ThemeManager>().isDefaultTheme
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final yeniIslem = {
                            'id':
                                islem?['id'] ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            'isim': isimController.text.trim(),
                            'tutar': double.parse(
                              tutarController.text.replaceAll(',', '.'),
                            ),
                            'kategori': 'Tekrarlayan İşlemler',
                            'gun': secilenGun,
                            'odemeYontemiId': secilenOdemeYontemiId,
                            'sonIslemTarihi': islem?['sonIslemTarihi'],
                          };

                          setState(() {
                            if (index != null) {
                              _tekrarlayanIslemler[index] = yeniIslem;
                            } else {
                              _tekrarlayanIslemler.add(yeniIslem);
                            }
                          });
                          _kaydet();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                index != null
                                    ? 'İşlem güncellendi'
                                    : 'İşlem eklendi',
                              ),
                              backgroundColor: Colors.green.shade700,
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
                        islem == null ? 'Ekle' : 'Güncelle',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    if (id == null) return 'Belirtilmemiş';
    final pm = _odemeYontemleri.firstWhere(
      (p) => p.id == id,
      orElse: () => PaymentMethod(
        id: '',
        name: 'Bilinmeyen',
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tekrarlayan İşlemler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _islemEkle,
        backgroundColor: context.watch<ThemeManager>().isDefaultTheme
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bilgi Kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tanımladığınız işlemler her ayın belirlediğiniz gününde otomatik olarak harcamalarınıza eklenir.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _tekrarlayanIslemler.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz tekrarlayan işlem yok',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Eklemek için + butonuna tıklayın',
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
                    itemCount: _tekrarlayanIslemler.length,
                    itemBuilder: (context, index) {
                      final islem = _tekrarlayanIslemler[index];
                      return _buildIslemKarti(islem, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslemKarti(Map<String, dynamic> islem, int index) {
    final gun = islem['gun'] ?? 1;
    final tutar = (islem['tutar'] as num?)?.toDouble() ?? 0;
    final odemeYontemi = _getOdemeYontemiAdi(islem['odemeYontemiId']);

    return Dismissible(
      key: Key(islem['id']?.toString() ?? index.toString()),
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
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'İşlemi Sil',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              '${islem['isim']} işlemini silmek istiyor musunuz?',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        setState(() {
          _tekrarlayanIslemler.removeAt(index);
        });
        _kaydet();
      },
      child: GestureDetector(
        onTap: () => _islemDuzenle(index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.repeat,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      islem['isim'] ?? 'İsimsiz',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Her ayın $gun. günü • $odemeYontemi',
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
                '${tutar.toStringAsFixed(2)} ₺',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
