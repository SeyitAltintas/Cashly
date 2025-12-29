import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// PDF Utils - Font yükleme, para formatı ve ortak yardımcı fonksiyonlar
/// Export service için kullanılan tüm yardımcı araçlar bu modülde toplanmıştır
class PdfUtils {
  PdfUtils._();

  /// Tarih formatı
  static final dateFormat = DateFormat('dd.MM.yyyy');

  /// Türkçe karakterleri destekleyen fontlar (cache)
  static pw.Font? _turkishFont;
  static pw.Font? _turkishFontBold;

  /// Renk tanımlamaları
  static const expenseColor = PdfColors.red700;
  static const expenseColorLight = PdfColors.red50;
  static const incomeColor = PdfColors.green700;
  static const incomeColorLight = PdfColors.green50;
  static const assetColor = PdfColors.blue700;
  static const assetColorLight = PdfColors.blue50;
  static const tableBorderColor = PdfColors.grey800;

  /// Koyu gri renk (başlıklar için)
  static PdfColor get darkGrey => PdfColor.fromHex('#1F2937');

  /// Font'ları yükle (Inter Regular)
  static Future<pw.Font> loadTurkishFont() async {
    if (_turkishFont != null) return _turkishFont!;
    final fontData = await rootBundle.load('assets/fonts/Inter-Regular.ttf');
    _turkishFont = pw.Font.ttf(fontData);
    return _turkishFont!;
  }

  /// Bold font yükle (Inter Bold)
  static Future<pw.Font> loadTurkishFontBold() async {
    if (_turkishFontBold != null) return _turkishFontBold!;
    try {
      final fontData = await rootBundle.load('assets/fonts/Inter-Bold.ttf');
      _turkishFontBold = pw.Font.ttf(fontData);
    } catch (_) {
      // Bold font bulunamazsa regular font kullan
      _turkishFontBold = await loadTurkishFont();
    }
    return _turkishFontBold!;
  }

  /// Siyah logo resmini yükle (seffaflogosiyah.png)
  static Future<Uint8List> loadBlackLogoImage() async {
    final logoData = await rootBundle.load('assets/image/seffaflogosiyah.png');
    return logoData.buffer.asUint8List();
  }

  /// Tutarı TL formatında göster (12.247,00 TL formatında)
  static String formatCurrency(double value) {
    // Negatif değerler için işaret
    final isNegative = value < 0;
    final absValue = value.abs();

    final parts = absValue.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    final formatted = '${buffer.toString()},$decPart TL';
    return isNegative ? '-$formatted' : formatted;
  }

  /// Font cache'i temizle (test için)
  static void clearFontCache() {
    _turkishFont = null;
    _turkishFontBold = null;
  }
}

/// Export işlemi sonucu
class ExportResult {
  final bool success;
  final String? filePath;
  final String message;

  ExportResult({required this.success, this.filePath, required this.message});
}

/// Tablo satır verisi
class TableRowData {
  final List<String> cells;
  final PdfColor backgroundColor;

  TableRowData({required this.cells, required this.backgroundColor});
}
