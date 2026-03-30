import 'package:flutter/material.dart';

/// UI Hata Sınırları (Error Boundaries)
/// Özellikle fl_chart gibi karmaşık widgetlar liste içinde vs. çökerse 
/// bütün ekranı beyaz bırakmak yerine o bölgeye bu Fallback widget konur.
class FallbackErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? details;

  const FallbackErrorWidget({super.key, this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
              SizedBox(height: 8),
              Text(
                'Bir sorun oluştu.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'Bu bileşen şu an yüklenemiyor, uygulama çalışmaya devam ediyor.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
