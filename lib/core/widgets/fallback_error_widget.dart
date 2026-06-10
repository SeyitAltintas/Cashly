import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// UI Hata Sınırları (Error Boundaries)
/// Bileşenler (listeler, grafikler, veya asenkron widgetlar) çöktüğünde
/// bütün ekranı beyaz bırakmak veya kırmızı ölüm ekranı göstermek yerine
/// o bölgeye bu zarif Fallback widget konur.
class FallbackErrorWidget extends StatefulWidget {
  final FlutterErrorDetails? details;
  final VoidCallback? onRetry;

  const FallbackErrorWidget({super.key, this.details, this.onRetry});

  @override
  State<FallbackErrorWidget> createState() => _FallbackErrorWidgetState();
}

class _FallbackErrorWidgetState extends State<FallbackErrorWidget> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sade, modern, pastel renkler
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;
    final subTextColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    return Material(
      color: Colors.transparent,
      child:
          Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minimalist İkon
                      Icon(
                            Icons.error_outline_rounded,
                            color: iconColor,
                            size: 32,
                          )
                          .animate()
                          .fade(duration: 400.ms)
                          .scaleXY(begin: 0.9, end: 1.0),

                      const SizedBox(height: 16),

                      // Başlık
                      Text(
                        'Beklenmeyen Bir Durum',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Alt Metin
                      Text(
                        'Bu içerik şu an yüklenemedi.\nUygulamanın geri kalanı çalışmaya devam ediyor.',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Aksiyon Butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.onRetry != null) ...[
                            FilledButton.tonalIcon(
                              onPressed: widget.onRetry,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text(
                                'Tekrar Dene',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (widget.details != null)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showDetails = !_showDetails;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: subTextColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                _showDetails
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Detaylar',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                        ],
                      ),

                      // Teknik Detaylar (Genişletilebilir)
                      if (_showDetails && widget.details != null) ...[
                        const SizedBox(height: 16),
                        Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.26)
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SelectableText(
                                widget.details!.exceptionAsString(),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            )
                            .animate()
                            .fade(duration: 200.ms)
                            .slideY(begin: -0.05, end: 0),
                      ],
                    ],
                  ),
                ),
              )
              .animate()
              .fade(duration: 400.ms)
              .scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutBack),
    );
  }
}
