import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

/// Rapor Export Servisi
/// Harcama ve gelir raporlarını PDF ve CSV formatında dışa aktarır
/// Türkçe karakter desteği ile
class ExportService {
  ExportService._();

  /// Para formatı - TL sembolü için
  static final _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: 'TL',
    decimalDigits: 2,
  );

  /// Tarih formatı
  static final _dateFormat = DateFormat('dd.MM.yyyy');

  /// Türkçe karakterleri destekleyen font
  static pw.Font? _turkishFont;

  /// Font'u yükle
  static Future<pw.Font> _loadTurkishFont() async {
    if (_turkishFont != null) return _turkishFont!;
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    _turkishFont = pw.Font.ttf(fontData);
    return _turkishFont!;
  }

  /// PDF olarak rapor oluştur ve paylaş
  static Future<ExportResult> exportToPdf({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    bool includeExpenses = true,
    bool includeIncomes = true,
  }) async {
    try {
      // Türkçe destekli font yükle
      final turkishFont = await _loadTurkishFont();
      final pdf = pw.Document();

      // Verileri al
      final harcamalar = includeExpenses
          ? _filterByDateRange(
              DatabaseHelper.harcamalariGetir(userId),
              startDate,
              endDate,
            )
          : <Map<String, dynamic>>[];

      final gelirler = includeIncomes
          ? _filterByDateRange(
              DatabaseHelper.gelirleriGetir(userId),
              startDate,
              endDate,
            )
          : <Map<String, dynamic>>[];

      // Toplamları hesapla
      final toplamHarcama = harcamalar.fold<double>(
        0,
        (sum, h) => sum + (h['tutar'] as num).toDouble(),
      );
      final toplamGelir = gelirler.fold<double>(
        0,
        (sum, g) => sum + (g['tutar'] as num).toDouble(),
      );

      // Font stilleri
      final titleStyle = pw.TextStyle(
        font: turkishFont,
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
      );
      final normalStyle = pw.TextStyle(font: turkishFont, fontSize: 12);
      final headerStyle = pw.TextStyle(
        font: turkishFont,
        fontWeight: pw.FontWeight.bold,
      );

      // PDF sayfası oluştur
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Başlık
            pw.Header(
              level: 0,
              child: pw.Text('Cashly Finansal Rapor', style: titleStyle),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Tarih Araligi: ${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
              style: normalStyle,
            ),
            pw.SizedBox(height: 20),

            // Özet
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Toplam Gelir',
                    toplamGelir,
                    PdfColors.green,
                    turkishFont,
                  ),
                  _buildSummaryItem(
                    'Toplam Harcama',
                    toplamHarcama,
                    PdfColors.red,
                    turkishFont,
                  ),
                  _buildSummaryItem(
                    'Net Durum',
                    toplamGelir - toplamHarcama,
                    toplamGelir >= toplamHarcama
                        ? PdfColors.green
                        : PdfColors.red,
                    turkishFont,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Harcamalar tablosu
            if (includeExpenses && harcamalar.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Harcamalar', style: headerStyle),
              ),
              pw.TableHelper.fromTextArray(
                headerStyle: headerStyle,
                cellStyle: normalStyle,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: ['Tarih', 'Kategori', 'Aciklama', 'Tutar'],
                data: harcamalar
                    .map(
                      (h) => [
                        _dateFormat.format(DateTime.parse(h['tarih'])),
                        h['kategori'] ?? '-',
                        h['aciklama'] ?? '-',
                        _currencyFormat.format(h['tutar']),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Gelirler tablosu
            if (includeIncomes && gelirler.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Gelirler', style: headerStyle),
              ),
              pw.TableHelper.fromTextArray(
                headerStyle: headerStyle,
                cellStyle: normalStyle,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: ['Tarih', 'Kategori', 'Aciklama', 'Tutar'],
                data: gelirler
                    .map(
                      (g) => [
                        _dateFormat.format(DateTime.parse(g['tarih'])),
                        g['kategori'] ?? '-',
                        g['aciklama'] ?? '-',
                        _currencyFormat.format(g['tutar']),
                      ],
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      );

      // Dosyayı kaydet
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/cashly_rapor_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return ExportResult(
        success: true,
        filePath: file.path,
        message: 'PDF raporu olusturuldu',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'PDF olusturulurken hata: $e',
      );
    }
  }

  /// CSV olarak rapor oluştur (Excel ile açılabilir)
  static Future<ExportResult> exportToCsv({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    bool includeExpenses = true,
    bool includeIncomes = true,
  }) async {
    try {
      final buffer = StringBuffer();

      // UTF-8 BOM ekle (Excel için Türkçe karakter desteği)
      buffer.write('\uFEFF');

      // Verileri al
      final harcamalar = includeExpenses
          ? _filterByDateRange(
              DatabaseHelper.harcamalariGetir(userId),
              startDate,
              endDate,
            )
          : <Map<String, dynamic>>[];

      final gelirler = includeIncomes
          ? _filterByDateRange(
              DatabaseHelper.gelirleriGetir(userId),
              startDate,
              endDate,
            )
          : <Map<String, dynamic>>[];

      // Harcamalar
      if (includeExpenses) {
        buffer.writeln('=== HARCAMALAR ===');
        buffer.writeln('Tarih;Kategori;Aciklama;Tutar;Odeme Yontemi');

        for (final h in harcamalar) {
          buffer.writeln(
            '${_dateFormat.format(DateTime.parse(h['tarih']))};'
            '${h['kategori'] ?? '-'};'
            '${_escapeCsv(h['aciklama'] ?? '-')};'
            '${(h['tutar'] as num).toDouble()};'
            '${h['odemeYontemi'] ?? '-'}',
          );
        }

        final toplamHarcama = harcamalar.fold<double>(
          0,
          (sum, h) => sum + (h['tutar'] as num).toDouble(),
        );
        buffer.writeln(';;TOPLAM;$toplamHarcama;');
        buffer.writeln();
      }

      // Gelirler
      if (includeIncomes) {
        buffer.writeln('=== GELIRLER ===');
        buffer.writeln('Tarih;Kategori;Aciklama;Tutar');

        for (final g in gelirler) {
          buffer.writeln(
            '${_dateFormat.format(DateTime.parse(g['tarih']))};'
            '${g['kategori'] ?? '-'};'
            '${_escapeCsv(g['aciklama'] ?? '-')};'
            '${(g['tutar'] as num).toDouble()}',
          );
        }

        final toplamGelir = gelirler.fold<double>(
          0,
          (sum, g) => sum + (g['tutar'] as num).toDouble(),
        );
        buffer.writeln(';;TOPLAM;$toplamGelir');
      }

      // Dosyayı kaydet
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/cashly_rapor_$timestamp.csv');
      await file.writeAsString(buffer.toString());

      return ExportResult(
        success: true,
        filePath: file.path,
        message: 'CSV raporu olusturuldu (Excel ile acilabilir)',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'CSV olusturulurken hata: $e',
      );
    }
  }

  /// CSV için özel karakterleri escape et
  static String _escapeCsv(String value) {
    if (value.contains(';') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Dosyayı paylaş
  static Future<void> shareFile(String filePath) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], subject: 'Cashly Raporu'),
    );
  }

  /// Tarih aralığına göre filtrele
  static List<Map<String, dynamic>> _filterByDateRange(
    List<Map<String, dynamic>> items,
    DateTime startDate,
    DateTime endDate,
  ) {
    return items.where((item) {
        final tarihStr = item['tarih'] as String?;
        if (tarihStr == null) return false;
        final tarih = DateTime.parse(tarihStr);
        return tarih.isAfter(startDate.subtract(const Duration(days: 1))) &&
            tarih.isBefore(endDate.add(const Duration(days: 1)));
      }).toList()
      ..sort((a, b) => (b['tarih'] as String).compareTo(a['tarih'] as String));
  }

  /// PDF özet öğesi oluştur
  static pw.Widget _buildSummaryItem(
    String label,
    double value,
    PdfColor color,
    pw.Font font,
  ) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(
          _currencyFormat.format(value),
          style: pw.TextStyle(
            font: font,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Export işlemi sonucu
class ExportResult {
  final bool success;
  final String? filePath;
  final String message;

  ExportResult({required this.success, this.filePath, required this.message});
}
