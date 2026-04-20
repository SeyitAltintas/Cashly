import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/payment_method_repository.dart';

/// Ödeme yöntemi repository implementasyonu (Firestore)
class PaymentMethodRepositoryFirestore implements PaymentMethodRepository {
  final _firestore = FirebaseFirestore.instance;

  static List<Map<String, dynamic>> get _defaultPaymentMethods => [
    {
      'id': 'nakit_default',
      'name': 'Nakit',
      'type': 'nakit',
      'lastFourDigits': null,
      'balance': 0.0,
      'limit': null,
      'colorIndex': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'isDeleted': false,
    },
  ];

  DocumentReference _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  List<Map<String, dynamic>> getPaymentMethods(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>(
          'payment_methods_$userId',
        ) ??
        _defaultPaymentMethods;
  }

  Stream<List<Map<String, dynamic>>> watchPaymentMethods(String userId) {
    return _userDoc(userId).collection('paymentMethods').snapshots().map((
      snapshot,
    ) {
      final methods = snapshot.docs.isEmpty
          ? _defaultPaymentMethods
          : snapshot.docs.map((doc) => doc.data()).toList();
      CacheService.set('payment_methods_$userId', methods);
      return methods;
    });
  }

  @override
  Future<void> savePaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('paymentMethods');
      final existing = await colRef.get();
      final ops = [
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...methods
            .where((m) => (m['id'] as String? ?? '').isNotEmpty)
            .map((m) => _BatchOp(colRef.doc(m['id'] as String), m)),
      ];
      await _commitInChunks(ops);
      CacheService.set('payment_methods_$userId', methods);
    } on TimeoutException {
      debugPrint('Ödeme yöntemleri kaydedilirken zaman aşımı. Cache korundu.');
    } catch (e) {
      debugPrint('Ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>(
          'deleted_payment_methods_$userId',
        ) ??
        [];
  }

  @override
  Future<void> saveDeletedPaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('deletedPaymentMethods');
      final existing = await colRef.get();
      final ops = [
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...methods
            .where((m) => (m['id'] as String? ?? '').isNotEmpty)
            .map((m) => _BatchOp(colRef.doc(m['id'] as String), m)),
      ];
      await _commitInChunks(ops);
      CacheService.set('deleted_payment_methods_$userId', methods);
    } on TimeoutException {
      debugPrint(
        'Silinen ödeme yöntemleri kaydedilirken zaman aşımı. Cache korundu.',
      );
    } catch (e) {
      debugPrint('Silinen ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  String? getDefaultPaymentMethod(String userId) {
    return CacheService.get<String>('default_payment_method_$userId');
  }

  @override
  Future<void> saveDefaultPaymentMethod(String userId, String? methodId) async {
    try {
      await _userDoc(userId).collection('settings').doc('general').set({
        'defaultPaymentMethod': methodId,
      }, SetOptions(merge: true));
      if (methodId != null) {
        CacheService.set('default_payment_method_$userId', methodId);
      }
    } catch (e) {
      debugPrint('Varsayılan ödeme yöntemi kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getTransfers(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>('transfers_$userId') ??
        [];
  }

  Stream<List<Map<String, dynamic>>> watchTransfers(String userId) {
    return _userDoc(userId)
        .collection('transfers')
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) {
          final transfers = snapshot.docs.map((doc) => doc.data()).toList();
          CacheService.set('transfers_$userId', transfers);
          return transfers;
        });
  }

  @override
  Future<void> saveTransfers(
    String userId,
    List<Map<String, dynamic>> transfers,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('transfers');
      final existing = await colRef.get();
      final ops = [
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...transfers
            .where((t) => (t['id'] as String? ?? '').isNotEmpty)
            .map((t) => _BatchOp(colRef.doc(t['id'] as String), t)),
      ];
      await _commitInChunks(ops);
      CacheService.set('transfers_$userId', transfers);
    } on TimeoutException {
      debugPrint('Transferler kaydedilirken zaman aşımı. Cache korundu.');
    } catch (e) {
      debugPrint('Transferler kaydedilirken hata: $e');
      rethrow;
    }
  }

  /// Firestore WriteBatch 500-op limitini aşmamak için 450'şerlik chunk'lara böler.
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
