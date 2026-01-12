import 'package:flutter/foundation.dart';
import '../../../../core/services/speech/speech_service.dart';

/// Harcama sesli giriş için ChangeNotifier state yöneticisi
class ExpenseVoiceInputState extends ChangeNotifier {
  bool _isListening = false;
  bool get isListening => _isListening;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _isCommandMode = false;
  bool get isCommandMode => _isCommandMode;

  // Onay modu için değişkenler
  bool _pendingConfirmation = false;
  bool get pendingConfirmation => _pendingConfirmation;

  String _confirmationTitle = '';
  String get confirmationTitle => _confirmationTitle;

  String _confirmationMessage = '';
  String get confirmationMessage => _confirmationMessage;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  SpeechParseResult? _parseResult;
  SpeechParseResult? get parseResult => _parseResult;

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  String? _selectedPaymentMethodId;
  String? get selectedPaymentMethodId => _selectedPaymentMethodId;

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
    _isCommandMode = false;
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

  /// Komut modu ayarla
  void setCommandMode(String text) {
    _recognizedText = text;
    _isCommandMode = true;
    _parseResult = null;
    notifyListeners();
  }

  /// Tanınan metni güncelle (harcama parse sonucu ile)
  void updateRecognizedText(String text, SpeechParseResult? result) {
    _recognizedText = text;
    _isCommandMode = false;
    _parseResult = result;
    notifyListeners();
  }

  /// Onay iste
  void requestConfirmation({required String title, required String message}) {
    _pendingConfirmation = true;
    _confirmationTitle = title;
    _confirmationMessage = message;
    notifyListeners();
  }

  /// Onayı temizle
  void clearConfirmation() {
    _pendingConfirmation = false;
    _confirmationTitle = '';
    _confirmationMessage = '';
    notifyListeners();
  }

  /// Kategori seç
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Ödeme yöntemi seç
  void setPaymentMethod(String? paymentMethodId) {
    if (_selectedPaymentMethodId != paymentMethodId) {
      _selectedPaymentMethodId = paymentMethodId;
      notifyListeners();
    }
  }

  /// Formu sıfırla
  void resetForm() {
    _parseResult = null;
    _recognizedText = '';
    _isCommandMode = false;
    notifyListeners();
  }
}
