import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

/// Tema renklerine kolay erişim için extension metodları
/// Tekrarlayan tema rengi çağrılarını sadeleştirir
extension ThemeExtensions on BuildContext {
  /// Tema verisi
  ThemeData get theme => Theme.of(this);

  /// Renk şeması
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Ana yüzey rengi
  Color get surface => colorScheme.surface;

  /// Yüzey üzerindeki metin rengi
  Color get onSurface => colorScheme.onSurface;

  /// İkincil metin rengi (alpha: 0.6)
  Color get textSecondary => colorScheme.onSurface.withValues(alpha: 0.6);

  /// Üçüncül metin rengi (alpha: 0.4)
  Color get textTertiary => colorScheme.onSurface.withValues(alpha: 0.4);

  /// Devre dışı metin rengi (alpha: 0.38)
  Color get textDisabled => colorScheme.onSurface.withValues(alpha: 0.38);

  /// Yarı saydam yüzey (alpha: 0.5)
  Color get surfaceVariant => colorScheme.surface.withValues(alpha: 0.5);

  /// Yarı saydam yüzey (alpha: 0.3)
  Color get surfaceLight => colorScheme.surface.withValues(alpha: 0.3);

  /// İkincil renk
  Color get secondary => colorScheme.secondary;

  /// Birincil renk
  Color get primary => colorScheme.primary;

  /// Hata rengi
  Color get error => colorScheme.error;
}

/// Sayı formatlama extension'ı
extension NumberFormatExtension on double {
  /// Türk Lirası formatında string (50.000,00 ₺)
  String get asTL => CurrencyFormatter.format(this);

  /// Binlik ayırıcılı format (50.000,00)
  String get formatted => CurrencyFormatter.formatWithoutSymbol(this);

  /// Binlik ayırıcılı TL formatı (50.000,00 ₺)
  String get formattedTL => CurrencyFormatter.format(this);

  /// İşaretli format (+50.000,00 ₺ veya -50.000,00 ₺)
  String asTLSigned({bool showPlus = false}) =>
      CurrencyFormatter.formatSigned(this, showPlus: showPlus);
}

/// DateTime extension'ları
extension DateTimeExtension on DateTime {
  /// Ay adı (Türkçe)
  String get monthNameTR {
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

  /// Kısa format: "19 Ara"
  String get shortFormat => '$day ${monthNameTR.substring(0, 3)}';

  /// Uzun format: "19 Aralık 2024"
  String get longFormat => '$day $monthNameTR $year';
}
