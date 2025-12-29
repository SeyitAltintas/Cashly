import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Modeller ve tipler
export 'voice_command_types.dart';

import 'voice_command_types.dart';
import 'voice_command_handler.dart';

// Handler'lar
import 'handlers/expense_query_handler.dart';
import 'handlers/expense_action_handler.dart';
import 'handlers/category_query_handler.dart';
import 'handlers/budget_handler.dart';
import 'handlers/misc_handler.dart';

// Utils
import 'utils/amount_extractor.dart';
import 'utils/category_matcher.dart';
import 'utils/date_extractor.dart';

/// Sesli harcama girişi servisi
/// Strategy pattern ile modüler komut işleme
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Kayıtlı handler'lar listesi
  final List<VoiceCommandHandler> _handlers;

  /// Varsayılan constructor - tüm handler'ları kaydet
  SpeechService()
    : _handlers = [
        ExpenseActionHandler(),
        ExpenseQueryHandler(),
        CategoryQueryHandler(),
        BudgetHandler(),
        MiscHandler(),
      ];

  /// Test için özel handler'larla oluşturma
  SpeechService.withHandlers(this._handlers);

  /// Servisi başlat
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: ${error.errorMsg}'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );

    return _isInitialized;
  }

  /// Mevcut durumu kontrol et
  bool get isAvailable => _isInitialized && _speech.isAvailable;
  bool get isListening => _speech.isListening;

  /// Dinlemeyi başlat
  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onDone,
    Duration listenFor = const Duration(seconds: 7),
  }) async {
    if (!_isInitialized) {
      bool success = await initialize();
      if (!success) return;
    }

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onDone();
        }
      },
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 3),
      localeId: 'tr_TR', // Türkçe
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  /// Dinlemeyi durdur
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Sesli komutu algıla
  /// Metni analiz ederek komut türünü belirler
  /// Handler'lar öncelik sırasına göre kontrol edilir
  VoiceCommandResult detectVoiceCommand(
    String text, {
    List<String>? mevcutKategoriler,
  }) {
    if (text.isEmpty) {
      return VoiceCommandResult.notDetected(text);
    }

    String normalizedText = text.toLowerCase().trim();

    // Handler'ları öncelik sırasına göre sırala ve kontrol et
    final sortedHandlers = List<VoiceCommandHandler>.from(_handlers)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final handler in sortedHandlers) {
      final result = handler.handle(
        normalizedText,
        categories: mevcutKategoriler,
      );
      if (result != null) {
        return result;
      }
    }

    // Hiçbir handler eşleşme bulamadı - normal harcama girişi olarak değerlendir
    return VoiceCommandResult(
      komutTuru: VoiceCommandType.harcamaEkle,
      rawText: text,
      komutAlgilandi: false,
    );
  }

  /// Metni parse et ve tutar/kategori çıkar
  SpeechParseResult parseText(String text, List<String> mevcutKategoriler) {
    if (text.isEmpty) {
      return SpeechParseResult.failure(text);
    }

    String normalizedText = text.toLowerCase().trim();

    // Tarihi çıkar (örn: "dün", "önceki gün", "geçen pazartesi")
    DateTime? tarih = DateExtractor.extractDate(normalizedText);

    // Tutarı çıkar
    double? tutar = AmountExtractor.extractAmount(normalizedText);

    // Kategoriyi bul
    String? kategori = CategoryMatcher.findCategory(
      normalizedText,
      mevcutKategoriler,
    );

    // Harcama ismini çıkar (tutar ve para birimi ifadelerini çıkar)
    String? harcamaIsmi = _extractExpenseName(normalizedText, kategori);

    // Tarih ifadelerini harcama isminden çıkar
    if (harcamaIsmi != null && tarih != null) {
      harcamaIsmi = DateExtractor.removeDateExpressions(harcamaIsmi);
    }

    bool basarili = tutar != null;

    return SpeechParseResult(
      tutar: tutar,
      kategori: kategori,
      harcamaIsmi: harcamaIsmi,
      rawText: text,
      basarili: basarili,
      tarih: tarih,
    );
  }

  /// Harcama ismini çıkar
  String? _extractExpenseName(String text, String? kategori) {
    // Para birimi ve tutarı çıkar
    String cleaned = text
        .replaceAll(
          RegExp(r'\d+[.,]?\d*\s*(lira|tl|₺)?', caseSensitive: false),
          '',
        )
        .trim();

    // Kategori adını da çıkar (eğer varsa)
    if (kategori != null) {
      cleaned = cleaned.replaceAll(kategori.toLowerCase(), '').trim();
    }

    // Gereksiz kelimeleri temizle
    cleaned = cleaned
        .replaceAll('lira', '')
        .replaceAll('tl', '')
        .replaceAll('₺', '')
        .trim();

    // Baş harfleri büyük yap
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    return cleaned.isNotEmpty ? cleaned : null;
  }

  /// Servisi temizle
  void dispose() {
    _speech.stop();
  }
}
