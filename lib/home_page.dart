import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/theme/theme_manager.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/constants/icon_constants.dart';
import 'package:cashly/core/widgets/money_animation.dart';
import 'package:cashly/core/widgets/skeleton_widget.dart';

import 'services/database_helper.dart';
import 'recycle_bin_page.dart';
import 'profile_page.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/assets/presentation/pages/assets_page.dart';
import 'features/assets/data/models/asset_model.dart';
import 'features/analysis/presentation/pages/analysis_page.dart';
import 'features/tools/presentation/pages/tools_page.dart';
import 'features/income/presentation/pages/income_page.dart';
import 'features/income/presentation/widgets/add_income_sheet.dart';
import 'features/income/data/models/income_model.dart';
import 'features/income/presentation/pages/income_recycle_bin_page.dart';
import 'features/expenses/presentation/widgets/add_expense_sheet.dart';
import 'features/expenses/presentation/widgets/voice_input_sheet.dart';
import 'features/expenses/presentation/widgets/expense_summary_card.dart';
import 'features/expenses/presentation/widgets/expense_list_item.dart';
import 'features/payment_methods/presentation/pages/payment_methods_page.dart';
import 'features/payment_methods/presentation/pages/transfer_page.dart';
import 'features/payment_methods/presentation/pages/payment_method_detail_page.dart';
import 'features/payment_methods/data/models/payment_method_model.dart';
import 'features/payment_methods/data/models/transfer_model.dart';
// home_app_bar.dart - Entegrasyon sonrası kullanılacak
import 'features/home/presentation/widgets/home_bottom_navigation.dart';
import 'features/home/presentation/widgets/month_year_picker_dialog.dart';

class AnaSayfa extends StatefulWidget {
  final AuthController authController;

  const AnaSayfa({super.key, required this.authController});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _selectedIndex = 0;
  late PageController _pageController;
  List<Map<String, dynamic>> tumHarcamalar = [];
  List<Map<String, dynamic>> gosterilenHarcamalar = [];
  List<Asset> varliklar = [];

  final TextEditingController tArama = TextEditingController();

  bool aramaModu = false;

  // Skeleton loading için yükleme durumu
  bool _isLoading = true;

  DateTime secilenAy = DateTime.now();

  double butceLimiti = 8000.0;

  Map<String, IconData> kategoriIkonlari = {};
  Map<String, IconData> gelirKategoriIkonlari = {};
  List<Income> tumGelirler = [];
  List<PaymentMethod> tumOdemeYontemleri = [];
  List<Transfer> tumTransferler = [];
  String? varsayilanOdemeYontemiId;

  // Gelir araması için
  final TextEditingController tGelirArama = TextEditingController();
  bool gelirAramaModu = false;

  // ===== MEMOIZATION: Hesaplama cache'leri =====
  // Bu değişkenler sadece veriler değiştiğinde yeniden hesaplanır
  double? _cachedToplamTutar;
  Map<String, double>? _cachedKategoriToplamlari;
  Map<String, List<Map<String, dynamic>>>? _cachedGunlukGruplar;
  int _cacheHarcamaHashCode = 0; // Cache invalidation için

  final List<String> aylarListesi = [
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
    _pageController = PageController(initialPage: _selectedIndex);
    kategorileriYukle();
    gelirKategorileriYukle();
    verileriOku();
    filtreleVeGoster();
    // Tekrarlayan işlemleri kontrol et (uygulama açıldığında)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tekrarlayanIslemleriKontrolEt();
      _tekrarlayanGelirleriKontrolEt();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    tArama.dispose();
    tGelirArama.dispose();
    super.dispose();
  }

  void kategorileriYukle() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> dbKategoriler = DatabaseHelper.kategorileriGetir(
      userId,
    );

