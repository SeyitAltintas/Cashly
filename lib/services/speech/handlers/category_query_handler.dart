import '../voice_command_types.dart';
import '../voice_command_handler.dart';
import '../utils/date_extractor.dart';
import '../utils/category_matcher.dart';

/// Kategori bazlı sorguları işleyen handler
/// "Markete ne kadar harcadım?", "En çok hangi kategoride harcamışım?" gibi sorguları işler
class CategoryQueryHandler extends VoiceCommandHandler {
  @override
  List<VoiceCommandType> get supportedCommands => [
    VoiceCommandType.enCokHangiKategori,
    VoiceCommandType.kategoriHarcamasi,
    VoiceCommandType.tarihliKategoriHarcamasi,
  ];

  @override
  int get priority => 30; // Kategori sorguları

  @override
  VoiceCommandResult? handle(String text, {List<String>? categories}) {
    // "En çok hangi kategoride harcamışım?" komutu
    if (_matchesEnCokHangiKategori(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.enCokHangiKategori,
        rawText: text,
      );
    }

    // Tarihli kategori sorgusu önce kontrol edilmeli
    // "Dün markete ne kadar harcadım?" gibi
    if (categories != null) {
      final tarihliResult = _matchesTarihliKategoriHarcamasi(text, categories);
      if (tarihliResult != null) {
        return VoiceCommandResult.detected(
          komutTuru: VoiceCommandType.tarihliKategoriHarcamasi,
          rawText: text,
          kategori: tarihliResult['kategori'],
          baslangicTarihi: tarihliResult['baslangic'],
          bitisTarihi: tarihliResult['bitis'],
        );
      }
    }

    // Basit kategori sorgusu
    // "Markete ne kadar harcadım?" gibi
    if (categories != null) {
      String? bulunanKategori = CategoryMatcher.matchCategoryQuery(
        text,
        categories,
      );
      if (bulunanKategori != null) {
        return VoiceCommandResult.detected(
          komutTuru: VoiceCommandType.kategoriHarcamasi,
          rawText: text,
          kategori: bulunanKategori,
        );
      }
    }

    return null;
  }

  bool _matchesEnCokHangiKategori(String text) {
    return matchesAny(text, [
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
    ]);
  }

  /// Tarihli kategori harcama sorgusunu kontrol et
  /// Örnek: "Dün markete ne kadar harcadım?", "Geçen hafta yakıt harcamam"
  Map<String, dynamic>? _matchesTarihliKategoriHarcamasi(
    String text,
    List<String> mevcutKategoriler,
  ) {
    // Önce tarih ifadesini kontrol et
    final dateRange = DateExtractor.getDateRangeForQuery(text);

    // Tarih yoksa bu tarihli kategori sorgusu değil
    if (dateRange == null) return null;

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
        return {
          'kategori': kategori,
          'baslangic': dateRange['baslangic'],
          'bitis': dateRange['bitis'],
        };
      }
    }

    return null;
  }
}
