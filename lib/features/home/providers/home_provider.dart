import 'package:flutter/material.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/features/assets/domain/repositories/asset_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/features/payment_methods/data/models/transfer_model.dart';
import 'package:cashly/core/constants/icon_constants.dart';
import 'package:cashly/core/services/asset_price_update_service.dart';
import 'package:intl/intl.dart';

/// Ana sayfa için state yönetimi sağlayan Provider sınıfı.
/// Harcamalar, gelirler, varlıklar, ödeme yöntemleri ve transferleri yönetir.
class HomeProvider extends ChangeNotifier {
  final String userId;

  HomeProvider({required this.userId}) {
    _init();
  }

  // ===== STATE DEĞİŞKENLERİ =====
  List<Map<String, dynamic>> tumHarcamalar = [];
  List<Map<String, dynamic>> gosterilenHarcamalar = [];
  List<Asset> varliklar = [];
  List<Income> tumGelirler = [];
  List<PaymentMethod> tumOdemeYontemleri = [];
  List<Transfer> tumTransferler = [];
  String? varsayilanOdemeYontemiId;

  DateTime secilenAy = DateTime.now();
  double butceLimiti = 8000.0;
  bool isLoading = true;
  bool isUpdatingAssetPrices = false; // Varlık fiyatları güncelleniyor mu?

  // Kategori ikonları
  Map<String, IconData> kategoriIkonlari = {};
  Map<String, IconData> gelirKategoriIkonlari = {};

  // Arama modları
  bool aramaModu = false;
  bool gelirAramaModu = false;
  String aramaMetni = '';
  String gelirAramaMetni = '';

  // ===== MEMOIZATION: Hesaplama cache'leri =====
  double? _cachedToplamTutar;
  Map<String, double>? _cachedKategoriToplamlari;
  Map<String, List<Map<String, dynamic>>>? _cachedGunlukGruplar;
  int _cacheHarcamaHashCode = 0;

  // Ay isimleri - dinamik locale
  String _locale = 'tr_TR';

  // ===== BAŞLATMA =====
  void _init() {
    kategorileriYukle();
    gelirKategorileriYukle();
    verileriOku();
  }

  /// Locale'i dışarıdan geçirmek için
  void setLocale(String locale) {
    _locale = locale;
    _invalidateCache();
    notifyListeners();
  }

  // ===== KATEGORİ YÖNETİMİ =====

  /// Harcama kategorilerini veritabanından yükler
  void kategorileriYukle() {
    final expenseRepo = getIt<ExpenseRepository>();
    List<Map<String, dynamic>> dbKategoriler = expenseRepo.getCategories(
      userId,
    );
    kategoriIkonlari = {};
    for (var kategori in dbKategoriler) {
      String isim = kategori['isim'];
      String ikonAdi = kategori['ikon'];
      kategoriIkonlari[isim] = IconConstants.getHarcamaIkonu(ikonAdi);
    }
    notifyListeners();
  }

  /// Gelir kategorilerini veritabanından yükler
  void gelirKategorileriYukle() {
    final incomeRepo = getIt<IncomeRepository>();
    List<Map<String, dynamic>> dbKategoriler = incomeRepo.getCategories(userId);
    gelirKategoriIkonlari = {};
    for (var kategori in dbKategoriler) {
      String isim = kategori['isim'];
      String ikonAdi = kategori['ikon'];
      gelirKategoriIkonlari[isim] = IconConstants.getGelirIkonu(ikonAdi);
    }
    notifyListeners();
  }

  // ===== VERİ OKUMA/YAZMA =====

