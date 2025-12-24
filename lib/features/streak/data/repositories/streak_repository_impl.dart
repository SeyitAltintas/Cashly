import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as developer;
import '../../domain/repositories/streak_repository.dart';
import '../models/streak_model.dart';

/// Seri (Streak) repository implementasyonu (Data Layer)
/// Hive veritabanı ile streak verilerini yönetir
class StreakRepositoryImpl implements StreakRepository {
  static const String _boxName = 'streak_box';
  static const String _logName = 'StreakRepository';

  @override
  StreakData getStreakData(String userId) {
    try {
      final box = Hive.box(_boxName);
      final data = box.get('streak_$userId');
      if (data == null) return StreakData.empty();
      return StreakData.fromMap(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      developer.log(
        'Seri verisi okunurken hata',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return StreakData.empty();
    }
  }

  @override
  Future<void> saveStreakData(String userId, StreakData data) async {
    try {
      final box = Hive.box(_boxName);
      await box.put('streak_$userId', data.toMap());
      developer.log(
        'Seri verisi kaydedildi: streak=${data.currentStreak}, userId=$userId',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Seri verisi kaydedilirken hata',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }
}
