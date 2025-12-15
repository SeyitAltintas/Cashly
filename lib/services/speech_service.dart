import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Sesli komut türleri
enum VoiceCommandType {
  /// Normal harcama ekleme
  harcamaEkle,

  /// "Son harcamayı sil" komutu
  sonHarcamayiSil,

  /// "Bu ay ne kadar harcadım?" komutu
  buAyNeKadarHarcadim,

  /// "En çok hangi kategoride harcamışım?" komutu
  enCokHangiKategori,

  /// "Bu hafta ne kadar harcadım?" komutu
  buHaftaNeKadarHarcadim,

  /// "Bugün ne kadar harcadım?" komutu
  bugunNeKadarHarcadim,

  /// "Son harcamalarım neler?" komutu
  sonHarcamalariListele,

  /// "Bütçemi aştım mı?" komutu
  butceyiAstimMi,

  /// "Markete ne kadar harcadım?" gibi kategori bazlı sorgu
  kategoriHarcamasi,

  /// "Sabit giderleri ekle" komutu
  sabitGiderleriEkle,

  /// "Son harcamayı 150 lira yap" komutu
  sonHarcamayiDuzenle,

  /// "Dün ne kadar harcadım?" komutu
  dunNeKadarHarcadim,

  /// "Geçen hafta ne kadar harcadım?" komutu
  gecenHaftaNeKadarHarcadim,

  /// "Geçen ay ne kadar harcadım?" komutu
  gecenAyNeKadarHarcadim,

  /// "Bu yıl ne kadar harcadım?" komutu
  buYilNeKadarHarcadim,

  /// "Dün markete ne kadar harcadım?" gibi tarihli kategori sorgusu
  tarihliKategoriHarcamasi,

  /// "Kalan bütçem ne kadar?" komutu
  kalanButce,

  /// "Aylık limitimi 5000 lira yap" komutu
  limitBelirle,

  /// "Bu ay ne kadar tasarruf ettim?" komutu
  tasarrufHesapla,

  /// Tanınmayan komut
  bilinmiyor,
}

/// Sesli komut sonuç modeli
class VoiceCommandResult {
  final VoiceCommandType komutTuru;
  final String rawText;
  final bool komutAlgilandi;
  final String? kategori; // Kategori bazlı sorgular için
  final double? yeniTutar; // Harcama düzenleme için yeni tutar
  final double? yeniLimit; // Bütçe limiti belirleme için
  final DateTime? baslangicTarihi; // Tarihli sorgular için başlangıç
  final DateTime? bitisTarihi; // Tarihli sorgular için bitiş

  VoiceCommandResult({
    required this.komutTuru,
    required this.rawText,
    required this.komutAlgilandi,
    this.kategori,
    this.yeniTutar,
    this.yeniLimit,
    this.baslangicTarihi,
    this.bitisTarihi,
  });
}

/// Sesli harcama girişi için parse edilmiş sonuç modeli
class SpeechParseResult {
  final double? tutar;
  final String? kategori;
  final String? harcamaIsmi;
  final String rawText;
  final bool basarili;
  final DateTime? tarih; // Tarihli harcama girişi için

  SpeechParseResult({
    this.tutar,
    this.kategori,
    this.harcamaIsmi,
    required this.rawText,
    required this.basarili,
    this.tarih,
  });
}

