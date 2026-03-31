import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/streak_repository.dart';
import '../models/streak_model.dart';
import '../services/streak_service.dart';

/// Streak repository - Firestore implementasyonu
///
/// Koleksiyon yapısı:
///   users/{uid}/streak/data → streak dokümanı (tek doküman)
class StreakRepositoryFirestore implements StreakRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _streakDoc(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('streak')
      .doc('data');

  @override
  StreakData getStreakData(String userId) {
    // Hive'daki güncel streak'i döndür (StreakService kaynak of truth'tur).
    // Eski implementasyon daima StreakData.empty() döndürüyordu → 0 gün hatası.
    return StreakService.getStreakData(userId);
  }

  /// Firestore'dan streak verisini çeker
  Future<StreakData> fetchStreakData(String userId) async {
    try {
      final doc = await _streakDoc(userId).get();
      if (!doc.exists) return StreakData.empty();
      final data = Map<String, dynamic>.from(doc.data() as Map);
      // Firestore'a özgü alanları temizle
      data.remove('updatedAt');
      return StreakData.fromMap(data);
    } catch (e) {
      debugPrint('Firestore streak verisi getirilirken hata: $e');
      return StreakData.empty();
    }
  }

  @override
  Future<void> saveStreakData(String userId, StreakData data) async {
    try {
      final map = data.toMap();
      map['updatedAt'] = FieldValue.serverTimestamp();
      await _streakDoc(userId).set(map);
    } catch (e) {
      debugPrint('Firestore streak verisi kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  Future<void> initialize() async {
    // Firestore'da box açmaya gerek yok
  }
}
