import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_category_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';


class NoteCategoryRepository {
  String _currentUserId = 'default';
  String get _boxName => 'note_categories_$_currentUserId';

  static final NoteCategoryRepository _instance = NoteCategoryRepository._internal();
  factory NoteCategoryRepository() => _instance;
  NoteCategoryRepository._internal();

  Box? _box;
  Future<void>? _initFuture;

  Future<void> init() {
    try {
      final authRepo = getIt<AuthRepository>();
      authRepo.getCurrentUser().then((user) {
        _currentUserId = user?.id ?? 'default';
      });
    } catch (_) {}

    if (_box != null && _box!.isOpen && _box!.name == _boxName) return Future.value();
    
    closeAll();

    return _initFuture ??= _openBox_().whenComplete(() => _initFuture = null);
  }

  Future<void> closeAll() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
    _box = null;
    _initFuture = null;
  }

  Future<void> _openBox_() async {
    // Migration: Migrate common 'note_categories' to scoped 'note_categories_$_currentUserId'
    if (_currentUserId != 'default') {
      if (await Hive.boxExists('note_categories') && !(await Hive.boxExists(_boxName))) {
        debugPrint('Migration: Taşıma başlıyor. note_categories -> $_boxName');
        final oldBox = await Hive.openBox('note_categories');
        final newBox = await Hive.openBox(_boxName);
        await newBox.putAll(Map.from(oldBox.toMap()));
        await oldBox.close();
        await Hive.deleteBoxFromDisk('note_categories');
      }
    }

    _box = await Hive.openBox(_boxName);
    
    // EC-ZOMBIE: Eğer kategoriler daha önce tohumlandıysa (seeded), tekrar oluşturma.
    // Aksi takdirde kullanıcı bir kategoriyi sildiğinde uygulama yeniden başlatılınca 
    // kategori zombi gibi geri dönüyordu!
    final isSeeded = _box!.get('defaults_seeded', defaultValue: false) as bool;
    if (isSeeded) return;

    final existingNames = _box!.values.whereType<Map>().map((e) => e['name'] as String).toSet();
    
    Future<void> addIfNotExists(String name) async {
      if (!existingNames.contains(name)) {
        final category = NoteCategoryModel.create(name: name);
        await _box!.put(category.id, category.toMap());
      }
    }

    await addIfNotExists('İş');
    await addIfNotExists('Kişisel');
    await addIfNotExists('Eğitim');
    await addIfNotExists('Fikir');
    await addIfNotExists('Alışveriş');
    await addIfNotExists('Seyahat');
    await addIfNotExists('Hatırlatma');
    await addIfNotExists('Önemli');
    
    await _box!.put('defaults_seeded', true);
  }

  ValueListenable<Box> listenable() => _requireBox.listenable();

  Box get _requireBox {
    assert(_box != null && _box!.isOpen, 'NoteCategoryRepository.init() must be called first');
    return _box!;
  }

  List<NoteCategoryModel> getAllCategories() {
    if (_box == null || !_box!.isOpen) return [];
    final result = <NoteCategoryModel>[];
    for (final raw in _box!.values) {
      try {
        if (raw is! Map) continue;
        final category = NoteCategoryModel.fromMap(Map<String, dynamic>.from(raw));
        if (category.id.isEmpty) continue;
        result.add(category);
      } catch (_) {}
    }
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }

  NoteCategoryModel? getCategoryById(String id) {
    if (_box == null || !_box!.isOpen) return null;
    try {
      final raw = _box!.get(id);
      if (raw == null || raw is! Map) return null;
      return NoteCategoryModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCategory(NoteCategoryModel category) async {
    await init();
    await _requireBox.put(category.id, category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await init();
    await _requireBox.delete(id);
  }
}
