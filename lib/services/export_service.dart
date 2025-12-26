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
          maxPages: 100,
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            buildBackground: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(color: PdfColors.grey100),
            ),
          ),
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

  /// PDF başlık bölümü - Minimalist tasarım (referans resme göre)
  static pw.Widget _buildHeader(
    pw.Font font,
    pw.Font fontBold,
    String userName,
    DateTime startDate,
    DateTime endDate,
    Uint8List logoBytes,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Sol taraf - Cashly başlık ve alt başlık
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Cashly',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 28,
                  color: PdfColor.fromHex('#10B981'), // Yeşil renk
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Finansal Durum Raporu',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                  color: PdfColors.grey800,
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
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  color: PdfColors.grey100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Görsel özet bölümü - Referans resme göre tasarım + Ek özellikler
  static pw.Widget _buildVisualSummary({
    required double toplamHarcama,
    required double toplamGelir,
    required double toplamVarlik,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    final netDurum = toplamGelir - toplamHarcama;
    final isPositive = netDurum >= 0;

    // Tasarruf oranı hesapla
    final tasarrufOrani = toplamGelir > 0
        ? ((toplamGelir - toplamHarcama) / toplamGelir * 100)
        : 0.0;

    // Bütçe durumu için oran
    final butceDurumu = toplamGelir > 0
        ? (toplamHarcama / toplamGelir * 100).clamp(0.0, 100.0)
        : 0.0;

    // Pasta grafiği için toplam ve oranlar
    final toplam = toplamHarcama + toplamGelir + toplamVarlik;
    final harcamaOran = toplam > 0 ? (toplamHarcama / toplam * 100) : 0.0;
    final gelirOran = toplam > 0 ? (toplamGelir / toplam * 100) : 0.0;
    final varlikOran = toplam > 0 ? (toplamVarlik / toplam * 100) : 0.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı - Referans resme göre
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4, bottom: 20),
          child: pw.Text(
            'Finansal Özet',
            style: pw.TextStyle(
              font: turkishFont,
              fontSize: 13,
              color: PdfColors.grey700,
            ),
          ),
        ),

        // Üst satır - 3 Özet Kartı (Referans resme göre)
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildSummaryCard(
                iconText: '↘',
                iconColor: _expenseColor,
                title: 'Toplam Harcama',
                value: _formatCurrency(toplamHarcama),
                font: turkishFont,
                fontBold: turkishFontBold,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _buildSummaryCard(
                iconText: '↗',
                iconColor: _incomeColor,
                title: 'Toplam Gelir',
                value: _formatCurrency(toplamGelir),
                font: turkishFont,
                fontBold: turkishFontBold,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _buildSummaryCard(
                iconText: '≈',
                iconColor: _assetColor,
                title: 'Toplam Varlık',
                value: _formatCurrency(toplamVarlik),
                font: turkishFont,
                fontBold: turkishFontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        // Alt satır - 2 Kart (Referans resme göre)
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildSummaryCard(
                iconText: '⚖',
                iconColor: isPositive ? _incomeColor : _expenseColor,
                title: 'Aylık Net Durum',
                value: '${isPositive ? '+' : ''}${_formatCurrency(netDurum)}',
                valueColor: isPositive ? _incomeColor : _expenseColor,
                font: turkishFont,
                fontBold: turkishFontBold,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _buildSummaryCard(
                iconText: '%',
                iconColor: PdfColors.blue700,
                title: 'Tasarruf Oranı',
                value: '%${tasarrufOrani.toStringAsFixed(1)}',
                valueColor: tasarrufOrani >= 0
                    ? PdfColors.blue700
                    : _expenseColor,
                font: turkishFont,
                fontBold: turkishFontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // Pasta Grafiği ve İstatistikler
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColors.grey200, width: 1),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Sol: Pasta Grafiği (CustomPaint)
              pw.Container(
                width: 100,
                height: 100,
                child: pw.CustomPaint(
                  size: const PdfPoint(100, 100),
                  painter: (canvas, size) {
                    final center = PdfPoint(size.x / 2, size.y / 2);
                    final radius = size.x / 2 - 2;

                    if (toplam > 0) {
                      double startAngle = -3.14159 / 2; // -90 derece (12 saat)

                      // Harcama dilimi (kırmızı)
                      final harcamaAngle =
                          (toplamHarcama / toplam) * 2 * 3.14159;
                      _drawPieSlice(
                        canvas,
                        center,
                        radius,
                        startAngle,
                        harcamaAngle,
                        _expenseColor,
                      );
                      startAngle += harcamaAngle;

                      // Gelir dilimi (yeşil)
                      final gelirAngle = (toplamGelir / toplam) * 2 * 3.14159;
                      _drawPieSlice(
                        canvas,
                        center,
                        radius,
                        startAngle,
                        gelirAngle,
                        _incomeColor,
                      );
                      startAngle += gelirAngle;

                      // Varlık dilimi (mavi)
                      final varlikAngle = (toplamVarlik / toplam) * 2 * 3.14159;
                      _drawPieSlice(
                        canvas,
                        center,
                        radius,
                        startAngle,
                        varlikAngle,
                        _assetColor,
                      );
                    }
                  },
                ),
              ),
              pw.SizedBox(width: 16),
              // Sağ: Pasta grafiği açıklaması ve istatistikler
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Dağılım',
                      style: pw.TextStyle(
                        font: turkishFontBold,
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    // Açıklama
                    _buildLegendItem(
                      'Harcama',
                      harcamaOran,
                      _expenseColor,
                      turkishFont,
                    ),
                    pw.SizedBox(height: 4),
                    _buildLegendItem(
                      'Gelir',
                      gelirOran,
                      _incomeColor,
                      turkishFont,
                    ),
                    pw.SizedBox(height: 4),
                    _buildLegendItem(
                      'Varlık',
                      varlikOran,
                      _assetColor,
                      turkishFont,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Divider(color: PdfColors.grey200),
                    pw.SizedBox(height: 8),
                    _buildStatRow(
                      label: 'Net Durum',
                      value:
                          '${isPositive ? '+' : ''}${_formatCurrency(netDurum)}',
                      color: isPositive ? _incomeColor : _expenseColor,
                      font: turkishFont,
                      fontBold: turkishFontBold,
                    ),
                    pw.SizedBox(height: 4),
                    _buildStatRow(
                      label: 'Harcama/Gelir',
                      value: '%${butceDurumu.toStringAsFixed(0)}',
                      color: butceDurumu > 90
                          ? _expenseColor
                          : (butceDurumu > 70
                                ? PdfColors.orange
                                : _incomeColor),
                      font: turkishFont,
                      fontBold: turkishFontBold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // Bütçe İlerleme Çubuğu
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColors.grey200, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Bütçe Durumu',
                    style: pw.TextStyle(
                      font: turkishFontBold,
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    '%${butceDurumu.toStringAsFixed(0)} kullanıldı',
                    style: pw.TextStyle(
                      font: turkishFont,
                      fontSize: 10,
                      color: butceDurumu > 90
                          ? _expenseColor
                          : PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              // İlerleme çubuğu
              pw.Container(
                height: 10,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  children: [
                    if (butceDurumu > 0)
                      pw.Expanded(
                        flex: butceDurumu.toInt().clamp(1, 100),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: butceDurumu > 90
                                ? _expenseColor
                                : (butceDurumu > 70
                                      ? PdfColors.orange
                                      : _incomeColor),
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    if (butceDurumu < 100)
                      pw.Expanded(
                        flex: (100 - butceDurumu.toInt()).clamp(1, 100),
                        child: pw.Container(),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              // Açıklama
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '0%',
                    style: pw.TextStyle(
                      font: turkishFont,
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                  pw.Row(
                    children: [
                      pw.Container(width: 8, height: 8, color: _incomeColor),
                      pw.Text(
                        ' <70%  ',
                        style: pw.TextStyle(
                          font: turkishFont,
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                      pw.Container(
                        width: 8,
                        height: 8,
                        color: PdfColors.orange,
                      ),
                      pw.Text(
                        ' 70-90%  ',
                        style: pw.TextStyle(
                          font: turkishFont,
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                      pw.Container(width: 8, height: 8, color: _expenseColor),
                      pw.Text(
                        ' >90%',
                        style: pw.TextStyle(
                          font: turkishFont,
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    '100%',
                    style: pw.TextStyle(
                      font: turkishFont,
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// İstatistik satırı widget'ı
  static pw.Widget _buildStatRow({
    required String label,
    required String value,
    required PdfColor color,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(font: fontBold, fontSize: 11, color: color),
        ),
      ],
    );
  }

  /// Özet kartı widget'ı - Referans resme göre tasarım
  static pw.Widget _buildSummaryCard({
    required String iconText,
    required PdfColor iconColor,
    required String title,
    required String value,
    PdfColor? valueColor,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // İkon ve başlık satırı
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                iconText,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 11,
                  color: iconColor,
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Expanded(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          // Değer - Büyük ve belirgin (siyah)
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 13,
              color: valueColor ?? PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  /// Pasta dilimi çiz
  static void _drawPieSlice(
    PdfGraphics canvas,
    PdfPoint center,
    double radius,
    double startAngle,
    double sweepAngle,
    PdfColor color,
  ) {
    if (sweepAngle <= 0) return;

    canvas.setFillColor(color);
    canvas.moveTo(center.x, center.y);
    canvas.lineTo(
      center.x + radius * _cosApprox(startAngle),
      center.y + radius * _sinApprox(startAngle),
    );

    // Arc çiz
    const segments = 20;
    for (int i = 1; i <= segments; i++) {
      final angle = startAngle + (sweepAngle * i / segments);
      canvas.lineTo(
        center.x + radius * _cosApprox(angle),
        center.y + radius * _sinApprox(angle),
      );
    }

    canvas.lineTo(center.x, center.y);
    canvas.fillPath();
  }

  /// Cos yaklaşımı
  static double _cosApprox(double rad) {
    double x = rad;
    while (x > 3.14159) {
      x -= 2 * 3.14159;
    }
    while (x < -3.14159) {
      x += 2 * 3.14159;
    }
    double r = 1.0, t = 1.0;
    for (int i = 1; i <= 10; i++) {
      t *= -x * x / ((2 * i - 1) * (2 * i));
      r += t;
    }
    return r;
  }

  /// Sin yaklaşımı
  static double _sinApprox(double rad) {
    double x = rad;
    while (x > 3.14159) {
      x -= 2 * 3.14159;
    }
    while (x < -3.14159) {
      x += 2 * 3.14159;
    }
    double r = x, t = x;
    for (int i = 1; i <= 10; i++) {
      t *= -x * x / ((2 * i) * (2 * i + 1));
      r += t;
    }
    return r;
  }

  /// Pasta grafiği açıklama öğesi
  static pw.Widget _buildLegendItem(
    String label,
    double percentage,
    PdfColor color,
    pw.Font font,
  ) {
    return pw.Row(
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          '$label: %${percentage.toStringAsFixed(0)}',
          style: pw.TextStyle(
            font: font,
            fontSize: 9,
            color: PdfColors.grey700,
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