    setState(() {
      kategoriIkonlari = {};
      for (var kategori in dbKategoriler) {
        String isim = kategori['isim'];
        String ikonAdi = kategori['ikon'];
        kategoriIkonlari[isim] = IconConstants.getHarcamaIkonu(ikonAdi);
      }
    });
  }

  void gelirKategorileriYukle() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> dbKategoriler =
        DatabaseHelper.gelirKategorileriGetir(userId);

    setState(() {
      gelirKategoriIkonlari = {};
      for (var kategori in dbKategoriler) {
        String isim = kategori['isim'];
        String ikonAdi = kategori['ikon'];
        gelirKategoriIkonlari[isim] = IconConstants.getGelirIkonu(ikonAdi);
      }
    });
  }

  void verileriOku() {
    String userId = widget.authController.currentUser!.id;

    // Harcamaları oku
    List<Map<String, dynamic>> gelen = DatabaseHelper.harcamalariGetir(userId);
    double kayitliButce = DatabaseHelper.butceGetir(userId);

    gelen.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    // Varlıkları oku
    List<Map<String, dynamic>> varlikVerileri = DatabaseHelper.varliklariGetir(
      userId,
    );
    List<Asset> okunanVarliklar = varlikVerileri
        .map((map) => Asset.fromMap(map))
        .toList();

    // Gelirleri oku
    List<Map<String, dynamic>> gelirVerileri = DatabaseHelper.gelirleriGetir(
      userId,
    );
    List<Income> okunanGelirler = gelirVerileri
        .map((map) => Income.fromMap(map))
        .toList();

    // Ödeme yöntemlerini oku
    List<Map<String, dynamic>> odemeVerileri =
        DatabaseHelper.odemeYontemleriGetir(userId);
    List<PaymentMethod> okunanOdemeYontemleri = odemeVerileri
        .map((map) => PaymentMethod.fromMap(map))
        .toList();
    // Varsayılan ödeme yöntemini oku
    String? varsayilanPm = DatabaseHelper.varsayilanOdemeYontemiGetir(userId);

    // Transferleri oku
    List<Map<String, dynamic>> transferVerileri =
        DatabaseHelper.transferleriGetir(userId);
    List<Transfer> okunanTransferler = transferVerileri
        .map((map) => Transfer.fromMap(map))
        .toList();

    setState(() {
      tumHarcamalar = gelen;
      butceLimiti = kayitliButce;
      varliklar = okunanVarliklar;
      tumGelirler = okunanGelirler;
      tumOdemeYontemleri = okunanOdemeYontemleri;
      tumTransferler = okunanTransferler;
      varsayilanOdemeYontemiId = varsayilanPm;
      _isLoading = false; // Skeleton loading tamamlandı
      filtreleVeGoster();
    });
  }

  /// Gelirleri veritabanına kaydeder
  void gelirleriKaydet() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> gelirMapleri = tumGelirler
        .map((income) => income.toMap())
        .toList();
    DatabaseHelper.gelirleriKaydet(userId, gelirMapleri);
  }

  /// Tekrarlayan işlemleri kontrol et ve gerekirse harcamalara ekle
  void _tekrarlayanIslemleriKontrolEt() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> tekrarlayanIslemler =
        DatabaseHelper.sabitGiderSablonlariGetir(userId);

    if (tekrarlayanIslemler.isEmpty) return;

    final bugun = DateTime.now();
    final buguninGunu = bugun.day;
    final buAy = '${bugun.year}-${bugun.month.toString().padLeft(2, '0')}';
    int eklenenAdet = 0;
    double toplamTutar = 0;
    List<String> yetersizBakiyeUyarilari = [];

    for (var islem in tekrarlayanIslemler) {
      final gun = islem['gun'] ?? 1;
      final sonIslemTarihi = islem['sonIslemTarihi'] as String?;

      // Bu ay zaten işlendi mi kontrol et
      final buAyIslendi =
          sonIslemTarihi != null && sonIslemTarihi.startsWith(buAy);

      // Eğer belirlenen gün bugün veya geçmişte VE bu ay işlenmedi ise
      if (gun <= buguninGunu && !buAyIslendi) {
        final tutar = (islem['tutar'] as num?)?.toDouble() ?? 0;
        final isim = islem['isim'] ?? 'Tekrarlayan İşlem';
        final odemeYontemiId = islem['odemeYontemiId'] as String?;

        // Harcama ekle - tarih belirlenen güne göre ayarlanır
        final islemTarihi = DateTime(bugun.year, bugun.month, gun);
        tumHarcamalar.add({
          'isim': isim,
          'tutar': tutar,
          'kategori': 'Tekrarlayan İşlemler',
          'tarih': islemTarihi.toString(),
          'silindi': false,
          'odemeYontemiId': odemeYontemiId,
        });

        // Ödeme yönteminden düş
        if (odemeYontemiId != null) {
          final pmIndex = tumOdemeYontemleri.indexWhere(
            (pm) => pm.id == odemeYontemiId,
          );
          if (pmIndex != -1) {
            final pm = tumOdemeYontemleri[pmIndex];
            double yeniBakiye;
            if (pm.type == 'kredi') {
              yeniBakiye = pm.balance + tutar; // Borç artar
            } else {
              yeniBakiye = pm.balance - tutar; // Bakiyeden düşer
              // Yetersiz bakiye kontrolü
              if (yeniBakiye < 0) {
                yetersizBakiyeUyarilari.add(
                  '${pm.name}: $isim için yetersiz bakiye',
                );
              }
            }
            tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: yeniBakiye);
          }
        }

        // Son işlem tarihini güncelle
        islem['sonIslemTarihi'] = bugun.toIso8601String().substring(0, 10);

        eklenenAdet++;
        toplamTutar += tutar;
      }
    }

    if (eklenenAdet > 0) {
      // Verileri kaydet
      DatabaseHelper.harcamalariKaydet(userId, tumHarcamalar);
      DatabaseHelper.sabitGiderSablonlariKaydet(userId, tekrarlayanIslemler);
      odemeYontemleriKaydet();

      setState(() {
        filtreleVeGoster();
      });

      // Bildirim göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$eklenenAdet tekrarlayan işlem otomatik eklendi (${toplamTutar.toStringAsFixed(0)} ₺)',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Yetersiz bakiye uyarıları
      if (yetersizBakiyeUyarilari.isNotEmpty && mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚠️ ${yetersizBakiyeUyarilari.length} hesapta yetersiz bakiye',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    }
  }

  /// Tekrarlayan gelirleri kontrol et ve gerekirse gelirlere ekle
  void _tekrarlayanGelirleriKontrolEt() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> tekrarlayanGelirler =
        DatabaseHelper.tekrarlayanGelirleriGetir(userId);

    if (tekrarlayanGelirler.isEmpty) return;

    final bugun = DateTime.now();
    final buguninGunu = bugun.day;
    final buAy = '${bugun.year}-${bugun.month.toString().padLeft(2, '0')}';
    int eklenenAdet = 0;
    double toplamTutar = 0;

    for (var gelir in tekrarlayanGelirler) {
      final gun = gelir['gun'] ?? 1;
      final sonIslemTarihi = gelir['sonIslemTarihi'] as String?;

      // Bu ay zaten işlendi mi kontrol et
      final buAyIslendi =
          sonIslemTarihi != null && sonIslemTarihi.startsWith(buAy);

      // Eğer belirlenen gün bugün veya geçmişte VE bu ay işlenmedi ise
      if (gun <= buguninGunu && !buAyIslendi) {
        final tutar = (gelir['tutar'] as num?)?.toDouble() ?? 0;
        final isim = gelir['isim'] ?? 'Tekrarlayan Gelir';
        final odemeYontemiId = gelir['odemeYontemiId'] as String?;

        // Gelir ekle - tarih belirlenen güne göre ayarlanır
        final islemTarihi = DateTime(bugun.year, bugun.month, gun);
        final yeniGelir = Income(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: isim,
          amount: tutar,
          category: 'Tekrarlayan Gelirler',
          date: islemTarihi,
          paymentMethodId: odemeYontemiId,
        );
        tumGelirler.add(yeniGelir);

        // Ödeme yöntemine ekle (bakiye artar)
        if (odemeYontemiId != null) {
          final pmIndex = tumOdemeYontemleri.indexWhere(
            (pm) => pm.id == odemeYontemiId,
          );
          if (pmIndex != -1) {
            final pm = tumOdemeYontemleri[pmIndex];
            double yeniBakiye;
            if (pm.type == 'kredi') {
              yeniBakiye = pm.balance - tutar; // Borç azalır
            } else {
              yeniBakiye = pm.balance + tutar; // Bakiye artar
            }
            tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: yeniBakiye);
          }
        }

        // Son işlem tarihini güncelle
        gelir['sonIslemTarihi'] = bugun.toIso8601String().substring(0, 10);

        eklenenAdet++;
        toplamTutar += tutar;
      }
    }

    if (eklenenAdet > 0) {
      // Verileri kaydet
      gelirleriKaydet();
      DatabaseHelper.tekrarlayanGelirleriKaydet(userId, tekrarlayanGelirler);
      odemeYontemleriKaydet();

      setState(() {});

      // Bildirim göster
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$eklenenAdet tekrarlayan gelir otomatik eklendi (+${toplamTutar.toStringAsFixed(0)} ₺)',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        });
      }
    }
  }

  void filtreleVeGoster() {
    setState(() {
      List<Map<String, dynamic>> aktifHarcamalar = tumHarcamalar
          .where((h) => h['silindi'] != true)
          .toList();

      if (aramaModu) {
        String aranan = tArama.text.toLowerCase();
        gosterilenHarcamalar = aktifHarcamalar.where((h) {
          return h['isim'].toString().toLowerCase().contains(aranan);
        }).toList();
      } else {
        gosterilenHarcamalar = aktifHarcamalar.where((h) {
          DateTime hTarih =
              DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
          return hTarih.year == secilenAy.year &&
              hTarih.month == secilenAy.month;
        }).toList();
      }
    });
  }

  void verileriKaydet() {
    String userId = widget.authController.currentUser!.id;
    DatabaseHelper.harcamalariKaydet(userId, tumHarcamalar);
  }

  /// Varlıkları veritabanına kaydeder
  void varliklariKaydet() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> varlikMapleri = varliklar
        .map((asset) => asset.toMap())
        .toList();
    DatabaseHelper.varliklariKaydet(userId, varlikMapleri);
  }

  /// Ödeme yöntemlerini veritabanına kaydeder
  void odemeYontemleriKaydet() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> yontemMapleri = tumOdemeYontemleri
        .map((pm) => pm.toMap())
        .toList();
    DatabaseHelper.odemeYontemleriKaydet(userId, yontemMapleri);
  }

  /// Transferleri veritabanına kaydeder
  void transferleriKaydet() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> transferMapleri = tumTransferler
        .map((t) => t.toMap())
        .toList();
    DatabaseHelper.transferleriKaydet(userId, transferMapleri);
  }

  void oncekiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month - 1);
      filtreleVeGoster();
    });
  }

  void sonrakiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month + 1);
      filtreleVeGoster();
    });
  }

  void ayYilSeciciAc() {
    MonthYearPickerDialog.show(
      context,
      secilenAy: secilenAy,
      aylarListesi: aylarListesi,
      onSecildi: (yil, ay) {
        setState(() {
          secilenAy = DateTime(yil, ay);
          filtreleVeGoster();
        });
      },
    );
  }

  // Cache invalidation: harcama listesi değiştiğinde çağrılmalı
  void _invalidateCache() {
    _cachedToplamTutar = null;
    _cachedKategoriToplamlari = null;
    _cachedGunlukGruplar = null;
  }

  // Mevcut harcama listesinin hash'ini hesapla
  int _calculateHarcamaHash() {
    return Object.hashAll([
      gosterilenHarcamalar.length,
      if (gosterilenHarcamalar.isNotEmpty) gosterilenHarcamalar.first.hashCode,
      if (gosterilenHarcamalar.length > 1) gosterilenHarcamalar.last.hashCode,
    ]);
  }

  // Cache'in geçerli olup olmadığını kontrol et
  void _checkCacheValidity() {
    final currentHash = _calculateHarcamaHash();
    if (_cacheHarcamaHashCode != currentHash) {
      _invalidateCache();
      _cacheHarcamaHashCode = currentHash;
    }
  }

  double get toplamTutar {
    _checkCacheValidity();
    if (_cachedToplamTutar != null) return _cachedToplamTutar!;

    double toplam = 0;
    for (var h in gosterilenHarcamalar) {
      toplam += double.tryParse(h['tutar'].toString()) ?? 0;
    }
    _cachedToplamTutar = toplam;
    return toplam;
  }

  Map<String, double> get kategoriToplamlari {
    _checkCacheValidity();
    if (_cachedKategoriToplamlari != null) return _cachedKategoriToplamlari!;

    Map<String, double> toplamlar = {};
    for (var kat in kategoriIkonlari.keys) {
      toplamlar[kat] = 0;
    }
    for (var h in gosterilenHarcamalar) {
      String kat = h['kategori'] ?? "Diğer";
      double tutar = double.tryParse(h['tutar'].toString()) ?? 0;
      if (toplamlar.containsKey(kat)) {
        toplamlar[kat] = (toplamlar[kat] ?? 0) + tutar;
      } else {
        toplamlar[kat] = tutar;
      }
    }
    _cachedKategoriToplamlari = toplamlar;
    return toplamlar;
  }

  Map<String, List<Map<String, dynamic>>> get gunlukGruplanmisHarcamalar {
    _checkCacheValidity();
    if (_cachedGunlukGruplar != null) return _cachedGunlukGruplar!;

    Map<String, List<Map<String, dynamic>>> gruplar = {};

    for (var h in gosterilenHarcamalar) {
      DateTime tarih =
          DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
      String tarihBasligi = tarihFormatla(tarih);

      if (!gruplar.containsKey(tarihBasligi)) {
        gruplar[tarihBasligi] = [];
      }
      gruplar[tarihBasligi]!.add(h);
    }
    _cachedGunlukGruplar = gruplar;
    return gruplar;
  }

  String tarihFormatla(DateTime tarih) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final oTarih = DateTime(tarih.year, tarih.month, tarih.day);
    final fark = bugun.difference(oTarih).inDays;

    if (fark == 0) return "Bugün";
    if (fark == 1) return "Dün";

    return "${oTarih.day} ${aylarListesi[oTarih.month - 1]}";
  }

  void harcamaSil(Map<String, dynamic> harcama) {
    setState(() {
      harcama['silindi'] = true;

      // Ödeme yönteminin bakiyesini geri ekle
      final paymentMethodId = harcama['odemeYontemiId'];
      if (paymentMethodId != null) {
        final pmIndex = tumOdemeYontemleri.indexWhere(
          (p) => p.id == paymentMethodId,
        );
        if (pmIndex != -1) {
          final pm = tumOdemeYontemleri[pmIndex];
          final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
          double newBalance;
          if (pm.type == 'kredi') {
            // Kredi kartı: borcu azalt
            newBalance = pm.balance - amount;
          } else {
            // Banka kartı/Nakit: bakiyeyi artır
            newBalance = pm.balance + amount;
          }
          tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
        }
      }

      filtreleVeGoster();
    });
    verileriKaydet();
    odemeYontemleriKaydet(); // Ödeme yöntemleri bakiyelerini kaydet

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Harcama çöp kutusuna taşındı 🗑️",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorConstants.koyuKirmizi,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void pencereAc({Map<String, dynamic>? duzenlenecekHarcama}) {
    // Düzenleme yapılıyorsa eski tutarı sakla
    final eskiTutar = duzenlenecekHarcama != null
        ? double.tryParse(duzenlenecekHarcama['tutar'].toString()) ?? 0.0
        : 0.0;
    final eskiOdemeYontemiId = duzenlenecekHarcama?['odemeYontemiId'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(
        expenseToEdit: duzenlenecekHarcama,
        categories: kategoriIkonlari,
        paymentMethods: tumOdemeYontemleri
            .where((pm) => !pm.isDeleted)
            .toList(),
        defaultPaymentMethodId: varsayilanOdemeYontemiId,
        onSave: (name, amount, category, date, paymentMethodId) {
          setState(() {
            // Bakiye güncelleme mantığı
            void updateBalance(String? pmId, double amountChange) {
              if (pmId == null) return;
              final pmIndex = tumOdemeYontemleri.indexWhere(
                (p) => p.id == pmId,
              );
              if (pmIndex == -1) return;

              final pm = tumOdemeYontemleri[pmIndex];
              double newBalance;
              if (pm.type == 'kredi') {
                // Kredi kartı: borca ekle
                newBalance = pm.balance + amountChange;
              } else {
                // Banka kartı/Nakit: bakiyeden düş
                newBalance = pm.balance - amountChange;
              }
              tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: newBalance);
            }

            if (duzenlenecekHarcama != null) {
              // Düzenleme: eski tutarı geri ekle, yeni tutarı düş
              if (eskiOdemeYontemiId != null) {
                updateBalance(
                  eskiOdemeYontemiId,
                  -eskiTutar,
                ); // Eski tutarı geri ekle
              }
              if (paymentMethodId != null) {
                updateBalance(paymentMethodId, amount); // Yeni tutarı düş
              }

              int index = tumHarcamalar.indexOf(duzenlenecekHarcama);
              if (index != -1) {
                tumHarcamalar[index] = {
                  "isim": name,
                  "tutar": amount,
                  "kategori": category,
                  "tarih": date.toString(),
                  "silindi": false,
                  "odemeYontemiId": paymentMethodId,
                };
              }
            } else {
              // Yeni harcama: sadece düş
              if (paymentMethodId != null) {
                updateBalance(paymentMethodId, amount);
              }

              tumHarcamalar.add({
                "isim": name,
                "tutar": amount,
                "kategori": category,
                "tarih": date.toString(),
                "silindi": false,
                "odemeYontemiId": paymentMethodId,
              });
            }

            tumHarcamalar.sort((a, b) {
              DateTime tarihA =
                  DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
              DateTime tarihB =
                  DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
              return tarihB.compareTo(tarihA);
            });

            filtreleVeGoster();
          });
          verileriKaydet();
          odemeYontemleriKaydet(); // Ödeme yöntemleri bakiyelerini kaydet

          // Yeni harcama eklendiyse para animasyonu göster
          if (duzenlenecekHarcama == null) {
            if (context.read<ThemeManager>().isMoneyAnimationEnabled) {
              MoneyAnimationOverlay.show(context);
            }
          }
        },
      ),
    );
  }

  String get ayIsmi {
    return "${aylarListesi[secilenAy.month - 1]} ${secilenAy.year}";
  }

  @override
  Widget build(BuildContext context) {
    DateTime simdi = DateTime.now();
    bool buAyMi =
        (secilenAy.year == simdi.year && secilenAy.month == simdi.month);

    Map<String, double> katToplamlar = kategoriToplamlari;
    List<MapEntry<String, double>> aktifKategoriler = katToplamlar.entries
        .where((e) => e.value > 0)
        .toList();
    aktifKategoriler.sort((a, b) => b.value.compareTo(a.value));

    // Bütçe hesaplamaları - onCheckBudget callback için gerekli
    double kalanLimit = butceLimiti - toplamTutar;
    double asilanMiktar = toplamTutar - butceLimiti;

    Map<String, List<Map<String, dynamic>>> gruplar =
        gunlukGruplanmisHarcamalar;

    // Harcamalar Sayfası İçeriği (Body)
    Widget harcamalarBody = _isLoading
        // Skeleton Loading - Yükleme sırasında gösterilir
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ExpenseSummarySkeleton(),
                const SizedBox(height: 10),
                ...List.generate(5, (index) => const ExpenseCardSkeleton()),
              ],
            ),
          )
        : Column(
            children: [
              if (!aramaModu) ...[
                ExpenseSummaryCard(
                  ayIsmi: ayIsmi,
                  toplamTutar: toplamTutar,
                  butceLimiti: butceLimiti,
                  oncekiAy: oncekiAy,
                  sonrakiAy: sonrakiAy,
                  ayYilSeciciAc: ayYilSeciciAc,
                ),
                const SizedBox(height: 10),
              ],

              Expanded(
                child: gosterilenHarcamalar.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              aramaModu
                                  ? Icons.search_off
                                  : Icons.account_balance_wallet,
                              size: 60,
                              color: Colors.white12,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              aramaModu
                                  ? "Sonuç bulunamadı."
                                  : "$ayIsmi için harcama yok.",
                              style: const TextStyle(color: Colors.white24),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        itemCount: gruplar.keys.length,
                        itemBuilder: (context, index) {
                          String gunBasligi = gruplar.keys.elementAt(index);
                          List<Map<String, dynamic>> harcamalar =
                              gruplar[gunBasligi]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  bottom: 5,
                                  top: 10,
                                ),
                                child: Text(
                                  gunBasligi.toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.54),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              ...harcamalar.map((harcama) {
                                return ExpenseListItem(
                                  harcama: harcama,
                                  categoryIcon:
                                      kategoriIkonlari[harcama['kategori']],
                                  paymentMethods: tumOdemeYontemleri,
                                  itemIndex: gosterilenHarcamalar.indexOf(
                                    harcama,
                                  ),
                                  onDelete: () => harcamaSil(harcama),
                                  onTap: () =>
                                      pencereAc(duzenlenecekHarcama: harcama),
                                );
                              }),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );

    // AppBar Seçimi
    PreferredSizeWidget? appBar;
    if (_selectedIndex == 0) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: aramaModu
            ? TextField(
                controller: tArama,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Harcama ara...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
                onChanged: (val) => filtreleVeGoster(),
              )
            : const Text("Harcamalarım"),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!aramaModu && !buAyMi)
            TextButton(
              onPressed: () {
                setState(() {
                  secilenAy = DateTime.now();
                  filtreleVeGoster();
                });
              },
              child: Text(
                "Bugüne git",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          if (!aramaModu) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: "Çöp Kutusu",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CopKutusuSayfasi(
                      userId: widget.authController.currentUser!.id,
                    ),
                  ),
                ).then((_) {
                  verileriOku();
                });
              },
            ),
            // Sesli harcama girişi butonu
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              tooltip: "Sesli Giriş",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => VoiceInputSheet(
                    categoryIcons: kategoriIkonlari,
                    userId: widget.authController.currentUser?.id,
                    onConfirm: (name, amount, category, date) {
                      setState(() {
                        tumHarcamalar.add({
                          "isim": name,
                          "tutar": amount,
                          "kategori": category,
                          "tarih": date.toString(),
                          "silindi": false,
                        });

                        tumHarcamalar.sort((a, b) {
                          DateTime tarihA =
                              DateTime.tryParse(a['tarih'].toString()) ??
                              DateTime.now();
                          DateTime tarihB =
                              DateTime.tryParse(b['tarih'].toString()) ??
                              DateTime.now();
                          return tarihB.compareTo(tarihA);
                        });

                        filtreleVeGoster();
                      });
                      verileriKaydet();

                      // Para animasyonu göster 💰
                      if (context
                          .read<ThemeManager>()
                          .isMoneyAnimationEnabled) {
                        MoneyAnimationOverlay.show(context);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Harcama eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(12),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    // Sesli komut: Son harcamayı sil
                    onDeleteLastExpense: () async {
                      // Bu ayın harcamalarından son eklenen (silindi=false) olanı bul
                      final buAyHarcamalari = tumHarcamalar.where((h) {
                        if (h['silindi'] == true) return false;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih == null) return false;
                        return tarih.year == secilenAy.year &&
                            tarih.month == secilenAy.month;
                      }).toList();

                      if (buAyHarcamalari.isEmpty) return null;

                      // En son eklenen harcamayı bul (tarihe göre sırala)
                      buAyHarcamalari.sort((a, b) {
                        DateTime tarihA =
                            DateTime.tryParse(a['tarih'].toString()) ??
                            DateTime.now();
                        DateTime tarihB =
                            DateTime.tryParse(b['tarih'].toString()) ??
                            DateTime.now();
                        return tarihB.compareTo(tarihA);
                      });

                      final sonHarcama = buAyHarcamalari.first;

                      // Harcamayı sil (soft delete)
                      setState(() {
                        sonHarcama['silindi'] = true;
                        filtreleVeGoster();
                      });
                      verileriKaydet();

                      return sonHarcama;
                    },
                    // Sesli komut: Bu ay ne kadar harcadım?
                    onGetMonthlyTotal: () {
                      return toplamTutar;
                    },
                    // Sesli komut: En çok hangi kategoride harcamışım?
                    onGetTopCategory: () {
                      if (kategoriToplamlari.isEmpty) return null;

                      String? enCokKategori;
                      double enYuksekTutar = 0;

                      kategoriToplamlari.forEach((kategori, tutar) {
                        if (tutar > enYuksekTutar) {
                          enYuksekTutar = tutar;
                          enCokKategori = kategori;
                        }
                      });

                      if (enCokKategori == null || enYuksekTutar == 0) {
                        return null;
                      }

                      return {
                        'kategori': enCokKategori,
                        'tutar': enYuksekTutar,
                      };
                    },
                    // Sesli komut: Bu hafta ne kadar harcadım?
                    onGetWeeklyTotal: () {
                      final now = DateTime.now();
                      final weekStart = now.subtract(
                        Duration(days: now.weekday - 1),
                      );

                      double haftalikToplam = 0;
                      for (var h in tumHarcamalar) {
                        if (h['silindi'] == true) continue;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih != null &&
                            tarih.isAfter(
                              weekStart.subtract(const Duration(days: 1)),
                            ) &&
                            tarih.isBefore(now.add(const Duration(days: 1)))) {
                          haftalikToplam +=
                              (h['tutar'] as num?)?.toDouble() ?? 0;
                        }
                      }
                      return haftalikToplam;
                    },
                    // Sesli komut: Bugün ne kadar harcadım?
                    onGetDailyTotal: () {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      double gunlukToplam = 0;
                      for (var h in tumHarcamalar) {
                        if (h['silindi'] == true) continue;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih != null) {
                          final harcamaTarihi = DateTime(
                            tarih.year,
                            tarih.month,
                            tarih.day,
                          );
                          if (harcamaTarihi.isAtSameMomentAs(today)) {
                            gunlukToplam +=
                                (h['tutar'] as num?)?.toDouble() ?? 0;
                          }
                        }
                      }
                      return gunlukToplam;
                    },
                    // Sesli komut: Son harcamalarım neler?
                    onGetLastExpenses: () {
                      final buAyHarcamalari = tumHarcamalar.where((h) {
                        if (h['silindi'] == true) return false;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih == null) return false;
                        return tarih.year == secilenAy.year &&
                            tarih.month == secilenAy.month;
                      }).toList();

                      buAyHarcamalari.sort((a, b) {
                        DateTime tarihA =
                            DateTime.tryParse(a['tarih'].toString()) ??
                            DateTime.now();
                        DateTime tarihB =
                            DateTime.tryParse(b['tarih'].toString()) ??
                            DateTime.now();
                        return tarihB.compareTo(tarihA);
                      });

                      return buAyHarcamalari.take(5).toList();
                    },
                    // Sesli komut: Bütçemi aştım mı? / Kalan bütçem ne kadar?
                    onCheckBudget: () {
                      return {
                        'kalanLimit': kalanLimit > 0 ? kalanLimit : 0,
                        'asilanMiktar': asilanMiktar,
                        'butceLimiti': butceLimiti,
                      };
                    },
                    // Sesli komut: Kategoride ne kadar harcadım?
                    onGetCategoryTotal: (String kategori) {
                      return kategoriToplamlari[kategori] ?? 0.0;
                    },
                    // Sesli komut: Sabit giderleri ekle
                    onAddFixedExpenses: () async {
                      final sabitGiderler =
                          DatabaseHelper.sabitGiderSablonlariGetir(
                            widget.authController.currentUser!.id,
                          );

                      if (sabitGiderler.isEmpty) {
                        return {'adet': 0, 'toplam': 0.0};
                      }

                      DateTime simdi = DateTime.now();
                      double toplam = 0;

                      for (var sablon in sabitGiderler) {
                        double tutar =
                            (sablon['tutar'] as num?)?.toDouble() ?? 0;
                        toplam += tutar;
                        tumHarcamalar.add({
                          'isim': sablon['isim'],
                          'tutar': tutar,
                          'kategori': 'Sabit Giderler',
                          'tarih': simdi.toString(),
                          'silindi': false,
                        });
                      }

                      verileriKaydet();
                      setState(() {
                        filtreleVeGoster();
                      });

                      return {'adet': sabitGiderler.length, 'toplam': toplam};
                    },
                    // Sesli komut: Son harcamayı düzenle
                    onEditLastExpense: (double yeniTutar) async {
                      // Bu ayın harcamalarından son eklenen (silindi=false) olanı bul
                      final buAyHarcamalari = tumHarcamalar.where((h) {
                        if (h['silindi'] == true) return false;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih == null) return false;
                        return tarih.year == secilenAy.year &&
                            tarih.month == secilenAy.month;
                      }).toList();

                      if (buAyHarcamalari.isEmpty) return null;

                      // Son harcamayı bul (tarih sıralı)
                      buAyHarcamalari.sort((a, b) {
                        DateTime tarihA =
                            DateTime.tryParse(a['tarih'].toString()) ??
                            DateTime.now();
                        DateTime tarihB =
                            DateTime.tryParse(b['tarih'].toString()) ??
                            DateTime.now();
                        return tarihB.compareTo(tarihA);
                      });

                      final sonHarcama = buAyHarcamalari.first;
                      final eskiTutar =
                          (sonHarcama['tutar'] as num?)?.toDouble() ?? 0;
                      final isim = sonHarcama['isim'] ?? 'Harcama';

                      // 0 TL ise harcamayı sil
                      if (yeniTutar == 0) {
                        sonHarcama['silindi'] = true;
                      } else {
                        // Tutarı güncelle
                        sonHarcama['tutar'] = yeniTutar;
                      }

                      // Veriyi kaydet - setState bottom sheet kapandıktan sonra çağrılacak
                      verileriKaydet();

                      // setState'i erteleyerek çağır (bottom sheet kapandıktan sonra)
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          setState(() {
                            filtreleVeGoster();
                          });
                        }
                      });

                      return {
                        'isim': isim,
                        'eskiTutar': eskiTutar,
                        'yeniTutar': yeniTutar,
                        'silindi': yeniTutar == 0,
                      };
                    },
                    // Sesli komut: Tarihli harcama sorgusu
                    onGetDateRangeTotal: (DateTime baslangic, DateTime bitis) {
                      double toplam = 0;
                      final baslangicGun = DateTime(
                        baslangic.year,
                        baslangic.month,
                        baslangic.day,
                      );
                      final bitisGun = DateTime(
                        bitis.year,
                        bitis.month,
                        bitis.day,
                      );

                      for (var h in tumHarcamalar) {
                        if (h['silindi'] == true) continue;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih != null) {
                          final harcamaTarihi = DateTime(
                            tarih.year,
                            tarih.month,
                            tarih.day,
                          );
                          if ((harcamaTarihi.isAtSameMomentAs(baslangicGun) ||
                                  harcamaTarihi.isAfter(baslangicGun)) &&
                              (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                                  harcamaTarihi.isBefore(bitisGun))) {
                            toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
                          }
                        }
                      }
                      return toplam;
                    },
                    // Sesli komut: Tarihli kategori sorgusu
                    onGetDateRangeCategoryTotal:
                        (DateTime baslangic, DateTime bitis, String kategori) {
                          double toplam = 0;
                          final baslangicGun = DateTime(
                            baslangic.year,
                            baslangic.month,
                            baslangic.day,
                          );
                          final bitisGun = DateTime(
                            bitis.year,
                            bitis.month,
                            bitis.day,
                          );

                          for (var h in tumHarcamalar) {
                            if (h['silindi'] == true) continue;
                            if (h['kategori'] != kategori) continue;
                            DateTime? tarih = DateTime.tryParse(
                              h['tarih'].toString(),
                            );
                            if (tarih != null) {
                              final harcamaTarihi = DateTime(
                                tarih.year,
                                tarih.month,
                                tarih.day,
                              );
                              if ((harcamaTarihi.isAtSameMomentAs(
                                        baslangicGun,
                                      ) ||
                                      harcamaTarihi.isAfter(baslangicGun)) &&
                                  (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                                      harcamaTarihi.isBefore(bitisGun))) {
                                toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
                              }
                            }
                          }
                          return toplam;
                        },
                    // Sesli komut: Aylık limitimi X lira yap
                    onSetBudgetLimit: (double yeniLimit) async {
                      await DatabaseHelper.butceKaydet(
                        widget.authController.currentUser!.id,
                        yeniLimit,
                      );
                      setState(() {
                        butceLimiti = yeniLimit;
                        filtreleVeGoster();
                      });
                    },
                    // Sesli komut: Bu ay ne kadar tasarruf ettim?
                    onGetSavings: () {
                      // Tasarruf = Bütçe - Harcama
                      final tasarruf = butceLimiti - toplamTutar;
                      return {'tasarruf': tasarruf, 'butceLimiti': butceLimiti};
                    },
                  ),
                );
              },
            ),
          ],
          IconButton(
            icon: Icon(
              aramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                aramaModu = !aramaModu;
                if (!aramaModu) {
                  tArama.clear();
                }
                filtreleVeGoster();
              });
            },
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: gelirAramaModu
            ? TextField(
                controller: tGelirArama,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Gelir ara...",
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text("Gelirlerim"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Çöp Kutusu",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GelirCopKutusuSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              ).then((_) {
                verileriOku();
              });
            },
          ),
          IconButton(
            icon: Icon(
              gelirAramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                gelirAramaModu = !gelirAramaModu;
                if (!gelirAramaModu) {
                  tGelirArama.clear();
                }
              });
            },
          ),
        ],
      );
    } else if (_selectedIndex == 2) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Araçlar"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    } else if (_selectedIndex == 3) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    }

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _pageController.jumpToPage(0);
        }
      },
      child: Scaffold(
        appBar: appBar,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            // Sayfa 0: Harcamalarım
            harcamalarBody,
            // Sayfa 1: Gelirlerim
            _isLoading
                ? const IncomePageSkeleton()
                : IncomePage(
                    incomes: tumGelirler,
                    selectedDate: secilenAy,
                    searchQuery: gelirAramaModu ? tGelirArama.text : '',
                    onDelete: (income) {
                      setState(() {
                        income.isDeleted = true;

                        // Bakiyeyi geri al (Silme işlemi)
                        if (income.paymentMethodId != null) {
                          final pmIndex = tumOdemeYontemleri.indexWhere(
                            (p) => p.id == income.paymentMethodId,
                          );
                          if (pmIndex != -1) {
                            final pm = tumOdemeYontemleri[pmIndex];
                            double yeniBakiye;
                            if (pm.type == 'kredi') {
                              // Kredi: Gelir silinince borç artar
                              yeniBakiye = pm.balance + income.amount;
                            } else {
                              // Banka/Nakit: Gelir silinince bakiye azalır
                              yeniBakiye = pm.balance - income.amount;
                            }
                            tumOdemeYontemleri[pmIndex] = pm.copyWith(
                              balance: yeniBakiye,
                            );
                            odemeYontemleriKaydet();
                          }
                        }
                      });
                      gelirleriKaydet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Gelir silindi 🗑️",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(12),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onEdit: (income) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AddIncomeSheet(
                          incomeToEdit: income.toMap(),
                          categories: gelirKategoriIkonlari,
                          paymentMethods: tumOdemeYontemleri
                              .where((pm) => !pm.isDeleted)
                              .toList(),
                          onSave:
                              (name, amount, category, date, paymentMethodId) {
                                setState(() {
                                  // 1. Eski bakiyeyi geri al
                                  if (income.paymentMethodId != null) {
                                    final eskiPmIndex = tumOdemeYontemleri
                                        .indexWhere(
                                          (p) => p.id == income.paymentMethodId,
                                        );
                                    if (eskiPmIndex != -1) {
                                      final pm =
                                          tumOdemeYontemleri[eskiPmIndex];
                                      double yeniBakiye;
                                      if (pm.type == 'kredi') {
                                        yeniBakiye = pm.balance + income.amount;
                                      } else {
                                        yeniBakiye = pm.balance - income.amount;
                                      }
                                      tumOdemeYontemleri[eskiPmIndex] = pm
                                          .copyWith(balance: yeniBakiye);
                                    }
                                  }

                                  // 2. Yeni bakiyeyi ekle
                                  if (paymentMethodId != null) {
                                    final yeniPmIndex = tumOdemeYontemleri
                                        .indexWhere(
                                          (p) => p.id == paymentMethodId,
                                        );
                                    if (yeniPmIndex != -1) {
                                      final pm =
                                          tumOdemeYontemleri[yeniPmIndex];
                                      double yeniBakiye;
                                      if (pm.type == 'kredi') {
                                        yeniBakiye = pm.balance - amount;
                                      } else {
                                        yeniBakiye = pm.balance + amount;
                                      }
                                      tumOdemeYontemleri[yeniPmIndex] = pm
                                          .copyWith(balance: yeniBakiye);
                                    }
                                  }
                                  odemeYontemleriKaydet();

                                  // 3. Geliri güncelle
                                  int index = tumGelirler.indexOf(income);
                                  if (index != -1) {
                                    tumGelirler[index] = Income(
                                      id: income.id,
                                      name: name,
                                      amount: amount,
                                      category: category,
                                      date: date,
                                      paymentMethodId: paymentMethodId,
                                      isDeleted: false,
                                    );
                                  }
                                });
                                gelirleriKaydet();
                              },
                        ),
                      );
                    },
                    onPreviousMonth: () {
                      setState(() {
                        secilenAy = DateTime(
                          secilenAy.year,
                          secilenAy.month - 1,
                        );
                      });
                    },
                    onNextMonth: () {
                      setState(() {
                        secilenAy = DateTime(
                          secilenAy.year,
                          secilenAy.month + 1,
                        );
                      });
                    },
                    onSelectMonth: ayYilSeciciAc,
                  ),
            // Sayfa 2: Araçlar
            ToolsPage(
              onAssetsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssetsPage(
                      assets: varliklar.where((a) => !a.isDeleted).toList(),
                      deletedAssets: varliklar
                          .where((a) => a.isDeleted)
                          .toList(),
                      onDelete: (asset) {
                        setState(() {
                          asset.isDeleted = true;
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık çöp kutusuna taşındı 🗑️",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: ColorConstants.koyuKirmizi,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onEdit: (asset) {
                        setState(() {
                          int index = varliklar.indexWhere(
                            (a) => a.id == asset.id,
                          );
                          if (index != -1) {
                            varliklar[index] = asset;
                          }
                        });
                        varliklariKaydet();
                      },
                      onRestore: (asset) {
                        setState(() {
                          asset.isDeleted = false;
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık geri yüklendi ♻️",
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
                      },
                      onPermanentDelete: (asset) {
                        setState(() {
                          varliklar.remove(asset);
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık kalıcı olarak silindi ❌",
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
                      },
                      onEmptyBin: () {
                        setState(() {
                          varliklar.removeWhere((a) => a.isDeleted);
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Çöp kutusu boşaltıldı 🧹",
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
                      },
                      onAdd: (name, amount, quantity, category, type) {
                        setState(() {
                          varliklar.add(
                            Asset(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: name,
                              amount: amount,
                              quantity: quantity,
                              category: category,
                              type: type,
                              lastUpdated: DateTime.now(),
                              isDeleted: false,
                            ),
                          );
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık eklendi ✅",
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
                      },
                    ),
                  ),
                );
              },
              onAnalysisPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnalysisPage(
                      expenses: tumHarcamalar,
                      assets: varliklar,
                      incomes: tumGelirler,
                      selectedDate: secilenAy,
                      paymentMethods: tumOdemeYontemleri
                          .where((pm) => !pm.isDeleted)
                          .toList(),
                    ),
                  ),
                );
              },
              onPaymentMethodsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodsPage(
                      paymentMethods: tumOdemeYontemleri
                          .where((pm) => !pm.isDeleted)
                          .toList(),
                      deletedPaymentMethods: tumOdemeYontemleri
                          .where((pm) => pm.isDeleted)
                          .toList(),
                      onDelete: (pm) {
                        setState(() {
                          final index = tumOdemeYontemleri.indexWhere(
                            (p) => p.id == pm.id,
                          );
                          if (index != -1) {
                            tumOdemeYontemleri[index] = pm.copyWith(
                              isDeleted: true,
                            );
                          }

                          // Silinen ödeme yöntemi varsayılansa varsayılanı temizle
                          if (varsayilanOdemeYontemiId == pm.id) {
                            varsayilanOdemeYontemiId = null;
                            DatabaseHelper.varsayilanOdemeYontemiKaydet(
                              widget.authController.currentUser!.id,
                              null,
                            );
                          }
                        });
                        odemeYontemleriKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Ödeme yöntemi çöp kutusuna taşındı 🗑️",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: ColorConstants.koyuKirmizi,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onEdit: (pm) {
                        setState(() {
                          int index = tumOdemeYontemleri.indexWhere(
                            (p) => p.id == pm.id,
                          );
                          if (index != -1) {
                            tumOdemeYontemleri[index] = pm;
                          }
                        });
                        odemeYontemleriKaydet();
                      },
                      onRestore: (pm) {
                        setState(() {
                          final index = tumOdemeYontemleri.indexWhere(
                            (p) => p.id == pm.id,
                          );
                          if (index != -1) {
                            // Bu PM'e bağlı aktif harcamaların toplamını hesapla
                            double toplamHarcama = 0;
                            for (var h in tumHarcamalar) {
                              if (h['odemeYontemiId'] == pm.id &&
                                  h['silindi'] != true) {
                                toplamHarcama +=
                                    double.tryParse(h['tutar'].toString()) ?? 0;
                              }
                            }

                            // Bakiyeyi ayarla
                            double yeniBakiye;
                            if (pm.type == 'kredi') {
                              // Kredi kartı: borç = toplam harcama
                              yeniBakiye = toplamHarcama;
                            } else {
                              // Banka/Nakit: bakiye düşürülür
                              yeniBakiye = pm.balance - toplamHarcama;
                            }

                            tumOdemeYontemleri[index] = pm.copyWith(
                              isDeleted: false,
                              balance: yeniBakiye,
                            );
                          }
                        });
                        odemeYontemleriKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Ödeme yöntemi geri yüklendi ♻️",
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
                      },
                      onPermanentDelete: (pm) {
                        setState(() {
                          tumOdemeYontemleri.removeWhere((p) => p.id == pm.id);

                          // Bu PM'e bağlı harcamaların odemeYontemiId'sini temizle
                          for (var h in tumHarcamalar) {
                            if (h['odemeYontemiId'] == pm.id) {
                              h['odemeYontemiId'] = null;
                            }
                          }

                          // Bu PM'e bağlı gelirlerin paymentMethodId'sini temizle
                          for (var g in tumGelirler) {
                            if (g.paymentMethodId == pm.id) {
                              final index = tumGelirler.indexOf(g);
                              tumGelirler[index] = g.copyWith(
                                paymentMethodId: null,
                              );
                            }
                          }

                          // Bu PM'e bağlı transferleri sil
                          tumTransferler.removeWhere(
                            (t) =>
                                t.fromAccountId == pm.id ||
                                t.toAccountId == pm.id,
                          );
                        });

                        // Tekrarlayan işlemlerde bu PM'e bağlı olanları temizle
                        final userId = widget.authController.currentUser!.id;

                        // Tekrarlayan giderler
                        List<Map<String, dynamic>> tekrarlayanIslemler =
                            DatabaseHelper.sabitGiderSablonlariGetir(userId);
                        tekrarlayanIslemler.removeWhere(
                          (islem) => islem['odemeYontemiId'] == pm.id,
                        );
                        DatabaseHelper.sabitGiderSablonlariKaydet(
                          userId,
                          tekrarlayanIslemler,
                        );

                        // Tekrarlayan gelirler
                        List<Map<String, dynamic>> tekrarlayanGelirler =
                            DatabaseHelper.tekrarlayanGelirleriGetir(userId);
                        tekrarlayanGelirler.removeWhere(
                          (gelir) => gelir['odemeYontemiId'] == pm.id,
                        );
                        DatabaseHelper.tekrarlayanGelirleriKaydet(
                          userId,
                          tekrarlayanGelirler,
                        );

                        odemeYontemleriKaydet();
                        verileriKaydet(); // Harcamaları kaydet
                        gelirleriKaydet(); // Gelirleri kaydet
                        transferleriKaydet(); // Transferleri kaydet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Ödeme yöntemi kalıcı olarak silindi ❌",
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
                      },
                      onEmptyBin: () {
                        setState(() {
                          // Silinen PM'lerin ID'lerini al
                          final silinenIdler = tumOdemeYontemleri
                              .where((pm) => pm.isDeleted)
                              .map((pm) => pm.id)
                              .toSet();

                          // Bu PM'lere bağlı harcamaların odemeYontemiId'sini temizle
                          for (var h in tumHarcamalar) {
                            if (silinenIdler.contains(h['odemeYontemiId'])) {
                              h['odemeYontemiId'] = null;
                            }
                          }

                          tumOdemeYontemleri.removeWhere((pm) => pm.isDeleted);
                        });
                        odemeYontemleriKaydet();
                        verileriKaydet(); // Harcamaları da kaydet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Çöp kutusu boşaltıldı 🧹",
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
                      },
                      onAdd:
                          (
                            name,
                            type,
                            lastFourDigits,
                            balance,
                            limit,
                            colorIndex,
                          ) {
                            setState(() {
                              tumOdemeYontemleri.add(
                                PaymentMethod(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  name: name,
                                  type: type,
                                  lastFourDigits: lastFourDigits,
                                  balance: balance,
                                  limit: limit,
                                  colorIndex: colorIndex,
                                  createdAt: DateTime.now(),
                                  isDeleted: false,
                                ),
                              );
                            });
                            odemeYontemleriKaydet();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Ödeme yöntemi eklendi ✅",
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
                          },
                      onCardTap: (pm) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodDetailPage(
                              paymentMethod: pm,
                              harcamalar: tumHarcamalar,
                              gelirler: tumGelirler,
                              transferler: tumTransferler,
                              tumOdemeYontemleri: tumOdemeYontemleri,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              onTransferPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferPage(
                      paymentMethods: tumOdemeYontemleri
                          .where((pm) => !pm.isDeleted)
                          .toList(),
                      onTransfer: (fromId, toId, amount, date) {
                        setState(() {
                          // Gönderen hesap (Kaynak)
                          final fromIndex = tumOdemeYontemleri.indexWhere(
                            (pm) => pm.id == fromId,
                          );
                          if (fromIndex != -1) {
                            final fromPm = tumOdemeYontemleri[fromIndex];
                            double yeniBakiye;
                            // Kaynak kredi ise borç artar, değilse bakiye azalır
                            if (fromPm.type == 'kredi') {
                              yeniBakiye = fromPm.balance + amount;
                            } else {
                              yeniBakiye = fromPm.balance - amount;
                            }
                            tumOdemeYontemleri[fromIndex] = fromPm.copyWith(
                              balance: yeniBakiye,
                            );
                          }

                          // Alan hesap (Hedef)
                          final toIndex = tumOdemeYontemleri.indexWhere(
                            (pm) => pm.id == toId,
                          );
                          if (toIndex != -1) {
                            final toPm = tumOdemeYontemleri[toIndex];
                            double yeniBakiye;
                            // Hedef kredi ise borç azalır, değilse bakiye artar
                            if (toPm.type == 'kredi') {
                              yeniBakiye = toPm.balance - amount;
                            } else {
                              yeniBakiye = toPm.balance + amount;
                            }
                            tumOdemeYontemleri[toIndex] = toPm.copyWith(
                              balance: yeniBakiye,
                            );
                          }
                        });
                        odemeYontemleriKaydet();

                        // Transfer kaydını oluştur ve kaydet
                        final yeniTransfer = Transfer(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          fromAccountId: fromId,
                          toAccountId: toId,
                          amount: amount,
                          date: date,
                        );
                        tumTransferler.insert(0, yeniTransfer);
                        transferleriKaydet();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Transfer işlemi başarılı ✅",
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
                      },
                    ),
                  ),
                );
              },
            ),
            // Sayfa 3: Profil
            ProfilSayfasi(
              authController: widget.authController,
              onRefresh: () {
                kategorileriYukle();
                verileriOku();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_selectedIndex == 0) {
              pencereAc();
            } else if (_selectedIndex == 1) {
              // Gelir ekleme bottom sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddIncomeSheet(
                  categories: gelirKategoriIkonlari,
                  paymentMethods: tumOdemeYontemleri
                      .where((pm) => !pm.isDeleted)
                      .toList(),
                  onSave: (name, amount, category, date, paymentMethodId) {
                    setState(() {
                      tumGelirler.insert(
                        0,
                        Income(
                          id: DateTime.now().toString(),
                          name: name,
                          amount: amount,
                          category: category,
                          date: date,
                          paymentMethodId: paymentMethodId,
                        ),
                      );

                      // Bakiyeyi güncelle
                      if (paymentMethodId != null) {
                        final pmIndex = tumOdemeYontemleri.indexWhere(
                          (p) => p.id == paymentMethodId,
                        );
                        if (pmIndex != -1) {
                          final pm = tumOdemeYontemleri[pmIndex];
                          double yeniBakiye;
                          if (pm.type == 'kredi') {
                            // Kredi kartına gelir girilirse borçtan düşülür
                            yeniBakiye = pm.balance - amount;
                          } else {
                            // Banka/Nakit için bakiye artar
                            yeniBakiye = pm.balance + amount;
                          }
                          tumOdemeYontemleri[pmIndex] = pm.copyWith(
                            balance: yeniBakiye,
                          );
                          odemeYontemleriKaydet();
                        }
                      }
                    });
                    gelirleriKaydet();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gelir eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  },
                ),
              );
            } else {
              // Araçlar ve Profil sayfalarında: Harcamalarım sayfasına git ve sheet aç
              _pageController.jumpToPage(0);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                pencereAc();
              });
            }
          },
          backgroundColor: context.watch<ThemeManager>().isDefaultTheme
              ? (_selectedIndex == 0
                    ? PageThemeColors.expensePrimary
                    : _selectedIndex == 1
                    ? PageThemeColors.incomePrimary
                    : PageThemeColors.defaultPrimary)
              : Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            color: context.watch<ThemeManager>().isDefaultTheme
                ? Colors.white
                : Colors.white,
            size: 32,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: HomeBottomNavigation(
          selectedIndex: _selectedIndex,
          pageController: _pageController,
        ),
      ),
    );
  }
}
