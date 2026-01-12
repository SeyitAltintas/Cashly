import 'package:flutter/foundation.dart';
import '../../../../core/services/speech/speech_service.dart';

/// Gelir sesli giriş için ChangeNotifier state yöneticisi
class IncomeVoiceInputState extends ChangeNotifier {
  bool _isListening = false;
  bool get isListening => _isListening;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  SpeechParseResult? _parseResult;
  SpeechParseResult? get parseResult => _parseResult;

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  /// Başlatma durumunu güncelle
  void setInitialized({bool success = true, String? error}) {
    _isInitializing = false;
    if (!success) {
      _hasError = true;
      _errorMessage =
          error ?? 'Mikrofon izni verilemedi veya cihaz desteklemiyor.';
    }
    notifyListeners();
  }

  /// Dinleme başlat
  void startListening() {
    _isListening = true;
    _recognizedText = '';
    _parseResult = null;
    _hasError = false;
    notifyListeners();
  }

  /// Dinleme durdur
  void stopListening() {
    _isListening = false;
    notifyListeners();
  }

  /// Tanınan metni güncelle
  void updateRecognizedText(String text, SpeechParseResult? result) {
    _recognizedText = text;
    _parseResult = result;
    notifyListeners();
  }

  /// Kategori seç
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Formu sıfırla
  void resetForm() {
    _parseResult = null;
    _recognizedText = '';
    notifyListeners();
  }
}
