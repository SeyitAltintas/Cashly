import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/streak_repository.dart';
import '../models/streak_model.dart';
import '../services/streak_service.dart';
import '../../../../core/services/network_service.dart';
import 'package:cashly/core/services/error_logger_service.dart';

/// Rank repository - Firestore implementasyonu
///
/// Koleksiyon yapısı:
///   users/{uid}/streak/data → rank dokümanı (tek doküman)
class StreakRepositoryFirestore implements StreakRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _rankDoc(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('streak')
      .doc('data');

  @override
  RankData getStreakData(String userId) {
    return StreakService.getStreakData(userId);
  }

  /// Firestore'dan rank verisini çeker
  Future<RankData> fetchRankData(String userId) async {
    try {
      final getOptions = NetworkService().isOffline
          ? const GetOptions(source: Source.cache)
          : const GetOptions();
      final doc = await _rankDoc(userId).get(getOptions);
      if (!doc.exists) return RankData.empty();
      final data = Map<String, dynamic>.from(doc.data() as Map);
      data.remove('updatedAt');
      return RankData.fromMap(data);
    } catch (e, stackTrace) {
      debugPrint('Firestore rank verisi getirilirken hata: $e');
      ErrorLoggerService.logError(
        'Firestore rank verisi getirilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      return RankData.empty();
    }
  }

  @override
  Future<void> saveStreakData(String userId, RankData data) async {
    try {
      final map = data.toMap();
      map['updatedAt'] = FieldValue.serverTimestamp();
      await _rankDoc(userId).set(map);
    } catch (e, stackTrace) {
      debugPrint('Firestore rank verisi kaydedilirken hata: $e');
      ErrorLoggerService.logError(
        'Firestore rank verisi kaydedilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> initialize() async {
    // Firestore'da box açmaya gerek yok
  }
}
