import '../voice_command_types.dart';
import '../voice_command_handler.dart';
import '../utils/amount_extractor.dart';

/// Bütçe ve limit komutlarını işleyen handler
/// "Bütçemi aştım mı?", "Kalan bütçem ne kadar?" gibi sorguları işler
class BudgetHandler extends VoiceCommandHandler {
  @override
  List<VoiceCommandType> get supportedCommands => [
    VoiceCommandType.butceyiAstimMi,
    VoiceCommandType.kalanButce,
    VoiceCommandType.limitBelirle,
    VoiceCommandType.tasarrufHesapla,
  ];

  @override
  int get priority => 40; // Bütçe sorguları

  @override
  VoiceCommandResult? handle(String text, {List<String>? categories}) {
    // "Bütçemi aştım mı?" komutu
    if (_matchesButceyiAstimMi(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.butceyiAstimMi,
        rawText: text,
      );
    }

    // "Kalan bütçem ne kadar?" komutu
    if (_matchesKalanButce(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.kalanButce,
        rawText: text,
      );
    }

    // "Aylık limitimi X lira yap" komutu
    final limitResult = _matchesLimitBelirle(text);
    if (limitResult != null) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.limitBelirle,
        rawText: text,
        yeniLimit: limitResult,
      );
    }

    // "Bu ay ne kadar tasarruf ettim?" komutu
    if (_matchesTasarrufHesapla(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.tasarrufHesapla,
        rawText: text,
      );
    }

    return null;
  }

  bool _matchesButceyiAstimMi(String text) {
    return matchesAny(text, [
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
    ]);
  }

  bool _matchesKalanButce(String text) {
    return matchesAny(text, [
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
    ]);
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
      return AmountExtractor.extractAmount(text);
    }

    return null;
  }

  bool _matchesTasarrufHesapla(String text) {
    return matchesAny(text, [
      'ne kadar tasarruf',
      'tasarrufum ne kadar',
      'tasarrufum',
      'tasarruf ettim',
      'biriktirdim',
      'ne kadar biriktirdim',
      'para biriktirdim mi',
      'artıda mıyım',
      'ekside miyim',
    ]);
  }
}