  /// Tüm verileri veritabanından okur
  void verileriOku() {
    final expenseRepo = getIt<ExpenseRepository>();
    final incomeRepo = getIt<IncomeRepository>();
    final assetRepo = getIt<AssetRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();

    // Harcamaları oku
    List<Map<String, dynamic>> gelen = expenseRepo.getExpenses(userId);
    double kayitliButce = expenseRepo.getBudget(userId);

    gelen.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    // Varlıkları oku
    List<Map<String, dynamic>> varlikVerileri = assetRepo.getAssets(userId);
    List<Asset> okunanVarliklar = varlikVerileri
        .map((map) => Asset.fromMap(map))
        .toList();

    // Gelirleri oku
    List<Map<String, dynamic>> gelirVerileri = incomeRepo.getIncomes(userId);
    List<Income> okunanGelirler = gelirVerileri
        .map((map) => Income.fromMap(map))
        .toList();

    // Ödeme yöntemlerini oku
    List<Map<String, dynamic>> odemeVerileri = paymentRepo.getPaymentMethods(
      userId,
    );
    List<PaymentMethod> okunanOdemeYontemleri = odemeVerileri
        .map((map) => PaymentMethod.fromMap(map))
        .toList();

    // Varsayılan ödeme yöntemini oku
    String? varsayilanPm = paymentRepo.getDefaultPaymentMethod(userId);

    // Transferleri oku
    List<Map<String, dynamic>> transferVerileri = paymentRepo.getTransfers(
      userId,
    );
    List<Transfer> okunanTransferler = transferVerileri
        .map((map) => Transfer.fromMap(map))
        .toList();

    tumHarcamalar = gelen;
    butceLimiti = kayitliButce;
    varliklar = okunanVarliklar;
    tumGelirler = okunanGelirler;
    tumOdemeYontemleri = okunanOdemeYontemleri;
    tumTransferler = okunanTransferler;
    varsayilanOdemeYontemiId = varsayilanPm;
    isLoading = false;

    filtreleVeGoster();
    notifyListeners();

    // Varlık fiyatlarını arka planda güncelle
    updateAssetPrices();
  }

  /// Varlık fiyatlarını güncel API verilerine göre günceller
  Future<void> updateAssetPrices() async {
    // Güncellenecek varlık yoksa çık
    if (varliklar.isEmpty) {
      return;
    }
    isUpdatingAssetPrices = true;
    notifyListeners();

    try {
      final priceUpdateService = AssetPriceUpdateService();
      final updatedAssets = await priceUpdateService.updateAllAssetPrices(
        varliklar,
      );

      varliklar = updatedAssets;
      varliklariKaydet();
    } catch (e) {
      // Sessizce geç
    } finally {
      isUpdatingAssetPrices = false;
      notifyListeners();
    }
  }

  /// Harcamaları veritabanına kaydeder
  void verileriKaydet() {
    getIt<ExpenseRepository>().saveExpenses(userId, tumHarcamalar);
  }

  /// Gelirleri veritabanına kaydeder
  void gelirleriKaydet() {
    List<Map<String, dynamic>> gelirMapleri = tumGelirler
        .map((income) => income.toMap())
        .toList();
    getIt<IncomeRepository>().saveIncomes(userId, gelirMapleri);
  }

  /// Varlıkları veritabanına kaydeder
  void varliklariKaydet() {
    List<Map<String, dynamic>> varlikMapleri = varliklar
        .map((asset) => asset.toMap())
        .toList();
    getIt<AssetRepository>().saveAssets(userId, varlikMapleri);
  }

  /// Ödeme yöntemlerini veritabanına kaydeder
  void odemeYontemleriKaydet() {
    List<Map<String, dynamic>> yontemMapleri = tumOdemeYontemleri
        .map((pm) => pm.toMap())
        .toList();
    getIt<PaymentMethodRepository>().savePaymentMethods(userId, yontemMapleri);
  }

  /// Transferleri veritabanına kaydeder
  void transferleriKaydet() {
    List<Map<String, dynamic>> transferMapleri = tumTransferler
        .map((t) => t.toMap())
        .toList();
    getIt<PaymentMethodRepository>().saveTransfers(userId, transferMapleri);
  }

  // ===== FİLTRELEME VE TAKVİM =====

