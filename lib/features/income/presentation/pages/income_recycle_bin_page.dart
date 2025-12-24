import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/di/injection_container.dart';
import '../../../income/domain/repositories/income_repository.dart';
import 'package:cashly/core/utils/error_handler.dart';
import '../../data/models/income_model.dart';

class GelirCopKutusuSayfasi extends StatefulWidget {
  final String userId;

  const GelirCopKutusuSayfasi({super.key, required this.userId});

  @override
  State<GelirCopKutusuSayfasi> createState() => _GelirCopKutusuSayfasiState();
}

class _GelirCopKutusuSayfasiState extends State<GelirCopKutusuSayfasi> {
  List<Income> silinenGelirler = [];
  List<Income> tumGelirler = [];

  final List<String> _months = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  void verileriYukle() {
    try {
      final incomeRepo = getIt<IncomeRepository>();
      List<Map<String, dynamic>> gelirVerileri = incomeRepo.getIncomes(
        widget.userId,
      );
      tumGelirler = gelirVerileri.map((map) => Income.fromMap(map)).toList();
      setState(() {
        silinenGelirler = tumGelirler.where((g) => g.isDeleted).toList();
      });
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Silinen gelirler yüklenirken hata', e);
    }
  }

  void kaydet() {
    try {
      List<Map<String, dynamic>> gelirMapleri = tumGelirler
          .map((income) => income.toMap())
          .toList();
      getIt<IncomeRepository>().saveIncomes(widget.userId, gelirMapleri);
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
      ErrorHandler.logError('Gelirler kaydedilirken hata', e);
    }
  }

  Future<void> copuBosalt() async {
    if (silinenGelirler.isEmpty) return;

    bool? onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Çöpü Boşalt", style: TextStyle(color: Colors.white)),
        content: Text(
          "Tüm silinen gelirler kalıcı olarak yok edilecek. Emin misin?",
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
        tumGelirler.removeWhere((g) => g.isDeleted);
        silinenGelirler.clear();
        kaydet();
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

  Future<void> geliriGeriYukle(Income gelir) async {
    setState(() {
      int index = tumGelirler.indexWhere((g) => g.id == gelir.id);
      if (index != -1) {
        tumGelirler[index] = gelir.copyWith(isDeleted: false);
      }
      silinenGelirler.removeWhere((g) => g.id == gelir.id);
    });
    kaydet();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Gelir geri yüklendi ♻️",
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

  Future<void> geliriKaliciSil(Income gelir) async {
    setState(() {
      tumGelirler.removeWhere((g) => g.id == gelir.id);
      silinenGelirler.removeWhere((g) => g.id == gelir.id);
    });
    kaydet();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Gelir kalıcı olarak silindi 🗑️",
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
        title: const Text("Gelir Çöp Kutusu"),
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
      body: silinenGelirler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 60, color: Colors.white12),
                  const SizedBox(height: 10),
                  Text(
                    "Silinen gelir yok.",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: silinenGelirler.length,
              itemBuilder: (context, index) {
                final gelir = silinenGelirler[index];

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
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Colors.green.shade400,
                      ),
                    ),
                    title: Text(
                      gelir.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${gelir.amount.toStringAsFixed(2)} ₺ • ${gelir.date.day} ${_months[gelir.date.month - 1]} ${gelir.date.year}",
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
                            color: Colors.green.shade400,
                          ),
                          onPressed: () => geliriGeriYukle(gelir),
                          tooltip: "Geri Yükle",
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: ColorConstants.kirmiziVurgu,
                          ),
                          onPressed: () => geliriKaliciSil(gelir),
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
