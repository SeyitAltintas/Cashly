/// Metinden kategori eşleştiren yardımcı sınıf
/// Geniş bir anahtar kelime haritası ile kullanıcının mevcut kategorilerine eşleşme yapar
class CategoryMatcher {
  /// Ana kategori eşleştirme haritası
  /// Her ana kategori için alternatif isimler ve ilgili anahtar kelimeler
  static final Map<List<String>, List<String>> _kategoriAnahtarlari = {
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

  /// Metinden kategoriyi bul
  /// Kullanıcının mevcut kategorileriyle eşleştirme yapar
  static String? findCategory(String text, List<String> mevcutKategoriler) {
    // Önce anahtar kelimeleri kontrol et
    for (var entry in _kategoriAnahtarlari.entries) {
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

  /// Kategori bazlı harcama sorgusunu kontrol et
  /// Örnek: "Markete ne kadar harcadım?", "Yemek kategorisinde ne kadar?"
  static String? matchCategoryQuery(
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
}