  /// Harcamaları seçilen aya ve arama metnine göre filtreler
  void filtreleVeGoster() {
    List<Map<String, dynamic>> aktifHarcamalar = tumHarcamalar
        .where((h) => h['silindi'] != true)
        .toList();

    if (aramaModu && aramaMetni.isNotEmpty) {
      String aranan = aramaMetni.toLowerCase();
      gosterilenHarcamalar = aktifHarcamalar.where((h) {
        return h['isim'].toString().toLowerCase().contains(aranan);
      }).toList();
    } else {
      gosterilenHarcamalar = aktifHarcamalar.where((h) {
        DateTime hTarih =
            DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
        return hTarih.year == secilenAy.year && hTarih.month == secilenAy.month;
      }).toList();
    }

    _invalidateCache();
    notifyListeners();
  }

  /// Bir önceki aya geçer
  void oncekiAy() {
    secilenAy = DateTime(secilenAy.year, secilenAy.month - 1);
    filtreleVeGoster();
  }

  /// Bir sonraki aya geçer
  void sonrakiAy() {
    secilenAy = DateTime(secilenAy.year, secilenAy.month + 1);
    filtreleVeGoster();
  }

  /// Belirli bir ayı seçer
  void ayiSec(int yil, int ay) {
    secilenAy = DateTime(yil, ay);
    filtreleVeGoster();
  }

  /// Bugüne gider
  void buganeGit() {
    secilenAy = DateTime.now();
    filtreleVeGoster();
  }

  /// Arama modunu değiştirir
  void aramaModunuDegistir(bool aktif, {String metin = ''}) {
    aramaModu = aktif;
    aramaMetni = metin;
    if (!aktif) {
      aramaMetni = '';
    }
    filtreleVeGoster();
  }

  /// Gelir arama modunu değiştirir
  void gelirAramaModunuDegistir(bool aktif, {String metin = ''}) {
    gelirAramaModu = aktif;
    gelirAramaMetni = metin;
    if (!aktif) {
      gelirAramaMetni = '';
    }
    notifyListeners();
  }

  // ===== CACHE YÖNETİMİ =====

  /// Cache'i geçersiz kılar
  void _invalidateCache() {
    _cachedToplamTutar = null;
    _cachedKategoriToplamlari = null;
    _cachedGunlukGruplar = null;
  }

  /// Mevcut harcama listesinin hash'ini hesaplar
  int _calculateHarcamaHash() {
    return Object.hashAll([
      gosterilenHarcamalar.length,
      if (gosterilenHarcamalar.isNotEmpty) gosterilenHarcamalar.first.hashCode,
      if (gosterilenHarcamalar.length > 1) gosterilenHarcamalar.last.hashCode,
    ]);
  }

  /// Cache'in geçerli olup olmadığını kontrol eder
  void _checkCacheValidity() {
    final currentHash = _calculateHarcamaHash();
    if (_cacheHarcamaHashCode != currentHash) {
      _invalidateCache();
      _cacheHarcamaHashCode = currentHash;
    }
  }

  // ===== HESAPLAMALAR (GETTER'lar) =====

  /// Seçili ayın toplam harcama tutarı
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

  /// Kategori bazında harcama toplamları
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

  /// Günlük gruplandırılmış harcamalar
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

  /// Ay ismini döndürür
  String get ayIsmi {
    final monthName = DateFormat('MMMM', _locale).format(secilenAy);
    return '$monthName ${secilenAy.year}';
  }

  /// Kalan bütçe limiti
  double get kalanLimit => butceLimiti - toplamTutar;

  /// Aşılan miktar
  double get asilanMiktar => toplamTutar - butceLimiti;

  /// Bu ay mı kontrolü
  bool get buAyMi {
    final simdi = DateTime.now();
    return secilenAy.year == simdi.year && secilenAy.month == simdi.month;
  }

  // ===== YARDIMCI METODLAR =====

  /// Tarihi formatlı string'e çevirir
  String tarihFormatla(DateTime tarih) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final oTarih = DateTime(tarih.year, tarih.month, tarih.day);
    final fark = bugun.difference(oTarih).inDays;

