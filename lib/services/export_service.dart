import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/di/injection_container.dart';
import '../features/expenses/domain/repositories/expense_repository.dart';
import '../features/income/domain/repositories/income_repository.dart';
import '../features/assets/domain/repositories/asset_repository.dart';

// PDF modülleri
import 'pdf_utils/pdf_utils.dart';
import 'pdf_builders/pdf_header_builder.dart';
import 'pdf_builders/pdf_table_builder.dart';
import 'pdf_builders/pdf_visual_summary_builder.dart';

// Publik erişim için export
export 'pdf_utils/pdf_utils.dart' show ExportResult, TableRowData, PdfUtils;

/// Rapor Export Servisi
/// Harcama ve gelir raporlarını PDF formatında dışa aktarır
/// Türkçe karakter desteği ile
class ExportService {
  ExportService._();

  /// PDF olarak rapor oluştur ve paylaş
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
      final turkishFont = await PdfUtils.loadTurkishFont();
      final turkishFontBold = await PdfUtils.loadTurkishFontBold();
      final logoBytes = await PdfUtils.loadBlackLogoImage();
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

      // Kullanıcının ayarladığı aylık bütçe limitini al
      final aylikButceLimiti = expenseRepo.getBudget(userId);

      // --- İçerik Zenginleştirme Hesaplamaları ---

      // 1. En Yüksek Harcamalar Top 5
      final sortedHarcamalar = List<Map<String, dynamic>>.from(tumHarcamalar)
        ..sort(
          (a, b) => ((b['tutar'] as num).toDouble()).compareTo(
            (a['tutar'] as num).toDouble(),
          ),
        );
      final top5Harcamalar = sortedHarcamalar.take(5).toList();

      // 2. Ortalama Günlük Harcama
      final gunSayisi = endDate.difference(startDate).inDays + 1;
      final ortalamaGunlukHarcama = gunSayisi > 0
          ? toplamHarcama / gunSayisi
          : 0.0;

