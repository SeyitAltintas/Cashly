import 'package:flutter/material.dart';

import 'services/database_helper.dart';
import 'features/expenses/presentation/pages/category_management_page.dart';
import 'features/settings/presentation/pages/appearance_page.dart';
import 'features/settings/presentation/pages/voice_assistant_page.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'core/utils/validators.dart';
import 'core/utils/error_handler.dart';

class AyarlarSayfasi extends StatefulWidget {
  final AuthController authController;

  const AyarlarSayfasi({super.key, required this.authController});

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
          iconTheme: const IconThemeData(color: Colors.white),
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
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppearancePage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Görünüm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sesli Asistan butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoiceAssistantPage(
                          authController: widget.authController,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Sesli Asistan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HarcamalarAyarlariSayfasi(
                          userId: widget.authController.currentUser!.id,
                        ),
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
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
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
                    Text(
                      "Sabit Gider Tanımla",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Gider Adı
                TextFormField(
                  controller: tSabitIsim,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  validator: (value) => Validators.validateRequired(
                    value,
                    fieldName: 'Gider adı',
                  ),
                  decoration: InputDecoration(
                    hintText: "Gider Adı (Örn: Netflix)",
                    prefixIcon: Icon(
                      Icons.label,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  validator: Validators.validateAmount,
                  decoration: InputDecoration(
                    hintText: "Tutar (Örn: 200)",
                    prefixIcon: Icon(
                      Icons.currency_lira,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Listeye Ekle",
                      style: TextStyle(
                        color: Colors.white,
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
          iconTheme: const IconThemeData(color: Colors.white),
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
              Text(
                "AYLIK GELİR (BÜTÇE LİMİTİ)",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tGelir,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
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
                      icon: Icon(
                        Icons.save,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
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
                  Text(
                    "SABİT GİDERLERİM",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: pencereAc,
                    icon: Icon(
                      Icons.add,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    label: Text(
                      "Yeni Ekle",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "Buraya eklediklerin otomatik düşmez. Her ay başında aşağıdaki butona basarak hepsini tek seferde ekleyebilirsin.",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.38),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              sabitGiderler.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "Henüz sabit gider tanımlamadın.",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.24),
                          ),
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
                          color: Theme.of(context).colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.push_pin,
                              color: Colors.orangeAccent,
                            ),
                            title: Text(
                              gider['isim'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${gider['tutar']} ₺",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
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
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
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
                        Text(
                          "Tüm Sabit Giderleri Bu Aya Ekle",
                          style: const TextStyle(
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
                  Text(
                    "KATEGORİ YÖNETİMİ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Harcama kategorilerini özelleştirin",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
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
