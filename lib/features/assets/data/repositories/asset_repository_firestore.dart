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
  Future<void> saveAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('assets');
      final existing = await colRef.get();

      final ops = [
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...assets.where((a) => (a['id'] as String? ?? '').isNotEmpty).map((a) {
          final data = Map<String, dynamic>.from(a)
            ..['updatedAt'] = FieldValue.serverTimestamp();
          return _BatchOp(colRef.doc(a['id'] as String), data);
        }),
      ];
      await _commitInChunks(ops);
      CacheService.set('assets_$userId', assets);
    } catch (e) {
      debugPrint('Varlıklar kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedAssets(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>('deleted_assets_$userId') ?? [];
  }

  @override
  Future<void> saveDeletedAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('deletedAssets');
      final existing = await colRef.get();

      final ops = [
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...assets.where((a) => (a['id'] as String? ?? '').isNotEmpty).map(
              (a) => _BatchOp(colRef.doc(a['id'] as String), a),
            ),
      ];
      await _commitInChunks(ops);
      CacheService.set('deleted_assets_$userId', assets);
    } catch (e) {
      debugPrint('Silinen varlıklar kaydedilirken hata: $e');
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