/// Sesli harcama girişi servisi
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Servisi başlat
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: ${error.errorMsg}'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );

    return _isInitialized;
  }

  /// Mevcut durumu kontrol et
  bool get isAvailable => _isInitialized && _speech.isAvailable;
  bool get isListening => _speech.isListening;

  /// Dinlemeyi başlat
  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onDone,
    Duration listenFor = const Duration(seconds: 7),
  }) async {
    if (!_isInitialized) {
      bool success = await initialize();
      if (!success) return;
    }

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onDone();
        }
      },
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 3),
      localeId: 'tr_TR', // Türkçe
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  /// Dinlemeyi durdur
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Sesli komutu algıla
  /// Metni analiz ederek komut türünü belirler
  VoiceCommandResult detectVoiceCommand(
    String text, {
    List<String>? mevcutKategoriler,
  }) {
    if (text.isEmpty) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.bilinmiyor,
        rawText: text,
        komutAlgilandi: false,
      );
    }

    String normalizedText = text.toLowerCase().trim();

    // "Son harcamayı sil" komutu
    if (_matchesSonHarcamayiSil(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.sonHarcamayiSil,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "Bu ay ne kadar harcadım?" komutu
    if (_matchesBuAyNeKadarHarcadim(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.buAyNeKadarHarcadim,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "En çok hangi kategoride harcamışım?" komutu
    if (_matchesEnCokHangiKategori(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.enCokHangiKategori,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "Bu hafta ne kadar harcadım?" komutu
    if (_matchesBuHaftaNeKadarHarcadim(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.buHaftaNeKadarHarcadim,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "Bugün ne kadar harcadım?" komutu
    if (_matchesBugunNeKadarHarcadim(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.bugunNeKadarHarcadim,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "Son harcamalarım neler?" komutu
    if (_matchesSonHarcamalariListele(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.sonHarcamalariListele,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "Bütçemi aştım mı?" komutu
    if (_matchesButceyiAstimMi(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.butceyiAstimMi,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // Kategori bazlı harcama sorgusu ("Markete ne kadar harcadım?")
    if (mevcutKategoriler != null) {
      String? bulunanKategori = _matchesKategoriHarcamasi(
        normalizedText,
        mevcutKategoriler,
      );
      if (bulunanKategori != null) {
        return VoiceCommandResult(
          komutTuru: VoiceCommandType.kategoriHarcamasi,
          rawText: text,
          komutAlgilandi: true,
          kategori: bulunanKategori,
        );
      }
    }

    // "Sabit giderleri ekle" komutu
    if (_matchesSabitGiderleriEkle(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.sabitGiderleriEkle,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "Son harcamayı 150 lira yap" komutu
    final duzenlemeResult = _matchesSonHarcamayiDuzenle(normalizedText);
    if (duzenlemeResult != null) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.sonHarcamayiDuzenle,
        rawText: text,
        komutAlgilandi: true,
        yeniTutar: duzenlemeResult,
      );
    }

    // "Dün ne kadar harcadım?" komutu
    if (_matchesDunNeKadarHarcadim(normalizedText)) {
      final now = DateTime.now();
      final dun = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1));
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.dunNeKadarHarcadim,
        rawText: text,
        komutAlgilandi: true,
        baslangicTarihi: dun,
        bitisTarihi: dun,
      );
    }

    // "Geçen hafta ne kadar harcadım?" komutu
    if (_matchesGecenHaftaNeKadarHarcadim(normalizedText)) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // Geçen haftanın pazartesisi
      final thisMondayOffset = now.weekday - 1;
      final lastMonday = today.subtract(Duration(days: thisMondayOffset + 7));
      final lastSunday = lastMonday.add(const Duration(days: 6));
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.gecenHaftaNeKadarHarcadim,
        rawText: text,
        komutAlgilandi: true,
        baslangicTarihi: lastMonday,
        bitisTarihi: lastSunday,
      );
    }

    // "Geçen ay ne kadar harcadım?" komutu
    if (_matchesGecenAyNeKadarHarcadim(normalizedText)) {
      final now = DateTime.now();
      // Geçen ayın ilk ve son günü
      final gecenAyBas = DateTime(now.year, now.month - 1, 1);
      final gecenAySon = DateTime(
        now.year,
        now.month,
        0,
      ); // Geçen ayın son günü
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.gecenAyNeKadarHarcadim,
        rawText: text,
        komutAlgilandi: true,
        baslangicTarihi: gecenAyBas,
        bitisTarihi: gecenAySon,
      );
    }

    // "Bu yıl ne kadar harcadım?" komutu
    if (_matchesBuYilNeKadarHarcadim(normalizedText)) {
      final now = DateTime.now();
      final yilBas = DateTime(now.year, 1, 1);
      final bugun = DateTime(now.year, now.month, now.day);
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.buYilNeKadarHarcadim,
        rawText: text,
        komutAlgilandi: true,
        baslangicTarihi: yilBas,
        bitisTarihi: bugun,
      );
    }

    // Tarihli kategori sorgusu ("Dün markete ne kadar harcadım?")
    if (mevcutKategoriler != null) {
      final tarihliKategoriResult = _matchesTarihliKategoriHarcamasi(
        normalizedText,
        mevcutKategoriler,
      );
      if (tarihliKategoriResult != null) {
        return VoiceCommandResult(
          komutTuru: VoiceCommandType.tarihliKategoriHarcamasi,
          rawText: text,
          komutAlgilandi: true,
          kategori: tarihliKategoriResult['kategori'],
          baslangicTarihi: tarihliKategoriResult['baslangic'],
          bitisTarihi: tarihliKategoriResult['bitis'],
        );
      }
    }

    // "Kalan bütçem ne kadar?" komutu
    if (_matchesKalanButce(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.kalanButce,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // "Aylık limitimi X lira yap" komutu
    final limitResult = _matchesLimitBelirle(normalizedText);
    if (limitResult != null) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.limitBelirle,
        rawText: text,
        komutAlgilandi: true,
        yeniLimit: limitResult,
      );
    }

    // "Bu ay ne kadar tasarruf ettim?" komutu
    if (_matchesTasarrufHesapla(normalizedText)) {
      return VoiceCommandResult(
        komutTuru: VoiceCommandType.tasarrufHesapla,
        rawText: text,
        komutAlgilandi: true,
      );
    }

    // Komut algılanmadı - normal harcama girişi olarak değerlendir
    return VoiceCommandResult(
      komutTuru: VoiceCommandType.harcamaEkle,
      rawText: text,
      komutAlgilandi: false,
    );
  }

  /// "Son harcamayı sil" komutunu kontrol et
  bool _matchesSonHarcamayiSil(String text) {
    List<String> patterns = [
      'son harcamayı sil',
      'son harcamayı silsene',
      'son harcamayı kaldır',
      'son harcamamı sil',
      'son eklediğimi sil',
      'son eklenen harcamayı sil',
      'son girdiğim harcamayı sil',
      'en son harcamayı sil',
      'en son eklediğimi sil',
      'sonuncuyu sil',
      'son kaydı sil',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Bu ay ne kadar harcadım?" komutunu kontrol et
  bool _matchesBuAyNeKadarHarcadim(String text) {
    List<String> patterns = [
      'bu ay ne kadar harcadım',
      'bu ay ne kadar harcamışım',
      'bu ay toplam harcamam',
      'bu ayki harcamam ne kadar',
      'bu ay kaç lira harcadım',
      'bu ay kaç para harcadım',
      'aylık harcamam ne kadar',
      'bu ayın toplamı',
      'bu ay harcama toplamı',
      'ne kadar harcamışım',
      'toplam harcamam ne kadar',
      'harcamalarım ne kadar',
      'harcamam ne kadar',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "En çok hangi kategoride harcamışım?" komutunu kontrol et
  bool _matchesEnCokHangiKategori(String text) {
    List<String> patterns = [
      'en çok hangi kategoride',
      'en çok hangi kategori',
      'en çok nereye harcadım',
      'en çok nereye harcamışım',
      'en fazla hangi kategoride',
      'en fazla hangi kategori',
      'hangi kategoride çok harcamışım',
      'hangi kategoride en çok',
      'en yüksek harcama kategorisi',
      'en çok para harcadığım kategori',
      'en fazla harcama nerede',
      'en çok harcama hangi',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Bu hafta ne kadar harcadım?" komutunu kontrol et
  bool _matchesBuHaftaNeKadarHarcadim(String text) {
    List<String> patterns = [
      'bu hafta ne kadar harcadım',
      'bu hafta ne kadar harcamışım',
      'bu hafta toplam harcamam',
      'bu haftaki harcamam',
      'haftalık harcamam',
      'bu hafta kaç lira harcadım',
      'bu hafta kaç para harcadım',
      'haftanın toplamı',
      'bu hafta harcama toplamı',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Bugün ne kadar harcadım?" komutunu kontrol et
  bool _matchesBugunNeKadarHarcadim(String text) {
    List<String> patterns = [
      'bugün ne kadar harcadım',
      'bugün ne kadar harcamışım',
      'bugün toplam harcamam',
      'bugünkü harcamam',
      'bugün kaç lira harcadım',
      'bugün kaç para harcadım',
      'bugünün toplamı',
      'bugün harcama toplamı',
      'bugünkü harcamalarım',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Son harcamalarım neler?" komutunu kontrol et
  bool _matchesSonHarcamalariListele(String text) {
    List<String> patterns = [
      'son harcamalarım',
      'son harcamalarım neler',
      'son harcamalarımı söyle',
      'son harcamalarımı listele',
      'son eklediğim harcamalar',
      'son girdiğim harcamalar',
      'son 5 harcamam',
      'son beş harcamam',
      'son harcama listesi',
      'son harcamaları söyle',
      'son harcamaları listele',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Bütçemi aştım mı?" komutunu kontrol et
  bool _matchesButceyiAstimMi(String text) {
    List<String> patterns = [
      'bütçemi aştım mı',
      'bütçeyi aştım mı',
      'limiti geçtim mi',
      'limitimi geçtim mi',
      'limiti aştım mı',
      'limitimi aştım mı',
      'bütçe durumum',
      'bütçe durumu',
      'limit durumum',
      'limit durumu',
      'harcama limitim',
      'bütçe ne durumda',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Kategori bazlı harcama sorgusunu kontrol et
  /// Örnek: "Markete ne kadar harcadım?", "Yemek kategorisinde ne kadar?"
  String? _matchesKategoriHarcamasi(
    String text,
    List<String> mevcutKategoriler,
  ) {
    // Önce pattern kontrolü yap
    List<String> sorguPatternleri = [
      'ne kadar harcadım',
      'ne kadar harcamışım',
      'kategorisinde ne kadar',
      'ne harcadım',
      'harcamam ne kadar',
      'toplam harcama',
      'kaç lira harcadım',
      'kaç para harcadım',
    ];

    bool sorguVar = false;
    for (var pattern in sorguPatternleri) {
      if (text.contains(pattern)) {
        sorguVar = true;
        break;
      }
    }

    if (!sorguVar) return null;

    // Mevcut kategorileri kontrol et
    for (var kategori in mevcutKategoriler) {
      String kategoriLower = kategori.toLowerCase();
      // Kategori ismi veya varyasyonları metinde geçiyor mu?
      if (text.contains(kategoriLower) ||
          text.contains('${kategoriLower}e') || // markete
          text.contains('${kategoriLower}a') || // yemeğe
          text.contains('${kategoriLower}de') || // markette
          text.contains('${kategoriLower}da') || // yemekte
          text.contains('${kategoriLower}te') ||
          text.contains('${kategoriLower}ta')) {
        return kategori; // Orijinal kategori ismini döndür
      }
    }

    return null;
  }

  /// "Tekrarlayan işlemleri ekle" komutunu kontrol et
  bool _matchesSabitGiderleriEkle(String text) {
    List<String> patterns = [
      'tekrarlayan işlemleri ekle',
      'tekrarlayan işlemleri bu aya ekle',
      'tekrarlayan işlemleri kaydet',
      'tekrarlayan işlemlerimi ekle',
      'sabit giderleri ekle',
      'sabit giderleri bu aya ekle',
      'sabit giderlerimi ekle',
      'aylık giderleri ekle',
      'düzenli giderleri ekle',
      'sabit ödemeleri ekle',
      'faturalarımı ekle',
      'faturaları ekle',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Dün ne kadar harcadım?" komutunu kontrol et
  bool _matchesDunNeKadarHarcadim(String text) {
    List<String> patterns = [
      'dün ne kadar harcadım',
      'dün ne kadar harcamışım',
      'dünkü harcamam',
      'dün toplam harcamam',
      'dün kaç lira harcadım',
      'dün kaç para harcadım',
      'dünün toplamı',
      'dün harcama toplamı',
      'dünkü harcamalarım',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Geçen hafta ne kadar harcadım?" komutunu kontrol et
  bool _matchesGecenHaftaNeKadarHarcadim(String text) {
    List<String> patterns = [
      'geçen hafta ne kadar harcadım',
      'geçen hafta ne kadar harcamışım',
      'geçen hafta toplam harcamam',
      'geçen haftaki harcamam',
      'geçen hafta kaç lira harcadım',
      'geçen hafta kaç para harcadım',
      'geçen haftanın toplamı',
      'geçen hafta harcama toplamı',
      'önceki hafta ne kadar harcadım',
      'önceki hafta harcamam',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Geçen ay ne kadar harcadım?" komutunu kontrol et
  bool _matchesGecenAyNeKadarHarcadim(String text) {
    List<String> patterns = [
      'geçen ay ne kadar harcadım',
      'geçen ay ne kadar harcamışım',
      'geçen ay toplam harcamam',
      'geçen ayki harcamam',
      'geçen ay kaç lira harcadım',
      'geçen ay kaç para harcadım',
      'geçen ayın toplamı',
      'geçen ay harcama toplamı',
      'önceki ay ne kadar harcadım',
      'önceki ay harcamam',
      'önceki ayki harcamam',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Bu yıl ne kadar harcadım?" komutunu kontrol et
  bool _matchesBuYilNeKadarHarcadim(String text) {
    List<String> patterns = [
      'bu yıl ne kadar harcadım',
      'bu yıl ne kadar harcamışım',
      'bu yıl toplam harcamam',
      'bu yılki harcamam',
      'bu yıl kaç lira harcadım',
      'bu yıl kaç para harcadım',
      'bu yılın toplamı',
      'yıllık harcamam',
      'yıllık toplam harcamam',
      'bu sene ne kadar harcadım',
      'bu sene harcamam',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Tarihli kategori harcama sorgusunu kontrol et
  /// Örnek: "Dün markete ne kadar harcadım?", "Geçen hafta yakıt harcamam"
  Map<String, dynamic>? _matchesTarihliKategoriHarcamasi(
    String text,
    List<String> mevcutKategoriler,
  ) {
    // Önce tarih ifadesini kontrol et
    DateTime? baslangic;
    DateTime? bitis;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Tarih ifadeleri
    if (text.contains('dün')) {
      final dun = today.subtract(const Duration(days: 1));
      baslangic = dun;
      bitis = dun;
    } else if (text.contains('geçen hafta') || text.contains('önceki hafta')) {
      final thisMondayOffset = now.weekday - 1;
      final lastMonday = today.subtract(Duration(days: thisMondayOffset + 7));
      final lastSunday = lastMonday.add(const Duration(days: 6));
      baslangic = lastMonday;
      bitis = lastSunday;
    } else if (text.contains('geçen ay') || text.contains('önceki ay')) {
      baslangic = DateTime(now.year, now.month - 1, 1);
      bitis = DateTime(now.year, now.month, 0);
    } else if (text.contains('bu hafta')) {
      final thisMondayOffset = now.weekday - 1;
      baslangic = today.subtract(Duration(days: thisMondayOffset));
      bitis = today;
    }

    // Tarih yoksa bu tarihli kategori sorgusu değil
    if (baslangic == null) return null;

    // Harcama sorgusu pattern kontrolü
    List<String> sorguPatternleri = [
      'ne kadar harcadım',
      'ne kadar harcamışım',
      'harcamam',
      'ne harcadım',
      'kaç lira harcadım',
      'kaç para harcadım',
    ];

    bool sorguVar = false;
    for (var pattern in sorguPatternleri) {
      if (text.contains(pattern)) {
        sorguVar = true;
        break;
      }
    }

    if (!sorguVar) return null;

    // Mevcut kategorileri kontrol et
    for (var kategori in mevcutKategoriler) {
      String kategoriLower = kategori.toLowerCase();
      if (text.contains(kategoriLower) ||
          text.contains('${kategoriLower}e') ||
          text.contains('${kategoriLower}a') ||
          text.contains('${kategoriLower}de') ||
          text.contains('${kategoriLower}da') ||
          text.contains('${kategoriLower}te') ||
          text.contains('${kategoriLower}ta')) {
        return {'kategori': kategori, 'baslangic': baslangic, 'bitis': bitis};
      }
    }

    return null;
  }

  /// "Kalan bütçem ne kadar?" komutunu kontrol et
  bool _matchesKalanButce(String text) {
    List<String> patterns = [
      'kalan bütçem',
      'kalan bütçe',
      'ne kadar bütçem kaldı',
      'ne kadar kaldı bütçem',
      'bütçemden ne kadar kaldı',
      'kalan limit',
      'kalan limitim',
      'ne kadar limitim kaldı',
      'harcayabileceğim ne kadar',
      'ne kadar harcayabilirim',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// "Aylık limitimi X lira yap" komutunu kontrol et
  /// Tutar bulunursa döndürür
  double? _matchesLimitBelirle(String text) {
    List<String> patterns = [
      'limitimi',
      'bütçemi',
      'aylık limit',
      'aylık bütçe',
      'limit olarak',
      'bütçe olarak',
    ];

    List<String> actionPatterns = [
      'yap',
      'ayarla',
      'belirle',
      'güncelle',
      'olsun',
    ];

    bool patternBulundu = false;
    bool actionBulundu = false;

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        patternBulundu = true;
        break;
      }
    }

    for (var action in actionPatterns) {
      if (text.contains(action)) {
        actionBulundu = true;
        break;
      }
    }

    if (patternBulundu && actionBulundu) {
      // Tutarı çıkar
      return _extractAmount(text);
    }

    return null;
  }

  /// "Bu ay ne kadar tasarruf ettim?" komutunu kontrol et
  bool _matchesTasarrufHesapla(String text) {
    List<String> patterns = [
      'ne kadar tasarruf',
      'tasarrufum ne kadar',
      'tasarrufum',
      'tasarruf ettim',
      'biriktirdim',
      'ne kadar biriktirdim',
      'para biriktirdim mi',
      'artıda mıyım',
      'ekside miyim',
    ];

    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Metni parse et ve tutar/kategori çıkar
  SpeechParseResult parseText(String text, List<String> mevcutKategoriler) {
    if (text.isEmpty) {
      return SpeechParseResult(rawText: text, basarili: false);
    }

    String normalizedText = text.toLowerCase().trim();

    // Tarihi çıkar (örn: "dün", "önceki gün", "geçen pazartesi")
    DateTime? tarih = _extractDate(normalizedText);

    // Tutarı çıkar
    double? tutar = _extractAmount(normalizedText);

    // Kategoriyi bul
    String? kategori = _findCategory(normalizedText, mevcutKategoriler);

    // Harcama ismini çıkar (tutar ve para birimi ifadelerini çıkar)
    String? harcamaIsmi = _extractExpenseName(normalizedText, kategori);

    // Tarih ifadelerini harcama isminden çıkar
    if (harcamaIsmi != null && tarih != null) {
      harcamaIsmi = _removeDateExpressions(harcamaIsmi);
    }

    bool basarili = tutar != null;

    return SpeechParseResult(
      tutar: tutar,
      kategori: kategori,
      harcamaIsmi: harcamaIsmi,
      rawText: text,
      basarili: basarili,
      tarih: tarih,
    );
  }

  /// Metinden tarih ifadesi çıkar
  DateTime? _extractDate(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Dün
    if (text.contains('dün') || text.contains('düne')) {
      return today.subtract(const Duration(days: 1));
    }

    // Önceki gün / evvelsi gün
    if (text.contains('önceki gün') ||
        text.contains('evvelsi') ||
        text.contains('evvelki gün') ||
        text.contains('iki gün önce')) {
      return today.subtract(const Duration(days: 2));
    }

    // 3 gün önce
    if (text.contains('üç gün önce') || text.contains('3 gün önce')) {
      return today.subtract(const Duration(days: 3));
    }

    // Geçen hafta
    if (text.contains('geçen hafta')) {
      return today.subtract(const Duration(days: 7));
    }

    // Gün isimleri (geçen pazartesi, salı, vb.)
    final gunler = {
      'pazartesi': DateTime.monday,
      'salı': DateTime.tuesday,
      'çarşamba': DateTime.wednesday,
      'perşembe': DateTime.thursday,
      'cuma': DateTime.friday,
      'cumartesi': DateTime.saturday,
      'pazar': DateTime.sunday,
    };

    for (var entry in gunler.entries) {
      if (text.contains('geçen ${entry.key}') ||
          text.contains('önceki ${entry.key}')) {
        // Geçen haftanın o gününü bul
        int hedefGun = entry.value;
        int bugunGunu = now.weekday;
        int fark = bugunGunu - hedefGun;
        if (fark <= 0) fark += 7;
        fark += 7; // Geçen haftaya git
        return today.subtract(Duration(days: fark));
      } else if (text.contains(entry.key)) {
        // Bu haftanın o günü veya geçen hafta (geçmişte ise)
        int hedefGun = entry.value;
        int bugunGunu = now.weekday;
        int fark = bugunGunu - hedefGun;
        if (fark <= 0) fark += 7;
        return today.subtract(Duration(days: fark));
      }
    }

    return null; // Tarih bulunamadı, bugün olarak kabul edilecek
  }

  /// Tarih ifadelerini metinden çıkar
  String _removeDateExpressions(String text) {
    List<String> tarihIfadeleri = [
      'dün',
      'düne',
      'önceki gün',
      'evvelsi',
      'evvelki gün',
      'iki gün önce',
      'üç gün önce',
      '3 gün önce',
      'geçen hafta',
      'geçen pazartesi',
      'geçen salı',
      'geçen çarşamba',
      'geçen perşembe',
      'geçen cuma',
      'geçen cumartesi',
      'geçen pazar',
      'önceki pazartesi',
      'önceki salı',
      'önceki çarşamba',
      'önceki perşembe',
      'önceki cuma',
      'önceki cumartesi',
      'önceki pazar',
      'pazartesi',
      'salı',
      'çarşamba',
      'perşembe',
      'cuma',
      'cumartesi',
      'pazar',
    ];

    String temiz = text.toLowerCase();
    for (var ifade in tarihIfadeleri) {
      temiz = temiz.replaceAll(ifade, '');
    }

    temiz = temiz.trim();
    if (temiz.isNotEmpty) {
      temiz = temiz[0].toUpperCase() + temiz.substring(1);
    }

    return temiz;
  }

  /// Metinden tutarı çıkar
  double? _extractAmount(String text) {
    // Farklı sayı formatlarını yakala
    // "100 lira", "100,50 tl", "150 bin tl", "2 milyon lira", "on bin lira" vb.

    debugPrint('_extractAmount çağrıldı: "$text"');

    // Önce çarpanları kontrol et
    double carpan = 1;
    bool binVar = text.contains('bin');
    bool milyonVar = text.contains('milyon');

    if (milyonVar) {
      carpan = 1000000;
    } else if (binVar) {
      carpan = 1000;
    }

    debugPrint('Çarpan: $carpan (bin: $binVar, milyon: $milyonVar)');

    // Çarpan varsa (bin veya milyon)
    if (carpan > 1) {
      // 1. Önce rakam ile bin/milyon kontrolü: "10 bin", "150 bin", "1,5 milyon"
      RegExp rakamCarpanRegex = RegExp(
        r'(\d+[.,]?\d*)\s*(bin|milyon)',
        caseSensitive: false,
      );
      Match? rakamMatch = rakamCarpanRegex.firstMatch(text);
      if (rakamMatch != null) {
        String amountStr = rakamMatch.group(1)!.replaceAll(',', '.');
        double? baseAmount = double.tryParse(amountStr);
        if (baseAmount != null) {
          debugPrint(
            'Rakam+çarpan bulundu: $baseAmount * $carpan = ${baseAmount * carpan}',
          );
          return baseAmount * carpan;
        }
      }

      // 2. Yazılı onluklar ile bin/milyon: "on bin", "yirmi bin", "elli milyon"
      // Sıralı liste kullan (Map sırası garanti değil)
      List<MapEntry<String, double>> onluklar = [
        MapEntry('doksan', 90),
        MapEntry('seksen', 80),
        MapEntry('yetmiş', 70),
        MapEntry('altmış', 60),
        MapEntry('elli', 50),
        MapEntry('kırk', 40),
        MapEntry('otuz', 30),
        MapEntry('yirmi', 20),
        MapEntry('on', 10),
      ];

      List<MapEntry<String, double>> birlikler = [
        MapEntry('dokuz', 9),
        MapEntry('sekiz', 8),
        MapEntry('yedi', 7),
        MapEntry('altı', 6),
        MapEntry('beş', 5),
        MapEntry('dört', 4),
        MapEntry('üç', 3),
        MapEntry('iki', 2),
        MapEntry('bir', 1),
      ];

      // 2a. Bileşik sayılar: "on beş bin", "yirmi üç milyon"
      for (var onluk in onluklar) {
        for (var birlik in birlikler) {
          String pattern1 = '${onluk.key} ${birlik.key} bin';
          String pattern2 = '${onluk.key} ${birlik.key} milyon';
          String pattern3 = '${onluk.key}${birlik.key} bin';
          String pattern4 = '${onluk.key}${birlik.key} milyon';

          if (text.contains(pattern1) ||
              text.contains(pattern2) ||
              text.contains(pattern3) ||
              text.contains(pattern4)) {
            double toplam = onluk.value + birlik.value;
            debugPrint(
              'Bileşik sayı bulundu: ${onluk.key} ${birlik.key} = $toplam * $carpan',
            );
            return toplam * carpan;
          }
        }
      }

      // 2b. Sadece onluklar: "on bin", "yirmi milyon"
      for (var onluk in onluklar) {
        if (text.contains('${onluk.key} bin') ||
            text.contains('${onluk.key}bin') ||
            text.contains('${onluk.key} milyon') ||
            text.contains('${onluk.key}milyon')) {
          debugPrint(
            'Onluk+çarpan bulundu: ${onluk.key} = ${onluk.value} * $carpan',
          );
          return onluk.value * carpan;
        }
      }

      // 2c. Sadece birlikler: "beş bin", "üç milyon"
      for (var birlik in birlikler) {
        if (text.contains('${birlik.key} bin') ||
            text.contains('${birlik.key}bin') ||
            text.contains('${birlik.key} milyon') ||
            text.contains('${birlik.key}milyon')) {
          debugPrint(
            'Birlik+çarpan bulundu: ${birlik.key} = ${birlik.value} * $carpan',
          );
          return birlik.value * carpan;
        }
      }

      // 2d. Yüz ile: "yüz bin", "iki yüz bin"
      if (text.contains('yüz')) {
        // "iki yüz bin" = 200,000
        for (var birlik in birlikler) {
          if (text.contains('${birlik.key} yüz')) {
            debugPrint('Birlik+yüz+çarpan: ${birlik.value} * 100 * $carpan');
            return birlik.value * 100 * carpan;
          }
        }
        // Sadece "yüz bin" = 100,000
        debugPrint('Yüz+çarpan: 100 * $carpan');
        return 100 * carpan;
      }

      // 3. Sadece "bin" veya "milyon" varsa = 1000 veya 1000000
      debugPrint('Sadece çarpan: $carpan');
      return carpan;
    }

    // Çarpan yoksa basit rakamları dene
    // Türkçe binlik formatını destekle: 10.000 = 10000, 5.000 = 5000
    // Önce Türkçe binlik formatını kontrol et (X.XXX veya X.XXX.XXX)
    RegExp turkishThousandRegex = RegExp(
      r'(\d{1,3}(?:\.\d{3})+)\s*(lira|tl|₺)?',
      caseSensitive: false,
    );
    Match? turkishMatch = turkishThousandRegex.firstMatch(text);
    if (turkishMatch != null) {
      // Noktaları kaldır (binlik ayıracı)
      String amountStr = turkishMatch.group(1)!.replaceAll('.', '');
      double? result = double.tryParse(amountStr);
      debugPrint(
        'Türkçe binlik format bulundu: ${turkishMatch.group(1)} → $result',
      );
      return result;
    }

    // Normal rakam formatı
    RegExp amountRegex = RegExp(
      r'(\d+[,]?\d*)\s*(lira|tl|₺)?',
      caseSensitive: false,
    );
    Match? match = amountRegex.firstMatch(text);

    if (match != null) {
      String amountStr = match.group(1)!.replaceAll(',', '.');
      double? result = double.tryParse(amountStr);
      debugPrint('Basit rakam bulundu: $result');
      return result;
    }

    // Yazıyla yazılmış basit sayılar (çarpan olmadan)
    Map<String, double> yaziSayilar = {
      'yüz': 100,
      'doksan': 90,
      'seksen': 80,
      'yetmiş': 70,
      'altmış': 60,
      'elli': 50,
      'kırk': 40,
      'otuz': 30,
      'yirmi': 20,
      'on': 10,
      'dokuz': 9,
      'sekiz': 8,
      'yedi': 7,
      'altı': 6,
      'beş': 5,
      'dört': 4,
      'üç': 3,
      'iki': 2,
      'bir': 1,
      'yarım': 0.5,
      'buçuk': 0.5,
    };

    for (var entry in yaziSayilar.entries) {
      if (text.contains(entry.key)) {
        debugPrint('Yazılı sayı bulundu: ${entry.key} = ${entry.value}');
        return entry.value;
      }
    }

    debugPrint('Tutar bulunamadı');
    return null;
  }

  /// Metinden kategoriyi bul
  String? _findCategory(String text, List<String> mevcutKategoriler) {
    // Genişletilmiş kategori eşleştirmeleri
    // Her ana kategori için alternatif isimler ve ilgili anahtar kelimeler
    Map<List<String>, List<String>> kategoriAnahtarlari = {
      // Spor & Fitness
      ['Spor', 'Fitness', 'Sağlık & Spor', 'Spor & Fitness', 'Gym']: [
        'spor',
        'fitness',
        'gym',
        'antrenman',
        'egzersiz',
        'protein',
        'whey',
        'kreatin',
        'bcaa',
        'amino',
        'supplement',
        'takviye',
        'dambıl',
        'halter',
        'ağırlık',
        'koşu',
        'yüzme',
        'pilates',
        'yoga',
        'futbol',
        'basketbol',
        'voleybol',
        'tenis',
        'golf',
        'spor salonu',
        'jimnastik',
        'boks',
        'kickbox',
        'mma',
        'bisiklet',
        'koşu bandı',
        'spor ayakkabı',
        'eşofman',
        'kas',
        'form',
        'diyet',
        'zayıflama',
      ],

      // Market & Alışveriş
      ['Market', 'Alışveriş', 'Gıda']: [
        'market',
        'alışveriş',
        'migros',
        'bim',
        'a101',
        'şok',
        'carrefour',
        'metro',
        'macro',
        'file',
        'happy center',
        'gratis',
        'süt',
        'ekmek',
        'yumurta',
        'peynir',
        'meyve',
        'sebze',
        'deterjan',
        'temizlik',
        'hijyen',
        'bakkal',
        'manav',
      ],

      // Yemek & Restoran
      ['Yemek', 'Restoran', 'Yeme-İçme', 'Yiyecek']: [
        'yemek',
        'restoran',
        'lokanta',
        'kebap',
        'pizza',
        'burger',
        'hamburger',
        'döner',
        'lahmacun',
        'pide',
        'tantuni',
        'kokoreç',
        'midye',
        'sushi',
        'çin yemeği',
        'hint yemeği',
        'italyan',
        'meksika',
        'fast food',
        'mcdonalds',
        'burger king',
        'kfc',
        'popeyes',
        'yemeksepeti',
        'getir yemek',
        'trendyol yemek',
        'kahvaltı',
        'öğle yemeği',
        'akşam yemeği',
        'brunch',
      ],

      // Kahve & Cafe
      ['Kahve', 'Cafe', 'Kafe', 'İçecek']: [
        'kahve',
        'kafe',
        'cafe',
        'starbucks',
        'gloria jeans',
        'caribou',
        'espresso',
        'latte',
        'cappuccino',
        'americano',
        'mocha',
        'frappe',
        'çay',
        'bitki çayı',
        'nescafe',
        'filtre kahve',
        'kahveci',
        'çay bahçesi',
        'pastane',
      ],

      // Ulaşım & Araç
      ['Ulaşım', 'Araç', 'Otopark', 'Yakıt']: [
        'ulaşım',
        'taksi',
        'uber',
        'bolt',
        'bitaksi',
        'benzin',
        'yakıt',
        'motorin',
        'lpg',
        'shell',
        'opet',
        'bp',
        'petrol ofisi',
        'otobüs',
        'metro',
        'metrobüs',
        'tramvay',
        'vapur',
        'marmaray',
        'akbil',
        'istanbulkart',
        'ankarakart',
        'kentkart',
        'otopark',
        'park',
        'araç yıkama',
        'oto yıkama',
        'sigorta',
        'kasko',
        'trafik sigortası',
        'muayene',
        'lastik',
        'yağ değişimi',
        'bakım',
        'servis',
        'tamir',
        'uçak',
        'bilet',
        'thy',
        'pegasus',
        'anadolujet',
      ],

      // Fatura & Abonelik
      ['Fatura', 'Faturalar', 'Abonelik', 'Ödemeler']: [
        'fatura',
        'elektrik',
        'su',
        'doğalgaz',
        'doğal gaz',
        'internet',
        'wifi',
        'telefon',
        'hat',
        'turkcell',
        'vodafone',
        'türk telekom',
        'netflix',
        'spotify',
        'youtube',
        'amazon prime',
        'disney',
        'exxen',
        'blutv',
        'dask',
        'aidat',
        'apartman',
        'site aidatı',
        'vergi',
        'harç',
        'ceza',
      ],

      // Kira & Ev
      ['Kira', 'Ev', 'Konut', 'Ev Giderleri']: [
        'kira',
        'konut',
        'ev',
        'daire',
        'apartman',
        'depozito',
        'kontrat',
        'emlak',
        'komisyon',
      ],

      // Sağlık & Medikal
      ['Sağlık', 'Medikal', 'Hastane', 'Eczane']: [
        'sağlık',
        'ilaç',
        'eczane',
        'doktor',
        'hastane',
        'klinik',
        'muayene',
        'tetkik',
        'tahlil',
        'röntgen',
        'mr',
        'tomografi',
        'diş',
        'dişçi',
        'ortodonti',
        'implant',
        'göz',
        'gözlük',
        'lens',
        'optik',
        'vitamin',
        'mineral',
        'gıda takviyesi',
        'psikoloji',
        'terapi',
        'psikolog',
        'psikiyatri',
        'fizyoterapi',
        'masaj',
        'akupunktur',
        'sgk',
        'özel sağlık',
        'sigorta',
      ],

      // Eğitim & Kurs
      ['Eğitim', 'Kurs', 'Okul', 'Eğitim Giderleri']: [
        'eğitim',
        'kurs',
        'okul',
        'üniversite',
        'lise',
        'ilkokul',
        'harç',
        'kayıt',
        'özel ders',
        'dershane',
        'etüt',
        'ingilizce',
        'almanca',
        'dil kursu',
        'yabancı dil',
        'udemy',
        'coursera',
        'online kurs',
        'sertifika',
        'kitap',
        'ders kitabı',
        'kırtasiye',
        'defter',
        'kalem',
        'sınav',
        'yks',
        'kpss',
        'ales',
        'toefl',
        'ielts',
      ],

      // Eğlence & Hobi
      ['Eğlence', 'Hobi', 'Aktivite', 'Etkinlik']: [
        'eğlence',
        'hobi',
        'aktivite',
        'etkinlik',
        'sinema',
        'film',
        'tiyatro',
        'konser',
        'festival',
        'müze',
        'oyun',
        'playstation',
        'xbox',
        'nintendo',
        'steam',
        'epic games',
        'bowling',
        'bilardo',
        'dart',
        'karaoke',
        'lunapark',
        'tema park',
        'aqua park',
        'eğlence merkezi',
        'biletix',
        'passo',
        'biletinial',
        'fotoğrafçılık',
        'resim',
        'müzik',
        'enstrüman',
        'gitar',
        'piyano',
      ],

      // Giyim & Moda
      ['Giyim', 'Moda', 'Kıyafet', 'Giysi']: [
        'giyim',
        'kıyafet',
        'giysi',
        'moda',
        'ayakkabı',
        'çanta',
        'elbise',
        'pantolon',
        'gömlek',
        'tişört',
        'ceket',
        'mont',
        'kaban',
        'kazak',
        'hırka',
        'iç çamaşır',
        'çorap',
        'kemer',
        'şapka',
        'atkı',
        'eldiven',
        'zara',
        'h&m',
        'mango',
        'lcw',
        'koton',
        'defacto',
        'mavi',
        'colins',
        'nike',
        'adidas',
        'puma',
        'new balance',
        'converse',
        'vans',
        'takım elbise',
        'kravat',
        'aksesuar',
        'takı',
        'saat',
      ],

      // Teknoloji & Elektronik
      ['Teknoloji', 'Elektronik', 'Bilgisayar', 'Telefon']: [
        'teknoloji',
        'elektronik',
        'bilgisayar',
        'laptop',
        'notebook',
        'pc',
        'telefon',
        'cep telefonu',
        'iphone',
        'samsung',
        'xiaomi',
        'huawei',
        'tablet',
        'ipad',
        'akıllı saat',
        'apple watch',
        'kulaklık',
        'airpods',
        'hoparlör',
        'ses sistemi',
        'televizyon',
        'tv',
        'monitör',
        'ekran',
        'klavye',
        'mouse',
        'fare',
        'webcam',
        'kamera',
        'hard disk',
        'ssd',
        'ram',
        'ekran kartı',
        'işlemci',
        'şarj aleti',
        'powerbank',
        'kablo',
        'adaptör',
        'yazıcı',
        'tarayıcı',
        'projeksiyon',
        'mediamarkt',
        'teknosa',
        'vatan',
        'hepsiburada',
        'trendyol',
        'amazon',
      ],

      // Kişisel Bakım & Kozmetik
      ['Kişisel Bakım', 'Kozmetik', 'Güzellik', 'Bakım']: [
        'kişisel bakım',
        'kozmetik',
        'güzellik',
        'bakım',
        'kuaför',
        'berber',
        'saç kesimi',
        'saç boyası',
        'perma',
        'manikür',
        'pedikür',
        'cilt bakımı',
        'yüz bakımı',
        'makyaj',
        'ruj',
        'fondöten',
        'maskara',
        'far',
        'parfüm',
        'deodorant',
        'krem',
        'losyon',
        'şampuan',
        'saç kremi',
        'saç spreyi',
        'jöle',
        'diş macunu',
        'diş fırçası',
        'ağız bakımı',
        'tıraş',
        'jilet',
        'tıraş köpüğü',
        'watsons',
        'gratis',
        'sephora',
        'mac',
        'loreal',
      ],

      // Bebek & Çocuk
      ['Bebek', 'Çocuk', 'Anne-Bebek']: [
        'bebek',
        'çocuk',
        'anne',
        'bebek bezi',
        'pampers',
        'prima',
        'mama',
        'biberon',
        'emzik',
        'bebek maması',
        'bebek arabası',
        'puset',
        'ana kucağı',
        'oto koltuğu',
        'oyuncak',
        'lego',
        'bebek oyuncağı',
        'kreş',
        'anaokulu',
        'bakıcı',
        'dadı',
        'çocuk kıyafeti',
        'bebek kıyafeti',
      ],

      // Evcil Hayvan
      ['Evcil Hayvan', 'Pet', 'Hayvan']: [
        'evcil hayvan',
        'pet',
        'hayvan',
        'kedi',
        'köpek',
        'kuş',
        'balık',
        'hamster',
        'tavşan',
        'mama',
        'kedi maması',
        'köpek maması',
        'petshop',
        'pet shop',
        'veteriner',
        'aşı',
        'kısırlaştırma',
        'tasma',
        'kafes',
        'akvaryum',
        'kum',
        'kedi kumu',
      ],

      // Hediye & Özel Gün
      ['Hediye', 'Özel Gün', 'Kutlama']: [
        'hediye',
        'özel gün',
        'kutlama',
        'doğum günü',
        'yıldönümü',
        'düğün',
        'nişan',
        'bebek',
        'sünnet',
        'sevgililer günü',
        'anneler günü',
        'babalar günü',
        'yılbaşı',
        'bayram',
        'ramazan',
        'çiçek',
        'buket',
        'pasta',
        'balon',
        'süsleme',
      ],

      // Sigorta & Finans
      ['Sigorta', 'Finans', 'Banka']: [
        'sigorta',
        'finans',
        'banka',
        'kredi',
        'hayat sigortası',
        'sağlık sigortası',
        'bireysel emeklilik',
        'bes',
        'kredi kartı',
        'faiz',
        'komisyon',
        'havale',
        'eft',
        'yatırım',
        'borsa',
        'hisse',
        'altın',
        'döviz',
      ],

      // Seyahat & Tatil
      ['Seyahat', 'Tatil', 'Gezi', 'Konaklama']: [
        'seyahat',
        'tatil',
        'gezi',
        'tur',
        'otel',
        'konaklama',
        'pansiyon',
        'apart',
        'airbnb',
        'booking',
        'uçak bileti',
        'otobüs bileti',
        'tren bileti',
        'vize',
        'pasaport',
        'transfer',
        'bavul',
        'valiz',
        'seyahat çantası',
        'plaj',
        'deniz',
        'kayak',
        'kamp',
      ],
    };

    // Önce anahtar kelimeleri kontrol et
    for (var entry in kategoriAnahtarlari.entries) {
      List<String> kategoriIsimleri = entry.key;
      List<String> anahtarKelimeler = entry.value;

      for (var anahtar in anahtarKelimeler) {
        if (text.contains(anahtar)) {
          // Bu kategoriye uyan mevcut kategori var mı?
          for (var mevcutKat in mevcutKategoriler) {
            String mevcutKatLower = mevcutKat.toLowerCase();

            // Kategori isimlerinden biri ile eşleşiyor mu?
            for (var kategoriIsmi in kategoriIsimleri) {
              if (mevcutKatLower == kategoriIsmi.toLowerCase() ||
                  mevcutKatLower.contains(kategoriIsmi.toLowerCase()) ||
                  kategoriIsmi.toLowerCase().contains(mevcutKatLower)) {
                return mevcutKat;
              }
            }

            // Anahtar kelimelerden biri kategori isminde geçiyor mu?
            for (var kw in anahtarKelimeler.take(5)) {
              // İlk 5 ana anahtar kelime
              if (mevcutKatLower.contains(kw)) {
                return mevcutKat;
              }
            }
          }
        }
      }
    }

    // Doğrudan kategori ismi geçiyor mu?
    for (var kategori in mevcutKategoriler) {
      if (text.contains(kategori.toLowerCase())) {
        return kategori;
      }
    }

    return null;
  }

  /// Harcama ismini çıkar
  String? _extractExpenseName(String text, String? kategori) {
    // Para birimi ve tutarı çıkar
    String cleaned = text
        .replaceAll(
          RegExp(r'\d+[.,]?\d*\s*(lira|tl|₺)?', caseSensitive: false),
          '',
        )
        .trim();

    // Kategori adını da çıkar (eğer varsa)
    if (kategori != null) {
      cleaned = cleaned.replaceAll(kategori.toLowerCase(), '').trim();
    }

    // Gereksiz kelimeleri temizle
    cleaned = cleaned
        .replaceAll('lira', '')
        .replaceAll('tl', '')
        .replaceAll('₺', '')
        .trim();

    // Baş harfleri büyük yap
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    return cleaned.isNotEmpty ? cleaned : null;
  }

  /// "Son harcamayı 150 lira yap" komutunu kontrol et
  /// Eğer eşleşirse yeni tutarı döndürür, yoksa null
  double? _matchesSonHarcamayiDuzenle(String text) {
    // Pattern'ler: "son harcamayı X lira yap", "sonuncuyu X TL yap", vb.
    List<RegExp> patterns = [
      RegExp(
        r'son harcamayı\s+(\d+(?:[.,]\d+)?)\s*(lira|tl|₺)?\s*(yap|değiştir|güncelle)',
        caseSensitive: false,
      ),
      RegExp(
        r'sonuncuyu\s+(\d+(?:[.,]\d+)?)\s*(lira|tl|₺)?\s*(yap|değiştir|güncelle)',
        caseSensitive: false,
      ),
      RegExp(
        r'son harcamamı\s+(\d+(?:[.,]\d+)?)\s*(lira|tl|₺)?\s*(yap|değiştir|güncelle)',
        caseSensitive: false,
      ),
      RegExp(
        r'son kaydı\s+(\d+(?:[.,]\d+)?)\s*(lira|tl|₺)?\s*(yap|değiştir|güncelle)',
        caseSensitive: false,
      ),
      RegExp(
        r'son harcamayı\s+(\d+(?:[.,]\d+)?)\s*(lira|tl|₺)?$',
        caseSensitive: false,
      ),
      RegExp(
        r'sonuncuyu\s+(\d+(?:[.,]\d+)?)\s*(lira|tl|₺)?$',
        caseSensitive: false,
      ),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String tutarStr = match.group(1)!.replaceAll(',', '.');
        return double.tryParse(tutarStr);
      }
    }

    return null;
  }

  /// Servisi temizle
  void dispose() {
    _speech.stop();
  }
}
