import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/speech/handlers/budget_handler.dart';
import 'package:cashly/core/services/speech/voice_command_types.dart';

/// BudgetHandler testleri
/// Sesli bütçe komutları: aştım mı, kalan, limit belirleme, tasarruf
void main() {
  late BudgetHandler handler;

  setUp(() {
    handler = BudgetHandler();
  });

  group('BudgetHandler — Metadata', () {
    test('desteklenen komutlar doğru', () {
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.butceyiAstimMi),
      );
      expect(handler.supportedCommands, contains(VoiceCommandType.kalanButce));
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.limitBelirle),
      );
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.tasarrufHesapla),
      );
    });

    test('priority 40', () {
      expect(handler.priority, equals(40));
    });
  });

  group('BudgetHandler — Bütçeyi Aştım Mı', () {
    test('"bütçemi aştım mı" → butceyiAstimMi', () {
      final result = handler.handle('bütçemi aştım mı');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.butceyiAstimMi));
      expect(result.komutAlgilandi, isTrue);
    });

    test('"limiti geçtim mi" → butceyiAstimMi', () {
      final result = handler.handle('limiti geçtim mi');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.butceyiAstimMi));
    });

    test('"bütçe ne durumda" → butceyiAstimMi', () {
      final result = handler.handle('bütçe ne durumda');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.butceyiAstimMi));
    });
  });

  group('BudgetHandler — Kalan Bütçe', () {
    test('"kalan bütçem" → kalanButce', () {
      final result = handler.handle('kalan bütçem');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.kalanButce));
    });

    test('"ne kadar harcayabilirim" → kalanButce', () {
      final result = handler.handle('ne kadar harcayabilirim');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.kalanButce));
    });

    test('"kalan limitim" → kalanButce', () {
      final result = handler.handle('kalan limitim');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.kalanButce));
    });
  });

  group('BudgetHandler — Limit Belirleme', () {
    test('"limitimi 5000 lira yap" → limitBelirle + tutar', () {
      final result = handler.handle('limitimi 5000 lira yap');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.limitBelirle));
      expect(result.yeniLimit, equals(5000.0));
    });

    test('"aylık bütçe 10000 lira olarak ayarla" → limitBelirle + tutar', () {
      final result = handler.handle('aylık bütçe 10000 lira olarak ayarla');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.limitBelirle));
      expect(result.yeniLimit, equals(10000.0));
    });

    test('sadece "limitimi" pattern yoksa null', () {
      final result = handler.handle('limitimi bildir');
      // "bildir" action pattern'lerinde yok
      expect(result, isNull);
    });

    test('sadece action pattern yoksa null', () {
      final result = handler.handle('5000 lira yap');
      // "limitimi" veya "bütçemi" pattern'i yok
      expect(result, isNull);
    });
  });

  group('BudgetHandler — Tasarruf Hesapla', () {
    test('"ne kadar tasarruf ettim" → tasarrufHesapla', () {
      final result = handler.handle('ne kadar tasarruf ettim');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.tasarrufHesapla));
    });

    test('"artıda mıyım" → tasarrufHesapla', () {
      final result = handler.handle('artıda mıyım');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.tasarrufHesapla));
    });

    test('"ne kadar biriktirdim" → tasarrufHesapla', () {
      final result = handler.handle('ne kadar biriktirdim');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.tasarrufHesapla));
    });
  });

  group('BudgetHandler — Eşleşmeyen Komutlar', () {
    test('ilgisiz metin → null', () {
      expect(handler.handle('merhaba nasılsın'), isNull);
    });

    test('boş metin → null', () {
      expect(handler.handle(''), isNull);
    });
  });
}
