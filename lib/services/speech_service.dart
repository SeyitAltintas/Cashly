import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Sesli harcama girişi için parse edilmiş sonuç modeli
class SpeechParseResult {
  final double? tutar;
  final String? kategori;
  final String? harcamaIsmi;
  final String rawText;
  final bool basarili;

  SpeechParseResult({
    this.tutar,
    this.kategori,
    this.harcamaIsmi,
    required this.rawText,
    required this.basarili,
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

  /// Metni parse et ve tutar/kategori çıkar
  SpeechParseResult parseText(String text, List<String> mevcutKategoriler) {
    if (text.isEmpty) {
      return SpeechParseResult(rawText: text, basarili: false);
    }

    String normalizedText = text.toLowerCase().trim();

    // Tutarı çıkar
    double? tutar = _extractAmount(normalizedText);

    // Kategoriyi bul
    String? kategori = _findCategory(normalizedText, mevcutKategoriler);

    // Harcama ismini çıkar (tutar ve para birimi ifadelerini çıkar)
    String? harcamaIsmi = _extractExpenseName(normalizedText, kategori);

    bool basarili = tutar != null;

    return SpeechParseResult(
      tutar: tutar,
      kategori: kategori,
      harcamaIsmi: harcamaIsmi,
      rawText: text,
      basarili: basarili,
    );
  }

  /// Metinden tutarı çıkar
  double? _extractAmount(String text) {
    // Farklı sayı formatlarını yakala
    // "100 lira", "100,50 tl", "100.50 ₺", "yüz lira" vb.

    // Önce rakamları dene
    RegExp amountRegex = RegExp(
      r'(\d+[.,]?\d*)\s*(lira|tl|₺)?',
      caseSensitive: false,
    );
    Match? match = amountRegex.firstMatch(text);

    if (match != null) {
      String amountStr = match.group(1)!.replaceAll(',', '.');
      return double.tryParse(amountStr);
    }

    // Yazıyla yazılmış sayıları kontrol et
    Map<String, double> yaziSayilar = {
      'bir': 1,
      'iki': 2,
      'üç': 3,
      'dört': 4,
      'beş': 5,
      'altı': 6,
      'yedi': 7,
      'sekiz': 8,
      'dokuz': 9,
      'on': 10,
      'yirmi': 20,
      'otuz': 30,
      'kırk': 40,
      'elli': 50,
      'altmış': 60,
      'yetmiş': 70,
      'seksen': 80,
      'doksan': 90,
      'yüz': 100,
      'bin': 1000,
    };

    // Basit yazı-sayı dönüşümü
    for (var entry in yaziSayilar.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Metinden kategoriyi bul
  String? _findCategory(String text, List<String> mevcutKategoriler) {
    // Kategori eşleştirmeleri (metin içinde aranacak anahtar kelimeler)
    Map<String, List<String>> kategoriAnahtarlari = {
      'Market': [
        'market',
        'alışveriş',
        'migros',
        'bim',
        'a101',
        'şok',
        'carrefour',
      ],
      'Yemek': [
        'yemek',
        'restoran',
        'lokanta',
        'kebap',
        'pizza',
        'burger',
        'döner',
        'lahmacun',
      ],
      'Kahve': ['kahve', 'kafe', 'starbucks', 'cafe', 'çay'],
      'Ulaşım': [
        'ulaşım',
        'taksi',
        'uber',
        'benzin',
        'yakıt',
        'otobüs',
        'metro',
        'akbil',
      ],
      'Fatura': ['fatura', 'elektrik', 'su', 'doğalgaz', 'internet', 'telefon'],
      'Kira': ['kira', 'ev', 'konut'],
      'Sağlık': ['sağlık', 'ilaç', 'eczane', 'doktor', 'hastane'],
      'Eğlence': ['eğlence', 'sinema', 'film', 'konser', 'oyun'],
      'Giyim': ['giyim', 'kıyafet', 'ayakkabı', 'çanta', 'elbise'],
      'Teknoloji': ['teknoloji', 'telefon', 'bilgisayar', 'laptop', 'tablet'],
    };

    // Önce anahtar kelimeleri kontrol et
    for (var entry in kategoriAnahtarlari.entries) {
      for (var anahtar in entry.value) {
        if (text.contains(anahtar)) {
          // Bu kategori mevcut kategorilerde var mı?
          for (var mevcutKat in mevcutKategoriler) {
            if (mevcutKat.toLowerCase() == entry.key.toLowerCase() ||
                mevcutKat.toLowerCase().contains(entry.key.toLowerCase())) {
              return mevcutKat;
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

  /// Servisi temizle
  void dispose() {
    _speech.stop();
  }
}
