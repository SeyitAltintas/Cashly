import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class VoiceDictationOverlay extends StatelessWidget {
  final bool isListening;
  final VoidCallback onToggleListening;

  const VoiceDictationOverlay({
    super.key,
    required this.isListening,
    required this.onToggleListening,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha(240),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle (visual only)
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        isListening
                            ? context.l10n.listeningToYou
                            : context.l10n.micPaused,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isListening
                            ? context.l10n.tapWaveToPause
                            : context.l10n.tapToContinue,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Center Lottie Animation
                GestureDetector(
                  onTap: onToggleListening,
                  behavior: HitTestBehavior.opaque,
                  child: ClipRect(
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 2.5,
                        child: Lottie.asset(
                          'assets/lottie/wave.json',
                          fit: BoxFit.cover,
                          animate: isListening,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 160,
                              child: Center(
                                child: Icon(
                                  Icons.mic_rounded,
                                  size: 48,
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
