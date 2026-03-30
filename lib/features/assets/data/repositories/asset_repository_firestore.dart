import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/asset_repository.dart';

/// Varlık repository implementasyonu (Firestore)
class AssetRepositoryFirestore implements AssetRepository {
  final _firestore = FirebaseFirestore.instance;

  DocumentReference _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  List<Map<String, dynamic>> getAssets(String userId) {
    try {
      // Senkron cache'den oku (Stream ile doldurulur)
      return [];
    } catch (e) {
      debugPrint('Varlıklar getirilirken hata: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> watchAssets(String userId) {
    return _userDoc(userId)
        .collection('assets')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> saveAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('assets');
      final batch = _firestore.batch();

      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final asset in assets) {
        final id = asset['id'] as String? ?? '';
        if (id.isEmpty) continue;
        batch.set(colRef.doc(id), asset);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedAssets(String userId) {
    try {
      return [];
    } catch (e) {
      debugPrint('Silinen varlıklar getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveDeletedAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('deletedAssets');
      final batch = _firestore.batch();

      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final asset in assets) {
        final id = asset['id'] as String? ?? '';
        if (id.isEmpty) continue;
        batch.set(colRef.doc(id), asset);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Silinen varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }
}
