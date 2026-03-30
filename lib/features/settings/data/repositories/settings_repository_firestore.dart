import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/settings_repository.dart';

/// Ayarlar repository - Firestore implementasyonu
///
/// Koleksiyon yapısı:
///   users/{uid}/settings/general → sesli geri bildirim, transfer limiti vb.
///
/// NOT: Tema, dil, haptic, bildirim gibi CIHAZ TERCİHLERİ burada değil,
/// lokal Hive'da kalır (SettingsRepositoryImpl). Bu repo yalnızca kullanıcıya
/// özel uygulama ayarlarını buluta yedekler.
class SettingsRepositoryFirestore implements SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _generalDoc = 'general';

  DocumentReference _settingsDoc(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('settings')
      .doc(_generalDoc);

  // ===== SESLİ GERİ BİLDİRİM =====

  @override
  bool isVoiceFeedbackEnabled(String userId) {
    // Sync: cache'den oku, yoksa varsayılan true
    return CacheService.get<bool>('voice_feedback_$userId') ?? true;
  }

  /// Firestore'dan sesli geri bildirim ayarını çeker
  Future<bool> fetchVoiceFeedbackEnabled(String userId) async {
    try {
      final doc = await _settingsDoc(userId).get();
      final value = (doc.data() as Map<String, dynamic>?)?['voiceFeedback'] as bool? ?? true;
      CacheService.set('voice_feedback_$userId', value);
      return value;
    } catch (e) {
      debugPrint('Firestore sesli geri bildirim ayarı okunurken hata: $e');
      return true;
    }
  }

  @override
  Future<void> saveVoiceFeedbackEnabled(String userId, bool enabled) async {
    try {
      await _settingsDoc(userId).set(
        {'voiceFeedback': enabled},
        SetOptions(merge: true),
      );
      CacheService.set('voice_feedback_$userId', enabled);
    } catch (e) {
      debugPrint('Firestore sesli geri bildirim ayarı kaydedilirken hata: $e');
      rethrow;
    }
  }

  // ===== TRANSFER GEÇMİŞİ LİMİTİ =====

  @override
  int getTransferHistoryLimit(String userId) {
    return CacheService.get<int>('transfer_limit_$userId') ?? 30;
  }

  /// Firestore'dan transfer geçmişi limitini çeker
  Future<int> fetchTransferHistoryLimit(String userId) async {
    try {
      final doc = await _settingsDoc(userId).get();
      final raw = (doc.data() as Map<String, dynamic>?)?['transferHistoryLimit'];
      int limit = 30;
      if (raw is int) {
        if (raw < -1 || raw == 0) {
          limit = 30;
        } else {
          limit = raw;
        }
      }
      CacheService.set('transfer_limit_$userId', limit);
      return limit;
    } catch (e) {
      debugPrint('Firestore transfer geçmişi limiti okunurken hata: $e');
      return 30;
    }
  }

  @override
  Future<void> saveTransferHistoryLimit(String userId, int limit) async {
    try {
      // Edge case: geçersiz değerleri düzelt
      int safeLimit = limit;
      if (limit < -1 || limit == 0) safeLimit = 30;

      await _settingsDoc(userId).set(
        {'transferHistoryLimit': safeLimit},
        SetOptions(merge: true),
      );
      CacheService.set('transfer_limit_$userId', safeLimit);
    } catch (e) {
      debugPrint('Firestore transfer geçmişi limiti kaydedilirken hata: $e');
      rethrow;
    }
  }

  // ===== TÜM KULLANICI VERİSİNİ SİL =====

  @override
  Future<void> deleteAllUserData(String userId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // Alt koleksiyonları sırayla sil
      final collections = [
        'expenses', 'incomes', 'assets', 'deletedAssets',
        'paymentMethods', 'deletedPaymentMethods', 'transfers',
        'expenseCategories', 'incomeCategories', 'categories',
        'recurring', 'streak', 'settings',
      ];

      for (final col in collections) {
        final snapshot = await userDoc.collection(col).get();
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        if (snapshot.docs.isNotEmpty) await batch.commit();
      }

      // Kullanıcı dokümanını sil
      await userDoc.delete();

      // Cache temizle
      CacheService.clear();

      debugPrint('✓ Tüm Firestore kullanıcı verileri silindi: $userId');
    } catch (e) {
      debugPrint('Firestore kullanıcı verileri silinirken hata: $e');
      rethrow;
    }
  }
}
