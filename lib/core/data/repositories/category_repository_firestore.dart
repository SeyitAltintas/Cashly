import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/category_repository.dart';

/// Kategori repository - Firestore implementasyonu
///
/// Koleksiyon yapısı:
///   users/{uid}/categories/expense_categories  → harcama kategorileri (tek doküman)
///   users/{uid}/categories/income_categories   → gelir kategorileri (tek doküman)
class CategoryRepositoryFirestore implements CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Varsayılan kategoriler (Firestore'dan boş gelirse kullanılır)
  static List<Map<String, dynamic>> get _defaultExpenseCategories => [
    {'isim': 'Yemek ve Kafe', 'ikon': 'restaurant'},
    {'isim': 'Market ve Atıştırmalık', 'ikon': 'shopping_basket'},
    {'isim': 'Araç ve Ulaşım', 'ikon': 'two_wheeler'},
    {'isim': 'Hediye ve Özel', 'ikon': 'card_giftcard'},
    {'isim': 'Sabit Giderler', 'ikon': 'credit_card'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  static List<Map<String, dynamic>> get _defaultIncomeCategories => [
    {'isim': 'Maaş', 'ikon': 'work'},
    {'isim': 'Freelance', 'ikon': 'laptop'},
    {'isim': 'Yatırım', 'ikon': 'trending_up'},
    {'isim': 'Kira Geliri', 'ikon': 'home'},
    {'isim': 'Hediye', 'ikon': 'card_giftcard'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  DocumentReference _categoryDoc(String userId, String docId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('categories')
      .doc(docId);

  // ===== HARCAMA KATEGORİLERİ =====

  @override
  List<Map<String, dynamic>> getExpenseCategories(String userId) {
    // Firestore sync interface — cached versiyon döner, async için _fetchExpense kullan
    return _defaultExpenseCategories;
  }

  /// Firestore'dan harcama kategorilerini çeker (gerçek async versiyon)
  Future<List<Map<String, dynamic>>> fetchExpenseCategories(String userId) async {
    try {
      final doc = await _categoryDoc(userId, 'expense_categories').get();
      if (!doc.exists) {
        // İlk kez — varsayılanları kaydet ve döndür
        await saveExpenseCategories(userId, _defaultExpenseCategories);
        return _defaultExpenseCategories;
      }
      final data = doc.data() as Map<String, dynamic>?;
      final list = data?['categories'] as List<dynamic>? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Firestore harcama kategorileri getirilirken hata: $e');
      return _defaultExpenseCategories;
    }
  }

  @override
  Future<void> saveExpenseCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      await _categoryDoc(userId, 'expense_categories').set({
        'categories': categories,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore harcama kategorileri kaydedilirken hata: $e');
      rethrow;
    }
  }

  // ===== GELİR KATEGORİLERİ =====

  @override
  List<Map<String, dynamic>> getIncomeCategories(String userId) {
    return _defaultIncomeCategories;
  }

  /// Firestore'dan gelir kategorilerini çeker
  Future<List<Map<String, dynamic>>> fetchIncomeCategories(String userId) async {
    try {
      final doc = await _categoryDoc(userId, 'income_categories').get();
      if (!doc.exists) {
        await saveIncomeCategories(userId, _defaultIncomeCategories);
        return _defaultIncomeCategories;
      }
      final data = doc.data() as Map<String, dynamic>?;
      final list = data?['categories'] as List<dynamic>? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Firestore gelir kategorileri getirilirken hata: $e');
      return _defaultIncomeCategories;
    }
  }

  @override
  Future<void> saveIncomeCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      await _categoryDoc(userId, 'income_categories').set({
        'categories': categories,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore gelir kategorileri kaydedilirken hata: $e');
      rethrow;
    }
  }
}
