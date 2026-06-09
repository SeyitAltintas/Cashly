import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../../../../core/services/batch_service.dart';
import 'package:cashly/core/services/error_logger_service.dart';

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

  // GÜVENLİK/KARARLILIK YAMASI:
  // Firestore verisi içindeki Timestamp'ler Hive'da desteklenmediğinden
  // okunurken her zaman String (ISO-8601) formatına dönüştürülmelidir.
  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    final sanitized = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Timestamp) {
        sanitized[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        sanitized[key] = _sanitizeMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        sanitized[key] = value.map((e) {
          if (e is Timestamp) return e.toDate().toIso8601String();
          if (e is Map) return _sanitizeMap(Map<String, dynamic>.from(e));
          return e;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchPaymentMethods(String userId) {
    return _userDoc(userId).collection('paymentMethods').snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) {
        // Boş snapshot: Firestore offline cache henüz ısınmamış olabilir veya
        // kullanıcının gerçekten hiç ödeme yöntemi yok. CacheService'e yazmıyoruz
        // (mevcut cache'i koruyoruz), UI için default değer döndürüyoruz.
        return _defaultPaymentMethods;
      }
      final methods = snapshot.docs
          .map((doc) => _sanitizeMap(doc.data()))
          .toList();
      CacheService.set('payment_methods_$userId', methods);
      return methods;
    });
  }

  @override
  Future<void> addPaymentMethod(
    String userId,
    Map<String, dynamic> method,
  ) async {
    try {
      if ((method['id']?.toString() ?? '').isEmpty) {
        throw Exception('Ödeme yöntemi eklenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('paymentMethods').doc(method['id'].toString());
      final data = Map<String, dynamic>.from(method);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data, SetOptions(merge: true));

      final cacheKey = 'payment_methods_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ??
          _defaultPaymentMethods;
      if (!cached.any((m) => m['id'] == method['id'])) {
        cached.add(method);
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore ödeme yöntemi ekleme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore ödeme yöntemi ekleme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> updatePaymentMethod(
    String userId,
    Map<String, dynamic> method,
  ) async {
    try {
      if ((method['id']?.toString() ?? '').isEmpty) {
        throw Exception('Ödeme yöntemi güncellenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('paymentMethods').doc(method['id'].toString());
      final data = Map<String, dynamic>.from(method);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data, SetOptions(merge: true));

      final cacheKey = 'payment_methods_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ??
          _defaultPaymentMethods;
      final index = cached.indexWhere((m) => m['id'] == method['id']);
      if (index != -1) {
        cached[index] = method;
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore ödeme yöntemi güncelleme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore ödeme yöntemi güncelleme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  BatchOperation getUpdatePaymentMethodOperation(
    String userId,
    Map<String, dynamic> method,
  ) {
    if ((method['id']?.toString() ?? '').isEmpty) {
      throw Exception('Ödeme yöntemi güncellenirken ID eksik!');
    }

    final data = Map<String, dynamic>.from(method);
    data['updatedAt'] = FieldValue.serverTimestamp();

    // Not: CacheService güncellemesi burada yapılamaz çünkü batch işlemi
    // başarılı mı başarısız mı henüz bilinmiyor. Optimistic UI'da bu sorun olmaz
    // çünkü yerel cache zaten controller tarafından anında güncellenir.

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/paymentMethods',
      documentId: method['id'].toString(),
      type: BatchOperationType
          .set, // GÜVENLİK YAMASI: Default methodlar db'de olmayabilir, set(merge) davranışı gerekir
      merge: true,
      data: data,
    );
  }

  @override
  BatchOperation getIncrementBalanceOperation(
    String userId,
    String methodId,
    double amountDelta,
  ) {
    if (methodId.isEmpty) {
      throw Exception('Ödeme yöntemi güncellenirken ID eksik!');
    }

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/paymentMethods',
      documentId: methodId,
      type: BatchOperationType.set,
      merge: true,
      data: {
        'balance': FieldValue.increment(amountDelta),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  @override
  BatchOperation getDeletePaymentMethodOperation(
    String userId,
    String methodId,
  ) {
    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/paymentMethods',
      documentId: methodId,
      type: BatchOperationType.delete,
    );
  }

  @override
  BatchOperation getAddPaymentMethodOperation(
    String userId,
    Map<String, dynamic> method,
  ) {
    if ((method['id']?.toString() ?? '').isEmpty) {
      throw Exception('Ödeme yöntemi eklenirken ID eksik!');
    }

    final data = Map<String, dynamic>.from(method);
    data['updatedAt'] = FieldValue.serverTimestamp();

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/paymentMethods',
      documentId: method['id'].toString(),
      type: BatchOperationType.set,
      merge: true,
      data: data,
    );
  }

  @override
  Future<void> deletePaymentMethod(String userId, String methodId) async {
    try {
      final docRef = _userDoc(
        userId,
      ).collection('paymentMethods').doc(methodId);
      await docRef.delete();

      final cacheKey = 'payment_methods_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ??
          _defaultPaymentMethods;
      cached.removeWhere((m) => m['id'] == methodId);
      CacheService.set(cacheKey, cached);
    } catch (e, stackTrace) {
      debugPrint('Firestore ödeme yöntemi silme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore ödeme yöntemi silme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
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
  Future<void> addDeletedPaymentMethod(
    String userId,
    Map<String, dynamic> method,
  ) async {
    try {
      if ((method['id']?.toString() ?? '').isEmpty) {
        throw Exception('Silinen ödeme yöntemi eklenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('deletedPaymentMethods').doc(method['id'].toString());
      await docRef.set(method);

      final cacheKey = 'deleted_payment_methods_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      if (!cached.any((m) => m['id'] == method['id'])) {
        cached.add(method);
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Silinen ödeme yöntemi ekleme hatası: $e');
      ErrorLoggerService.logError(
        'Silinen ödeme yöntemi ekleme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> removeDeletedPaymentMethod(
    String userId,
    String methodId,
  ) async {
    try {
      final docRef = _userDoc(
        userId,
      ).collection('deletedPaymentMethods').doc(methodId);
      await docRef.delete();

      final cacheKey = 'deleted_payment_methods_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      cached.removeWhere((m) => m['id'] == methodId);
      CacheService.set(cacheKey, cached);
    } catch (e, stackTrace) {
      debugPrint('Silinen ödeme yöntemi kalıcı silme hatası: $e');
      ErrorLoggerService.logError(
        'Silinen ödeme yöntemi kalıcı silme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
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
    } catch (e, stackTrace) {
      debugPrint('Varsayılan ödeme yöntemi kaydedilirken hata: $e');
      ErrorLoggerService.logError(
        'Varsayılan ödeme yöntemi kaydedilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getTransfers(String userId) {
    return CacheService.get<List<Map<String, dynamic>>>('transfers_$userId') ??
        [];
  }

  @override
  Stream<List<Map<String, dynamic>>> watchTransfers(String userId) {
    return _userDoc(userId)
        .collection('transfers')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          final transfers = snapshot.docs
              .map((doc) => _sanitizeMap(doc.data()))
              .toList();
          CacheService.set('transfers_$userId', transfers);
          return transfers;
        });
  }

  @override
  BatchOperation getAddTransferOperation(
    String userId,
    Map<String, dynamic> transfer,
  ) {
    if ((transfer['id']?.toString() ?? '').isEmpty) {
      throw Exception('Transfer eklenirken ID eksik!');
    }

    final data = Map<String, dynamic>.from(transfer);
    data['updatedAt'] = FieldValue.serverTimestamp();

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/transfers',
      documentId: transfer['id'].toString(),
      type: BatchOperationType.set,
      data: data,
    );
  }

  @override
  BatchOperation getUpdateTransferOperation(
    String userId,
    Map<String, dynamic> transfer,
  ) {
    if ((transfer['id']?.toString() ?? '').isEmpty) {
      throw Exception('Transfer güncellenirken ID eksik!');
    }

    final data = Map<String, dynamic>.from(transfer);
    data['updatedAt'] = FieldValue.serverTimestamp();

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/transfers',
      documentId: transfer['id'].toString(),
      type: BatchOperationType.update,
      data: data,
    );
  }

  @override
  Future<void> addTransfer(String userId, Map<String, dynamic> transfer) async {
    try {
      if ((transfer['id']?.toString() ?? '').isEmpty) {
        throw Exception('Transfer eklenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('transfers').doc(transfer['id'].toString());
      final data = Map<String, dynamic>.from(transfer);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);

      final cacheKey = 'transfers_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      if (!cached.any((t) => t['id'] == transfer['id'])) {
        cached.add(transfer);
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore transfer ekleme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore transfer ekleme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTransfer(
    String userId,
    Map<String, dynamic> transfer,
  ) async {
    try {
      if ((transfer['id']?.toString() ?? '').isEmpty) {
        throw Exception('Transfer güncellenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('transfers').doc(transfer['id'].toString());
      final data = Map<String, dynamic>.from(transfer);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.update(data);

      final cacheKey = 'transfers_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      final index = cached.indexWhere((t) => t['id'] == transfer['id']);
      if (index != -1) {
        cached[index] = transfer;
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore transfer güncelleme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore transfer güncelleme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteTransfer(String userId, String transferId) async {
    try {
      final docRef = _userDoc(userId).collection('transfers').doc(transferId);
      await docRef.delete();

      final cacheKey = 'transfers_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      cached.removeWhere((t) => t['id'] == transferId);
      CacheService.set(cacheKey, cached);
    } catch (e, stackTrace) {
      debugPrint('Firestore transfer silme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore transfer silme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }
}
