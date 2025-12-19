import 'voice_command_types.dart';

/// Sesli komut handler arayüzü
/// Strategy pattern uygulaması için temel interface
/// Her handler, belirli bir grup komutu işlemekten sorumludur
abstract class VoiceCommandHandler {
  /// Bu handler'ın işleyebileceği komut türlerini döndürür
  List<VoiceCommandType> get supportedCommands;

  /// Metni analiz eder ve eşleşen komutu döndürür
  /// Eşleşme yoksa null döner
  ///
  /// [text] - Kullanıcının söylediği metin (lowercase ve trim edilmiş)
  /// [categories] - Mevcut kategori listesi (kategori bazlı sorgular için)
  VoiceCommandResult? handle(String text, {List<String>? categories});

  /// Handler önceliği (düşük değer = önce kontrol edilir)
  /// Varsayılan: 100
  int get priority => 100;

  /// Verilen pattern listesinden herhangi biri metinde geçiyor mu kontrol eder
  /// Ortak kullanım için yardımcı metod
  bool matchesAny(String text, List<String> patterns) {
    for (var pattern in patterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }
    return false;
  }
}
