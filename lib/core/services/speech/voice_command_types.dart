/// Sesli komut türleri
/// Her komut türü, kullanıcının söyleyebileceği farklı bir işlemi temsil eder
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
/// Komut algılama işleminin sonucunu taşır
class VoiceCommandResult {
  /// Algılanan komut türü
  final VoiceCommandType komutTuru;

  /// Ham metin (kullanıcının söylediği)
  final String rawText;

  /// Komut başarıyla algılandı mı?
  final bool komutAlgilandi;

  /// Kategori bazlı sorgular için kategori ismi
  final String? kategori;

  /// Harcama düzenleme için yeni tutar
  final double? yeniTutar;

  /// Bütçe limiti belirleme için yeni limit
  final double? yeniLimit;

  /// Tarihli sorgular için başlangıç tarihi
  final DateTime? baslangicTarihi;

  /// Tarihli sorgular için bitiş tarihi
  final DateTime? bitisTarihi;

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

  /// Basit sonuç oluşturma yardımcısı (komut algılandı)
  factory VoiceCommandResult.detected({
    required VoiceCommandType komutTuru,
    required String rawText,
    String? kategori,
    double? yeniTutar,
    double? yeniLimit,
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
  }) {
    return VoiceCommandResult(
      komutTuru: komutTuru,
      rawText: rawText,
      komutAlgilandi: true,
      kategori: kategori,
      yeniTutar: yeniTutar,
      yeniLimit: yeniLimit,
      baslangicTarihi: baslangicTarihi,
      bitisTarihi: bitisTarihi,
    );
  }

  /// Komut algılanmadığında kullanılır
  factory VoiceCommandResult.notDetected(String rawText) {
    return VoiceCommandResult(
      komutTuru: VoiceCommandType.bilinmiyor,
      rawText: rawText,
      komutAlgilandi: false,
    );
  }
}

/// Sesli harcama girişi için parse edilmiş sonuç modeli
class SpeechParseResult {
  /// Çıkarılan tutar
  final double? tutar;

  /// Eşleşen kategori
  final String? kategori;

  /// Çıkarılan harcama ismi/açıklaması
  final String? harcamaIsmi;

  /// Ham metin
  final String rawText;

  /// Parse işlemi başarılı mı?
  final bool basarili;

  /// Tarihli harcama girişi için tarih
  final DateTime? tarih;

  SpeechParseResult({
    this.tutar,
    this.kategori,
    this.harcamaIsmi,
    required this.rawText,
    required this.basarili,
    this.tarih,
  });

  /// Başarılı sonuç oluşturma yardımcısı
  factory SpeechParseResult.success({
    required double tutar,
    required String rawText,
    String? kategori,
    String? harcamaIsmi,
    DateTime? tarih,
  }) {
    return SpeechParseResult(
      tutar: tutar,
      kategori: kategori,
      harcamaIsmi: harcamaIsmi,
      rawText: rawText,
      basarili: true,
      tarih: tarih,
    );
  }

  /// Başarısız sonuç oluşturma yardımcısı
  factory SpeechParseResult.failure(String rawText) {
    return SpeechParseResult(rawText: rawText, basarili: false);
  }
}
