import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

// Repository imports - geriye dönük uyumluluk için
import '../repositories/expense_repository.dart';
import '../repositories/income_repository.dart';
import '../repositories/asset_repository.dart';
import '../repositories/payment_method_repository.dart';

/// Veritabanı Yardımcı Sınıfı
///
/// Bu sınıf artık sadece temel Hive işlemlerini ve
/// geriye dönük uyumluluk için repository delegasyonlarını içerir.
///
/// Yeni kod için doğrudan repository sınıflarını kullanın:
/// - [ExpenseRepository] - Harcama işlemleri
/// - [IncomeRepository] - Gelir işlemleri
/// - [AssetRepository] - Varlık işlemleri
/// - [PaymentMethodRepository] - Ödeme yöntemi işlemleri
class DatabaseHelper {
  static const String _boxName = 'cashly_box';
  static Box get _box => Hive.box(_boxName);

  /// Veritabanını başlatır
  static Future<void> baslat() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(_boxName);
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
    }
  }

  // ============================================================
  // GERIYE DÖNÜK UYUMLULUK - Repository Delegasyonları
  // Bu metodlar eski kodun çalışmaya devam etmesi için korundu.
  // Yeni kod için doğrudan repository sınıflarını kullanın.
  // ============================================================

  // --- HARCAMA İŞLEMLERİ (ExpenseRepository'ye delege) ---
  static List<Map<String, dynamic>> get defaultKategoriler =>
      ExpenseRepository.defaultKategoriler;

  static List<Map<String, dynamic>> harcamalariGetir(String userId) =>
      ExpenseRepository.harcamalariGetir(userId);

  static Future<void> harcamalariKaydet(
    String userId,
    List<Map<String, dynamic>> harcamalar,
  ) => ExpenseRepository.harcamalariKaydet(userId, harcamalar);

  static double butceGetir(String userId) =>
      ExpenseRepository.butceGetir(userId);

  static Future<void> butceKaydet(String userId, double yeniLimit) =>
      ExpenseRepository.butceKaydet(userId, yeniLimit);

  static List<Map<String, dynamic>> sabitGiderSablonlariGetir(String userId) =>
      ExpenseRepository.sabitGiderSablonlariGetir(userId);

  static Future<void> sabitGiderSablonlariKaydet(
    String userId,
    List<Map<String, dynamic>> sablonlar,
  ) => ExpenseRepository.sabitGiderSablonlariKaydet(userId, sablonlar);

  static List<Map<String, dynamic>> kategorileriGetir(String userId) =>
      ExpenseRepository.kategorileriGetir(userId);

  static Future<void> kategorileriKaydet(
    String userId,
    List<Map<String, dynamic>> kategoriler,
  ) => ExpenseRepository.kategorileriKaydet(userId, kategoriler);

  // --- GELİR İŞLEMLERİ (IncomeRepository'ye delege) ---
  static List<Map<String, dynamic>> get defaultGelirKategorileri =>
      IncomeRepository.defaultGelirKategorileri;

  static List<Map<String, dynamic>> gelirleriGetir(String userId) =>
      IncomeRepository.gelirleriGetir(userId);

  static Future<void> gelirleriKaydet(
    String userId,
    List<Map<String, dynamic>> gelirler,
  ) => IncomeRepository.gelirleriKaydet(userId, gelirler);

  static List<Map<String, dynamic>> gelirKategorileriGetir(String userId) =>
      IncomeRepository.gelirKategorileriGetir(userId);

  static Future<void> gelirKategorileriKaydet(
    String userId,
    List<Map<String, dynamic>> kategoriler,
  ) => IncomeRepository.gelirKategorileriKaydet(userId, kategoriler);

  static List<Map<String, dynamic>> tekrarlayanGelirleriGetir(String userId) =>
      IncomeRepository.tekrarlayanGelirleriGetir(userId);

  static Future<void> tekrarlayanGelirleriKaydet(
    String userId,
    List<Map<String, dynamic>> gelirler,
  ) => IncomeRepository.tekrarlayanGelirleriKaydet(userId, gelirler);

  // --- VARLIK İŞLEMLERİ (AssetRepository'ye delege) ---
  static List<Map<String, dynamic>> varliklariGetir(String userId) =>
      AssetRepository.varliklariGetir(userId);

  static Future<void> varliklariKaydet(
    String userId,
    List<Map<String, dynamic>> varliklar,
  ) => AssetRepository.varliklariKaydet(userId, varliklar);

  // --- ÖDEME YÖNTEMİ İŞLEMLERİ (PaymentMethodRepository'ye delege) ---
  static List<Map<String, dynamic>> get defaultOdemeYontemleri =>
      PaymentMethodRepository.defaultOdemeYontemleri;

  static List<Map<String, dynamic>> odemeYontemleriGetir(String userId) =>
      PaymentMethodRepository.odemeYontemleriGetir(userId);

  static Future<void> odemeYontemleriKaydet(
    String userId,
    List<Map<String, dynamic>> yontemler,
  ) => PaymentMethodRepository.odemeYontemleriKaydet(userId, yontemler);

  static List<Map<String, dynamic>> silinenOdemeYontemleriGetir(
    String userId,
  ) => PaymentMethodRepository.silinenOdemeYontemleriGetir(userId);

  static Future<void> silinenOdemeYontemleriKaydet(
    String userId,
    List<Map<String, dynamic>> yontemler,
  ) => PaymentMethodRepository.silinenOdemeYontemleriKaydet(userId, yontemler);

  static String? varsayilanOdemeYontemiGetir(String userId) =>
      PaymentMethodRepository.varsayilanOdemeYontemiGetir(userId);

  static Future<void> varsayilanOdemeYontemiKaydet(
    String userId,
    String? paymentMethodId,
  ) => PaymentMethodRepository.varsayilanOdemeYontemiKaydet(
    userId,
    paymentMethodId,
  );

  static List<Map<String, dynamic>> transferleriGetir(String userId) =>
      PaymentMethodRepository.transferleriGetir(userId);

  static Future<void> transferleriKaydet(
    String userId,
    List<Map<String, dynamic>> transferler,
  ) => PaymentMethodRepository.transferleriKaydet(userId, transferler);

  // ============================================================
  // SADECE DatabaseHelper'DA KALAN İŞLEMLER
  // ============================================================

  // --- SESLİ GERİ BİLDİRİM AYARI ---
  /// Sesli geri bildirim ayarını kontrol eder
  static bool sesliGeriBildirimAktifMi(String userId) {
    try {
      return _box.get('sesli_geri_bildirim_$userId', defaultValue: true);
    } catch (e) {
      debugPrint('Error getting voice feedback setting: $e');
      return true;
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

  // --- KULLANICI VERİLERİNİ SİLME ---
  /// Kullanıcıya ait tüm verileri siler
  /// Bu fonksiyon hesap silme işleminde çağrılır
  static Future<void> deleteUserData(String userId) async {
    try {
      // Harcama verileri
      await _box.delete('harcamalar_$userId');
      await _box.delete('butce_limiti_$userId');
      await _box.delete('sabit_gider_sablonlari_$userId');
      await _box.delete('kategoriler_$userId');

      // Varlıklar
      await _box.delete('varliklar_$userId');
      await _box.delete('silinen_varliklar_$userId');

      // Ödeme yöntemleri
      await _box.delete('odeme_yontemleri_$userId');
      await _box.delete('silinen_odeme_yontemleri_$userId');
      await _box.delete('varsayilan_odeme_yontemi_$userId');
      await _box.delete('transferler_$userId');

      // Gelirler
      await _box.delete('gelirler_$userId');
      await _box.delete('gelir_kategorileri_$userId');
      await _box.delete('tekrarlayan_gelirler_$userId');

      // Ayarlar
      await _box.delete('sesli_geri_bildirim_$userId');

      debugPrint('✓ Tüm kullanıcı verileri silindi: $userId');
    } catch (e) {
      debugPrint('Kullanıcı verileri silinirken hata: $e');
      rethrow;
    }
  }
}
