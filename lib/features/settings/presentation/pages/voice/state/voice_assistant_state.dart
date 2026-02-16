import 'package:flutter/foundation.dart';

/// Sesli asistan ayarları için ChangeNotifier state yöneticisi
class VoiceAssistantState extends ChangeNotifier {
  bool _sesliGeriBildirimAktif = true;
  bool get sesliGeriBildirimAktif => _sesliGeriBildirimAktif;
  set sesliGeriBildirimAktif(bool value) {
    _sesliGeriBildirimAktif = value;
    notifyListeners();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
