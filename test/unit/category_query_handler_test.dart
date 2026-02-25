import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/speech/handlers/category_query_handler.dart';
import 'package:cashly/core/services/speech/voice_command_types.dart';

/// CategoryQueryHandler testleri
/// Kategori bazlı harcama sorguları, en çok kategori, tarihli sorgular
void main() {
  late CategoryQueryHandler handler;
  final kategoriler = ['Market', 'Yemek', 'Ulaşım', 'Fatura', 'Kahve'];

  setUp(() {
    handler = CategoryQueryHandler();
  });

  group('CategoryQueryHandler — Metadata', () {
    test('priority 30', () {
      expect(handler.priority, equals(30));
    });

    test('desteklenen komutlar', () {
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.enCokHangiKategori),
      );
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.kategoriHarcamasi),
      );
      expect(
        handler.supportedCommands,
        contains(VoiceCommandType.tarihliKategoriHarcamasi),
      );
    });
  });

  group('CategoryQueryHandler — En Çok Hangi Kategori', () {
    test('"en çok hangi kategoride harcamışım" → enCokHangiKategori', () {
      final result = handler.handle('en çok hangi kategoride harcamışım');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.enCokHangiKategori));
    });

    test('"en çok nereye harcadım" → enCokHangiKategori', () {
      final result = handler.handle('en çok nereye harcadım');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.enCokHangiKategori));
    });

    test('"en fazla harcama nerede" → enCokHangiKategori', () {
      final result = handler.handle('en fazla harcama nerede');
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.enCokHangiKategori));
    });
  });

  group('CategoryQueryHandler — Kategori Harcaması', () {
    test('"markete ne kadar harcadım" → kategoriHarcamasi + Market', () {
      final result = handler.handle(
        'markete ne kadar harcadım',
        categories: kategoriler,
      );
      expect(result, isNotNull);
      expect(result!.komutTuru, equals(VoiceCommandType.kategoriHarcamasi));
      expect(result.kategori, equals('Market'));
    });

    test('"yemek kategorisinde ne kadar" → kategoriHarcamasi + Yemek', () {
      final result = handler.handle(
        'yemek kategorisinde ne kadar',
        categories: kategoriler,
      );
      expect(result, isNotNull);
      expect(result!.kategori, equals('Yemek'));
    });

    test('kategorisiz sorgu → null', () {
      final result = handler.handle(
        'markete ne kadar harcadım',
        categories: null,
      );
      // categories null olunca kategori sorgusu yapılmaz
      expect(result, isNull);
    });

    test('boş kategori listesi → null', () {
      final result = handler.handle(
        'markete ne kadar harcadım',
        categories: [],
      );
      expect(result, isNull);
    });
  });

  group('CategoryQueryHandler — Tarihli Kategori Harcaması', () {
    test('"dün markete ne kadar harcadım" → tarihli + Market + tarih', () {
      final result = handler.handle(
        'dün markete ne kadar harcadım',
        categories: kategoriler,
      );
      expect(result, isNotNull);
      expect(
        result!.komutTuru,
        equals(VoiceCommandType.tarihliKategoriHarcamasi),
      );
      expect(result.kategori, equals('Market'));
      expect(result.baslangicTarihi, isNotNull);
      expect(result.bitisTarihi, isNotNull);
    });

    test('"geçen hafta yemek harcamam" → tarihli + Yemek', () {
      final result = handler.handle(
        'geçen hafta yemek harcamam',
        categories: kategoriler,
      );
      expect(result, isNotNull);
      expect(
        result!.komutTuru,
        equals(VoiceCommandType.tarihliKategoriHarcamasi),
      );
      expect(result.kategori, equals('Yemek'));
    });

    test('tarihsiz kategori sorgusu → kategoriHarcamasi (tarihli değil)', () {
      final result = handler.handle(
        'markete ne kadar harcadım',
        categories: kategoriler,
      );
      expect(result, isNotNull);
      // Tarih yok → basit kategori sorgusu
      expect(result!.komutTuru, equals(VoiceCommandType.kategoriHarcamasi));
    });
  });

  group('CategoryQueryHandler — Edge Cases', () {
    test('eşleşmeyen metin → null', () {
      expect(handler.handle('merhaba dünya', categories: kategoriler), isNull);
    });

    test('boş metin → null', () {
      expect(handler.handle('', categories: kategoriler), isNull);
    });
  });
}
