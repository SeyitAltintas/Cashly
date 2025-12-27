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

class _PdfExportPageState extends State<PdfExportPage> {
  // Switch durumları - varsayılan hepsi seçili
  bool _includeExpenses = true;
  bool _includeIncomes = true;
  bool _includeAssets = true;
  bool _includeVisualSummary = true; // Görsel özet varsayılan olarak açık
  bool _isExporting = false;

  bool get _hasSelection =>
      _includeExpenses || _includeIncomes || _includeAssets;

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

            // Görsel Özet bölümü - çerçeveli başlık
            _buildSectionHeader('Rapor Seçenekleri', theme),
            const SizedBox(height: 12),

            // Görsel özet switch'i
            _buildSwitchTile(
              title: 'Görsel Özet',
              subtitle: 'PDF\'in başına grafikli özet ekle',
              icon: Icons.pie_chart_outline_rounded,
              color: Colors.purple,
              value: _includeVisualSummary,
              onChanged: (value) {
                setState(() => _includeVisualSummary = value);
              },
            ),
            const SizedBox(height: 20),

            // Tablolar bölüm başlığı - çerçeveli
            _buildSectionHeader('Rapora Dahil Edilecek Tablolar', theme),
            const SizedBox(height: 12),

            // Switch listesi
            _buildSwitchTile(
              title: 'Harcamalarım',
              subtitle: 'Aylık harcama detayları',
              icon: Icons.shopping_cart_outlined,
              color: Colors.red,
              value: _includeExpenses,
              onChanged: (value) {
                setState(() => _includeExpenses = value);
              },
            ),
            const SizedBox(height: 8),

            _buildSwitchTile(
              title: 'Gelirlerim',
              subtitle: 'Aylık gelir detayları',
              icon: Icons.wallet_outlined,
              color: Colors.green,
              value: _includeIncomes,
              onChanged: (value) {
                setState(() => _includeIncomes = value);
              },
            ),
            const SizedBox(height: 8),

            _buildSwitchTile(
              title: 'Varlıklarım',
              subtitle: 'Varlık listesi ve değerleri',
              icon: Icons.account_balance_outlined,
              color: Colors.blue,
              value: _includeAssets,
              onChanged: (value) {
                setState(() => _includeAssets = value);
              },
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

  /// Çerçeveli bölüm başlığı oluşturur
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  /// Switch ile seçim kartı oluşturur - minimal tasarım
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            // İkon - küçük ve minimal
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: value ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // Başlık ve alt başlık
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      includeVisualSummary: _includeVisualSummary,
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
