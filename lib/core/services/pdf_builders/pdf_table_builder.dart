import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_utils/pdf_utils.dart';

/// PDF Tablo Builder
/// Harcama, gelir ve varlık tablolarını oluşturur
class PdfTableBuilder {
  PdfTableBuilder._();

  /// Tablo bölümü oluştur (sayfa geçişlerini destekler)
  /// Liste olarak döndürülür çünkü Column widget'ı MultiPage içinde bölünemez
  static List<pw.Widget> buildTableSection({
    required String title,
    required PdfColor headerColor,
    required List<TableRowData> data,
    required List<String> headers,
    required String total,
    required int totalColumnIndex,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
    required bool isTr,
  }) {
    final headerStyle = pw.TextStyle(
      font: turkishFontBold,
      fontSize: 11,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(font: turkishFont, fontSize: 10);

    // Toplam satırı için veriyi hazırla
    final totalRow = List<String>.generate(headers.length, (index) {
      if (index == totalColumnIndex - 1) return isTr ? 'TOPLAM' : 'TOTAL';
      if (index == totalColumnIndex) return total;
      return '';
    });

    // Tüm satır verilerini hazırla
    final allRows = <List<String>>[];
    for (final row in data) {
      allRows.add(row.cells);
    }
    allRows.add(totalRow);

    return [
      // Tablo başlığı
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: pw.BoxDecoration(
          color: headerColor,
          border: pw.Border.all(color: PdfUtils.tableBorderColor, width: 0.5),
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(8),
            topRight: pw.Radius.circular(8),
          ),
        ),
        child: pw.Text(
          title,
          style: pw.TextStyle(
            font: turkishFontBold,
            fontSize: 14,
            color: PdfColors.white,
          ),
        ),
      ),
      // TableHelper.fromTextArray sayfa geçişlerini otomatik destekler
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: allRows,
        border: pw.TableBorder.all(
          color: PdfUtils.tableBorderColor,
          width: 0.5,
        ),
        headerStyle: headerStyle,
        cellStyle: cellStyle,
        headerDecoration: pw.BoxDecoration(color: headerColor.shade(0.8)),
        columnWidths: _getColumnWidths(headers.length),
        cellAlignments: {headers.length - 1: pw.Alignment.centerRight},
        oddRowDecoration: pw.BoxDecoration(
          color: _getZebraColorLight(headerColor),
        ),
        rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        headerCellDecoration: pw.BoxDecoration(color: headerColor.shade(0.8)),
      ),
    ];
  }

  /// Zebra pattern için açık renk al
  static PdfColor _getZebraColorLight(PdfColor headerColor) {
    if (headerColor == PdfUtils.expenseColor) return PdfUtils.expenseColorLight;
    if (headerColor == PdfUtils.incomeColor) return PdfUtils.incomeColorLight;
    if (headerColor == PdfUtils.assetColor) return PdfUtils.assetColorLight;
    return PdfColors.grey100;
  }

  /// Sütun genişliklerini ayarla
  static Map<int, pw.TableColumnWidth> _getColumnWidths(int columnCount) {
    if (columnCount == 4) {
      return {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(2),
      };
    } else if (columnCount == 3) {
      return {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      };
    }
    return {};
  }
}
