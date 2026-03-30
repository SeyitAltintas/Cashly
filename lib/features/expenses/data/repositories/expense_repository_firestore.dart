import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/expense_repository.dart';

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
  Future<void> saveExpenses(
    String userId,
    List<Map<String, dynamic>> expenses,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('expenses');
      
      // Mevcut dokümanları sil (tam üzerine yazma)
      final existing = await colRef.get();
      final batch = _firestore.batch();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }
      
      // Yenilerini ekle
      for (final expense in expenses) {
        final id = expense['id'] as String? ?? '';
        if (id.isEmpty) continue;
        final data = _convertStringToTimestamp(expense);
        batch.set(colRef.doc(id), data);
      }
      
      await batch.commit();
      CacheService.set('expenses_$userId', expenses);
    } catch (e) {
      debugPrint('Firestore harcama kaydetme hatası: $e');
      rethrow;
    }
  }

  @override
  double getBudget(String userId) {
    final cacheKey = 'budget_$userId';
    final cached = CacheService.get<double>(cacheKey);
    if (cached != null) return cached;
    return 8000.0;
  }

  Stream<double> watchBudget(String userId) {
    return _userDoc(userId)
        .collection('settings')
        .doc('general')
        .snapshots()
        .map((doc) {
      final budget = (doc.data()?['budget'] as num?)?.toDouble() ?? 8000.0;
      CacheService.set('budget_$userId', budget);
      return budget;
    });
  }

  @override
  Future<void> saveBudget(String userId, double limit) async {
    try {
      await _userDoc(userId).collection('settings').doc('general').set(
        {'budget': limit},
        SetOptions(merge: true),
      );
      CacheService.set('budget_$userId', limit);
    } catch (e) {
      debugPrint('Firestore bütçe kaydetme hatası: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getFixedExpenseTemplates(String userId) {
    try {
      return CacheService.get<List<Map<String, dynamic>>>(
              'fixed_templates_$userId') ??
          [];
    } catch (e) {
      debugPrint('Sabit gider şablonları getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveFixedExpenseTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  ) async {
    try {
      await _userDoc(userId).collection('settings').doc('general').set(
        {'fixedExpenseTemplates': templates},
        SetOptions(merge: true),
      );
      CacheService.set('fixed_templates_$userId', templates);
    } catch (e) {
      debugPrint('Sabit gider şablonları kaydedilirken hata: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getCategories(String userId) {
    try {
      final cached = CacheService.get<List<Map<String, dynamic>>>(
          'expense_categories_$userId');
      if (cached != null) return cached;
      saveCategories(userId, defaultCategories);
      return defaultCategories;
    } catch (e) {
      debugPrint('Kategoriler getirilirken hata: $e');
      return defaultCategories;
    }
  }

  Stream<List<Map<String, dynamic>>> watchCategories(String userId) {
    return _userDoc(userId)
        .collection('expenseCategories')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return defaultCategories;
      final categories =
          snapshot.docs.map((doc) => doc.data()).toList();
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

      // Mevcut dokümanları sil
      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // Yenilerini ekle
      for (int i = 0; i < categories.length; i++) {
        final catId = categories[i]['isim']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'cat_$i';
        batch.set(colRef.doc(catId), categories[i]);
      }

      await batch.commit();
      CacheService.set('expense_categories_$userId', categories);
    } catch (e) {
      debugPrint('Kategoriler kaydedilirken hata: $e');
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
      await _userDoc(userId).collection('settings').doc('general').set(
        {'categoryBudgets': budgets},
        SetOptions(merge: true),
      );
      CacheService.set('category_budgets_$userId', budgets);
    } catch (e) {
      debugPrint('Kategori bütçeleri kaydedilirken hata: $e');
      rethrow;
    }
  }

  // -- Yardımcı metodlar --

  void _convertTimestampToString(Map<String, dynamic> data) {
    if (data['tarih'] is Timestamp) {
      data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
    }
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
