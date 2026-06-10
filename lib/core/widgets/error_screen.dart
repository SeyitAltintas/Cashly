import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Beklenmedik fatal hata durumlarında gösterilecek error ekranı
class ErrorScreen extends StatefulWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.errorDetails,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    // Sadece Dark Mode tasarımı baz alınabilir çünkü Fatal Error Screen
    // genellikle karanlık bir background ile daha az göz yorar ve profesyonel durur.
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // Koyu ve Premium arka plan
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hata ikonu & Animasyonu
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scaleXY(
                            begin: 1.0,
                            end: 1.15,
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emergency_outlined,
                          color: Colors.redAccent,
                          size: 56,
                        ),
                      ).animate().shake(
                        hz: 3,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Başlık
                  Text(
                    widget.errorMessage != null &&
                            widget.errorMessage!.contains('başlatılamadı')
                        ? 'Uygulama Başlatılamadı'
                        : context.l10n.errorOccurred,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Alt mesaj
                  Text(
                    widget.errorMessage ?? context.l10n.unexpectedErrorRestart,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),

                  // Tekrar dene butonu
                  if (widget.onRetry != null)
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: widget.onRetry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              context.l10n.retry,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fade(delay: 600.ms)
                        .scaleXY(
                          begin: 0.9,
                          end: 1.0,
                          curve: Curves.easeOutBack,
                        ),

                  // Debug bilgisi (Genişletilebilir)
                  if (widget.errorDetails != null) ...[
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () => setState(() => _showDetails = !_showDetails),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showDetails
                                  ? Icons.code_off_rounded
                                  : Icons.code_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.technicalDetails,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showDetails
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 800.ms),

                    if (_showDetails) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          widget.errorDetails!.exceptionAsString(),
                          style: TextStyle(
                            color: Colors.redAccent.shade100,
                            fontSize: 12,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                      ).animate().fade().slideY(begin: -0.1, end: 0),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
