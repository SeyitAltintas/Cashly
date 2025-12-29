import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/services/pdf_utils/pdf_utils.dart';

/// PDF Utils Test Suite
/// formatCurrency fonksiyonunu test eder
void main() {
  group('PdfUtils.formatCurrency', () {
    test('pozitif tam sayı formatlamalı', () {
      // 1000 -> 1.000,00 TL
      expect(PdfUtils.formatCurrency(1000), '1.000,00 TL');
    });

    test('pozitif ondalık sayı formatlamalı', () {
      // 1234.56 -> 1.234,56 TL
      expect(PdfUtils.formatCurrency(1234.56), '1.234,56 TL');
    });

    test('büyük sayı binlik ayırıcı ile formatlamalı', () {
      // 12247.00 -> 12.247,00 TL
      expect(PdfUtils.formatCurrency(12247.00), '12.247,00 TL');
    });

    test('çok büyük sayı formatlamalı', () {
      // 1234567.89 -> 1.234.567,89 TL
      expect(PdfUtils.formatCurrency(1234567.89), '1.234.567,89 TL');
    });

    test('sıfır değeri formatlamalı', () {
      // 0 -> 0,00 TL
      expect(PdfUtils.formatCurrency(0), '0,00 TL');
    });

    test('negatif sayı formatlamalı', () {
      // -500 -> -500,00 TL
      expect(PdfUtils.formatCurrency(-500), '-500,00 TL');
    });

    test('küçük ondalık sayı formatlamalı', () {
      // 0.99 -> 0,99 TL
      expect(PdfUtils.formatCurrency(0.99), '0,99 TL');
    });

    test('tek haneli sayı formatlamalı', () {
      // 5 -> 5,00 TL
      expect(PdfUtils.formatCurrency(5), '5,00 TL');
    });

    test('iki haneli sayı formatlamalı', () {
      // 99 -> 99,00 TL
      expect(PdfUtils.formatCurrency(99), '99,00 TL');
    });

    test('üç haneli sayı formatlamalı', () {
      // 999 -> 999,00 TL
      expect(PdfUtils.formatCurrency(999), '999,00 TL');
    });

    test('hassas ondalık kesilmeli', () {
      // 123.456789 -> 123,46 TL (yuvarlanmış)
      expect(PdfUtils.formatCurrency(123.456789), '123,46 TL');
    });
  });

  group('PdfUtils renk sabitleri', () {
    test('expense renk sabitleri tanımlı olmalı', () {
      expect(PdfUtils.expenseColor, isNotNull);
      expect(PdfUtils.expenseColorLight, isNotNull);
    });

    test('income renk sabitleri tanımlı olmalı', () {
      expect(PdfUtils.incomeColor, isNotNull);
      expect(PdfUtils.incomeColorLight, isNotNull);
    });

    test('asset renk sabitleri tanımlı olmalı', () {
      expect(PdfUtils.assetColor, isNotNull);
      expect(PdfUtils.assetColorLight, isNotNull);
    });

    test('tableBorderColor tanımlı olmalı', () {
      expect(PdfUtils.tableBorderColor, isNotNull);
    });

    test('darkGrey tanımlı olmalı', () {
      expect(PdfUtils.darkGrey, isNotNull);
    });
  });

  group('PdfUtils.dateFormat', () {
    test('tarih formatı dd.MM.yyyy olmalı', () {
      final date = DateTime(2025, 12, 29);
      expect(PdfUtils.dateFormat.format(date), '29.12.2025');
    });

    test('tek haneli gün ve ay formatlanmalı', () {
      final date = DateTime(2025, 1, 5);
      expect(PdfUtils.dateFormat.format(date), '05.01.2025');
    });
  });

  group('ExportResult model', () {
    test('başarılı sonuç oluşturulmalı', () {
      final result = ExportResult(
        success: true,
        filePath: '/path/to/file.pdf',
        message: 'PDF oluşturuldu',
      );

      expect(result.success, true);
      expect(result.filePath, '/path/to/file.pdf');
      expect(result.message, 'PDF oluşturuldu');
    });

    test('başarısız sonuç oluşturulmalı', () {
      final result = ExportResult(success: false, message: 'Hata oluştu');

      expect(result.success, false);
      expect(result.filePath, isNull);
      expect(result.message, 'Hata oluştu');
    });
  });

  group('TableRowData model', () {
    test('tablo satır verisi oluşturulmalı', () {
      final rowData = TableRowData(
        cells: ['İsim', 'Kategori', '100,00 TL'],
        backgroundColor: PdfUtils.expenseColorLight,
      );

      expect(rowData.cells.length, 3);
      expect(rowData.backgroundColor, PdfUtils.expenseColorLight);
    });
  });
}
