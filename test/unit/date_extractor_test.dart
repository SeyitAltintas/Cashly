import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/speech/utils/date_extractor.dart';

/// DateExtractor testleri
/// Türkçe doğal dil ifadelerinden tarih çıkarma:
/// "dün", "önceki gün", "geçen pazartesi", tarih aralıkları
void main() {
  group('DateExtractor.extractDate — Göreli Tarihler', () {
    test('"dün" → bugünden 1 gün önce', () {
      final result = DateExtractor.extractDate('dün markete gittim');
      final expected = DateTime.now().subtract(const Duration(days: 1));

      expect(result, isNotNull);
      expect(result!.year, equals(expected.year));
      expect(result.month, equals(expected.month));
      expect(result.day, equals(expected.day));
    });

    test('"düne" → bugünden 1 gün önce (ek halinde)', () {
      final result = DateExtractor.extractDate('düne ait harcama');
      expect(result, isNotNull);

      final expected = DateTime.now().subtract(const Duration(days: 1));
      expect(result!.day, equals(expected.day));
    });

    test('"önceki gün" → 2 gün önce', () {
      final result = DateExtractor.extractDate('önceki gün yemek yedim');
      final expected = DateTime.now().subtract(const Duration(days: 2));

      expect(result, isNotNull);
      expect(result!.day, equals(expected.day));
    });

    test('"iki gün önce" → 2 gün önce', () {
      final result = DateExtractor.extractDate('iki gün önce');
      final expected = DateTime.now().subtract(const Duration(days: 2));

      expect(result, isNotNull);
      expect(result!.day, equals(expected.day));
    });

    test('"üç gün önce" → 3 gün önce', () {
      final result = DateExtractor.extractDate('üç gün önce market');

      expect(result, isNotNull);
      final expected = DateTime.now().subtract(const Duration(days: 3));
      expect(result!.day, equals(expected.day));
    });

    test('"3 gün önce" → 3 gün önce (rakamla)', () {
      final result = DateExtractor.extractDate('3 gün önce');

      expect(result, isNotNull);
      final expected = DateTime.now().subtract(const Duration(days: 3));
      expect(result!.day, equals(expected.day));
    });

    test('"geçen hafta" → 7 gün önce', () {
      final result = DateExtractor.extractDate('geçen hafta aldım');
      final expected = DateTime.now().subtract(const Duration(days: 7));

      expect(result, isNotNull);
      expect(result!.day, equals(expected.day));
    });

    test('tarih içermeyen metin → null', () {
      final result = DateExtractor.extractDate('markete 100 lira verdim');
      expect(result, isNull);
    });
  });

  group('DateExtractor.removeDateExpressions', () {
    test('"dün" ifadesi kaldırılır', () {
      final result = DateExtractor.removeDateExpressions('dün markete gittim');
      expect(result.toLowerCase(), isNot(contains('dün')));
      expect(result.toLowerCase(), contains('market'));
    });

    test('"geçen hafta" ifadesi kaldırılır', () {
      final result = DateExtractor.removeDateExpressions(
        'geçen hafta yemek yedim',
      );
      expect(result.toLowerCase(), isNot(contains('geçen hafta')));
    });

    test('"önceki gün" ifadesi kaldırılır', () {
      final result = DateExtractor.removeDateExpressions('önceki gün taksi');
      expect(result.toLowerCase(), isNot(contains('önceki gün')));
    });

    test('gün isimleri kaldırılır', () {
      final result = DateExtractor.removeDateExpressions(
        'pazartesi market alışverişi',
      );
      expect(result.toLowerCase(), isNot(contains('pazartesi')));
    });

    test('temizlenmiş metin büyük harfle başlar', () {
      final result = DateExtractor.removeDateExpressions('dün market');
      // İlk karakter büyük olmalı
      if (result.isNotEmpty) {
        expect(result[0], equals(result[0].toUpperCase()));
      }
    });
  });

  group('DateExtractor.getDateRangeForQuery', () {
    test('"dün" → tek gün aralığı', () {
      final range = DateExtractor.getDateRangeForQuery('dün ne kadar harcadım');

      expect(range, isNotNull);
      expect(range!['baslangic'], isNotNull);
      expect(range['bitis'], isNotNull);

      // Başlangıç ve bitiş aynı gün olmalı
      expect(range['baslangic']!.day, equals(range['bitis']!.day));
    });

    test('"geçen hafta" → pazartesi-pazar aralığı', () {
      final range = DateExtractor.getDateRangeForQuery(
        'geçen hafta harcamalar',
      );

      expect(range, isNotNull);

      final baslangic = range!['baslangic']!;
      final bitis = range['bitis']!;

      // Başlangıç pazartesi olmalı
      expect(baslangic.weekday, equals(DateTime.monday));
      // Bitiş pazar olmalı
      expect(bitis.weekday, equals(DateTime.sunday));
      // 6 gün fark
      expect(bitis.difference(baslangic).inDays, equals(6));
    });

    test('"geçen ay" → ay başı ve sonu', () {
      final range = DateExtractor.getDateRangeForQuery('geçen ay toplam');

      expect(range, isNotNull);

      final baslangic = range!['baslangic']!;
      final bitis = range['bitis']!;

      // Başlangıç 1. gün olmalı
      expect(baslangic.day, equals(1));
      // Bitiş bu ayın 0. günü = geçen ayın son günü
      expect(bitis.month, isNot(equals(DateTime.now().month)));
    });

    test('"bu hafta" → bu haftanın pazartesisi-bugün', () {
      final range = DateExtractor.getDateRangeForQuery('bu hafta harcamalarım');

      expect(range, isNotNull);

      final baslangic = range!['baslangic']!;
      final bitis = range['bitis']!;

      expect(baslangic.weekday, equals(DateTime.monday));
      expect(bitis.day, equals(DateTime.now().day));
    });

    test('"bu ay" → ayın ilk günü-bugün', () {
      final range = DateExtractor.getDateRangeForQuery('bu ay ne harcadım');

      expect(range, isNotNull);
      expect(range!['baslangic']!.day, equals(1));
      expect(range['bitis']!.day, equals(DateTime.now().day));
    });

    test('"bu yıl" → yılın ilk günü-bugün', () {
      final range = DateExtractor.getDateRangeForQuery('bu yıl toplam');

      expect(range, isNotNull);
      expect(range!['baslangic']!.month, equals(1));
      expect(range['baslangic']!.day, equals(1));
    });

    test('"bu sene" → bu yıl ile aynı', () {
      final range = DateExtractor.getDateRangeForQuery('bu sene ne kadar');

      expect(range, isNotNull);
      expect(range!['baslangic']!.month, equals(1));
      expect(range['baslangic']!.day, equals(1));
    });

    test('tarih aralığı olmayan sorgu → null', () {
      final range = DateExtractor.getDateRangeForQuery('ne kadar harcadım');
      expect(range, isNull);
    });
  });
}
