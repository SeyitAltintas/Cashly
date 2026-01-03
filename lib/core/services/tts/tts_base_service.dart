/// TTS Temel Servis
/// Ana TTS başlatma ve konuşma fonksiyonlarını içerir
library;

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import '../../di/injection_container.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';

/// Temel TTS işlevselliğini sağlayan sınıf
class TtsBaseService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Türkçe dil ayarı
      await _flutterTts.setLanguage('tr-TR');

      // Ses hızı (0.0 - 1.0 arası, 0.5 normal)
      await _flutterTts.setSpeechRate(0.5);

      // Ses tonu (0.5 - 2.0 arası, 1.0 normal)
      await _flutterTts.setPitch(1.0);

      // Ses seviyesi (0.0 - 1.0 arası)
      await _flutterTts.setVolume(1.0);

      _isInitialized = true;
      debugPrint('TTS Service initialized successfully');
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// Metni sesli oku (ayar kontrolü ile)
  Future<void> speak(String text, {String? userId}) async {
    // Kullanıcı ID'si verilmişse ayarı kontrol et
    if (userId != null) {
      bool isEnabled = getIt<SettingsRepository>().isVoiceFeedbackEnabled(
        userId,
      );
      if (!isEnabled) {
        debugPrint('TTS disabled by user settings');
        return;
      }
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Sesi durdur
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Test sesi çal
  Future<void> testSesiCal() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _flutterTts.speak('Sesli asistan aktif');
  }

  /// Tarihi konuşma için formatla
  String formatDateForSpeech(DateTime? tarih) {
    if (tarih == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(tarih.year, tarih.month, tarih.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return ''; // Bugün - ek bilgi verme
    } else if (difference == 1) {
      return ' dün tarihiyle';
    } else if (difference == 2) {
      return ' önceki gün tarihiyle';
    } else if (difference <= 7) {
      // Gün ismini bul
      final gunIsimleri = [
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar',
      ];
      final gunIsmi = gunIsimleri[tarih.weekday - 1];
      return ' $gunIsmi günü tarihiyle';
    } else {
      return ' ${tarih.day}/${tarih.month} tarihiyle';
    }
  }

  /// Servisi temizle
  void dispose() {
    _flutterTts.stop();
  }
}