      // 3. Geçen Aya Kıyasla Değişim
      final gecenAyBaslangic = DateTime(startDate.year, startDate.month - 1, 1);
      final gecenAyBitis = DateTime(
        startDate.year,
        startDate.month,
        0,
      ); // Geçen ayın son günü
      final gecenAyHarcamalar = _filterByDateRange(
        expenseRepo.getExpenses(userId),
        gecenAyBaslangic,
        gecenAyBitis,
      );
      final gecenAyToplam = gecenAyHarcamalar.fold<double>(
        0,
        (sum, h) => sum + (h['tutar'] as num).toDouble(),
      );
      final degisimYuzdesi = gecenAyToplam > 0
          ? ((toplamHarcama - gecenAyToplam) / gecenAyToplam * 100)
          : 0.0;

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
              child: pw.Container(color: PdfColor.fromHex('#F5F9FC')),
            ),
          ),
          footer: (context) =>
              PdfHeaderBuilder.buildFooter(context, turkishFont),
          build: (context) => [
            // Başlık bölümü - Logo ile
            PdfHeaderBuilder.buildHeader(
              font: turkishFont,
              fontBold: turkishFontBold,
              userName: userName,
              startDate: startDate,
              endDate: endDate,
              logoBytes: logoBytes,
            ),
            pw.SizedBox(height: 12),

            // TÜM VERİLER BOŞ İSE BİLGİ MESAJI GÖSTER
            if (tumHarcamalar.isEmpty &&
                tumGelirler.isEmpty &&
                tumVarliklar.isEmpty) ...[
              pw.SizedBox(height: 80),
              PdfHeaderBuilder.buildNoDataMessage(
                font: turkishFont,
                fontBold: turkishFontBold,
              ),
            ] else ...[
              // Görsel Özet bölümü (eğer seçiliyse)
              if (includeVisualSummary) ...[
                PdfVisualSummaryBuilder.buildVisualSummary(
                  toplamHarcama: toplamHarcama,
                  toplamGelir: toplamGelir,
                  toplamVarlik: toplamVarlik,
                  aylikButceLimiti: aylikButceLimiti,
                  top5Harcamalar: top5Harcamalar,
                  ortalamaGunlukHarcama: ortalamaGunlukHarcama,
                  gecenAyToplam: gecenAyToplam,
                  degisimYuzdesi: degisimYuzdesi,
                  turkishFont: turkishFont,
                  turkishFontBold: turkishFontBold,
                ),
              ],

              // Harcamalar tablosu - Yeni sayfada başlasın
              if (includeExpenses && harcamalar.isNotEmpty) ...[
                pw.NewPage(),
                ...PdfTableBuilder.buildTableSection(
                  title: 'Harcamalar',
                  headerColor: PdfUtils.expenseColor,
                  data: harcamalar.asMap().entries.map((entry) {
                    final h = entry.value;
                    final isEven = entry.key % 2 == 0;
                    return TableRowData(
                      cells: [
                        h['isim'] ?? '-',
                        h['kategori'] ?? '-',
                        PdfUtils.dateFormat.format(DateTime.parse(h['tarih'])),
                        PdfUtils.formatCurrency((h['tutar'] as num).toDouble()),
                      ],
                      backgroundColor: isEven
                          ? PdfUtils.expenseColorLight
                          : PdfColors.white,
                    );
                  }).toList(),
                  headers: ['İsim', 'Kategori', 'Tarih', 'Tutar'],
                  total: PdfUtils.formatCurrency(toplamHarcama),
                  totalColumnIndex: 3,
                  turkishFont: turkishFont,
                  turkishFontBold: turkishFontBold,
                ),
              ],

              // Gelirler tablosu - Yeni sayfada başlasın
              if (includeIncomes && gelirler.isNotEmpty) ...[
                pw.NewPage(),
                ...PdfTableBuilder.buildTableSection(
                  title: 'Gelirler',
                  headerColor: PdfUtils.incomeColor,
                  data: gelirler.asMap().entries.map((entry) {
                    final g = entry.value;
                    final isEven = entry.key % 2 == 0;
                    return TableRowData(
                      cells: [
                        g['name'] ?? '-',
                        g['category'] ?? '-',
                        PdfUtils.dateFormat.format(DateTime.parse(g['date'])),
                        PdfUtils.formatCurrency(
                          ((g['amount'] as num?) ?? 0).toDouble(),
                        ),
                      ],
                      backgroundColor: isEven
                          ? PdfUtils.incomeColorLight
                          : PdfColors.white,
                    );
                  }).toList(),
                  headers: ['İsim', 'Kategori', 'Tarih', 'Tutar'],
                  total: PdfUtils.formatCurrency(toplamGelir),
                  totalColumnIndex: 3,
                  turkishFont: turkishFont,
                  turkishFontBold: turkishFontBold,
                ),
              ],

              // Varlıklar tablosu - Yeni sayfada başlasın
              if (includeAssets && varliklar.isNotEmpty) ...[
                pw.NewPage(),
                ...PdfTableBuilder.buildTableSection(
                  title: 'Varlıklar',
                  headerColor: PdfUtils.assetColor,
                  data: varliklar.asMap().entries.map((entry) {
                    final v = entry.value;
                    final isEven = entry.key % 2 == 0;
                    return TableRowData(
                      cells: [
                        v['name'] ?? '-',
                        v['category'] ?? '-',
                        PdfUtils.formatCurrency(
                          ((v['amount'] as num?) ?? 0).toDouble(),
                        ),
                      ],
                      backgroundColor: isEven
                          ? PdfUtils.assetColorLight
                          : PdfColors.white,
                    );
                  }).toList(),
                  headers: ['İsim', 'Kategori', 'Değer'],
                  total: PdfUtils.formatCurrency(toplamVarlik),
                  totalColumnIndex: 2,
                  turkishFont: turkishFont,
                  turkishFontBold: turkishFontBold,
                ),
              ],
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
