import 'package:flutter/material.dart';
import 'services/database_helper.dart';

class CopKutusuSayfasi extends StatefulWidget {
  final String userId;

  const CopKutusuSayfasi({super.key, required this.userId});

  @override
  State<CopKutusuSayfasi> createState() => _CopKutusuSayfasiState();
}

class _CopKutusuSayfasiState extends State<CopKutusuSayfasi> {
  List<Map<String, dynamic>> silinenHarcamalar = [];
  List<Map<String, dynamic>> tumHarcamalarHam = [];

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  void verileriYukle() {
    tumHarcamalarHam = DatabaseHelper.harcamalariGetir(widget.userId);
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
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Çöpü Boşalt", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Tüm silinen harcamalar kalıcı olarak yok edilecek. Emin misin?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        DatabaseHelper.harcamalariKaydet(widget.userId, tumHarcamalarHam);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade900,
              content: const Text(
                "Çöp kutusu temizlendi.",
                style: TextStyle(color: Colors.white),
              ),
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
    });
    DatabaseHelper.harcamalariKaydet(widget.userId, tumHarcamalarHam);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harcama geri yüklendi ♻️")));
    }
  }

  Future<void> harcamayiKaliciSil(Map<String, dynamic> harcama) async {
    setState(() {
      tumHarcamalarHam.remove(harcama);
      silinenHarcamalar.remove(harcama);
    });
    DatabaseHelper.harcamalariKaydet(widget.userId, tumHarcamalarHam);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Harcama kalıcı olarak silindi 🗑️",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade900,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Çöpü Boşalt",
            onPressed: copuBosalt,
          ),
        ],
      ),
      body: silinenHarcamalar.isEmpty
          ? const Center(
              child: Text(
                "Silinen harcama yok.",
                style: TextStyle(color: Colors.white54),
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
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.money_off,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      harcama['isim'] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${harcama['tutar']} ₺ • ${tarih.day}.${tarih.month}.${tarih.year}",
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.restore,
                            color: Color(0xFFBB86FC),
                          ),
                          onPressed: () => harcamayiGeriYukle(harcama),
                          tooltip: "Geri Yükle",
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.redAccent,
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
