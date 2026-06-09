import 'package:flutter/foundation.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';

/// Sesli asistan ayarları için ChangeNotifier state yöneticisi
class VoiceAssistantState extends ChangeNotifier with SafeNotifierMixin {
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
