import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/payment_method_repository.dart';

/// Ödeme yöntemi repository implementasyonu (Firestore)
class PaymentMethodRepositoryFirestore implements PaymentMethodRepository {
  final _firestore = FirebaseFirestore.instance;

  static List<Map<String, dynamic>> get defaultPaymentMethods => [
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
    try {
      return defaultPaymentMethods;
    } catch (e) {
      debugPrint('Ödeme yöntemleri getirilirken hata: $e');
      return defaultPaymentMethods;
    }
  }

  Stream<List<Map<String, dynamic>>> watchPaymentMethods(String userId) {
    return _userDoc(userId)
        .collection('paymentMethods')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return defaultPaymentMethods;
      return snapshot.docs.map((doc) => doc.data()).toList();
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
    } catch (e) {
      debugPrint('Ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId) {
    return [];
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
    } catch (e) {
      debugPrint('Silinen ödeme yöntemleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  String? getDefaultPaymentMethod(String userId) {
    return 'nakit_default';
  }

  @override
  Future<void> saveDefaultPaymentMethod(String userId, String? methodId) async {
    try {
      await _userDoc(userId).collection('settings').doc('general').set(
        {'defaultPaymentMethod': methodId},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Varsayılan ödeme yöntemi kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getTransfers(String userId) {
    return [];
  }

  Stream<List<Map<String, dynamic>>> watchTransfers(String userId) {
    return _userDoc(userId)
        .collection('transfers')
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
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
    } catch (e) {
      debugPrint('Transferler kaydedilirken hata: $e');
      rethrow;
    }
  }
}
