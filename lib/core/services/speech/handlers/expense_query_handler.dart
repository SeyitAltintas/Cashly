import '../voice_command_types.dart';
import '../voice_command_handler.dart';
import '../utils/date_extractor.dart';

/// Harcama sorgu komutlarını işleyen handler
/// "Bu ay ne kadar harcadım?", "Bugün ne harcadım?" gibi zaman bazlı sorguları işler
class ExpenseQueryHandler extends VoiceCommandHandler {
  @override
  List<VoiceCommandType> get supportedCommands => [
    VoiceCommandType.buAyNeKadarHarcadim,
    VoiceCommandType.buHaftaNeKadarHarcadim,
    VoiceCommandType.bugunNeKadarHarcadim,
    VoiceCommandType.dunNeKadarHarcadim,
    VoiceCommandType.gecenHaftaNeKadarHarcadim,
    VoiceCommandType.gecenAyNeKadarHarcadim,
    VoiceCommandType.buYilNeKadarHarcadim,
  ];

  @override
  int get priority => 20; // Sorgu komutları öncelikli

  @override
  VoiceCommandResult? handle(String text, {List<String>? categories}) {
    // "Bu ay ne kadar harcadım?" komutu
    if (_matchesBuAyNeKadarHarcadim(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.buAyNeKadarHarcadim,
        rawText: text,
      );
    }

    // "Bu hafta ne kadar harcadım?" komutu
    if (_matchesBuHaftaNeKadarHarcadim(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.buHaftaNeKadarHarcadim,
        rawText: text,
      );
    }

    // "Bugün ne kadar harcadım?" komutu
    if (_matchesBugunNeKadarHarcadim(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.bugunNeKadarHarcadim,
        rawText: text,
      );
    }

    // "Dün ne kadar harcadım?" komutu
    if (_matchesDunNeKadarHarcadim(text)) {
      final dateRange = DateExtractor.getDateRangeForQuery(text);
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.dunNeKadarHarcadim,
        rawText: text,
        baslangicTarihi: dateRange?['baslangic'],
        bitisTarihi: dateRange?['bitis'],
      );
    }

    // "Geçen hafta ne kadar harcadım?" komutu
    if (_matchesGecenHaftaNeKadarHarcadim(text)) {
      final dateRange = DateExtractor.getDateRangeForQuery(text);
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.gecenHaftaNeKadarHarcadim,
        rawText: text,
        baslangicTarihi: dateRange?['baslangic'],
        bitisTarihi: dateRange?['bitis'],
      );
    }

    // "Geçen ay ne kadar harcadım?" komutu
    if (_matchesGecenAyNeKadarHarcadim(text)) {
      final dateRange = DateExtractor.getDateRangeForQuery(text);
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.gecenAyNeKadarHarcadim,
        rawText: text,
        baslangicTarihi: dateRange?['baslangic'],
        bitisTarihi: dateRange?['bitis'],
      );
    }

    // "Bu yıl ne kadar harcadım?" komutu
    if (_matchesBuYilNeKadarHarcadim(text)) {
      final dateRange = DateExtractor.getDateRangeForQuery(text);
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.buYilNeKadarHarcadim,
        rawText: text,
        baslangicTarihi: dateRange?['baslangic'],
        bitisTarihi: dateRange?['bitis'],
      );
    }

    return null;
  }

  bool _matchesBuAyNeKadarHarcadim(String text) {
    return matchesAny(text, [
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
    ]);
  }

  bool _matchesBuHaftaNeKadarHarcadim(String text) {
    return matchesAny(text, [
      'bu hafta ne kadar harcadım',
      'bu hafta ne kadar harcamışım',
      'bu hafta toplam harcamam',
      'bu haftaki harcamam',
      'haftalık harcamam',
      'bu hafta kaç lira harcadım',
      'bu hafta kaç para harcadım',
      'haftanın toplamı',
      'bu hafta harcama toplamı',
    ]);
  }

  bool _matchesBugunNeKadarHarcadim(String text) {
    return matchesAny(text, [
      'bugün ne kadar harcadım',
      'bugün ne kadar harcamışım',
      'bugün toplam harcamam',
      'bugünkü harcamam',
      'bugün kaç lira harcadım',
      'bugün kaç para harcadım',
      'bugünün toplamı',
      'bugün harcama toplamı',
      'bugünkü harcamalarım',
    ]);
  }

  bool _matchesDunNeKadarHarcadim(String text) {
    return matchesAny(text, [
      'dün ne kadar harcadım',
      'dün ne kadar harcamışım',
      'dünkü harcamam',
      'dün toplam harcamam',
      'dün kaç lira harcadım',
      'dün kaç para harcadım',
      'dünün toplamı',
      'dün harcama toplamı',
      'dünkü harcamalarım',
    ]);
  }

  bool _matchesGecenHaftaNeKadarHarcadim(String text) {
    return matchesAny(text, [
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
    ]);
  }

  bool _matchesGecenAyNeKadarHarcadim(String text) {
    return matchesAny(text, [
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
    ]);
  }

  bool _matchesBuYilNeKadarHarcadim(String text) {
    return matchesAny(text, [
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
    ]);
  }
}
