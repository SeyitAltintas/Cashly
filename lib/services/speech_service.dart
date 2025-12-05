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
    // "100 lira", "100,50 tl", "150 bin tl", "2 milyon lira" vb.

    // Önce "X bin" veya "X milyon" kalıplarını kontrol et
    // Örn: "150 bin", "2 milyon", "1.5 milyon", "500 bin lira"

    // Bin kalıbı: "150 bin", "1,5 bin"
    RegExp binRegex = RegExp(r'(\d+[.,]?\d*)\s*bin', caseSensitive: false);
    Match? binMatch = binRegex.firstMatch(text);
    if (binMatch != null) {
      String amountStr = binMatch.group(1)!.replaceAll(',', '.');
      double? baseAmount = double.tryParse(amountStr);
      if (baseAmount != null) {
        return baseAmount * 1000;
      }
    }

    // Milyon kalıbı: "2 milyon", "1.5 milyon"
    RegExp milyonRegex = RegExp(
      r'(\d+[.,]?\d*)\s*milyon',
      caseSensitive: false,
    );
    Match? milyonMatch = milyonRegex.firstMatch(text);
    if (milyonMatch != null) {
      String amountStr = milyonMatch.group(1)!.replaceAll(',', '.');
      double? baseAmount = double.tryParse(amountStr);
      if (baseAmount != null) {
        return baseAmount * 1000000;
      }
    }

    // Basit rakamları dene (bin/milyon olmadan)
    // Ama "bin" veya "milyon" kelimesi geçmiyorsa
    if (!text.contains('bin') && !text.contains('milyon')) {
      RegExp amountRegex = RegExp(
        r'(\d+[.,]?\d*)\s*(lira|tl|₺)?',
        caseSensitive: false,
      );
      Match? match = amountRegex.firstMatch(text);

      if (match != null) {
        String amountStr = match.group(1)!.replaceAll(',', '.');
        return double.tryParse(amountStr);
      }
    }

    // Yazıyla yazılmış sayıları kontrol et
    // Önce çarpanları kontrol et
    double carpan = 1;
    if (text.contains('milyon')) {
      carpan = 1000000;
    } else if (text.contains('bin')) {
      carpan = 1000;
    }

    // Temel sayıları kontrol et
    Map<String, double> yaziSayilar = {
      'yarım': 0.5,
      'buçuk': 0.5,
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
    };

    // Basit yazı-sayı dönüşümü (çarpan ile)
    for (var entry in yaziSayilar.entries) {
      if (text.contains(entry.key)) {
        return entry.value * carpan;
      }
    }

    // Sadece "bin" veya "milyon" geçiyorsa
    if (carpan > 1) {
      return carpan; // 1 bin = 1000, 1 milyon = 1000000
    }

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

  /// Servisi temizle
  void dispose() {
    _speech.stop();
  }
}
