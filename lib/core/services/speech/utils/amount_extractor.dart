import 'package:flutter/foundation.dart';

/// Metinden tutar çıkaran yardımcı sınıf
/// Türkçe sayı formatlarını destekler: "100 lira", "on bin tl", "1,5 milyon" vb.
class AmountExtractor {
  /// Metinden tutarı çıkar
  /// Farklı sayı formatlarını destekler:
  /// - Rakamlarla: "100 lira", "100,50 tl", "10.000 lira"
  /// - Yazıyla: "yüz lira", "on bin lira", "beş milyon"
  /// - Karışık: "150 bin tl", "2 milyon lira"
  static double? extractAmount(String text) {
    debugPrint('AmountExtractor.extractAmount çağrıldı: "$text"');

    // Önce çarpanları kontrol et
    double carpan = 1;
    bool binVar = text.contains('bin');
    bool milyonVar = text.contains('milyon');

    if (milyonVar) {
      carpan = 1000000;
    } else if (binVar) {
      carpan = 1000;
    }

    debugPrint('Çarpan: $carpan (bin: $binVar, milyon: $milyonVar)');

    // Çarpan varsa (bin veya milyon)
    if (carpan > 1) {
      // 1. Önce rakam ile bin/milyon kontrolü: "10 bin", "150 bin", "1,5 milyon"
      RegExp rakamCarpanRegex = RegExp(
        r'(\d+[.,]?\d*)\s*(bin|milyon)',
        caseSensitive: false,
      );
      Match? rakamMatch = rakamCarpanRegex.firstMatch(text);
      if (rakamMatch != null) {
        String amountStr = rakamMatch.group(1)!.replaceAll(',', '.');
        double? baseAmount = double.tryParse(amountStr);
        if (baseAmount != null) {
          debugPrint(
            'Rakam+çarpan bulundu: $baseAmount * $carpan = ${baseAmount * carpan}',
          );
          return baseAmount * carpan;
        }
      }

      // 2. Yazılı onluklar ile bin/milyon: "on bin", "yirmi bin", "elli milyon"
      final result = _extractWrittenNumberWithMultiplier(text, carpan);
      if (result != null) return result;

      // 3. Sadece "bin" veya "milyon" varsa = 1000 veya 1000000
      debugPrint('Sadece çarpan: $carpan');
      return carpan;
    }

    // Çarpan yoksa basit rakamları dene
    return _extractSimpleAmount(text);
  }

