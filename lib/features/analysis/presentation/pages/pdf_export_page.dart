import 'package:flutter/material.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../state/pdf_export_state.dart';

/// PDF Rapor Hazırlama Sayfası
/// Kullanıcı hangi tabloların PDF'e ekleneceğini seçebilir
class PdfExportPage extends StatefulWidget {
  final String userId;
  final String userName;
  final DateTime selectedDate;

  const PdfExportPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.selectedDate,
  });

  @override
  State<PdfExportPage> createState() => _PdfExportPageState();
}

class _PdfExportPageState extends State<PdfExportPage> {
  late final PdfExportState _pdfState;

  DateTime get _selectedDate => _pdfState.selectedDate;
  bool get _includeExpenses => _pdfState.includeExpenses;
  bool get _includeIncomes => _pdfState.includeIncomes;
  bool get _includeAssets => _pdfState.includeAssets;
  bool get _isExporting => _pdfState.isExporting;
  bool get _includeFinansalOzet => _pdfState.includeFinansalOzet;
  bool get _includeNetDurum => _pdfState.includeNetDurum;
  bool get _includePastaGrafik => _pdfState.includePastaGrafik;
  bool get _includeButceDurumu => _pdfState.includeButceDurumu;
  bool get _includeIstatistikler => _pdfState.includeIstatistikler;
  bool get _includeTop5Harcama => _pdfState.includeTop5Harcama;

  @override
  void initState() {
    super.initState();
    _pdfState = PdfExportState();
    _pdfState.initWithDate(widget.selectedDate);
    _pdfState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pdfState.removeListener(_onStateChanged);
    _pdfState.dispose();
    super.dispose();
  }

  bool get _hasSelection => _pdfState.hasSelection;
  bool get _allVisualOptionsSelected => _pdfState.allVisualOptionsSelected;
  bool get _hasAnyVisualOption => _pdfState.hasAnyVisualOption;

