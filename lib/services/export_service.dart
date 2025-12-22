import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

/// Rapor Export Servisi
/// Harcama ve gelir raporlarını PDF formatında dışa aktarır
/// Türkçe karakter desteği ile
class ExportService {
  ExportService._();

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

  /// Tutarı TL formatında göster (12.247,00 TL formatında)
  static String _formatCurrency(double value) {
    // Binlik ayraç ve virgül ile Türk formatı
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Binlik ayraç ekle
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }
    return '${buffer.toString()},$decPart TL';
  }

  /// PDF olarak rapor olustur ve paylas
  static Future<ExportResult> exportToPdf({
    required String userId,
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
    bool includeSummary = true,
    bool includeExpenses = true,
    bool includeIncomes = true,
    bool includeAssets = true,
  }) async {
    try {
      // Türkçe destekli font yükle
      final turkishFont = await _loadTurkishFont();
      final pdf = pw.Document();

      // Özet için TÜM verileri al (seçim ne olursa olsun)
      final tumHarcamalar = _filterByDateRange(
        DatabaseHelper.harcamalariGetir(userId),
        startDate,
        endDate,
      );
      final tumGelirler = _filterIncomesByDateRange(
        DatabaseHelper.gelirleriGetir(userId),
        startDate,
        endDate,
      );
      final tumVarliklar = DatabaseHelper.varliklariGetir(userId);

      // Tablolar için seçime göre verileri belirle
      final harcamalar = includeExpenses
          ? tumHarcamalar
          : <Map<String, dynamic>>[];
      final gelirler = includeIncomes ? tumGelirler : <Map<String, dynamic>>[];
      final varliklar = includeAssets ? tumVarliklar : <Map<String, dynamic>>[];

      // Toplamları hesapla (her zaman tüm verilerden)
      final toplamHarcama = tumHarcamalar.fold<double>(
        0,
        (sum, h) => sum + (h['tutar'] as num).toDouble(),
      );
      final toplamGelir = tumGelirler.fold<double>(
        0,
        (sum, g) => sum + ((g['amount'] as num?) ?? 0).toDouble(),
      );
      final toplamVarlik = tumVarliklar.fold<double>(
        0,
        (sum, v) => sum + ((v['amount'] as num?) ?? 0).toDouble(),
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

            // Tarih aralığı ve kullanıcı adı - yan yana
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tarih Aralığı : ${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
                  style: normalStyle,
                ),
                pw.Text(
                  userName,
                  style: pw.TextStyle(
                    font: turkishFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Özet - includeSummary true ise göster
            if (includeSummary) ...[
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
            ],

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
                headers: ['İsim', 'Kategori', 'Tarih', 'Tutar'],
                data: harcamalar
                    .map(
                      (h) => [
                        h['isim'] ?? '-',
                        h['kategori'] ?? '-',
                        _dateFormat.format(DateTime.parse(h['tarih'])),
                        _formatCurrency((h['tutar'] as num).toDouble()),
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
                headers: ['İsim', 'Kategori', 'Tarih', 'Tutar'],
                data: gelirler
                    .map(
                      (g) => [
                        g['name'] ?? '-',
                        g['category'] ?? '-',
                        _dateFormat.format(DateTime.parse(g['date'])),
                        _formatCurrency(
                          ((g['amount'] as num?) ?? 0).toDouble(),
                        ),
                      ],
                    )
                    .toList(),
              ),
            ],

            // Varliklar tablosu
            if (includeAssets && varliklar.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Varlıklar', style: headerStyle),
              ),
              pw.TableHelper.fromTextArray(
                headerStyle: headerStyle,
                cellStyle: normalStyle,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: ['İsim', 'Kategori', 'Değer'],
                data: varliklar
                    .map(
                      (v) => [
                        v['name'] ?? '-',
                        v['category'] ?? '-',
                        _formatCurrency(
                          ((v['amount'] as num?) ?? 0).toDouble(),
                        ),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Toplam Varlık Değeri: ${_formatCurrency(toplamVarlik)}',
                style: pw.TextStyle(
                  font: turkishFont,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
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
        message: 'PDF raporu oluşturuldu',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'PDF oluşturulurken hata: $e',
      );
    }
  }

  /// Dosyayı paylaş
  static Future<void> shareFile(String filePath) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], subject: 'Cashly Raporu'),
    );
  }

  /// Tarih aralığına göre harcamaları filtrele (tarih alanı kullanır)
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

  /// Tarih aralığına göre gelirleri filtrele (date alanı kullanır)
  static List<Map<String, dynamic>> _filterIncomesByDateRange(
    List<Map<String, dynamic>> items,
    DateTime startDate,
    DateTime endDate,
  ) {
    return items.where((item) {
        final dateStr = item['date'] as String?;
        if (dateStr == null) return false;
        final date = DateTime.parse(dateStr);
        return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList()
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
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
          _formatCurrency(value),
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
