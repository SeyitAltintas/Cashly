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
                  // Başlık
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sesli Asistan",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sesli komut ve geri bildirim ayarlarını yönetin",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.54),
                            fontSize: 14,
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
                              ? Theme.of(context).colorScheme.secondary
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
                          ).colorScheme.secondary.withValues(alpha: 0.5),
                          activeThumbColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
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
                      icon: const Icon(Icons.list_alt, color: Colors.black),
                      label: const Text(
                        'Tüm Sesli Komutları Görüntüle',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
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
