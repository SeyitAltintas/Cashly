import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static const String _boxName = 'cashly_box'; // İsim değişti
  static Box get _box => Hive.box(_boxName);

  static Future<void> baslat() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // --- HARCAMA İŞLEMLERİ ---
  static List<Map<String, dynamic>> harcamalariGetir(String userId) {
    final veri = _box.get('harcamalar_$userId', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      veri.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  static Future<void> harcamalariKaydet(
    String userId,
    List<Map<String, dynamic>> harcamalar,
  ) async {
    await _box.put('harcamalar_$userId', harcamalar);
  }

  // --- BÜTÇE AYARLARI ---
  static double butceGetir(String userId) {
    return _box.get('butce_limiti_$userId', defaultValue: 8000.0);
  }

  static Future<void> butceKaydet(String userId, double yeniLimit) async {
    await _box.put('butce_limiti_$userId', yeniLimit);
  }

  // --- SABİT GİDER ŞABLONLARI ---
  static List<Map<String, dynamic>> sabitGiderSablonlariGetir(String userId) {
    final veri = _box.get('sabit_gider_sablonlari_$userId', defaultValue: []);
    return List<Map<String, dynamic>>.from(
      veri.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  static Future<void> sabitGiderSablonlariKaydet(
    String userId,
    List<Map<String, dynamic>> sablonlar,
  ) async {
    await _box.put('sabit_gider_sablonlari_$userId', sablonlar);
  }

  // --- KATEGORİ YÖNETİMİ ---
  static List<Map<String, dynamic>> get defaultKategoriler => [
    {'isim': 'Yemek & Kafe', 'ikon': 'restaurant'},
    {'isim': 'Market & Atıştırmalık', 'ikon': 'shopping_basket'},
    {'isim': 'Araç & Ulaşım', 'ikon': 'two_wheeler'},
    {'isim': 'Hediye & Özel', 'ikon': 'card_giftcard'},
    {'isim': 'Sabit Giderler', 'ikon': 'credit_card'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  static List<Map<String, dynamic>> kategorileriGetir(String userId) {
    final veri = _box.get('kategoriler_$userId', defaultValue: null);
    if (veri == null) {
      // İlk kullanım, default kategorileri yükle
      kategorileriKaydet(userId, defaultKategoriler);
      return defaultKategoriler;
    }
    return List<Map<String, dynamic>>.from(
      veri.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  static Future<void> kategorileriKaydet(
    String userId,
    List<Map<String, dynamic>> kategoriler,
  ) async {
    await _box.put('kategoriler_$userId', kategoriler);
  }
}
