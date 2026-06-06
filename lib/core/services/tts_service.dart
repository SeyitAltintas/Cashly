import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import '../di/injection_container.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

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

  /// Harcama eklendi bildirimini oku
  /// Format: "[tutar] lira [harcama ismi] [kategori] kategorisine eklendi"
  Future<void> harcamaEklendiBildirimi({
    required double tutar,
    required String harcamaIsmi,
    required String kategori,
    String? userId,
    DateTime? tarih,
  }) async {
    String tutarStr = tutar.toStringAsFixed(0);
    String tarihStr = _formatDateForSpeech(tarih);
    String mesaj =
        '$tutarStr lira $harcamaIsmi $kategori kategorisine$tarihStr eklendi';
    await speak(mesaj, userId: userId);
  }

  /// Tarihi konuşma için formatla
  String _formatDateForSpeech(DateTime? tarih) {
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

  /// Bu hafta toplam harcama bildirimi
  Future<void> buHaftaHarcamaBildirimi({
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = 'Bu hafta toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Bugün toplam harcama bildirimi
  Future<void> bugunHarcamaBildirimi({
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = toplam == 0
        ? 'Bugün henüz harcama yapmadınız'
        : 'Bugün toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Son harcamalar bildirimi
  Future<void> sonHarcamalarBildirimi({
    required List<Map<String, dynamic>> harcamalar,
    String? userId,
  }) async {
    if (harcamalar.isEmpty) {
      await speak('Henüz harcama bulunmuyor', userId: userId);
      return;
    }

    // En fazla 5 harcama söyle
    int adet = harcamalar.length > 5 ? 5 : harcamalar.length;
    StringBuffer mesaj = StringBuffer('Son $adet harcamanız: ');

    for (int i = 0; i < adet; i++) {
      var h = harcamalar[i];
      String isim = h['isim'] ?? 'Harcama';
      double tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      mesaj.write('$isim ${tutar.toStringAsFixed(0)} lira');
      if (i < adet - 1) mesaj.write(', ');
    }

    await speak(mesaj.toString(), userId: userId);
  }

  /// Bütçe durumu bildirimi
  Future<void> butceDurumBildirimi({
    required double kalanLimit,
    required double asilanMiktar,
    String? userId,
  }) async {
    String mesaj;
    if (asilanMiktar > 0) {
      mesaj = 'Bütçenizi ${asilanMiktar.toStringAsFixed(0)} lira aştınız';
    } else if (kalanLimit > 0) {
      mesaj = 'Bütçenizden ${kalanLimit.toStringAsFixed(0)} lira kaldı';
    } else {
      mesaj = 'Bütçeniz tam olarak harcandı';
    }
    await speak(mesaj, userId: userId);
  }

  /// Kategori bazlı harcama bildirimi
  Future<void> kategoriHarcamaBildirimi({
    required String kategori,
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = toplam == 0
        ? '$kategori kategorisinde henüz harcama yok'
        : '$kategori kategorisinde toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Tekrarlayan işlemler eklendi bildirimi
  Future<void> sabitGiderlerEklendiBildirimi({
    required int adet,
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = adet == 0
        ? 'Eklenecek tekrarlayan işlem bulunamadı. Önce ayarlardan tekrarlayan işlem tanımlayın.'
        : '$adet adet tekrarlayan işlem eklendi. Toplam $toplamStr lira.';
    await speak(mesaj, userId: userId);
  }

  /// Harcama düzenlendi bildirimi
  Future<void> harcamaDuzenlendiBildirimi({
    required String harcamaIsmi,
    required double eskiTutar,
    required double yeniTutar,
    String? userId,
  }) async {
    String eskiStr = eskiTutar.toStringAsFixed(0);
    String yeniStr = yeniTutar.toStringAsFixed(0);
    String mesaj = '$harcamaIsmi, $eskiStr liradan $yeniStr liraya güncellendi';
    await speak(mesaj, userId: userId);
  }

  /// Dün toplam harcama bildirimi
  Future<void> dunHarcamaBildirimi({
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = toplam == 0
        ? 'Dün harcama yapmadınız'
        : 'Dün toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Geçen hafta toplam harcama bildirimi
  Future<void> gecenHaftaHarcamaBildirimi({
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = toplam == 0
        ? 'Geçen hafta harcama yapmadınız'
        : 'Geçen hafta toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Geçen ay toplam harcama bildirimi
  Future<void> gecenAyHarcamaBildirimi({
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = toplam == 0
        ? 'Geçen ay harcama yapmadınız'
        : 'Geçen ay toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Bu yıl toplam harcama bildirimi
  Future<void> buYilHarcamaBildirimi({
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = toplam == 0
        ? 'Bu yıl henüz harcama yapmadınız'
        : 'Bu yıl toplam $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Tarihli kategori harcama bildirimi
  Future<void> tarihliKategoriHarcamaBildirimi({
    required String donem,
    required String kategori,
    required double toplam,
    String? userId,
  }) async {
    String toplamStr = toplam.toStringAsFixed(0);
    String mesaj = toplam == 0
        ? '$donem $kategori kategorisinde harcama yapmadınız'
        : '$donem $kategori kategorisinde $toplamStr lira harcadınız';
    await speak(mesaj, userId: userId);
  }

  /// Kalan bütçe bildirimi
  Future<void> kalanButceBildirimi({
    required double kalanButce,
    required double butceLimiti,
    String? userId,
  }) async {
    String kalanStr = kalanButce.toStringAsFixed(0);
    String limitStr = butceLimiti.toStringAsFixed(0);
    String mesaj;

    if (kalanButce > 0) {
      mesaj = '$limitStr liralık bütçenizden $kalanStr lira kaldı.';
    } else if (kalanButce < 0) {
      mesaj = 'Bütçenizi ${(-kalanButce).toStringAsFixed(0)} lira aştınız.';
    } else {
      mesaj = 'Bütçeniz tam olarak tükendi.';
    }
    await speak(mesaj, userId: userId);
  }

  /// Limit güncellendi bildirimi
  Future<void> limitGuncellendiBildirimi({
    required double yeniLimit,
    String? userId,
  }) async {
    String limitStr = yeniLimit.toStringAsFixed(0);
    String mesaj = 'Aylık bütçeniz $limitStr lira olarak güncellendi.';
    await speak(mesaj, userId: userId);
  }

  /// Tasarruf bildirimi
  Future<void> tasarrufBildirimi({
    required double tasarruf,
    required double butceLimiti,
    String? userId,
  }) async {
    String tasarrufStr = tasarruf.abs().toStringAsFixed(0);
    String mesaj;

    if (tasarruf > 0) {
      mesaj = 'Bu ay $tasarrufStr lira tasarruf ettiniz. Tebrikler!';
    } else if (tasarruf < 0) {
      mesaj = 'Bu ay $tasarrufStr lira açık verdiniz. Dikkatli olun.';
    } else {
      mesaj = 'Bu ay tam bütçeniz kadar harcadınız.';
    }
    await speak(mesaj, userId: userId);
  }

  /// Servisi temizle
  void dispose() {
    _flutterTts.stop();
  }
}
