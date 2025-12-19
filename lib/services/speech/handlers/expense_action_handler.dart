import '../voice_command_types.dart';
import '../voice_command_handler.dart';
import '../utils/amount_extractor.dart';

/// Harcama işlem komutlarını işleyen handler
/// "Son harcamayı sil", "Son harcamayı 150 lira yap" gibi aksiyonları işler
class ExpenseActionHandler extends VoiceCommandHandler {
  @override
  List<VoiceCommandType> get supportedCommands => [
    VoiceCommandType.sonHarcamayiSil,
    VoiceCommandType.sonHarcamayiDuzenle,
    VoiceCommandType.sabitGiderleriEkle,
  ];

  @override
  int get priority => 10; // İşlem komutları en yüksek öncelik

  @override
  VoiceCommandResult? handle(String text, {List<String>? categories}) {
    // "Son harcamayı sil" komutu
    if (_matchesSonHarcamayiSil(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.sonHarcamayiSil,
        rawText: text,
      );
    }

    // "Son harcamayı 150 lira yap" komutu
    final duzenlemeResult = _matchesSonHarcamayiDuzenle(text);
    if (duzenlemeResult != null) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.sonHarcamayiDuzenle,
        rawText: text,
        yeniTutar: duzenlemeResult,
      );
    }

    // "Sabit giderleri ekle" komutu
    if (_matchesSabitGiderleriEkle(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.sabitGiderleriEkle,
        rawText: text,
      );
    }

    return null;
  }

  bool _matchesSonHarcamayiSil(String text) {
    return matchesAny(text, [
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
    ]);
  }

  /// "Son harcamayı 150 lira yap" komutunu kontrol et
  /// Eğer eşleşirse yeni tutarı döndürür, yoksa null
  double? _matchesSonHarcamayiDuzenle(String text) {
    List<String> duzenlePatternleri = [
      'son harcamayı',
      'son harcamamı',
      'son eklediğimi',
      'sonuncuyu',
      'son kaydı',
    ];

    List<String> yapPatternleri = [
      'yap',
      'güncelle',
      'değiştir',
      'düzelt',
      'olarak değiştir',
      'olarak güncelle',
    ];

    bool duzenlePatterni = false;
    bool yapPatterni = false;

    for (var pattern in duzenlePatternleri) {
      if (text.contains(pattern)) {
        duzenlePatterni = true;
        break;
      }
    }

    for (var pattern in yapPatternleri) {
      if (text.contains(pattern)) {
        yapPatterni = true;
        break;
      }
    }

    if (duzenlePatterni && yapPatterni) {
      // Tutarı çıkar
      return AmountExtractor.extractAmount(text);
    }

    return null;
  }

  bool _matchesSabitGiderleriEkle(String text) {
    return matchesAny(text, [
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
    ]);
  }
}
