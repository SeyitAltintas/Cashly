import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../core/di/injection_container.dart';
import '../features/expenses/domain/repositories/expense_repository.dart';
import '../features/income/domain/repositories/income_repository.dart';
import '../features/assets/domain/repositories/asset_repository.dart';

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
    bool includeVisualSummary = false,
  }) async {
    try {
      // Fontları ve logoyu yükle
      final turkishFont = await _loadTurkishFont();
      final turkishFontBold = await _loadTurkishFontBold();
      final logoBytes = await _loadLogoImage();
      final pdf = pw.Document();

      // Repository'leri al
      final expenseRepo = getIt<ExpenseRepository>();
      final incomeRepo = getIt<IncomeRepository>();
      final assetRepo = getIt<AssetRepository>();

      // Finansal özet için TÜM verileri al (switch durumuna bakmaksızın)
      final tumHarcamalar = _filterByDateRange(
        expenseRepo.getExpenses(userId),
        startDate,
        endDate,
      );
      final tumGelirler = _filterIncomesByDateRange(
        incomeRepo.getIncomes(userId),
        startDate,
        endDate,
      );
      final tumVarliklar = assetRepo.getAssets(userId);

      // Finansal özet için toplamları hesapla (TÜM verilerden)
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

      // Tablolar için seçime göre verileri al
      final harcamalar = includeExpenses
          ? tumHarcamalar
          : <Map<String, dynamic>>[];
      final gelirler = includeIncomes ? tumGelirler : <Map<String, dynamic>>[];
      final varliklar = includeAssets ? tumVarliklar : <Map<String, dynamic>>[];

      // PDF sayfası oluştur
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          maxPages:
              100, // Sayfa limitini artır - TooManyPagesException hatasını önler
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

            // Görsel Özet bölümü (eğer seçiliyse) - İlk sayfada başlık ile birlikte
            if (includeVisualSummary) ...[
              _buildVisualSummary(
                toplamHarcama: toplamHarcama,
                toplamGelir: toplamGelir,
                toplamVarlik: toplamVarlik,
                turkishFont: turkishFont,
                turkishFontBold: turkishFontBold,
              ),
            ],

            // Harcamalar tablosu - Yeni sayfada başlasın
            if (includeExpenses && harcamalar.isNotEmpty) ...[
              pw.NewPage(), // Yeni sayfa
              ..._buildTableSection(
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
            ],

            // Gelirler tablosu - Yeni sayfada başlasın
            if (includeIncomes && gelirler.isNotEmpty) ...[
              pw.NewPage(), // Yeni sayfa
              ..._buildTableSection(
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
            ],

            // Varlıklar tablosu - Yeni sayfada başlasın
            if (includeAssets && varliklar.isNotEmpty) ...[
              pw.NewPage(), // Yeni sayfa
              ..._buildTableSection(
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
        border: pw.Border.all(color: PdfColors.black, width: 1),
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
                'Finansal Durum Raporu',
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

  /// Görsel özet bölümü - Finansal özet kartları
  static pw.Widget _buildVisualSummary({
    required double toplamHarcama,
    required double toplamGelir,
    required double toplamVarlik,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    final netDurum = toplamGelir - toplamHarcama;
    final isPositive = netDurum >= 0;

    // Tasarruf oranı hesapla (Gelir > 0 ise)
    final tasarrufOrani = toplamGelir > 0
        ? ((toplamGelir - toplamHarcama) / toplamGelir * 100)
        : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Başlık
          pw.Row(
            children: [
              pw.Container(width: 4, height: 24, color: PdfColors.purple700),
              pw.SizedBox(width: 12),
              pw.Text(
                'Finansal Özet',
                style: pw.TextStyle(
                  font: turkishFontBold,
                  fontSize: 18,
                  color: PdfColors.grey800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Üç özet kartı - Harcama, Gelir, Varlık
          pw.Row(
            children: [
              // Harcama kartı
              pw.Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Harcama',
                  value: _formatCurrency(toplamHarcama),
                  color: _expenseColor,
                  bgColor: PdfColors.red50,
                  font: turkishFont,
                  fontBold: turkishFontBold,
                ),
              ),
              pw.SizedBox(width: 12),
              // Gelir kartı
              pw.Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Gelir',
                  value: _formatCurrency(toplamGelir),
                  color: _incomeColor,
                  bgColor: PdfColors.green50,
                  font: turkishFont,
                  fontBold: turkishFontBold,
                ),
              ),
              pw.SizedBox(width: 12),
              // Varlık kartı
              pw.Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Varlık',
                  value: _formatCurrency(toplamVarlik),
                  color: _assetColor,
                  bgColor: PdfColors.blue50,
                  font: turkishFont,
                  fontBold: turkishFontBold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Alt kısım - Net durum ve Tasarruf oranı
          pw.Row(
            children: [
              // Net durum kartı
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: isPositive ? PdfColors.green50 : PdfColors.red50,
                    border: pw.Border.all(
                      color: isPositive ? _incomeColor : _expenseColor,
                      width: 1.5,
                    ),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Aylık Net Durum',
                        style: pw.TextStyle(
                          font: turkishFont,
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Gelir - Harcama',
                        style: pw.TextStyle(
                          font: turkishFont,
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '${isPositive ? '+' : ''}${_formatCurrency(netDurum)}',
                        style: pw.TextStyle(
                          font: turkishFontBold,
                          fontSize: 16,
                          color: isPositive ? _incomeColor : _expenseColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Tasarruf oranı kartı
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple50,
                    border: pw.Border.all(color: PdfColors.purple300, width: 1),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Tasarruf Oranı',
                        style: pw.TextStyle(
                          font: turkishFont,
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        '%${tasarrufOrani.toStringAsFixed(1)}',
                        style: pw.TextStyle(
                          font: turkishFontBold,
                          fontSize: 20,
                          color: tasarrufOrani >= 0
                              ? PdfColors.purple700
                              : _expenseColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Özet kartı widget'ı
  static pw.Widget _buildSummaryCard({
    required String title,
    required String value,
    required PdfColor color,
    required PdfColor bgColor,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    // PDF'de borderRadius sadece Border.all ile kullanılabilir
    // Sol kenardaki renkli çizgi için Row kullanıyoruz
    return pw.Row(
      children: [
        // Sol kenardaki renkli çizgi
        pw.Container(
          width: 3,
          height: 50,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              bottomLeft: pw.Radius.circular(4),
            ),
          ),
        ),
        // Ana içerik kartı
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: bgColor,
              borderRadius: const pw.BorderRadius.only(
                topRight: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  value,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tablo bölümü oluştur (sayfa geçişlerini destekler)
  /// Liste olarak döndürülür çünkü Column widget'ı MultiPage içinde bölünemez
  static List<pw.Widget> _buildTableSection({
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

    // Toplam satırı için veriyi hazırla
    final totalRow = List<String>.generate(headers.length, (index) {
      if (index == totalColumnIndex - 1) return 'TOPLAM';
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
      // TableHelper.fromTextArray sayfa geçişlerini otomatik destekler
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: allRows,
        border: pw.TableBorder.all(color: _tableBorderColor, width: 0.5),
        headerStyle: headerStyle,
        cellStyle: cellStyle,
        headerDecoration: pw.BoxDecoration(color: headerColor.shade(0.8)),
        columnWidths: _getColumnWidths(headers.length),
        cellAlignments: {headers.length - 1: pw.Alignment.centerRight},
        oddRowDecoration: pw.BoxDecoration(
          color: _getZebraColorLight(headerColor),
        ),
        rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
        cellPadding: const pw.EdgeInsets.all(10),
        headerCellDecoration: pw.BoxDecoration(color: headerColor.shade(0.8)),
      ),
    ];
  }

  /// Zebra pattern için açık renk al
  static PdfColor _getZebraColorLight(PdfColor headerColor) {
    if (headerColor == _expenseColor) return _expenseColorLight;
    if (headerColor == _incomeColor) return _incomeColorLight;
    if (headerColor == _assetColor) return _assetColorLight;
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
