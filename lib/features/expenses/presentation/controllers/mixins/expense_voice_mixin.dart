import 'package:flutter/foundation.dart';
import '../../../../../core/services/speech/speech_service.dart';

mixin ExpenseVoiceMixin on ChangeNotifier {

  bool _voiceIsListening = false;
  bool get voiceIsListening => _voiceIsListening;

  bool _voiceIsInitializing = true;
  bool get voiceIsInitializing => _voiceIsInitializing;

  bool _voiceHasError = false;
  bool get voiceHasError => _voiceHasError;

  bool _voiceIsCommandMode = false;
  bool get voiceIsCommandMode => _voiceIsCommandMode;

  bool _voicePendingConfirmation = false;
  bool get voicePendingConfirmation => _voicePendingConfirmation;

  String _voiceConfirmationTitle = '';
  String get voiceConfirmationTitle => _voiceConfirmationTitle;

  String _voiceConfirmationMessage = '';
  String get voiceConfirmationMessage => _voiceConfirmationMessage;

  String _voiceErrorMessage = '';
  String get voiceErrorMessage => _voiceErrorMessage;

  String _voiceRecognizedText = '';
  String get voiceRecognizedText => _voiceRecognizedText;

  /// Voice state: Başlatma durumunu güncelle
  void setVoiceInitialized({bool success = true, String? error}) {
    _voiceIsInitializing = false;
    if (!success) {
      _voiceHasError = true;
      _voiceErrorMessage =
          error ?? 'Mikrofon izni verilemedi veya cihaz desteklemiyor.';
    }
    notifyListeners();
  }

  /// Voice state: Dinleme başlat
  void startVoiceListening() {
    _voiceIsListening = true;
    _voiceIsCommandMode = false;
    _voiceRecognizedText = '';
    _voiceHasError = false;
    notifyListeners();
  }

  /// Voice state: Dinleme durdur
  void stopVoiceListening() {
    _voiceIsListening = false;
    notifyListeners();
  }

  /// Voice state: Komut modu ayarla
  void setVoiceCommandMode(String text) {
    _voiceRecognizedText = text;
    _voiceIsCommandMode = true;
    notifyListeners();
  }

  /// Voice state: Tanınan metni güncelle
  void updateVoiceRecognizedText(String text) {
    _voiceRecognizedText = text;
    _voiceIsCommandMode = false;
    notifyListeners();
  }

  /// Voice state: Onay iste
  void requestVoiceConfirmation({
    required String title,
    required String message,
  }) {
    _voicePendingConfirmation = true;
    _voiceConfirmationTitle = title;
    _voiceConfirmationMessage = message;
    notifyListeners();
  }

  /// Voice state: Onayı temizle
  void clearVoiceConfirmation() {
    _voicePendingConfirmation = false;
    _voiceConfirmationTitle = '';
    _voiceConfirmationMessage = '';
    notifyListeners();
  }

  // Voice: Parse result
  SpeechParseResult? _voiceParseResult;
  SpeechParseResult? get voiceParseResult => _voiceParseResult;
  void setVoiceParseResult(SpeechParseResult? result) {
    _voiceParseResult = result;
    notifyListeners();
  }

  // Voice: Seçilen kategori
  String _voiceSelectedCategory = '';
  String get voiceSelectedCategory => _voiceSelectedCategory;
  void setVoiceCategory(String category) {
    if (_voiceSelectedCategory != category) {
      _voiceSelectedCategory = category;
      notifyListeners();
    }
  }

  // Voice: Seçilen ödeme yöntemi
  String? _voiceSelectedPaymentMethodId;
  String? get voiceSelectedPaymentMethodId => _voiceSelectedPaymentMethodId;
  void setVoicePaymentMethod(String? paymentMethodId) {
    if (_voiceSelectedPaymentMethodId != paymentMethodId) {
      _voiceSelectedPaymentMethodId = paymentMethodId;
      notifyListeners();
    }
  }

  /// Voice state: Formu sıfırla
  void resetVoiceForm() {
    _voiceRecognizedText = '';
    _voiceIsCommandMode = false;
    _voiceParseResult = null;
    notifyListeners();
  }
}