    if (fark == 0) return _locale.startsWith('tr') ? 'Bugün' : 'Today';
    if (fark == 1) return _locale.startsWith('tr') ? 'Dün' : 'Yesterday';

    final monthName = DateFormat('MMMM', _locale).format(oTarih);
    return '${oTarih.day} $monthName';
  }

  // ===== HARCAMA İŞLEMLERİ =====

  /// Harcama ekler
  void harcamaEkle({
    required String isim,
    required double tutar,
    required String kategori,
    required DateTime tarih,
    String? odemeYontemiId,
  }) {
    tumHarcamalar.add({
      "isim": isim,
      "tutar": tutar,
      "kategori": kategori,
      "tarih": tarih.toString(),
      "silindi": false,
      "odemeYontemiId": odemeYontemiId,
    });

    // Ödeme yönteminden düş
    if (odemeYontemiId != null) {
      _bakiyeGuncelle(odemeYontemiId, tutar, isHarcama: true);
    }

    _siralaHarcamalar();
    verileriKaydet();
    odemeYontemleriKaydet();
    filtreleVeGoster();
  }

  /// Harcama günceller
  void harcamaGuncelle({
    required Map<String, dynamic> eskiHarcama,
    required String isim,
    required double tutar,
    required String kategori,
    required DateTime tarih,
    String? odemeYontemiId,
  }) {
    final eskiTutar = double.tryParse(eskiHarcama['tutar'].toString()) ?? 0.0;
    final eskiOdemeYontemiId = eskiHarcama['odemeYontemiId'];

    // Eski tutarı geri ekle
    if (eskiOdemeYontemiId != null) {
      _bakiyeGuncelle(eskiOdemeYontemiId, eskiTutar, isHarcama: false);
    }

    // Yeni tutarı düş
    if (odemeYontemiId != null) {
      _bakiyeGuncelle(odemeYontemiId, tutar, isHarcama: true);
    }

    int index = tumHarcamalar.indexOf(eskiHarcama);
    if (index != -1) {
      tumHarcamalar[index] = {
        "isim": isim,
        "tutar": tutar,
        "kategori": kategori,
        "tarih": tarih.toString(),
        "silindi": false,
        "odemeYontemiId": odemeYontemiId,
      };
    }

    _siralaHarcamalar();
    verileriKaydet();
    odemeYontemleriKaydet();
    filtreleVeGoster();
  }

  /// Harcama siler (soft delete)
  void harcamaSil(Map<String, dynamic> harcama) {
    harcama['silindi'] = true;

    // Ödeme yönteminin bakiyesini geri ekle
    final paymentMethodId = harcama['odemeYontemiId'];
    if (paymentMethodId != null) {
      final amount = double.tryParse(harcama['tutar'].toString()) ?? 0.0;
      _bakiyeGuncelle(paymentMethodId, amount, isHarcama: false);
    }

    verileriKaydet();
    odemeYontemleriKaydet();
    filtreleVeGoster();
  }

  /// Harcamaları tarihe göre sıralar
  void _siralaHarcamalar() {
    tumHarcamalar.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });
  }

  // ===== GELİR İŞLEMLERİ =====

  /// Gelir ekler
  void gelirEkle({
    required String isim,
    required double tutar,
    required String kategori,
    required DateTime tarih,
    String? odemeYontemiId,
  }) {
    tumGelirler.insert(
      0,
      Income(
        id: DateTime.now().toString(),
        name: isim,
        amount: tutar,
        category: kategori,
        date: tarih,
        paymentMethodId: odemeYontemiId,
      ),
    );

    // Bakiyeyi güncelle
    if (odemeYontemiId != null) {
      _bakiyeGuncelle(odemeYontemiId, tutar, isHarcama: false);
    }

    gelirleriKaydet();
    odemeYontemleriKaydet();
    notifyListeners();
  }

  /// Gelir siler
  void gelirSil(Income income) {
    income.isDeleted = true;

    // Bakiyeyi geri al
    if (income.paymentMethodId != null) {
      _bakiyeGuncelle(income.paymentMethodId!, income.amount, isHarcama: true);
    }

    gelirleriKaydet();
    odemeYontemleriKaydet();
    notifyListeners();
  }

  // ===== BAKİYE YÖNETİMİ =====

  /// Ödeme yöntemi bakiyesini günceller
  void _bakiyeGuncelle(String pmId, double miktar, {required bool isHarcama}) {
    final pmIndex = tumOdemeYontemleri.indexWhere((p) => p.id == pmId);
    if (pmIndex == -1) return;

    final pm = tumOdemeYontemleri[pmIndex];
    double yeniBakiye;

    if (pm.type == 'kredi') {
      // Kredi kartı: harcama borcu artırır, gelir borcu azaltır
      yeniBakiye = isHarcama ? pm.balance + miktar : pm.balance - miktar;
    } else {
      // Banka/Nakit: harcama bakiyeyi azaltır, gelir artırır
      yeniBakiye = isHarcama ? pm.balance - miktar : pm.balance + miktar;
    }

    tumOdemeYontemleri[pmIndex] = pm.copyWith(balance: yeniBakiye);
  }

  // ===== SESLİ KOMUT CALLBACK'LERİ =====

  /// Son harcamayı döndürür
  Map<String, dynamic>? getSonHarcama() {
    final buAyHarcamalari = tumHarcamalar.where((h) {
      if (h['silindi'] == true) return false;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      return tarih.year == secilenAy.year && tarih.month == secilenAy.month;
    }).toList();

    if (buAyHarcamalari.isEmpty) return null;

    buAyHarcamalari.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    return buAyHarcamalari.first;
  }

  /// Haftalık toplam harcama
  double getHaftalikToplam() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    double haftalikToplam = 0;
    for (var h in tumHarcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null &&
          tarih.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          tarih.isBefore(now.add(const Duration(days: 1)))) {
        haftalikToplam += (h['tutar'] as num?)?.toDouble() ?? 0;
      }
    }
    return haftalikToplam;
  }

  /// Günlük toplam harcama
  double getGunlukToplam() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double gunlukToplam = 0;
    for (var h in tumHarcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        final harcamaTarihi = DateTime(tarih.year, tarih.month, tarih.day);
        if (harcamaTarihi.isAtSameMomentAs(today)) {
          gunlukToplam += (h['tutar'] as num?)?.toDouble() ?? 0;
        }
      }
    }
    return gunlukToplam;
  }

  /// Son 5 harcamayı döndürür
  List<Map<String, dynamic>> getSonHarcamalar() {
    final buAyHarcamalari = tumHarcamalar.where((h) {
      if (h['silindi'] == true) return false;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      return tarih.year == secilenAy.year && tarih.month == secilenAy.month;
    }).toList();

    buAyHarcamalari.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    return buAyHarcamalari.take(5).toList();
  }

  /// Tarih aralığına göre harcama toplamı
  double getTarihAraligiToplam(DateTime baslangic, DateTime bitis) {
    double toplam = 0;
    final baslangicGun = DateTime(
      baslangic.year,
      baslangic.month,
      baslangic.day,
    );
    final bitisGun = DateTime(bitis.year, bitis.month, bitis.day);

    for (var h in tumHarcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        final harcamaTarihi = DateTime(tarih.year, tarih.month, tarih.day);
        if ((harcamaTarihi.isAtSameMomentAs(baslangicGun) ||
                harcamaTarihi.isAfter(baslangicGun)) &&
            (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                harcamaTarihi.isBefore(bitisGun))) {
          toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
        }
      }
    }
    return toplam;
  }

  /// Bütçe limitini günceller
  Future<void> butceLimitiGuncelle(double yeniLimit) async {
    await getIt<ExpenseRepository>().saveBudget(userId, yeniLimit);
    butceLimiti = yeniLimit;
    filtreleVeGoster();
  }
}
