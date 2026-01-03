import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/settings_repository.dart';

/// Ayarlar repository implementasyonu (Data Layer)
/// Hive veritabanı ile kullanıcı ayarlarını yönetir
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _boxName = 'cashly_box';
  Box get _box => Hive.box(_boxName);

  @override
  bool isVoiceFeedbackEnabled(String userId) {
    try {
      return _box.get('sesli_geri_bildirim_$userId', defaultValue: true);
    } catch (e) {
      debugPrint('Sesli geri bildirim ayarı okunurken hata: $e');
      return true; // Varsayılan olarak açık
    }
  }

  @override
  Future<void> saveVoiceFeedbackEnabled(String userId, bool enabled) async {
    try {
      await _box.put('sesli_geri_bildirim_$userId', enabled);
    } catch (e) {
      debugPrint('Sesli geri bildirim ayarı kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  int getTransferHistoryLimit(String userId) {
    try {
      final value = _box.get(
        'transfer_gecmisi_limiti_$userId',
        defaultValue: 20,
      );
      // Edge case: Negatif değerleri (Tümü=-1 hariç) varsayılana çevir
      if (value is int) {
        if (value < -1) return 20;
        if (value == 0) return 5; // 0 geçersiz, minimum 5
        return value;
      }
      return 20; // Varsayılan
    } catch (e) {
      debugPrint('Transfer geçmişi limiti okunurken hata: $e');
      return 20; // Hata durumunda varsayılan
    }
  }

  @override
  Future<void> saveTransferHistoryLimit(String userId, int limit) async {
    try {
      // Edge case: Geçersiz değerleri düzelt
      int safeLimit = limit;
      if (limit < -1) safeLimit = 20;
      if (limit == 0) safeLimit = 5;

      await _box.put('transfer_gecmisi_limiti_$userId', safeLimit);
    } catch (e) {
      debugPrint('Transfer geçmişi limiti kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllUserData(String userId) async {
    try {
      // Harcama verileri
      await _box.delete('harcamalar_$userId');

      // Bütçe ayarları
      await _box.delete('butce_limiti_$userId');

      // Sabit gider şablonları
      await _box.delete('sabit_gider_sablonlari_$userId');

      // Kullanıcı kategorileri
      await _box.delete('kategoriler_$userId');

      // Varlıklar
      await _box.delete('varliklar_$userId');
      await _box.delete('silinen_varliklar_$userId');

      // Ödeme yöntemleri
      await _box.delete('odeme_yontemleri_$userId');
      await _box.delete('silinen_odeme_yontemleri_$userId');

      // Gelirler
      await _box.delete('gelirler_$userId');

      // Gelir kategorileri
      await _box.delete('gelir_kategorileri_$userId');

      // Varsayılan ödeme yöntemi
      await _box.delete('varsayilan_odeme_yontemi_$userId');

      // Transferler
      await _box.delete('transferler_$userId');

      // Tekrarlayan gelirler
      await _box.delete('tekrarlayan_gelirler_$userId');

      // Sesli geri bildirim
      await _box.delete('sesli_geri_bildirim_$userId');

      debugPrint('✓ Tüm kullanıcı verileri silindi: $userId');
    } catch (e) {
      debugPrint('Kullanıcı verileri silinirken hata: $e');
      rethrow;
    }
  }
}
