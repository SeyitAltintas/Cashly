import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Veritabanı Yardımcı Sınıfı
///
/// Hive başlatma, kullanıcıya özel ayarlar ve veritabanı temizleme işlemlerini yönetir.
///
/// Veri işlemleri için doğrudan repository sınıflarını kullanın:
/// - ExpenseRepository, IncomeRepository, AssetRepository, PaymentMethodRepository
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
