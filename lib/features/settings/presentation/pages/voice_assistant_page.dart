import 'package:flutter/material.dart';
import '../../../../services/database_helper.dart';
import '../../../../services/tts_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'voice_commands_page.dart';

/// Sesli Asistan ayarları sayfası
class VoiceAssistantPage extends StatefulWidget {
  final AuthController authController;

  const VoiceAssistantPage({super.key, required this.authController});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  final TtsService _ttsService = TtsService();
  bool _sesliGeriBildirimAktif = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ayarlariYukle();
  }

  void _ayarlariYukle() {
    final userId = widget.authController.currentUser?.id;
    if (userId != null) {
      setState(() {
        _sesliGeriBildirimAktif = DatabaseHelper.sesliGeriBildirimAktifMi(
          userId,
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _ayariDegistir(bool yeniDeger) async {
    final userId = widget.authController.currentUser?.id;
    if (userId != null) {
      await DatabaseHelper.sesliGeriBildirimKaydet(userId, yeniDeger);
      setState(() {
        _sesliGeriBildirimAktif = yeniDeger;
      });

      // Açıldığında test sesi çal
      if (yeniDeger) {
        await _ttsService.testSesiCal();
      }
    }
  }

  Future<void> _onizlemeYap() async {
    await _ttsService.initialize();
    await _ttsService.harcamaEklendiBildirimi(
      tutar: 1000,
      harcamaIsmi: 'protein tozu',
      kategori: 'Spor',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli Asistan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Açıklama kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.record_voice_over,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sesli Geri Bildirim',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sesli harcama girişi yaptığınızda, eklenen harcama için sesli onay alırsınız.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sesli geri bildirim ayarı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _sesliGeriBildirimAktif
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: _sesliGeriBildirimAktif
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sesli Geri Bildirim',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _sesliGeriBildirimAktif ? 'Açık' : 'Kapalı',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _sesliGeriBildirimAktif,
                          onChanged: _ayariDegistir,
                          activeTrackColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.5),
                          activeThumbColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Önizleme butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _sesliGeriBildirimAktif ? _onizlemeYap : null,
                      icon: Icon(
                        Icons.play_arrow,
                        color: _sesliGeriBildirimAktif
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      label: Text(
                        'Önizleme: "1000 lira protein tozu Spor kategorisine eklendi"',
                        style: TextStyle(
                          color: _sesliGeriBildirimAktif
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: _sesliGeriBildirimAktif
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bilgi notu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sesli geri bildirim, yalnızca sesli harcama girişi modunda çalışır.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tüm Komutları Görüntüle butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoiceCommandsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt, color: Colors.white),
                      label: const Text(
                        'Tüm Sesli Komutları Görüntüle',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
