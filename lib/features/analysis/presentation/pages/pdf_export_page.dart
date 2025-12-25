import 'package:flutter/material.dart';
import '../../../../services/export_service.dart';

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

/// Seçilebilecek tablo türleri
enum TableType { expenses, incomes, assets }

class _PdfExportPageState extends State<PdfExportPage> {
  // Sadece bir tablo seçilebilir - varsayılan olarak harcamalar seçili
  TableType? _selectedTable = TableType.expenses;
  bool _isExporting = false;

  bool get _hasSelection => _selectedTable != null;

  bool get _includeExpenses => _selectedTable == TableType.expenses;
  bool get _includeIncomes => _selectedTable == TableType.incomes;
  bool get _includeAssets => _selectedTable == TableType.assets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = _getMonthName(widget.selectedDate.month);
    final year = widget.selectedDate.year;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PDF Raporu',
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

            // Üst bilgi kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.15),
                    Colors.red.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$month $year Raporu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Raporunuza dahil edilecek bölümleri seçin',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bölüm başlığı
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Rapora Dahil Edilecek Tablolar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),

            // Switch listesi - sadece biri seçilebilir
            _buildSwitchTile(
              title: 'Harcamalarım',
              subtitle: 'Aylık harcama detayları',
              icon: Icons.shopping_cart_outlined,
              color: Colors.red,
              value: _includeExpenses,
              tableType: TableType.expenses,
            ),
            const SizedBox(height: 12),

            _buildSwitchTile(
              title: 'Gelirlerim',
              subtitle: 'Aylık gelir detayları',
              icon: Icons.wallet_outlined,
              color: Colors.green,
              value: _includeIncomes,
              tableType: TableType.incomes,
            ),
            const SizedBox(height: 12),

            _buildSwitchTile(
              title: 'Varlıklarım',
              subtitle: 'Varlık listesi ve değerleri',
              icon: Icons.account_balance_outlined,
              color: Colors.blue,
              value: _includeAssets,
              tableType: TableType.assets,
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
                        'En az bir tablo seçmelisiniz',
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
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Hazırlanıyor...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.share_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'PDF Oluştur ve Paylaş',
                            style: TextStyle(
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

  /// Switch tile: seçildiğinde diğer switch'ler kapanır
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required TableType tableType,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          // Zaten seçili ise kapat, değilse bu tabloyu seç
          if (_selectedTable == tableType) {
            _selectedTable = null;
          } else {
            _selectedTable = tableType;
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: value
                ? color.withValues(alpha: 0.5)
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: value ? color.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: value ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (newValue) {
                setState(() {
                  if (newValue) {
                    // Açılırsa bu tabloyu seç (diğerleri otomatik kapanır)
                    _selectedTable = tableType;
                  } else {
                    // Kapanırsa seçimi kaldır
                    _selectedTable = null;
                  }
                });
              },
              activeTrackColor: color.withValues(alpha: 0.5),
              activeThumbColor: color,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);

    // Ayın başı ve sonu
    final startDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
    final endDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + 1,
      0,
    );

    final result = await ExportService.exportToPdf(
      userId: widget.userId,
      userName: widget.userName,
      startDate: startDate,
      endDate: endDate,
      includeExpenses: _includeExpenses,
      includeIncomes: _includeIncomes,
      includeAssets: _includeAssets,
    );

    setState(() => _isExporting = false);

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
