import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/speech/handlers/expense_action_handler.dart';
import 'package:cashly/core/services/speech/handlers/expense_query_handler.dart';
import 'package:cashly/core/services/speech/handlers/misc_handler.dart';
import 'package:cashly/core/services/speech/voice_command_types.dart';

/// Voice Command Handler testleri
/// ExpenseActionHandler, ExpenseQueryHandler, MiscHandler
void main() {
  // ========== ExpenseActionHandler ==========
  group('ExpenseActionHandler', () {
    late ExpenseActionHandler handler;

    setUp(() {
      handler = ExpenseActionHandler();
    });

    test('priority en yüksek (10)', () {
      expect(handler.priority, equals(10));
    });

    test('desteklenen komutlar', () {
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.sonHarcamayiSil),
      );
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.sonHarcamayiDuzenle),
      );
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.sabitGiderleriEkle),
      );
    });

    group('Son Harcamayı Sil', () {
      test('"son harcamayı sil" → sonHarcamayiSil', () {
        final result = handler.handle('son harcamayı sil');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamayiSil));
      });

      test('"sonuncuyu sil" → sonHarcamayiSil', () {
        final result = handler.handle('sonuncuyu sil');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamayiSil));
      });

      test('"en son harcamayı sil" → sonHarcamayiSil', () {
        final result = handler.handle('en son harcamayı sil');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamayiSil));
      });
    });

    group('Son Harcamayı Düzenle', () {
      test('"son harcamayı 150 lira yap" → sonHarcamayiDuzenle + tutar', () {
        final result = handler.handle('son harcamayı 150 lira yap');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamayiDuzenle));
        expect(result.yeniTutar, equals(150.0));
      });

      test('"sonuncuyu 200 lira olarak değiştir" → düzenle + tutar', () {
        final result = handler.handle('sonuncuyu 200 lira olarak değiştir');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamayiDuzenle));
        expect(result.yeniTutar, equals(200.0));
      });

      test(
        'sadece "son harcamayı" action olmadan → null (sil ile çakışmaz)',
        () {
          final result = handler.handle('son harcamayı göster');
          expect(result, isNull);
        },
      );
    });

    group('Sabit Giderleri Ekle', () {
      test('"sabit giderleri ekle" → sabitGiderleriEkle', () {
        final result = handler.handle('sabit giderleri ekle');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sabitGiderleriEkle));
      });

      test('"tekrarlayan işlemleri bu aya ekle" → sabitGiderleriEkle', () {
        final result = handler.handle('tekrarlayan işlemleri bu aya ekle');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sabitGiderleriEkle));
      });

      test('"faturaları ekle" → sabitGiderleriEkle', () {
        final result = handler.handle('faturaları ekle');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.sabitGiderleriEkle));
      });
    });

    test('eşleşmeyen metin → null', () {
      expect(handler.handle('merhaba dünya'), isNull);
    });
  });

  // ========== ExpenseQueryHandler ==========
  group('ExpenseQueryHandler', () {
    late ExpenseQueryHandler handler;

    setUp(() {
      handler = ExpenseQueryHandler();
    });

    test('priority 20', () {
      expect(handler.priority, equals(20));
    });

    test('7 komut türünü destekler', () {
      expect(handler.supportedCommands.length, equals(7));
    });

    group('Bu Ay Sorguları', () {
      test('"bu ay ne kadar harcadım" → buAyNeKadarHarcadim', () {
        final result = handler.handle('bu ay ne kadar harcadım');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.buAyNeKadarHarcadim));
      });

      test('"toplam harcamam ne kadar" → buAyNeKadarHarcadim', () {
        final result = handler.handle('toplam harcamam ne kadar');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.buAyNeKadarHarcadim));
      });
    });

    group('Bu Hafta Sorguları', () {
      test('"bu hafta ne kadar harcadım" → buHaftaNeKadarHarcadim', () {
        final result = handler.handle('bu hafta ne kadar harcadım');
        expect(result, isNotNull);
        expect(
          result!.komutTuru,
          equals(VoiceCommandType.buHaftaNeKadarHarcadim),
        );
      });
    });

    group('Bugün Sorguları', () {
      test('"bugün ne kadar harcadım" → bugunNeKadarHarcadim', () {
        final result = handler.handle('bugün ne kadar harcadım');
        expect(result, isNotNull);
        expect(
          result!.komutTuru,
          equals(VoiceCommandType.bugunNeKadarHarcadim),
        );
      });
    });

    group('Dün Sorguları', () {
      test('"dün ne kadar harcadım" → dunNeKadarHarcadim + tarih aralığı', () {
        final result = handler.handle('dün ne kadar harcadım');
        expect(result, isNotNull);
        expect(result!.komutTuru, equals(VoiceCommandType.dunNeKadarHarcadim));
        expect(result.baslangicTarihi, isNotNull);
        expect(result.bitisTarihi, isNotNull);
      });
    });

    group('Geçen Hafta Sorguları', () {
      test('"geçen hafta ne kadar harcadım" → gecenHaftaNeKadarHarcadim', () {
        final result = handler.handle('geçen hafta ne kadar harcadım');
        expect(result, isNotNull);
        expect(
          result!.komutTuru,
          equals(VoiceCommandType.gecenHaftaNeKadarHarcadim),
        );
        expect(result.baslangicTarihi, isNotNull);
      });

      test('"önceki hafta ne kadar harcadım" → gecenHaftaNeKadarHarcadim', () {
        final result = handler.handle('önceki hafta ne kadar harcadım');
        expect(result, isNotNull);
        expect(
          result!.komutTuru,
          equals(VoiceCommandType.gecenHaftaNeKadarHarcadim),
        );
      });
    });

    group('Geçen Ay Sorguları', () {
      test('"geçen ay ne kadar harcadım" → gecenAyNeKadarHarcadim', () {
        final result = handler.handle('geçen ay ne kadar harcadım');
        expect(result, isNotNull);
        expect(
          result!.komutTuru,
          equals(VoiceCommandType.gecenAyNeKadarHarcadim),
        );
        expect(result.baslangicTarihi, isNotNull);
      });
    });

    group('Bu Yıl Sorguları', () {
      test('"bu yıl ne kadar harcadım" → buYilNeKadarHarcadim', () {
        final result = handler.handle('bu yıl ne kadar harcadım');
        expect(result, isNotNull);
        expect(
          result!.komutTuru,
          equals(VoiceCommandType.buYilNeKadarHarcadim),
        );
      });

      test('"bu sene ne kadar harcadım" → buYilNeKadarHarcadim', () {
        final result = handler.handle('bu sene ne kadar harcadım');
        expect(result, isNotNull);
        expect(
          result!.komutTuru,
          equals(VoiceCommandType.buYilNeKadarHarcadim),
        );
      });
    });

    test('eşleşmeyen metin → null', () {
      expect(handler.handle('kahve içtim'), isNull);
    });
  });

  // ========== MiscHandler ==========
  group('MiscHandler', () {
    late MiscHandler handler;

    setUp(() {
      handler = MiscHandler();
    });

    test('priority en düşük (50)', () {
      expect(handler.priority, equals(50));
    });

    test('desteklenen komutlar: sonHarcamalariListele', () {
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.sonHarcamalariListele),
      );
      expect(handler.supportedCommands.length, equals(1));
    });

    test('"son harcamalarım" → sonHarcamalariListele', () {
      final result = handler.handle('son harcamalarım');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamalariListele));
    });

    test('"son 5 harcamam" → sonHarcamalariListele', () {
      final result = handler.handle('son 5 harcamam');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamalariListele));
    });

    test('"son harcamaları listele" → sonHarcamalariListele', () {
      final result = handler.handle('son harcamaları listele');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.sonHarcamalariListele));
    });

    test('eşleşmeyen metin → null', () {
      expect(handler.handle('merhaba'), isNull);
    });
  });
}
