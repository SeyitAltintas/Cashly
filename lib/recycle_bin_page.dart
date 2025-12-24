import 'package:flutter/material.dart';
import 'core/constants/color_constants.dart';
import 'core/di/injection_container.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'features/payment_methods/data/models/payment_method_model.dart';

class CopKutusuSayfasi extends StatefulWidget {
  final String userId;

  const CopKutusuSayfasi({super.key, required this.userId});

  @override
  State<CopKutusuSayfasi> createState() => _CopKutusuSayfasiState();
}

class _CopKutusuSayfasiState extends State<CopKutusuSayfasi> {
  List<Map<String, dynamic>> silinenHarcamalar = [];
  List<Map<String, dynamic>> tumHarcamalarHam = [];
  List<PaymentMethod> odemeYontemleri = [];

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  void verileriYukle() {
    final expenseRepo = getIt<ExpenseRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();

    tumHarcamalarHam = expenseRepo.getExpenses(widget.userId);

    // Ödeme yöntemlerini yükle
    List<Map<String, dynamic>> pmVerileri = paymentRepo.getPaymentMethods(
      widget.userId,
    );
    odemeYontemleri = pmVerileri.map((m) => PaymentMethod.fromMap(m)).toList();

    setState(() {
      silinenHarcamalar = tumHarcamalarHam
          .where((element) => element['silindi'] == true)
          .toList();
    });
  }

  Future<void> copuBosalt() async {
    if (silinenHarcamalar.isEmpty) return;

    bool? onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Çöpü Boşalt", style: TextStyle(color: Colors.white)),
        content: Text(
          "Tüm silinen harcamalar kalıcı olarak yok edilecek. Emin misin?",
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Evet, Sil",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (onay == true) {
      setState(() {
        tumHarcamalarHam.removeWhere((element) => element['silindi'] == true);
        silinenHarcamalar.clear();
        getIt<ExpenseRepository>().saveExpenses(
          widget.userId,
          tumHarcamalarHam,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorConstants.koyuKirmizi,
              content: const Text(
                "Çöp kutusu temizlendi.",
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      });
    }
  }

  Future<void> harcamayiGeriYukle(Map<String, dynamic> harcama) async {
    setState(() {
      var hedef = tumHarcamalarHam.firstWhere((element) => element == harcama);
      hedef['silindi'] = false;
      silinenHarcamalar.remove(harcama);

      // Ödeme yönteminin bakiyesinden düş (geri yüklenince harcama aktif oluyor)
      final paymentMethodId = harcama['odemeYontemiId'];
      if (paymentMethodId != null) {
        final pmIndex = odemeYontemleri.indexWhere(
          (p) => p.id == paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = odemeYontemleri[pmIndex];
          final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
          double newBalance;
          if (pm.type == 'kredi') {
            // Kredi kartı: borca ekle
            newBalance = pm.balance + amount;
          } else {
            // Banka kartı/Nakit: bakiyeden düş
            newBalance = pm.balance - amount;
          }
          odemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
        }
      }
    });
    getIt<ExpenseRepository>().saveExpenses(widget.userId, tumHarcamalarHam);
    // Ödeme yöntemlerini kaydet
    List<Map<String, dynamic>> pmMapleri = odemeYontemleri
        .map((pm) => pm.toMap())
        .toList();
    getIt<PaymentMethodRepository>().savePaymentMethods(
      widget.userId,
      pmMapleri,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Harcama geri yüklendi ♻️",
            style: TextStyle(color: Colors.white),
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
  }

  Future<void> harcamayiKaliciSil(Map<String, dynamic> harcama) async {
    setState(() {
      tumHarcamalarHam.remove(harcama);
      silinenHarcamalar.remove(harcama);
    });
    getIt<ExpenseRepository>().saveExpenses(widget.userId, tumHarcamalarHam);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Harcama kalıcı olarak silindi 🗑️",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: ColorConstants.koyuKirmizi,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Çöp Kutusu"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: "Çöpü Boşalt",
            onPressed: copuBosalt,
          ),
        ],
      ),
      body: silinenHarcamalar.isEmpty
          ? Center(
              child: Text(
                "Silinen harcama yok.",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: silinenHarcamalar.length,
              itemBuilder: (context, index) {
                final harcama = silinenHarcamalar[index];
                DateTime tarih =
                    DateTime.tryParse(harcama['tarih'].toString()) ??
                    DateTime.now();

                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.money_off,
                      color: ColorConstants.kirmiziVurgu,
                    ),
                    title: Text(
                      harcama['isim'] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${harcama['tutar']} ₺ • ${tarih.day}.${tarih.month}.${tarih.year}",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.restore,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => harcamayiGeriYukle(harcama),
                          tooltip: "Geri Yükle",
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: ColorConstants.kirmiziVurgu,
                          ),
                          onPressed: () => harcamayiKaliciSil(harcama),
                          tooltip: "Kalıcı Sil",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
