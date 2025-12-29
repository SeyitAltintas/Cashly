import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../pdf_utils/pdf_utils.dart';

/// PDF Header ve Footer Builder
/// Raporun başlık ve alt bilgi bölümlerini oluşturur
class PdfHeaderBuilder {
  PdfHeaderBuilder._();

  /// Tarih formatı
  static final _dateFormat = DateFormat('dd.MM.yyyy');

  /// PDF başlık bölümü - Logo ile minimalist tasarım
  static pw.Widget buildHeader({
    required pw.Font font,
    required pw.Font fontBold,
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
    required Uint8List logoBytes,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Sol taraf - Logo ve alt başlık
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              pw.Image(pw.MemoryImage(logoBytes), height: 35),
              pw.SizedBox(height: 6),
              pw.Text(
                'Finansal Durum Raporu',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  color: PdfUtils.darkGrey,
                ),
              ),
            ],
          ),
          // Sağ taraf - Kullanıcı adı ve tarih
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                userName,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 11,
                  color: PdfUtils.darkGrey,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfUtils.darkGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Footer oluştur - sayfa numarası ve tarih
  static pw.Widget buildFooter(pw.Context context, pw.Font font) {
    final now = DateTime.now();
    final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Cashly ile oluşturuldu • ${dateTimeFormat.format(now)}',
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Veri bulunamadı mesajı
  static pw.Widget buildNoDataMessage({
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.SizedBox(
      height: 80,
      child: pw.Center(
        child: pw.Container(
          width: 400,
          padding: const pw.EdgeInsets.all(32),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey300, width: 1),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                '!',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 48,
                  color: PdfColors.orange,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Veri Bulunamadı',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                  color: PdfUtils.darkGrey,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Finansal durum raporunu görebilmeniz için\nharcama, gelir veya varlık verisi eklemeniz gerekmektedir.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  color: PdfColors.grey700,
                  lineSpacing: 4,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F0F9FF'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'Uygulamadan veri ekledikten sonra tekrar deneyin.',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: PdfColor.fromHex('#0369A1'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
