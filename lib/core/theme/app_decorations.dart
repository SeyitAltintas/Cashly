import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan ortak dekorasyon stilleri
/// Tekrarlayan BoxDecoration pattern'lerini birleştirir
class AppDecorations {
  AppDecorations._();

  /// Standart kart dekorasyonu
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Gradient kart dekorasyonu
  static BoxDecoration gradientCard({
    required Color primaryColor,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.3),
          primaryColor.withValues(alpha: 0.15),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
    );
  }

  /// Basit yüzey dekorasyonu
  static BoxDecoration surfaceDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Segment/Tab bar container dekorasyonu
  static BoxDecoration segmentDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        width: 1.5,
      ),
    );
  }

  /// Bottom navigation dekorasyonu
  static BoxDecoration bottomNavDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  /// İkon container dekorasyonu
  static BoxDecoration iconContainer(Color color, {double radius = 12}) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// Uygulama genelinde kullanılan sabit değerler
class AppConstants {
  AppConstants._();

  // Padding değerleri
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  // Border radius değerleri
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusRound = 25.0;

  // İkon boyutları
  static const double iconS = 18.0;
  static const double iconM = 22.0;
  static const double iconL = 28.0;

  // Animasyon süreleri
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
}
