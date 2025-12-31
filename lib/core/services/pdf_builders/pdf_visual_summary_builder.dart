import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../pdf_utils/pdf_utils.dart';

/// PDF Visual Summary Builder
/// Finansal özet kartları, pasta grafiği, bütçe durumu ve istatistikleri oluşturur
class PdfVisualSummaryBuilder {
  PdfVisualSummaryBuilder._();

  /// Görsel özet bölümü - Referans resme göre tasarım + Ek özellikler
  static pw.Widget buildVisualSummary({
    required double toplamHarcama,
    required double toplamGelir,
    required double toplamVarlik,
    required double aylikButceLimiti,
    required List<Map<String, dynamic>> top5Harcamalar,
    required double ortalamaGunlukHarcama,
    required double gecenAyToplam,
    required double degisimYuzdesi,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
    // Alt seçenek kontrolleri
    bool showFinansalOzet = true,
    bool showNetDurum = true,
    bool showPastaGrafik = true,
    bool showButceDurumu = true,
    bool showIstatistikler = true,
    bool showTop5Harcama = true,
  }) {
    final netDurum = toplamGelir - toplamHarcama;
    final isPositive = netDurum >= 0;

    // Tasarruf oranı hesapla
    final tasarrufOrani = toplamGelir > 0
        ? ((toplamGelir - toplamHarcama) / toplamGelir * 100)
        : 0.0;

    // Bütçe durumu için oran (kullanıcının ayarladığı bütçe limitine göre)
    final butceDurumu = aylikButceLimiti > 0
        ? (toplamHarcama / aylikButceLimiti * 100).clamp(0.0, 100.0)
        : 0.0;

    // Pasta grafiği için toplam ve oranlar
    final toplam = toplamHarcama + toplamGelir + toplamVarlik;
    final harcamaOran = toplam > 0 ? (toplamHarcama / toplam * 100) : 0.0;
    final gelirOran = toplam > 0 ? (toplamGelir / toplam * 100) : 0.0;
    final varlikOran = toplam > 0 ? (toplamVarlik / toplam * 100) : 0.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4, bottom: 12),
          child: pw.Text(
            'Finansal Özet',
            style: pw.TextStyle(
              font: turkishFont,
              fontSize: 13,
              color: PdfUtils.darkGrey,
            ),
          ),
        ),

        // 1. Finansal Özet Kartları (Harcama, Gelir, Varlık)
        if (showFinansalOzet) ...[
          _buildTopSummaryCards(
            toplamHarcama: toplamHarcama,
            toplamGelir: toplamGelir,
            toplamVarlik: toplamVarlik,
            turkishFont: turkishFont,
            turkishFontBold: turkishFontBold,
          ),
          pw.SizedBox(height: 10),
        ],

        // 2. Net Durum ve Tasarruf Oranı Kartları
        if (showNetDurum) ...[
          _buildNetStatusCards(
            netDurum: netDurum,
            isPositive: isPositive,
            tasarrufOrani: tasarrufOrani,
            turkishFont: turkishFont,
            turkishFontBold: turkishFontBold,
          ),
          pw.SizedBox(height: 20),
        ],

        // 3. Pasta Grafiği ve Dağılım
        if (showPastaGrafik) ...[
          _buildPieChartSection(
            toplamHarcama: toplamHarcama,
            toplamGelir: toplamGelir,
            toplamVarlik: toplamVarlik,
            toplam: toplam,
            harcamaOran: harcamaOran,
            gelirOran: gelirOran,
            varlikOran: varlikOran,
            netDurum: netDurum,
            isPositive: isPositive,
            butceDurumu: butceDurumu,
            turkishFont: turkishFont,
            turkishFontBold: turkishFontBold,
          ),
          pw.SizedBox(height: 16),
        ],

        // 4. Bütçe İlerleme Çubuğu
        if (showButceDurumu) ...[
          _buildBudgetProgressBar(
            butceDurumu: butceDurumu,
            aylikButceLimiti: aylikButceLimiti,
            toplamHarcama: toplamHarcama,
            turkishFont: turkishFont,
            turkishFontBold: turkishFontBold,
          ),
          pw.SizedBox(height: 16),
        ],

        // 5. İstatistik Kartları (Günlük Ortalama + Geçen Ay Karşılaştırma)
        if (showIstatistikler) ...[
          _buildStatisticsCards(
            ortalamaGunlukHarcama: ortalamaGunlukHarcama,
            degisimYuzdesi: degisimYuzdesi,
            gecenAyToplam: gecenAyToplam,
            turkishFont: turkishFont,
            turkishFontBold: turkishFontBold,
          ),
          pw.SizedBox(height: 16),
        ],

        // 6. En Yüksek 5 Harcama
        if (showTop5Harcama && top5Harcamalar.isNotEmpty)
          _buildTop5Expenses(
            top5Harcamalar: top5Harcamalar,
            turkishFont: turkishFont,
            turkishFontBold: turkishFontBold,
          ),
      ],
    );
  }

  /// Üst satır - 3 Özet Kartı
  static pw.Widget _buildTopSummaryCards({
    required double toplamHarcama,
    required double toplamGelir,
    required double toplamVarlik,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Harcama
          pw.Expanded(
            child: _buildCompactSummaryItem(
              icon: '↓',
              iconColor: PdfUtils.expenseColor,
              title: 'Toplam Harcama',
              value: PdfUtils.formatCurrency(toplamHarcama),
              valueColor: PdfUtils.expenseColor,
              font: turkishFont,
              fontBold: turkishFontBold,
            ),
          ),
          // Dikey çizgi
          pw.Container(width: 1, height: 40, color: PdfColors.grey300),
          // Gelir
          pw.Expanded(
            child: _buildCompactSummaryItem(
              icon: '↑',
              iconColor: PdfUtils.incomeColor,
              title: 'Toplam Gelir',
              value: PdfUtils.formatCurrency(toplamGelir),
              valueColor: PdfUtils.incomeColor,
              font: turkishFont,
              fontBold: turkishFontBold,
            ),
          ),
          // Dikey çizgi
          pw.Container(width: 1, height: 40, color: PdfColors.grey300),
          // Varlık
          pw.Expanded(
            child: _buildCompactSummaryItem(
              icon: '≈',
              iconColor: PdfUtils.assetColor,
              title: 'Toplam Varlık',
              value: PdfUtils.formatCurrency(toplamVarlik),
              valueColor: PdfUtils.assetColor,
              font: turkishFont,
              fontBold: turkishFontBold,
            ),
          ),
        ],
      ),
    );
  }

  /// Net Durum ve Tasarruf Oranı kartları
  static pw.Widget _buildNetStatusCards({
    required double netDurum,
    required bool isPositive,
    required double tasarrufOrani,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    return pw.Row(
      children: [
        // Aylık Net Durum
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      isPositive ? '+/-' : '-/+',
                      style: pw.TextStyle(
                        font: turkishFontBold,
                        fontSize: 10,
                        color: isPositive
                            ? PdfUtils.incomeColor
                            : PdfUtils.expenseColor,
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Text(
                      'Aylık Net Durum',
                      style: pw.TextStyle(
                        font: turkishFont,
                        fontSize: 9,
                        color: PdfUtils.darkGrey,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  '${isPositive ? '+' : ''}${PdfUtils.formatCurrency(netDurum)}',
                  style: pw.TextStyle(
                    font: turkishFontBold,
                    fontSize: 14,
                    color: isPositive
                        ? PdfUtils.incomeColor
                        : PdfUtils.expenseColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        // Tasarruf Oranı
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      '%',
                      style: pw.TextStyle(
                        font: turkishFontBold,
                        fontSize: 10,
                        color: PdfColors.blue700,
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Text(
                      'Tasarruf Oranı',
                      style: pw.TextStyle(
                        font: turkishFont,
                        fontSize: 9,
                        color: PdfUtils.darkGrey,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  '%${tasarrufOrani.toStringAsFixed(1)}',
                  style: pw.TextStyle(
                    font: turkishFontBold,
                    fontSize: 14,
                    color: tasarrufOrani >= 0
                        ? PdfColors.blue700
                        : PdfUtils.expenseColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Pasta Grafiği ve İstatistikler
  static pw.Widget _buildPieChartSection({
    required double toplamHarcama,
    required double toplamGelir,
    required double toplamVarlik,
    required double toplam,
    required double harcamaOran,
    required double gelirOran,
    required double varlikOran,
    required double netDurum,
    required bool isPositive,
    required double butceDurumu,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
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
                  final harcamaAngle = (toplamHarcama / toplam) * 2 * 3.14159;
                  _drawPieSlice(
                    canvas,
                    center,
                    radius,
                    startAngle,
                    harcamaAngle,
                    PdfUtils.expenseColor,
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
                    PdfUtils.incomeColor,
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
                    PdfUtils.assetColor,
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
                    color: PdfUtils.darkGrey,
                  ),
                ),
                pw.SizedBox(height: 10),
                // Açıklama
                _buildLegendItem(
                  'Harcama',
                  harcamaOran,
                  PdfUtils.expenseColor,
                  turkishFont,
                ),
                pw.SizedBox(height: 4),
                _buildLegendItem(
                  'Gelir',
                  gelirOran,
                  PdfUtils.incomeColor,
                  turkishFont,
                ),
                pw.SizedBox(height: 4),
                _buildLegendItem(
                  'Varlık',
                  varlikOran,
                  PdfUtils.assetColor,
                  turkishFont,
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColors.grey200),
                pw.SizedBox(height: 8),
                _buildStatRow(
                  label: 'Net Durum',
                  value:
                      '${isPositive ? '+' : ''}${PdfUtils.formatCurrency(netDurum)}',
                  color: isPositive
                      ? PdfUtils.incomeColor
                      : PdfUtils.expenseColor,
                  font: turkishFont,
                  fontBold: turkishFontBold,
                ),
                pw.SizedBox(height: 4),
                _buildStatRow(
                  label: 'Harcama/Gelir',
                  value: '%${butceDurumu.toStringAsFixed(0)}',
                  color: butceDurumu > 90
                      ? PdfUtils.expenseColor
                      : (butceDurumu > 70
                            ? PdfColors.orange
                            : PdfUtils.incomeColor),
                  font: turkishFont,
                  fontBold: turkishFontBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bütçe İlerleme Çubuğu
  static pw.Widget _buildBudgetProgressBar({
    required double butceDurumu,
    required double aylikButceLimiti,
    required double toplamHarcama,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
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
                  color: PdfUtils.darkGrey,
                ),
              ),
              pw.Text(
                '%${butceDurumu.toStringAsFixed(0)} kullanıldı',
                style: pw.TextStyle(
                  font: turkishFont,
                  fontSize: 10,
                  color: butceDurumu > 90
                      ? PdfUtils.expenseColor
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
                            ? PdfUtils.expenseColor
                            : (butceDurumu > 70
                                  ? PdfColors.orange
                                  : PdfUtils.incomeColor),
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
                  color: PdfUtils.darkGrey,
                ),
              ),
              pw.Text(
                '100%',
                style: pw.TextStyle(
                  font: turkishFont,
                  fontSize: 8,
                  color: PdfUtils.darkGrey,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          // Aylık gelir bütçe limiti ve aşım durumu
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Harcama limitiniz: ${PdfUtils.formatCurrency(aylikButceLimiti)}',
                  style: pw.TextStyle(
                    font: turkishFont,
                    fontSize: 9,
                    color: PdfUtils.darkGrey,
                  ),
                ),
                // Bütçe aşıldıysa aşım miktarını göster
                if (toplamHarcama > aylikButceLimiti &&
                    aylikButceLimiti > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Limit aşımı: ${PdfUtils.formatCurrency(toplamHarcama - aylikButceLimiti)}',
                    style: pw.TextStyle(
                      font: turkishFontBold,
                      fontSize: 9,
                      color: PdfUtils.expenseColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// İstatistik Kartları (Günlük Ortalama + Geçen Ay Karşılaştırma)
  static pw.Widget _buildStatisticsCards({
    required double ortalamaGunlukHarcama,
    required double degisimYuzdesi,
    required double gecenAyToplam,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Ortalama Günlük Harcama
        pw.Expanded(
          child: pw.Container(
            height: 65,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Günlük Ortalama',
                  style: pw.TextStyle(
                    font: turkishFont,
                    fontSize: 9,
                    color: PdfUtils.darkGrey,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      PdfUtils.formatCurrency(ortalamaGunlukHarcama),
                      style: pw.TextStyle(
                        font: turkishFontBold,
                        fontSize: 14,
                        color: PdfUtils.expenseColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        // Geçen Aya Kıyasla Değişim
        pw.Expanded(
          child: pw.Container(
            height: 65,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Geçen Aya Göre',
                  style: pw.TextStyle(
                    font: turkishFont,
                    fontSize: 9,
                    color: PdfUtils.darkGrey,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Text(
                      degisimYuzdesi >= 0 ? '+' : '',
                      style: pw.TextStyle(
                        font: turkishFontBold,
                        fontSize: 14,
                        color: degisimYuzdesi >= 0
                            ? PdfUtils.expenseColor
                            : PdfUtils.incomeColor,
                      ),
                    ),
                    pw.Text(
                      '%${degisimYuzdesi.toStringAsFixed(1)}',
                      style: pw.TextStyle(
                        font: turkishFontBold,
                        fontSize: 14,
                        color: degisimYuzdesi >= 0
                            ? PdfUtils.expenseColor
                            : PdfUtils.incomeColor,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    if (gecenAyToplam > 0)
                      pw.Text(
                        '(${PdfUtils.formatCurrency(gecenAyToplam)})',
                        style: pw.TextStyle(
                          font: turkishFont,
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// En Yüksek 5 Harcama
  static pw.Widget _buildTop5Expenses({
    required List<Map<String, dynamic>> top5Harcamalar,
    required pw.Font turkishFont,
    required pw.Font turkishFontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'En Yüksek 5 Harcama',
            style: pw.TextStyle(
              font: turkishFontBold,
              fontSize: 11,
              color: PdfUtils.darkGrey,
            ),
          ),
          pw.SizedBox(height: 10),
          ...top5Harcamalar.asMap().entries.map((entry) {
            final index = entry.key;
            final h = entry.value;
            final kategori = h['kategori'] as String? ?? 'Diğer';
            final tutar = (h['tutar'] as num).toDouble();
            final aciklama = h['aciklama'] as String? ?? '';
            final isim = h['isim'] as String? ?? '';
            final tarihStr = h['tarih'] as String? ?? '';

            // Harcama display ismi: önce name, sonra aciklama, en son kategori
            String displayName = '';
            if (isim.isNotEmpty) {
              displayName = isim;
            } else if (aciklama.isNotEmpty) {
              displayName = aciklama;
            }

            // Uzun isimleri kısalt
            if (displayName.length > 30) {
              displayName = '${displayName.substring(0, 27)}...';
            }

            // Tarihi format
            String formattedTarih = '';
            if (tarihStr.isNotEmpty) {
              try {
                final tarih = DateTime.parse(tarihStr);
                formattedTarih =
                    '${tarih.day.toString().padLeft(2, '0')}.${tarih.month.toString().padLeft(2, '0')}.${tarih.year}';
              } catch (_) {
                formattedTarih = tarihStr;
              }
            }

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                children: [
                  // Sıra numarası (beyaz yazı, kırmızı arka plan)
                  pw.Container(
                    width: 18,
                    height: 18,
                    decoration: pw.BoxDecoration(
                      color: PdfUtils.expenseColor,
                      borderRadius: pw.BorderRadius.circular(9),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${index + 1}',
                        style: pw.TextStyle(
                          font: turkishFontBold,
                          fontSize: 9,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  // Harcama ismi, kategori ve tarih
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Harcama ismi (varsa göster)
                        if (displayName.isNotEmpty)
                          pw.Text(
                            displayName,
                            style: pw.TextStyle(
                              font: turkishFontBold,
                              fontSize: 9,
                              color: PdfUtils.darkGrey,
                            ),
                          ),
                        // Kategori (her zaman göster - ikon ile)
                        pw.Text(
                          kategori,
                          style: pw.TextStyle(
                            font: displayName.isNotEmpty
                                ? turkishFont
                                : turkishFontBold,
                            fontSize: displayName.isNotEmpty ? 8 : 9,
                            color: displayName.isNotEmpty
                                ? PdfColors.grey600
                                : PdfUtils.darkGrey,
                          ),
                        ),
                        // Tarih
                        if (formattedTarih.isNotEmpty)
                          pw.Text(
                            formattedTarih,
                            style: pw.TextStyle(
                              font: turkishFont,
                              fontSize: 7,
                              color: PdfColors.grey500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Tutar
                  pw.Text(
                    PdfUtils.formatCurrency(tutar),
                    style: pw.TextStyle(
                      font: turkishFontBold,
                      fontSize: 10,
                      color: PdfUtils.expenseColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Kompakt özet öğesi (tek container içindeki 3 kart için)
  static pw.Widget _buildCompactSummaryItem({
    required String icon,
    required PdfColor iconColor,
    required String title,
    required String value,
    required PdfColor valueColor,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                icon,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 10,
                  color: iconColor,
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                  color: PdfUtils.darkGrey,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
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
            color: PdfUtils.darkGrey,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(font: fontBold, fontSize: 11, color: color),
        ),
      ],
    );
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
            color: PdfUtils.darkGrey,
          ),
        ),
      ],
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

  /// Cos yaklaşımı (Taylor serisi)
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

  /// Sin yaklaşımı (Taylor serisi)
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
}
