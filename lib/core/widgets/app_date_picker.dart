import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan merkezi tarih seçici
/// Tüm tarih seçme işlemleri bu fonksiyon üzerinden yapılmalıdır
class AppDatePicker {
  /// Tarih seçici dialogunu açar
  /// [context] - BuildContext
  /// [initialDate] - Başlangıç tarihi (varsayılan: bugün)
  /// [firstDate] - Seçilebilecek en erken tarih (varsayılan: 2020)
  /// [lastDate] - Seçilebilecek en geç tarih (varsayılan: 2030)
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2030),
      locale: const Locale('tr', 'TR'),
    );
  }
}
