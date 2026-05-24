import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/asset_repository.dart';

/// Varlık repository implementasyonu (Firestore)
class AssetRepositoryFirestore implements AssetRepository {
  final _firestore = FirebaseFirestore.instance;

  DocumentReference _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  List<Map<String, dynamic>> getAssets(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>('assets_$userId') ?? [];
  }

  Stream<List<Map<String, dynamic>>> watchAssets(String userId) {
    return _userDoc(userId)
        .collection('assets')
        .snapshots()
        .map((snapshot) {
      final assets = snapshot.docs.map((doc) => doc.data()).toList();
      CacheService.set('assets_$userId', assets);
      return assets;
    });
  }

  @override
  Future<void> addAsset(String userId, Map<String, dynamic> asset) async {
    try {
      if ((asset['id']?.toString() ?? '').isEmpty) {
        throw Exception('Varlık eklenirken ID eksik!');
      }
      final docRef = _userDoc(userId).collection('assets').doc(asset['id'].toString());
      final data = Map<String, dynamic>.from(asset);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);

      final cacheKey = 'assets_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      if (!cached.any((a) => a['id'] == asset['id'])) {
        cached.add(asset);
        CacheService.set(cacheKey, cached);
      }
    } catch (e) {
      debugPrint('Firestore varlık ekleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAsset(String userId, Map<String, dynamic> asset) async {
    try {
      if ((asset['id']?.toString() ?? '').isEmpty) {
        throw Exception('Varlık güncellenirken ID eksik!');
      }
      final docRef = _userDoc(userId).collection('assets').doc(asset['id'].toString());
      final data = Map<String, dynamic>.from(asset);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.update(data);

      final cacheKey = 'assets_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      final index = cached.indexWhere((a) => a['id'] == asset['id']);
      if (index != -1) {
        cached[index] = asset;
        CacheService.set(cacheKey, cached);
      }
    } catch (e) {
      debugPrint('Firestore varlık güncelleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAsset(String userId, String assetId) async {
    try {
      final docRef = _userDoc(userId).collection('assets').doc(assetId);
      await docRef.delete();

      final cacheKey = 'assets_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      cached.removeWhere((a) => a['id'] == assetId);
      CacheService.set(cacheKey, cached);
    } catch (e) {
      debugPrint('Firestore varlık silme hatası: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedAssets(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>('deleted_assets_$userId') ?? [];
  }

  @override
  Future<void> addDeletedAsset(String userId, Map<String, dynamic> asset) async {
    try {
      if ((asset['id']?.toString() ?? '').isEmpty) {
        throw Exception('Silinen varlık eklenirken ID eksik!');
      }
      final docRef = _userDoc(userId).collection('deletedAssets').doc(asset['id'].toString());
      await docRef.set(asset);

      final cacheKey = 'deleted_assets_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      if (!cached.any((a) => a['id'] == asset['id'])) {
        cached.add(asset);
        CacheService.set(cacheKey, cached);
      }
    } catch (e) {
      debugPrint('Silinen varlık ekleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeDeletedAsset(String userId, String assetId) async {
    try {
      final docRef = _userDoc(userId).collection('deletedAssets').doc(assetId);
      await docRef.delete();

      final cacheKey = 'deleted_assets_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      cached.removeWhere((a) => a['id'] == assetId);
      CacheService.set(cacheKey, cached);
    } catch (e) {
      debugPrint('Silinen varlık kalıcı silme hatası: $e');
      rethrow;
    }
  }

  /// Firestore WriteBatch 500-op limitini aşmamak için işlemleri 450'şerlik
  /// parçalara bölerek sırayla commit eder.
  Future<void> _commitInChunks(List<_BatchOp> ops) async {
    const chunkSize = 450;
    for (int i = 0; i < ops.length; i += chunkSize) {
      final chunk = ops.sublist(i, (i + chunkSize).clamp(0, ops.length));
      final batch = _firestore.batch();
      for (final op in chunk) {
        if (op.data == null) {
          batch.delete(op.ref);
        } else {
          batch.set(op.ref, op.data!);
        }
      }
      await batch.commit().timeout(const Duration(seconds: 10));
    }
  }
}

/// Batch işlemini temsil eden yardımcı sınıf (set veya delete)
class _BatchOp {
  final DocumentReference ref;
  final Map<String, dynamic>? data;
  const _BatchOp(this.ref, this.data);
}
