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
    return CacheService.get<List<Map<String, dynamic>>>('payment_methods_$userId')
        ?? _defaultPaymentMethods;
  }

  Stream<List<Map<String, dynamic>>> watchPaymentMethods(String userId) {
    return _userDoc(userId)
        .collection('paymentMethods')
        .snapshots()
        .map((snapshot) {
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
      final batch = _firestore.batch();

      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final method in methods) {
        final id = method['id'] as String? ?? '';
        if (id.isEmpty) continue;
        batch.set(colRef.doc(id), method);
      }

      await batch.commit();
      CacheService.set('payment_methods_$userId', methods);
    } catch (e) {
      debugPrint('Ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>('deleted_payment_methods_$userId') ?? [];
  }

  @override
  Future<void> saveDeletedPaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('deletedPaymentMethods');
      final batch = _firestore.batch();

      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final method in methods) {
        final id = method['id'] as String? ?? '';
        if (id.isEmpty) continue;
        batch.set(colRef.doc(id), method);
      }

      await batch.commit();
      CacheService.set('deleted_payment_methods_$userId', methods);
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
      await _userDoc(userId).collection('settings').doc('general').set(
        {'defaultPaymentMethod': methodId},
        SetOptions(merge: true),
      );
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
    return CacheService.get<List<Map<String, dynamic>>>('transfers_$userId') ?? [];
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
      final batch = _firestore.batch();

      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final transfer in transfers) {
        final id = transfer['id'] as String? ?? '';
        if (id.isEmpty) continue;
        batch.set(colRef.doc(id), transfer);
      }

      await batch.commit();
      CacheService.set('transfers_$userId', transfers);
    } catch (e) {
      debugPrint('Transferler kaydedilirken hata: $e');
      rethrow;
    }
  }
}
