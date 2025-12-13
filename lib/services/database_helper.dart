import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static const String _boxName = 'cashly_box';
  static Box get _box => Hive.box(_boxName);

  static Future<void> baslat() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(_boxName);
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
    }
  }

  // --- HARCAMA İŞLEMLERİ ---
  static List<Map<String, dynamic>> harcamalariGetir(String userId) {
    try {
      final veri = _box.get('harcamalar_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting expenses: $e');
      return [];
    }
  }

  static Future<void> harcamalariKaydet(
    String userId,
    List<Map<String, dynamic>> harcamalar,
  ) async {
    try {
      await _box.put('harcamalar_$userId', harcamalar);
    } catch (e) {
      debugPrint('Error saving expenses: $e');
      rethrow;
    }
  }

  // --- BÜTÇE AYARLARI ---
  static double butceGetir(String userId) {
    try {
      return _box.get('butce_limiti_$userId', defaultValue: 8000.0);
    } catch (e) {
      debugPrint('Error getting budget: $e');
      return 8000.0;
    }
  }

  static Future<void> butceKaydet(String userId, double yeniLimit) async {
    try {
      await _box.put('butce_limiti_$userId', yeniLimit);
    } catch (e) {
      debugPrint('Error saving budget: $e');
      rethrow;
    }
  }

  // --- SABİT GİDER ŞABLONLARI ---
  static List<Map<String, dynamic>> sabitGiderSablonlariGetir(String userId) {
    try {
      final veri = _box.get('sabit_gider_sablonlari_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting fixed expenses: $e');
      return [];
    }
  }

  static Future<void> sabitGiderSablonlariKaydet(
    String userId,
    List<Map<String, dynamic>> sablonlar,
  ) async {
    try {
      await _box.put('sabit_gider_sablonlari_$userId', sablonlar);
    } catch (e) {
      debugPrint('Error saving fixed expenses: $e');
      rethrow;
    }
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
    try {
      final veri = _box.get('kategoriler_$userId', defaultValue: null);
      if (veri == null) {
        kategorileriKaydet(userId, defaultKategoriler);
        return defaultKategoriler;
      }
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return defaultKategoriler;
    }
  }

  static Future<void> kategorileriKaydet(
    String userId,
    List<Map<String, dynamic>> kategoriler,
  ) async {
    try {
      await _box.put('kategoriler_$userId', kategoriler);
    } catch (e) {
      debugPrint('Error saving categories: $e');
      rethrow;
    }
  }

  // --- VARLIK YÖNETİMİ ---
  /// Kullanıcının varlıklarını getirir
  static List<Map<String, dynamic>> varliklariGetir(String userId) {
    try {
      final veri = _box.get('varliklar_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Varlıklar getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının varlıklarını kaydeder
  static Future<void> varliklariKaydet(
    String userId,
    List<Map<String, dynamic>> varliklar,
  ) async {
    try {
      await _box.put('varliklar_$userId', varliklar);
    } catch (e) {
      debugPrint('Varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }

  // --- KULLANICI VERİLERİNİ SİLME ---
  /// Kullanıcıya ait tüm verileri siler
  /// Bu fonksiyon hesap silme işleminde çağrılır
  static Future<void> deleteUserData(String userId) async {
    try {
      // Harcama verileri
      await _box.delete('harcamalar_$userId');

      // Bütçe ayarları
      await _box.delete('butce_limiti_$userId');

      // Sabit gider şablonları
      await _box.delete('sabit_gider_sablonlari_$userId');

      // Kullanıcı kategorileri
      await _box.delete('kategoriler_$userId');

      // Varlıklar (assets) - gelecekte eklenirse
      await _box.delete('varliklar_$userId');
      await _box.delete('silinen_varliklar_$userId');

      debugPrint('✓ Tüm kullanıcı verileri silindi: $userId');
    } catch (e) {
      debugPrint('Kullanıcı verileri silinirken hata: $e');
      rethrow;
    }
  }

  // --- SESLİ GERİ BİLDİRİM AYARI ---
  /// Sesli geri bildirim ayarını kontrol eder
  static bool sesliGeriBildirimAktifMi(String userId) {
    try {
      return _box.get('sesli_geri_bildirim_$userId', defaultValue: true);
    } catch (e) {
      debugPrint('Error getting voice feedback setting: $e');
      return true; // Varsayılan olarak açık
    }
  }

  /// Sesli geri bildirim ayarını kaydeder
  static Future<void> sesliGeriBildirimKaydet(String userId, bool aktif) async {
    try {
      await _box.put('sesli_geri_bildirim_$userId', aktif);
    } catch (e) {
      debugPrint('Error saving voice feedback setting: $e');
      rethrow;
    }
  }

  // --- GELİR İŞLEMLERİ ---
  /// Varsayılan gelir kategorileri
  static List<Map<String, dynamic>> get defaultGelirKategorileri => [
    {'isim': 'Maaş', 'ikon': 'work'},
    {'isim': 'Freelance', 'ikon': 'laptop'},
    {'isim': 'Yatırım', 'ikon': 'trending_up'},
    {'isim': 'Kira Geliri', 'ikon': 'home'},
    {'isim': 'Hediye', 'ikon': 'card_giftcard'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  /// Kullanıcının gelirlerini getirir
  static List<Map<String, dynamic>> gelirleriGetir(String userId) {
    try {
      final veri = _box.get('gelirler_$userId', defaultValue: []);
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Gelirler getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının gelirlerini kaydeder
  static Future<void> gelirleriKaydet(
    String userId,
    List<Map<String, dynamic>> gelirler,
  ) async {
    try {
      await _box.put('gelirler_$userId', gelirler);
    } catch (e) {
      debugPrint('Gelirler kaydedilirken hata: $e');
      rethrow;
    }
  }

  /// Gelir kategorilerini getirir
  static List<Map<String, dynamic>> gelirKategorileriGetir(String userId) {
    try {
      final veri = _box.get('gelir_kategorileri_$userId', defaultValue: null);
      if (veri == null) {
        gelirKategorileriKaydet(userId, defaultGelirKategorileri);
        return defaultGelirKategorileri;
      }
      return List<Map<String, dynamic>>.from(
        veri.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint('Gelir kategorileri getirilirken hata: $e');
      return defaultGelirKategorileri;
    }
  }

  /// Gelir kategorilerini kaydeder
  static Future<void> gelirKategorileriKaydet(
    String userId,
    List<Map<String, dynamic>> kategoriler,
  ) async {
    try {
      await _box.put('gelir_kategorileri_$userId', kategoriler);
    } catch (e) {
      debugPrint('Gelir kategorileri kaydedilirken hata: $e');
      rethrow;
    }
  }
}
