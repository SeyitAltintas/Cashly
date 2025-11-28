import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'features/expenses/presentation/pages/category_management_page.dart';
import 'core/utils/validators.dart';
import 'core/utils/error_handler.dart';

class AyarlarSayfasi extends StatefulWidget {
  final String userId;

  const AyarlarSayfasi({super.key, required this.userId});

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  bool _needsRefresh = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _needsRefresh);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ayarlar"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _needsRefresh),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HarcamalarAyarlariSayfasi(userId: widget.userId),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _needsRefresh = true;
                      });
                    }
                  },
                  child: const Text(
                    "Harcamalar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HarcamalarAyarlariSayfasi extends StatefulWidget {
  final String userId;

  const HarcamalarAyarlariSayfasi({super.key, required this.userId});

  @override
  State<HarcamalarAyarlariSayfasi> createState() =>
      _HarcamalarAyarlariSayfasiState();
}

class _HarcamalarAyarlariSayfasiState extends State<HarcamalarAyarlariSayfasi> {
  final _sabitGiderFormKey = GlobalKey<FormState>();
  final TextEditingController tGelir = TextEditingController();
  final TextEditingController tSabitIsim = TextEditingController();
  final TextEditingController tSabitTutar = TextEditingController();

  List<Map<String, dynamic>> sabitGiderler = [];
  bool categoryChanged = false;

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  void verileriYukle() {
    double mevcutButce = DatabaseHelper.butceGetir(widget.userId);
    tGelir.text = mevcutButce.toStringAsFixed(0);
    setState(() {
      sabitGiderler = DatabaseHelper.sabitGiderSablonlariGetir(widget.userId);
    });
  }

  void butceyiKaydet() {
    final tutarText = tGelir.text.trim();

    // Validation
    final validationError = Validators.validateAmount(
      tutarText,
      maxAmount: 10000000,
    );

    if (validationError != null) {
      ErrorHandler.showErrorSnackBar(context, validationError);
      return;
    }

    double? yeniLimit = double.tryParse(tutarText);
    if (yeniLimit != null) {
      try {
        DatabaseHelper.butceKaydet(widget.userId, yeniLimit);
        ErrorHandler.showSuccessSnackBar(context, "Aylık bütçe güncellendi ✅");
      } catch (e) {
        ErrorHandler.handleDatabaseError(context, e);
      }
    }
  }

  void sabitGiderEkleListeye() {
    // Form validation
    if (!_sabitGiderFormKey.currentState!.validate()) {
      return;
    }

    final isim = tSabitIsim.text.trim();
    final tutarText = tSabitTutar.text.trim();
    final tutar = double.tryParse(tutarText);

    if (tutar == null) return;

    try {
      setState(() {
        sabitGiderler.add({
          "isim": isim,
          "tutar": tutar,
          "kategori": "Sabit Giderler",
        });
      });

      DatabaseHelper.sabitGiderSablonlariKaydet(widget.userId, sabitGiderler);
      tSabitIsim.clear();
      tSabitTutar.clear();
      Navigator.pop(context);

      ErrorHandler.showSuccessSnackBar(context, 'Sabit gider eklendi');
    } catch (e) {
      ErrorHandler.handleDatabaseError(context, e);
    }
  }

  void sabitGiderSil(int index) {
    setState(() {
      sabitGiderler.removeAt(index);
    });
    DatabaseHelper.sabitGiderSablonlariKaydet(widget.userId, sabitGiderler);
  }

  void buAyIsle() {
    if (sabitGiderler.isEmpty) return;

    List<Map<String, dynamic>> mevcutHarcamalar =
        DatabaseHelper.harcamalariGetir(widget.userId);
    DateTime simdi = DateTime.now();

    for (var sablon in sabitGiderler) {
      mevcutHarcamalar.add({
        "isim": sablon['isim'],
        "tutar": sablon['tutar'],
        "kategori": "Sabit Giderler",
        "tarih": simdi.toString(),
        "silindi": false,
      });
    }

    DatabaseHelper.harcamalariKaydet(widget.userId, mevcutHarcamalar);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${sabitGiderler.length} adet sabit gider bu aya eklendi! 🚀",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF9D00FF),
      ),
    );
  }

  void pencereAc() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _sabitGiderFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sabit Gider Tanımla",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Gider Adı
                TextFormField(
                  controller: tSabitIsim,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => Validators.validateRequired(
                    value,
                    fieldName: 'Gider adı',
                  ),
                  decoration: InputDecoration(
                    hintText: "Gider Adı (Örn: Netflix)",
                    prefixIcon: const Icon(
                      Icons.label,
                      color: Color(0xFFBB86FC),
                    ),
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFBB86FC),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tutar
                TextFormField(
                  controller: tSabitTutar,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  validator: Validators.validateAmount,
                  decoration: InputDecoration(
                    hintText: "Tutar (Örn: 200)",
                    prefixIcon: const Icon(
                      Icons.currency_lira,
                      color: Color(0xFFBB86FC),
                    ),
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFBB86FC),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ekle Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sabitGiderEkleListeye,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9D00FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Listeye Ekle",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, categoryChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gelir ve Gider Ayarları"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, categoryChanged),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "AYLIK GELİR (BÜTÇE LİMİTİ)",
                style: TextStyle(
                  color: Color(0xFFBB86FC),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tGelir,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: "₺",
                          hintText: "0",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save, color: Color(0xFFBB86FC)),
                      onPressed: butceyiKaydet,
                      tooltip: "Kaydet",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SABİT GİDERLERİM",
                    style: TextStyle(
                      color: Color(0xFFBB86FC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: pencereAc,
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      "Yeni Ekle",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                "Buraya eklediklerin otomatik düşmez. Her ay başında aşağıdaki butona basarak hepsini tek seferde ekleyebilirsin.",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 10),
              sabitGiderler.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "Henüz sabit gider tanımlamadın.",
                          style: TextStyle(color: Colors.white24),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sabitGiderler.length,
                      itemBuilder: (context, index) {
                        final gider = sabitGiderler[index];
                        return Card(
                          color: const Color(0xFF1E1E1E),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.push_pin,
                              color: Colors.orangeAccent,
                            ),
                            title: Text(
                              gider['isim'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${gider['tutar']} ₺",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => sabitGiderSil(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              // Bu Aya Ekle Butonu
              if (sabitGiderler.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E004F), Color(0xFF7F00FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7F00FF).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      buAyIsle();
                      setState(() {
                        categoryChanged = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Tüm Sabit Giderleri Bu Aya Ekle",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "KATEGORİ YÖNETİMİ",
                    style: TextStyle(
                      color: Color(0xFFBB86FC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category, color: Color(0xFFBB86FC)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Harcama kategorilerini özelleştirin",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 18,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                KategoriYonetimiSayfasi(userId: widget.userId),
                          ),
                        ).then((_) {
                          setState(() {
                            categoryChanged = true;
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
