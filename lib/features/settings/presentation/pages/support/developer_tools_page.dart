import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/services/mock_data_service.dart';
import 'package:cashly/core/services/cloud_sync_service.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cashly/features/streak/presentation/controllers/streak_controller.dart';
import 'package:cashly/features/streak/presentation/widgets/streak_celebration_dialog.dart';
import 'package:cashly/features/streak/presentation/widgets/streak_broken_dialog.dart';
import 'package:cashly/features/streak/data/constants/streak_badges.dart';
import 'error_logs_page.dart';

class DeveloperToolsPage extends StatefulWidget {
  const DeveloperToolsPage({super.key});

  @override
  State<DeveloperToolsPage> createState() => _DeveloperToolsPageState();
}

class _DeveloperToolsPageState extends State<DeveloperToolsPage> {
  bool _mockLoading = false;
  int _rankTestIndex = 0;

  Future<void> _generateMockData() async {
    final userId = getIt<AuthController>().currentUser?.id;
    if (userId == null) return;

    setState(() => _mockLoading = true);
    try {
      await MockDataService().generateMockData(userId);
      await CloudSyncService.syncAllUserData(userId);
      
      // Sayfa kapansa bile global state güncellensin ki Profil sayfası vb. anında tepki versin
      getIt<StreakController>().loadStreakData(userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Sahte veriler oluşturuldu!'),
            backgroundColor: ColorConstants.yesil,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: ColorConstants.kirmiziVurgu,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _mockLoading = false);
    }
  }

  Future<void> _clearMockData() async {
    final userId = getIt<AuthController>().currentUser?.id;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mock Verileri Temizle'),
        content: const Text('Sahte veriler silinecek. Gerçek verileriniz korunur.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sil',
              style: TextStyle(color: ColorConstants.kirmiziVurgu),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _mockLoading = true);
    try {
      await MockDataService().clearMockData(userId);
      await CloudSyncService.syncAllUserData(userId);
      
      getIt<StreakController>().refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Sahte veriler temizlendi!'),
            backgroundColor: ColorConstants.yesil,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: ColorConstants.kirmiziVurgu,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _mockLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geliştirici Araçları'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error Logs Section
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ErrorLogsPage()),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bug_report_outlined, color: ColorConstants.kirmiziVurgu),
                ),
                title: const Text('Sistem Hata Kayıtları'),
                subtitle: const Text('Geliştirici için hata kayıtlarını görüntüleyin'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mock Data Section
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.deepPurple.withValues(alpha: 0.25),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: Colors.deepPurple,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sahte Veri Yönetimi',
                        style: TextStyle(
                          color: ColorConstants.morVurgu,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Test amaçlı rastgele işlem, gelir ve varlık verisi oluşturun veya temizleyin.',
                    style: TextStyle(
                      color: Colors.deepPurple.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_mockLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _generateMockData,
                            icon: const Icon(Icons.data_object, size: 18),
                            label: const Text('Sahte Veri Üret'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorConstants.morVurgu,
                              side: BorderSide(
                                color: ColorConstants.morVurgu.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _clearMockData,
                          icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                          label: const Text('Temizle'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorConstants.kirmiziVurgu,
                            side: BorderSide(
                              color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pop-up Test Section
            Container(
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.25),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.animation,
                        color: Colors.orange,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Pop-up Ekran Testleri',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seri kutlama ve kırılma ekranlarını test edin.',
                    style: TextStyle(
                      color: Colors.orange.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          final tier = RankTiers.allTiers[_rankTestIndex];
                          StreakCelebrationDialog.showRankUp(
                            context,
                            tier.requiredXp ~/ 10, // örnek streak sayısı
                            tier,
                          );
                          setState(() {
                            _rankTestIndex = (_rankTestIndex + 1) % RankTiers.allTiers.length;
                          });
                        },
                        icon: const Icon(Icons.star, size: 18),
                        label: const Text('Rütbe Atlama Testi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(
                            color: Colors.orange.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          StreakCelebrationDialog.show(context, 15);
                        },
                        icon: const Icon(Icons.local_fire_department, size: 18),
                        label: const Text('Seri Devam Testi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(
                            color: Colors.orange.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          StreakBrokenDialog.show(context, 15);
                        },
                        icon: const Icon(Icons.heart_broken, size: 18),
                        label: const Text('Kırılma Testi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorConstants.kirmiziVurgu,
                          side: BorderSide(
                            color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
