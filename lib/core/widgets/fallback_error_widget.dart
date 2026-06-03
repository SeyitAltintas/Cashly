import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// UI Hata Sınırları (Error Boundaries)
/// Bileşenler (listeler, grafikler, veya asenkron widgetlar) çöktüğünde
/// bütün ekranı beyaz bırakmak veya kırmızı ölüm ekranı göstermek yerine 
/// o bölgeye bu zarif Fallback widget konur.
class FallbackErrorWidget extends StatefulWidget {
  final FlutterErrorDetails? details;
  final VoidCallback? onRetry;

  const FallbackErrorWidget({
    super.key,
    this.details,
    this.onRetry,
  });

  @override
  State<FallbackErrorWidget> createState() => _FallbackErrorWidgetState();
}

class _FallbackErrorWidgetState extends State<FallbackErrorWidget> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Glassmorphism stili için renkler
    final bgColor = isDark 
        ? Colors.red.withValues(alpha: 0.1) 
        : Colors.red.withValues(alpha: 0.05);
    final borderColor = Colors.red.withValues(alpha: 0.2);
    final iconBgColor = Colors.red.withValues(alpha: 0.2);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Uyarı İkonu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.redAccent,
                  size: 36,
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds, curve: Curves.easeInOut),
              
              const SizedBox(height: 16),
              
              // Başlık
              Text(
                'Bir Sorun Oluştu',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Alt Metin
              Text(
                'Bu içerik şu an yüklenemiyor.\nUygulama çalışmaya devam ediyor.',
                style: TextStyle(
                  color: subTextColor, 
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),

              // Aksiyon Butonları (Tekrar Dene & Detaylar)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.onRetry != null) ...[
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Tekrar Dene', style: TextStyle(fontWeight: FontWeight.w600)),
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
                        foregroundColor: isDark ? Colors.red.shade300 : Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      icon: Icon(
                        _showDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 18,
                      ),
                      label: const Text('Detaylar', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.details!.exceptionAsString(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                      ),
                    ),
                  ),
                ).animate().fade(duration: 300.ms).slideY(begin: -0.1, end: 0),
              ],
            ],
          ),
        ),
      ).animate().fade(duration: 400.ms).scaleXY(begin: 0.95, end: 1.0, curve: Curves.easeOutBack),
    );
  }
}
