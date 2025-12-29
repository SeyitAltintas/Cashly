import '../voice_command_types.dart';
import '../voice_command_handler.dart';

/// Diğer komutları işleyen handler
/// "Son harcamalarım neler?" gibi çeşitli sorguları işler
class MiscHandler extends VoiceCommandHandler {
  @override
  List<VoiceCommandType> get supportedCommands => [
    VoiceCommandType.sonHarcamalariListele,
  ];

  @override
  int get priority => 50; // Diğer komutlar en düşük öncelik

  @override
  VoiceCommandResult? handle(String text, {List<String>? categories}) {
    // "Son harcamalarım neler?" komutu
    if (_matchesSonHarcamalariListele(text)) {
      return VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.sonHarcamalariListele,
        rawText: text,
      );
    }

    return null;
  }

  bool _matchesSonHarcamalariListele(String text) {
    return matchesAny(text, [
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
    ]);
  }
}
