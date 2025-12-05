import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';

/// Text-to-Speech servisi - Sesli geri bildirim için kullanılır
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

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
      bool isEnabled = DatabaseHelper.sesliGeriBildirimAktifMi(userId);
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

  /// Harcama eklendi bildirimini oku
  /// Format: "[tutar] lira [harcama ismi] [kategori] kategorisine eklendi"
  Future<void> harcamaEklendiBildirimi({
    required double tutar,
    required String harcamaIsmi,
    required String kategori,
    String? userId,
  }) async {
    String tutarStr = tutar.toStringAsFixed(0);
    String mesaj = '$tutarStr lira $harcamaIsmi $kategori kategorisine eklendi';
    await speak(mesaj, userId: userId);
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

  /// Son harcama silindi bildirimi
  Future<void> harcamaSilindiBildirimi({
    required String harcamaIsmi,
    required double tutar,
    String? userId,
  }) async {
    String tutarStr = tutar.toStringAsFixed(0);
    String mesaj = '$harcamaIsmi, $tutarStr lira silindi';
    await speak(mesaj, userId: userId);
  }

  /// Bu ay toplam harcama bildirimi
  Future<void> buAyHarcamaBildirimi({
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = 'Bu ay toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// En çok harcanan kategori bildirimi
  Future<void> enCokKategoriBildirimi({
    required String kategori,
    required double tutar,
    String? userId,
  }) async {
    String tutarStr = tutar.toStringAsFixed(0);
    String mesaj = 'En çok $kategori kategorisinde, $tutarStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Harcama bulunamadı bildirimi
  Future<void> harcamaBulunamadiBildirimi({String? userId}) async {
    String mesaj = 'Silinecek harcama bulunamadı';
    await speak(mesaj, userId: userId);
  }

  /// Servisi temizle
  void dispose() {
    _flutterTts.stop();
  }
}
