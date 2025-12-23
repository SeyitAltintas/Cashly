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

  /// Türkçe karakterleri destekleyen fontlar
  static pw.Font? _turkishFont;
  static pw.Font? _turkishFontBold;

  /// Renk tanımlamaları
  static const _expenseColor = PdfColors.red700;
  static const _expenseColorLight = PdfColors.red50;
  static const _incomeColor = PdfColors.green700;
  static const _incomeColorLight = PdfColors.green50;
  static const _assetColor = PdfColors.blue700;
  static const _assetColorLight = PdfColors.blue50;
  static const _totalRowColor = PdfColors.grey300;
  static const _tableBorderColor = PdfColors.grey800;

  /// Font'ları yükle
  static Future<pw.Font> _loadTurkishFont() async {
    if (_turkishFont != null) return _turkishFont!;
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    _turkishFont = pw.Font.ttf(fontData);
    return _turkishFont!;
  }

  static Future<pw.Font> _loadTurkishFontBold() async {
    if (_turkishFontBold != null) return _turkishFontBold!;
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      _turkishFontBold = pw.Font.ttf(fontData);
    } catch (_) {
      _turkishFontBold = await _loadTurkishFont();
    }
    return _turkishFontBold!;
  }

  /// Logo resmini yükle
  static Future<Uint8List> _loadLogoImage() async {
    final logoData = await rootBundle.load('assets/image/seffaflogo.png');
    return logoData.buffer.asUint8List();
  }

  /// Tutarı TL formatında göster (12.247,00 TL formatında)
  static String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

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
    bool includeExpenses = true,
    bool includeIncomes = true,
    bool includeAssets = true,
  }) async {
    try {
      // Fontları ve logoyu yükle
      final turkishFont = await _loadTurkishFont();
      final turkishFontBold = await _loadTurkishFontBold();
      final logoBytes = await _loadLogoImage();
      final pdf = pw.Document();

      // Seçime göre verileri al
      final harcamalar = includeExpenses
          ? _filterByDateRange(
              DatabaseHelper.harcamalariGetir(userId),
              startDate,
              endDate,
            )
          : <Map<String, dynamic>>[];
      final gelirler = includeIncomes
          ? _filterIncomesByDateRange(
              DatabaseHelper.gelirleriGetir(userId),
              startDate,
              endDate,
            )
          : <Map<String, dynamic>>[];
      final varliklar = includeAssets
          ? DatabaseHelper.varliklariGetir(userId)
          : <Map<String, dynamic>>[];

      // Toplamları hesapla
      final toplamHarcama = harcamalar.fold<double>(
        0,
        (sum, h) => sum + (h['tutar'] as num).toDouble(),
      );
      final toplamGelir = gelirler.fold<double>(
        0,
        (sum, g) => sum + ((g['amount'] as num?) ?? 0).toDouble(),
      );
      final toplamVarlik = varliklar.fold<double>(
        0,
        (sum, v) => sum + ((v['amount'] as num?) ?? 0).toDouble(),
      );

      // PDF sayfası oluştur
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          footer: (context) => _buildFooter(context, turkishFont),
          build: (context) => [
            // Başlık bölümü - Logo ile
            _buildHeader(
              turkishFont,
              turkishFontBold,
              userName,
              startDate,
              endDate,
              logoBytes,
            ),
            pw.SizedBox(height: 24),

            // Harcamalar tablosu
            if (includeExpenses && harcamalar.isNotEmpty) ...[
              _buildTableSection(
                title: 'Harcamalar',
                headerColor: _expenseColor,
                data: harcamalar.asMap().entries.map((entry) {
                  final h = entry.value;
                  final isEven = entry.key % 2 == 0;
                  return _TableRowData(
                    cells: [
                      h['isim'] ?? '-',
                      h['kategori'] ?? '-',
                      _dateFormat.format(DateTime.parse(h['tarih'])),
                      _formatCurrency((h['tutar'] as num).toDouble()),
                    ],
                    backgroundColor: isEven
                        ? _expenseColorLight
                        : PdfColors.white,
                  );
                }).toList(),
                headers: ['İsim', 'Kategori', 'Tarih', 'Tutar'],
                total: _formatCurrency(toplamHarcama),
                totalColumnIndex: 3,
                turkishFont: turkishFont,
                turkishFontBold: turkishFontBold,
              ),
              pw.SizedBox(height: 24),
            ],

            // Gelirler tablosu
            if (includeIncomes && gelirler.isNotEmpty) ...[
              _buildTableSection(
                title: 'Gelirler',
                headerColor: _incomeColor,
                data: gelirler.asMap().entries.map((entry) {
                  final g = entry.value;
                  final isEven = entry.key % 2 == 0;
                  return _TableRowData(
                    cells: [
                      g['name'] ?? '-',
                      g['category'] ?? '-',
                      _dateFormat.format(DateTime.parse(g['date'])),
                      _formatCurrency(((g['amount'] as num?) ?? 0).toDouble()),
                    ],
                    backgroundColor: isEven
                        ? _incomeColorLight
                        : PdfColors.white,
                  );
                }).toList(),
                headers: ['İsim', 'Kategori', 'Tarih', 'Tutar'],
                total: _formatCurrency(toplamGelir),
                totalColumnIndex: 3,
                turkishFont: turkishFont,
                turkishFontBold: turkishFontBold,
              ),
              pw.SizedBox(height: 24),
            ],

            // Varlıklar tablosu
            if (includeAssets && varliklar.isNotEmpty) ...[
              _buildTableSection(
                title: 'Varlıklar',
                headerColor: _assetColor,
                data: varliklar.asMap().entries.map((entry) {
                  final v = entry.value;
                  final isEven = entry.key % 2 == 0;
                  return _TableRowData(
                    cells: [
                      v['name'] ?? '-',
                      v['category'] ?? '-',
                      _formatCurrency(((v['amount'] as num?) ?? 0).toDouble()),
                    ],
                    backgroundColor: isEven
                        ? _assetColorLight
                        : PdfColors.white,
                  );
                }).toList(),
                headers: ['İsim', 'Kategori', 'Değer'],
                total: _formatCurrency(toplamVarlik),
                totalColumnIndex: 2,
                turkishFont: turkishFont,
                turkishFontBold: turkishFontBold,
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

  /// PDF başlık bölümü - Logo ve bilgiler
  static pw.Widget _buildHeader(
    pw.Font font,
    pw.Font fontBold,
    String userName,
    DateTime startDate,
    DateTime endDate,
    Uint8List logoBytes,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            PdfColor.fromHex('#0f2027'),
            PdfColor.fromHex('#203a43'),
            PdfColor.fromHex('#2c5364'),
          ],
        ),
        border: pw.Border.all(color: PdfColors.grey800, width: 1),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Sol taraf - Logo resmi
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(pw.MemoryImage(logoBytes), height: 50),
              pw.SizedBox(height: 8),
              pw.Text(
                'Finansal Rapor',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  color: PdfColors.grey300,
                ),
              ),
            ],
          ),
          // Sağ taraf - Kullanıcı ve tarih bilgileri
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                userName,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  color: PdfColors.grey300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tablo bölümü oluştur
  static pw.Widget _buildTableSection({
    required String title,
    required PdfColor headerColor,
    required List<_TableRowData> data,
    required List<String> headers,
    required String total,
    required int totalColumnIndex,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    final headerStyle = pw.TextStyle(
      font: turkishFontBold,
      fontSize: 11,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(font: turkishFont, fontSize: 10);
    final totalStyle = pw.TextStyle(font: turkishFontBold, fontSize: 11);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Tablo başlığı - sadece isim, simge yok
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: pw.BoxDecoration(
            color: headerColor,
            border: pw.Border.all(color: _tableBorderColor, width: 0.5),
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
        // Tablo - daha belirgin çizgiler
        pw.Table(
          border: pw.TableBorder.all(color: _tableBorderColor, width: 0.5),
          columnWidths: _getColumnWidths(headers.length),
          children: [
            // Başlık satırı
            pw.TableRow(
              decoration: pw.BoxDecoration(color: headerColor.shade(0.8)),
              children: headers
                  .map(
                    (h) => pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(h, style: headerStyle),
                    ),
                  )
                  .toList(),
            ),
            // Veri satırları - Zebra pattern
            ...data.map(
              (row) => pw.TableRow(
                decoration: pw.BoxDecoration(color: row.backgroundColor),
                children: row.cells
                    .map(
                      (cell) => pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(cell, style: cellStyle),
                      ),
                    )
                    .toList(),
              ),
            ),
            // Toplam satırı
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _totalRowColor),
              children: List.generate(headers.length, (index) {
                if (index == totalColumnIndex - 1) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('TOPLAM', style: totalStyle),
                  );
                } else if (index == totalColumnIndex) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(total, style: totalStyle),
                  );
                }
                return pw.Container(padding: const pw.EdgeInsets.all(10));
              }),
            ),
          ],
        ),
      ],
    );
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

  /// Footer oluştur
  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
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

  /// Dosyayı paylaş
  static Future<void> shareFile(String filePath) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], subject: 'Cashly Raporu'),
    );
  }

  /// Tarih aralığına göre harcamaları filtrele
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

  /// Tarih aralığına göre gelirleri filtrele
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
}

/// Tablo satır verisi
class _TableRowData {
  final List<String> cells;
  final PdfColor backgroundColor;

  _TableRowData({required this.cells, required this.backgroundColor});
}

/// Export işlemi sonucu
class ExportResult {
  final bool success;
  final String? filePath;
  final String message;

  ExportResult({required this.success, this.filePath, required this.message});
}
