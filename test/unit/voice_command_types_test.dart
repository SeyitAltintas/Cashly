import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/speech/voice_command_types.dart';

/// VoiceCommandResult ve SpeechParseResult model testleri
/// Factory constructors, field doğruluğu, model davranışı
void main() {
  group('VoiceCommandResult — Factory Constructors', () {
    test('detected factory doğru alanları set eder', () {
      final result = VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.harcamaEkle,
        rawText: 'markete 100 lira harcadım',
        kategori: 'Market',
      );

      expect(result.komutTuru, equals(VoiceCommandType.harcamaEkle));
      expect(result.rawText, equals('markete 100 lira harcadım'));
      expect(result.komutAlgilandi, isTrue);
      expect(result.kategori, equals('Market'));
      expect(result.yeniTutar, isNull);
      expect(result.yeniLimit, isNull);
    });

    test('detected tüm opsiyonel alanlarla', () {
      final baslangic = DateTime(2024, 6, 1);
      final bitis = DateTime(2024, 6, 30);

      final result = VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.tarihliKategoriHarcamasi,
        rawText: 'geçen ay markete ne kadar harcadım',
        kategori: 'Market',
        baslangicTarihi: baslangic,
        bitisTarihi: bitis,
      );

      expect(result.komutAlgilandi, isTrue);
      expect(result.kategori, equals('Market'));
      expect(result.baslangicTarihi, equals(baslangic));
      expect(result.bitisTarihi, equals(bitis));
    });

    test('detected limit belirleme komutu', () {
      final result = VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.limitBelirle,
        rawText: 'limiti 5000 lira yap',
        yeniLimit: 5000.0,
      );

      expect(result.komutTuru, equals(VoiceCommandType.limitBelirle));
      expect(result.yeniLimit, equals(5000.0));
    });

    test('detected düzenleme komutu', () {
      final result = VoiceCommandResult.detected(
        komutTuru: VoiceCommandType.sonHarcamayiDuzenle,
        rawText: 'son harcamayı 150 lira yap',
        yeniTutar: 150.0,
      );

      expect(result.yeniTutar, equals(150.0));
    });

    test('notDetected factory', () {
      final result = VoiceCommandResult.notDetected('anlaşılmadı');

      expect(result.komutTuru, equals(VoiceCommandType.bilinmiyor));
      expect(result.rawText, equals('anlaşılmadı'));
      expect(result.komutAlgilandi, isFalse);
      expect(result.kategori, isNull);
      expect(result.yeniTutar, isNull);
    });
  });

  group('VoiceCommandType — Enum Değerleri', () {
    test('tüm komut türleri mevcut', () {
      expect(VoiceCommandType.values.length, greaterThanOrEqualTo(18));
    });

    test('temel komutlar var', () {
      expect(VoiceCommandType.values, contains(VoiceCommandType.harcamaEkle));
      expect(
        VoiceCommandType.values,
        contains(VoiceCommandType.sonHarcamayiSil),
      );
      expect(
        VoiceCommandType.values,
        contains(VoiceCommandType.buAyNeKadarHarcadim),
      );
      expect(
        VoiceCommandType.values,
        contains(VoiceCommandType.butceyiAstimMi),
      );
      expect(VoiceCommandType.values, contains(VoiceCommandType.kalanButce));
      expect(VoiceCommandType.values, contains(VoiceCommandType.bilinmiyor));
    });

    test('tarihli sorgular var', () {
      expect(
        VoiceCommandType.values,
        contains(VoiceCommandType.dunNeKadarHarcadim),
      );
      expect(
        VoiceCommandType.values,
        contains(VoiceCommandType.gecenHaftaNeKadarHarcadim),
      );
      expect(
        VoiceCommandType.values,
        contains(VoiceCommandType.gecenAyNeKadarHarcadim),
      );
      expect(
        VoiceCommandType.values,
        contains(VoiceCommandType.buYilNeKadarHarcadim),
      );
    });
  });

  group('SpeechParseResult — Factory Constructors', () {
    test('success factory doğru alanları set eder', () {
      final result = SpeechParseResult.success(
        tutar: 100.0,
        rawText: 'markete yüz lira',
        kategori: 'Market',
        harcamaIsmi: 'Market Alışverişi',
      );

      expect(result.basarili, isTrue);
      expect(result.tutar, equals(100.0));
      expect(result.kategori, equals('Market'));
      expect(result.harcamaIsmi, equals('Market Alışverişi'));
      expect(result.rawText, equals('markete yüz lira'));
    });

    test('success tarihli giriş', () {
      final dun = DateTime(2024, 6, 14);
      final result = SpeechParseResult.success(
        tutar: 50.0,
        rawText: 'dün kahve 50 lira',
        kategori: 'Kahve',
        tarih: dun,
      );

      expect(result.tarih, equals(dun));
      expect(result.basarili, isTrue);
    });

    test('failure factory', () {
      final result = SpeechParseResult.failure('anlaşılamadı');

      expect(result.basarili, isFalse);
      expect(result.rawText, equals('anlaşılamadı'));
      expect(result.tutar, isNull);
      expect(result.kategori, isNull);
      expect(result.harcamaIsmi, isNull);
      expect(result.tarih, isNull);
    });

    test('success opsiyonel alanlar null olabilir', () {
      final result = SpeechParseResult.success(
        tutar: 200.0,
        rawText: '200 lira',
      );

      expect(result.basarili, isTrue);
      expect(result.tutar, equals(200.0));
      expect(result.kategori, isNull);
      expect(result.harcamaIsmi, isNull);
      expect(result.tarih, isNull);
    });
  });
}