  /// Yazılı sayıları çarpanla birlikte çıkar
  static double? _extractWrittenNumberWithMultiplier(
    String text,
    double carpan,
  ) {
    // Sıralı liste kullan (Map sırası garanti değil)
    List<MapEntry<String, double>> onluklar = [
      const MapEntry('doksan', 90),
      const MapEntry('seksen', 80),
      const MapEntry('yetmiş', 70),
      const MapEntry('altmış', 60),
      const MapEntry('elli', 50),
      const MapEntry('kırk', 40),
      const MapEntry('otuz', 30),
      const MapEntry('yirmi', 20),
      const MapEntry('on', 10),
    ];

    List<MapEntry<String, double>> birlikler = [
      const MapEntry('dokuz', 9),
      const MapEntry('sekiz', 8),
      const MapEntry('yedi', 7),
      const MapEntry('altı', 6),
      const MapEntry('beş', 5),
      const MapEntry('dört', 4),
      const MapEntry('üç', 3),
      const MapEntry('iki', 2),
      const MapEntry('bir', 1),
    ];

    // 2a. Bileşik sayılar: "on beş bin", "yirmi üç milyon"
    for (var onluk in onluklar) {
      for (var birlik in birlikler) {
        String pattern1 = '${onluk.key} ${birlik.key} bin';
        String pattern2 = '${onluk.key} ${birlik.key} milyon';
        String pattern3 = '${onluk.key}${birlik.key} bin';
        String pattern4 = '${onluk.key}${birlik.key} milyon';

        if (text.contains(pattern1) ||
            text.contains(pattern2) ||
            text.contains(pattern3) ||
            text.contains(pattern4)) {
          double toplam = onluk.value + birlik.value;
          debugPrint(
            'Bileşik sayı bulundu: ${onluk.key} ${birlik.key} = $toplam * $carpan',
          );
          return toplam * carpan;
        }
      }
    }

    // 2b. Sadece onluklar: "on bin", "yirmi milyon"
    for (var onluk in onluklar) {
      if (text.contains('${onluk.key} bin') ||
          text.contains('${onluk.key}bin') ||
          text.contains('${onluk.key} milyon') ||
          text.contains('${onluk.key}milyon')) {
        debugPrint(
          'Onluk+çarpan bulundu: ${onluk.key} = ${onluk.value} * $carpan',
        );
        return onluk.value * carpan;
      }
    }

    // 2c. Sadece birlikler: "beş bin", "üç milyon"
    for (var birlik in birlikler) {
      if (text.contains('${birlik.key} bin') ||
          text.contains('${birlik.key}bin') ||
          text.contains('${birlik.key} milyon') ||
          text.contains('${birlik.key}milyon')) {
        debugPrint(
          'Birlik+çarpan bulundu: ${birlik.key} = ${birlik.value} * $carpan',
        );
        return birlik.value * carpan;
      }
    }

    // 2d. Yüz ile: "yüz bin", "iki yüz bin"
    if (text.contains('yüz')) {
      // "iki yüz bin" = 200,000
      for (var birlik in birlikler) {
        if (text.contains('${birlik.key} yüz')) {
          debugPrint('Birlik+yüz+çarpan: ${birlik.value} * 100 * $carpan');
          return birlik.value * 100 * carpan;
        }
      }
      // Sadece "yüz bin" = 100,000
      debugPrint('Yüz+çarpan: 100 * $carpan');
      return 100 * carpan;
    }

    return null;
  }

  /// Basit sayı formatlarını çıkar
  static double? _extractSimpleAmount(String text) {
    // Türkçe binlik formatını destekle: 10.000 = 10000, 5.000 = 5000
    // Önce Türkçe binlik formatını kontrol et (X.XXX veya X.XXX.XXX)
    RegExp turkishThousandRegex = RegExp(
      r'(\d{1,3}(?:\.\d{3})+)\s*(lira|tl|₺)?',
      caseSensitive: false,
    );
    Match? turkishMatch = turkishThousandRegex.firstMatch(text);
    if (turkishMatch != null) {
      // Noktaları kaldır (binlik ayıracı)
      String amountStr = turkishMatch.group(1)!.replaceAll('.', '');
      double? result = double.tryParse(amountStr);
      debugPrint(
        'Türkçe binlik format bulundu: ${turkishMatch.group(1)} → $result',
      );
      return result;
    }

    // Normal rakam formatı
    RegExp amountRegex = RegExp(
      r'(\d+[,]?\d*)\s*(lira|tl|₺)?',
      caseSensitive: false,
    );
    Match? match = amountRegex.firstMatch(text);

    if (match != null) {
      String amountStr = match.group(1)!.replaceAll(',', '.');
      double? result = double.tryParse(amountStr);
      debugPrint('Basit rakam bulundu: $result');
      return result;
    }

    // Yazıyla yazılmış basit sayılar (çarpan olmadan)
    Map<String, double> yaziSayilar = {
      'yüz': 100,
      'doksan': 90,
      'seksen': 80,
      'yetmiş': 70,
      'altmış': 60,
      'elli': 50,
      'kırk': 40,
      'otuz': 30,
      'yirmi': 20,
      'on': 10,
      'dokuz': 9,
      'sekiz': 8,
      'yedi': 7,
      'altı': 6,
      'beş': 5,
      'dört': 4,
      'üç': 3,
      'iki': 2,
      'bir': 1,
      'yarım': 0.5,
      'buçuk': 0.5,
    };

    for (var entry in yaziSayilar.entries) {
      if (text.contains(entry.key)) {
        debugPrint('Yazılı sayı bulundu: ${entry.key} = ${entry.value}');
        return entry.value;
      }
    }

    debugPrint('Tutar bulunamadı');
    return null;
  }
}
