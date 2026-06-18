import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/services/batch_service.dart';
import 'package:cashly/core/services/error_logger_service.dart';

/// Harcama repository implementasyonu (Firestore)
/// Clean Architecture: ExpenseRepository interface'ini Firestore ile uygular.
class ExpenseRepositoryFirestore implements ExpenseRepository {
  final _firestore = FirebaseFirestore.instance;

  static List<Map<String, dynamic>> get defaultCategories => [
    {'isim': 'Yemek ve Kafe', 'ikon': 'restaurant'},
    {'isim': 'Market ve Atıştırmalık', 'ikon': 'shopping_basket'},
    {'isim': 'Araç ve Ulaşım', 'ikon': 'two_wheeler'},
    {'isim': 'Hediye ve Özel', 'ikon': 'card_giftcard'},
    {'isim': 'Sabit Giderler', 'ikon': 'credit_card'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  DocumentReference _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  List<Map<String, dynamic>> getExpenses(String userId) {
    final cacheKey = 'expenses_$userId';
    final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;
    return [];
  }

  @override
  List<Map<String, dynamic>> getExpensesByMonth(String userId, DateTime month) {
    final all = getExpenses(userId);
    return all.where((h) {
      if (h['silindi'] == true) return false;
      final tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      return tarih.year == month.year && tarih.month == month.month;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> watchExpenses(String userId) {
    return _userDoc(userId)
        .collection('expenses')
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) {
          final expenses = snapshot.docs.map((doc) {
            final data = doc.data();
            _convertTimestampToString(data);
            return data;
          }).toList();
          CacheService.set('expenses_$userId', expenses);
          return expenses;
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchExpensesByMonth(
    String userId,
    DateTime month,
  ) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
      999,
    );

    return _userDoc(userId)
        .collection('expenses')
        .where(
          'tarih',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('tarih', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) {
          final newMonthExpenses = snapshot.docs.map((doc) {
            final data = doc.data();
            _convertTimestampToString(data);
            return data;
          }).toList();

          // Global cache'e bu ayın verilerini merge et
          final cacheKey = 'expenses_$userId';
          final cached =
              CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];

          // Eski bu aya ait verileri sil
          cached.removeWhere((e) {
            final tarih = DateTime.tryParse(e['tarih'].toString());
            if (tarih == null) return false;
            return tarih.year == month.year && tarih.month == month.month;
          });

          // Yeni verileri ekle
          cached.addAll(newMonthExpenses);
          CacheService.set(cacheKey, cached);

          return newMonthExpenses;
        });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchExpensesForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snap = await _userDoc(userId)
          .collection('expenses')
          .where('tarih', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('tarih', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('tarih', descending: true)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        _convertTimestampToString(data);
        return data;
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('fetchExpensesForDateRange hatası: $e');
      ErrorLoggerService.logError(
        'fetchExpensesForDateRange hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      return [];
    }
  }

  @override
  Future<void> addExpense(String userId, Map<String, dynamic> expense) async {
    try {
      if ((expense['id']?.toString() ?? '').isEmpty) {
        throw Exception('Harcama eklenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('expenses').doc(expense['id'].toString());
      final data = _convertStringToTimestamp(expense);
      await docRef.set(data);

      // Cache'i güncelle
      final cacheKey = 'expenses_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      // Aynı ID'de veri varsa ekleme
      if (!cached.any((e) => e['id'] == expense['id'])) {
        cached.add(expense);
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore harcama ekleme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore harcama ekleme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(
    String userId,
    Map<String, dynamic> expense,
  ) async {
    try {
      if ((expense['id']?.toString() ?? '').isEmpty) {
        throw Exception('Harcama güncellenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('expenses').doc(expense['id'].toString());
      final data = _convertStringToTimestamp(expense);
      await docRef.update(data);

      // Cache'i güncelle
      final cacheKey = 'expenses_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      final index = cached.indexWhere((e) => e['id'] == expense['id']);
      if (index != -1) {
        cached[index] = expense;
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore harcama güncelleme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore harcama güncelleme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      final docRef = _userDoc(userId).collection('expenses').doc(expenseId);
      await docRef.delete();

      // Cache'i güncelle
      final cacheKey = 'expenses_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      cached.removeWhere((e) => e['id'] == expenseId);
      CacheService.set(cacheKey, cached);
    } catch (e, stackTrace) {
      debugPrint('Firestore harcama silme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore harcama silme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  BatchOperation getAddExpenseOperation(
    String userId,
    Map<String, dynamic> expense,
  ) {
    if ((expense['id']?.toString() ?? '').isEmpty) {
      throw Exception('Harcama eklenirken ID eksik!');
    }
    final data = _convertStringToTimestamp(expense);

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/expenses',
      documentId: expense['id'].toString(),
      type: BatchOperationType.set,
      data: data,
    );
  }

  @override
  BatchOperation getUpdateExpenseOperation(
    String userId,
    Map<String, dynamic> expense,
  ) {
    if ((expense['id']?.toString() ?? '').isEmpty) {
      throw Exception('Harcama güncellenirken ID eksik!');
    }
    final data = _convertStringToTimestamp(expense);

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/expenses',
      documentId: expense['id'].toString(),
      type: BatchOperationType.update,
      data: data,
    );
  }

  @override
  BatchOperation getDeleteExpenseOperation(String userId, String expenseId) {
    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/expenses',
      documentId: expenseId,
      type: BatchOperationType.delete,
    );
  }

  @override
  double getBudget(String userId) {
    final cacheKey = 'budget_$userId';
    final cached = CacheService.get<double>(cacheKey);
    if (cached != null) return cached;
    return 8000.0;
  }

  Stream<double> watchBudget(String userId) {
    return _userDoc(
      userId,
    ).collection('settings').doc('general').snapshots().map((doc) {
      final budget = (doc.data()?['budget'] as num?)?.toDouble() ?? 8000.0;
      CacheService.set('budget_$userId', budget);
      return budget;
    });
  }

  @override
  Future<void> saveBudget(String userId, double limit) async {
    try {
      await _userDoc(userId).collection('settings').doc('general').set({
        'budget': limit,
      }, SetOptions(merge: true));
      CacheService.set('budget_$userId', limit);
    } catch (e, stackTrace) {
      debugPrint('Firestore bütçe kaydetme hatası: $e');
      ErrorLoggerService.logError(
        'Firestore bütçe kaydetme hatası: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getFixedExpenseTemplates(String userId) {
    try {
      return CacheService.get<List<Map<String, dynamic>>>(
            'fixed_templates_$userId',
          ) ??
          [];
    } catch (e, stackTrace) {
      debugPrint('Sabit gider şablonları getirilirken hata: $e');
      ErrorLoggerService.logError(
        'Sabit gider şablonları getirilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      return [];
    }
  }

  @override
  Future<void> saveFixedExpenseTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  ) async {
    try {
      await _userDoc(userId).collection('settings').doc('general').set({
        'fixedExpenseTemplates': templates,
      }, SetOptions(merge: true));
      CacheService.set('fixed_templates_$userId', templates);
    } catch (e, stackTrace) {
      debugPrint('Sabit gider şablonları kaydedilirken hata: $e');
      ErrorLoggerService.logError(
        'Sabit gider şablonları kaydedilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getCategories(String userId) {
    try {
      final cached = CacheService.get<List<Map<String, dynamic>>>(
        'expense_categories_$userId',
      );
      if (cached != null && cached.isNotEmpty) return cached;

      // Cache boşsa veya null ise sadece defaultları döndür.
      // Firestore'a kaydetmeye çalışmak custom kategorileri silebilir!
      return defaultCategories;
    } catch (e, stackTrace) {
      debugPrint('Kategoriler getirilirken hata: $e');
      ErrorLoggerService.logError(
        'Kategoriler getirilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      return defaultCategories;
    }
  }

  Stream<List<Map<String, dynamic>>> watchCategories(String userId) {
    return _userDoc(userId).collection('expenseCategories').snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) return defaultCategories;
      final categories = snapshot.docs.map((doc) => doc.data()).toList();
      CacheService.set('expense_categories_$userId', categories);
      return categories;
    });
  }

  @override
  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('expenseCategories');
      final batch = _firestore.batch();

      final getOptions = NetworkService().isOffline
          ? const GetOptions(source: Source.cache)
          : const GetOptions();
      final existing = await colRef
          .get(getOptions)
          .timeout(const Duration(seconds: 10));
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // Yenilerini ekle
      for (int i = 0; i < categories.length; i++) {
        final catId =
            categories[i]['isim']?.toString().toLowerCase().replaceAll(
              ' ',
              '_',
            ) ??
            'cat_$i';
        batch.set(colRef.doc(catId), categories[i]);
      }

      if (NetworkService().isOffline) {
        batch.commit(); // Çevrimdışıysa arkada bekle
      } else {
        await batch.commit().timeout(const Duration(seconds: 10));
      }
      CacheService.set('expense_categories_$userId', categories);
    } on TimeoutException {
      debugPrint('Kategori kaydetme zaman aşımına uğradı.');
    } catch (e, stackTrace) {
      debugPrint('Kategoriler kaydedilirken hata: $e');
      ErrorLoggerService.logError(
        'Kategoriler kaydedilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  @override
  Map<String, double> getCategoryBudgets(String userId) {
    final cacheKey = 'category_budgets_$userId';
    final cached = CacheService.get<Map<String, double>>(cacheKey);
    if (cached != null) return cached;
    return {};
  }

  @override
  Future<void> saveCategoryBudgets(
    String userId,
    Map<String, double> budgets,
  ) async {
    try {
      await _userDoc(userId).collection('settings').doc('general').set({
        'categoryBudgets': budgets,
      }, SetOptions(merge: true));
      CacheService.set('category_budgets_$userId', budgets);
    } catch (e, stackTrace) {
      debugPrint('Kategori bütçeleri kaydedilirken hata: $e');
      ErrorLoggerService.logError(
        'Kategori bütçeleri kaydedilirken hata: $e',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    }
  }

  // -- Yardımcı metodlar --

  void _convertTimestampToString(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value is Timestamp) {
        data[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        _convertTimestampToString(Map<String, dynamic>.from(value));
      } else if (value is List) {
        data[key] = value.map((e) {
          if (e is Timestamp) return e.toDate().toIso8601String();
          if (e is Map) {
            final m = Map<String, dynamic>.from(e);
            _convertTimestampToString(m);
            return m;
          }
          return e;
        }).toList();
      }
    });
  }

  Map<String, dynamic> _convertStringToTimestamp(Map<String, dynamic> source) {
    final data = Map<String, dynamic>.from(source);
    if (data['tarih'] is String) {
      data['tarih'] = Timestamp.fromDate(DateTime.parse(data['tarih']));
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    return data;
  }
}