  void _toggleAllVisualOptions(bool value) {
    _pdfState.toggleAllVisualOptions(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = context.getShortMonthName(_selectedDate.month);
    final year = _selectedDate.year;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.pdfReportTitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Üst bilgi kartı - tarih seçici ile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.15),
                    Colors.red.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 24,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.pdfReportTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          context.l10n.selectSectionsToInclude,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tarih Seçici Kartı
            InkWell(
              onTap: () async {
                final newDate = await MonthYearPicker.show(
                  context,
                  initialDate: _selectedDate,
                  accentColor: Colors.red,
                );
                if (newDate != null) {
                  _pdfState.selectedDate = newDate;
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 22,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.reportPeriod,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$month $year',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rapor Seçenekleri - görsel özet alt seçenekleri
            _buildFieldsetSection(
              title: context.l10n.reportOptions,
              theme: theme,
              child: Column(
                children: [
                  // Hepsi checkbox
                  _buildCheckboxTile(
                    title: context.l10n.selectAll,
                    subtitle: context.l10n.includeAllVisualSummaries,
                    icon: Icons.select_all,
                    color: Colors.purple,
                    value: _allVisualOptionsSelected,
                    isTristate:
                        !_allVisualOptionsSelected && _hasAnyVisualOption,
                    onChanged: (value) =>
                        _toggleAllVisualOptions(value ?? true),
                  ),
                  Divider(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    height: 16,
                  ),
                  // 1. Finansal Özet Kartları
                  _buildCheckboxTile(
                    title: context.l10n.financialSummaryCards,
                    subtitle: context.l10n.expenseIncomeAssetTotals,
                    icon: Icons.dashboard_outlined,
                    color: Colors.orange,
                    value: _includeFinansalOzet,
                    onChanged: (value) =>
                        _pdfState.includeFinansalOzet = value ?? false,
                  ),
                  // 2. Net Durum Kartları
                  _buildCheckboxTile(
                    title: context.l10n.netStatusCards,
                    subtitle: context.l10n.monthlyNetStatusAndSavings,
                    icon: Icons.balance,
                    color: Colors.teal,
                    value: _includeNetDurum,
                    onChanged: (value) =>
                        _pdfState.includeNetDurum = value ?? false,
                  ),
                  // 3. Pasta Grafiği ve Dağılım
                  _buildCheckboxTile(
                    title: context.l10n.pieChartAndDistribution,
                    subtitle: context.l10n.expenseIncomeAssetDistribution,
                    icon: Icons.pie_chart_outline,
                    color: Colors.indigo,
                    value: _includePastaGrafik,
                    onChanged: (value) =>
                        _pdfState.includePastaGrafik = value ?? false,
                  ),
                  // 4. Bütçe Durumu
                  _buildCheckboxTile(
                    title: context.l10n.budgetStatusTitle,
                    subtitle: context.l10n.budgetProgressBarAndLimit,
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                    value: _includeButceDurumu,
                    onChanged: (value) =>
                        _pdfState.includeButceDurumu = value ?? false,
                  ),
                  // 5. İstatistik Kartları
                  _buildCheckboxTile(
                    title: context.l10n.statisticsCards,
                    subtitle:
                        context.l10n.dailyAverageAndPreviousMonthComparison,
                    icon: Icons.analytics_outlined,
                    color: Colors.blue,
                    value: _includeIstatistikler,
                    onChanged: (value) =>
                        _pdfState.includeIstatistikler = value ?? false,
                  ),
                  // 6. En Yüksek 5 Harcama
                  _buildCheckboxTile(
                    title: context.l10n.top5Expenses,
                    subtitle: context.l10n.top5ExpensesListDescription,
                    icon: Icons.leaderboard_outlined,
                    color: Colors.red,
                    value: _includeTop5Harcama,
                    onChanged: (value) =>
                        _pdfState.includeTop5Harcama = value ?? false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tablolar bölümü - fieldset tarzı çerçeveli section
            _buildFieldsetSection(
              title: context.l10n.tablesToIncludeInReport,
              theme: theme,
              child: Column(
                children: [
                  _buildCheckboxTile(
                    title: context.l10n.myExpensesTitle,
                    subtitle: context.l10n.monthlyExpenseDetails,
                    icon: Icons.shopping_cart_outlined,
                    color: Colors.red,
                    value: _includeExpenses,
                    onChanged: (value) =>
                        _pdfState.includeExpenses = value ?? false,
                  ),
                  _buildCheckboxTile(
                    title: context.l10n.myIncomesTitle,
                    subtitle: context.l10n.monthlyIncomeDetails,
                    icon: Icons.wallet_outlined,
                    color: Colors.green,
                    value: _includeIncomes,
                    onChanged: (value) =>
                        _pdfState.includeIncomes = value ?? false,
                  ),
                  _buildCheckboxTile(
                    title: context.l10n.myAssets,
                    subtitle: context.l10n.assetListAndValues,
                    icon: Icons.account_balance_outlined,
                    color: Colors.blue,
                    value: _includeAssets,
                    onChanged: (value) =>
                        _pdfState.includeAssets = value ?? false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Uyarı - en az bir seçim yapılmalı
            if (!_hasSelection)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.selectAtLeastOneTable,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // PDF Oluştur butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _hasSelection && !_isExporting
                    ? _exportPdf
                    : (_isExporting ? () {} : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasSelection
                      ? Colors.red.shade700
                      : Colors.grey.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                  disabledForegroundColor: Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isExporting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.l10n.preparing,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.share_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            context.l10n.createAndSharePdf,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Fieldset tarzı çerçeveli section oluşturur
  /// Başlık çerçevenin üst kenarının ortasından geçer (HTML fieldset/legend gibi)
  Widget _buildFieldsetSection({
    required String title,
    required ThemeData theme,
    required Widget child,
  }) {
    return Stack(
      children: [
        // Çerçeve - üstten padding bırakarak başlık için yer aç
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
        // Başlık - çerçevenin üst kenarının ortasında
        Positioned(
          left: 16,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: theme.colorScheme.surface,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Checkbox ile seçim kartı oluşturur - minimal tasarım
  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isTristate = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isTristate ? null : value,
                tristate: isTristate,
                onChanged: onChanged,
                activeColor: color,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 12),
            // İkon - küçük ve minimal
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: value ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            // Başlık ve alt başlık
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    _pdfState.isExporting = true;

    // Ayın başı ve sonu
    final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    final result = await ExportService.exportToPdf(
      userId: widget.userId,
      userName: widget.userName,
      startDate: startDate,
      endDate: endDate,
      includeExpenses: _includeExpenses,
      includeIncomes: _includeIncomes,
      includeAssets: _includeAssets,
      // Görsel özet alt seçenekleri
      includeFinansalOzet: _includeFinansalOzet,
      includeNetDurum: _includeNetDurum,
      includePastaGrafik: _includePastaGrafik,
      includeButceDurumu: _includeButceDurumu,
      includeIstatistikler: _includeIstatistikler,
      includeTop5Harcama: _includeTop5Harcama,
    );

    _pdfState.isExporting = false;

    if (result.success && result.filePath != null) {
      // Paylaşım menüsünü aç
      await ExportService.shareFile(result.filePath!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    }
  }
}
