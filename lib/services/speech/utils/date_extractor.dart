/// Metinden tarih ifadelerini çıkaran yardımcı sınıf
class DateExtractor {
  /// Metinden tarih ifadesi çıkar
  /// "dün", "önceki gün", "geçen pazartesi" gibi ifadeleri algılar
  /// Tarih bulunamazsa null döner
  static DateTime? extractDate(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Dün
    if (text.contains('dün') || text.contains('düne')) {
      return today.subtract(const Duration(days: 1));
    }

    // Önceki gün / evvelsi gün
    if (text.contains('önceki gün') ||
        text.contains('evvelsi') ||
        text.contains('evvelki gün') ||
        text.contains('iki gün önce')) {
      return today.subtract(const Duration(days: 2));
    }

    // 3 gün önce
    if (text.contains('üç gün önce') || text.contains('3 gün önce')) {
      return today.subtract(const Duration(days: 3));
    }

    // Geçen hafta
    if (text.contains('geçen hafta')) {
      return today.subtract(const Duration(days: 7));
    }

    // Gün isimleri (geçen pazartesi, salı, vb.)
    final gunler = {
      'pazartesi': DateTime.monday,
      'salı': DateTime.tuesday,
      'çarşamba': DateTime.wednesday,
      'perşembe': DateTime.thursday,
      'cuma': DateTime.friday,
      'cumartesi': DateTime.saturday,
      'pazar': DateTime.sunday,
    };

    for (var entry in gunler.entries) {
      if (text.contains('geçen ${entry.key}') ||
          text.contains('önceki ${entry.key}')) {
        // Geçen haftanın o gününü bul
        int hedefGun = entry.value;
        int bugunGunu = now.weekday;
        int fark = bugunGunu - hedefGun;
        if (fark <= 0) fark += 7;
        fark += 7; // Geçen haftaya git
        return today.subtract(Duration(days: fark));
      } else if (text.contains(entry.key)) {
        // Bu haftanın o günü veya geçen hafta (geçmişte ise)
        int hedefGun = entry.value;
        int bugunGunu = now.weekday;
        int fark = bugunGunu - hedefGun;
        if (fark <= 0) fark += 7;
        return today.subtract(Duration(days: fark));
      }
    }

    return null; // Tarih bulunamadı, bugün olarak kabul edilecek
  }

  /// Tarih ifadelerini metinden çıkar
  /// Harcama ismini temizlemek için kullanılır
  static String removeDateExpressions(String text) {
    List<String> tarihIfadeleri = [
      'dün',
      'düne',
      'önceki gün',
      'evvelsi',
      'evvelki gün',
      'iki gün önce',
      'üç gün önce',
      '3 gün önce',
      'geçen hafta',
      'geçen pazartesi',
      'geçen salı',
      'geçen çarşamba',
      'geçen perşembe',
      'geçen cuma',
      'geçen cumartesi',
      'geçen pazar',
      'önceki pazartesi',
      'önceki salı',
      'önceki çarşamba',
      'önceki perşembe',
      'önceki cuma',
      'önceki cumartesi',
      'önceki pazar',
      'pazartesi',
      'salı',
      'çarşamba',
      'perşembe',
      'cuma',
      'cumartesi',
      'pazar',
    ];

    String temiz = text.toLowerCase();
    for (var ifade in tarihIfadeleri) {
      temiz = temiz.replaceAll(ifade, '');
    }

    temiz = temiz.trim();
    if (temiz.isNotEmpty) {
      temiz = temiz[0].toUpperCase() + temiz.substring(1);
    }

    return temiz;
  }

  /// Tarihli sorgu için tarih aralığı hesapla
  /// Dün, geçen hafta, geçen ay gibi ifadeler için başlangıç ve bitiş tarihleri döner
  static Map<String, DateTime>? getDateRangeForQuery(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Dün
    if (text.contains('dün')) {
      final dun = today.subtract(const Duration(days: 1));
      return {'baslangic': dun, 'bitis': dun};
    }

    // Geçen hafta
    if (text.contains('geçen hafta') || text.contains('önceki hafta')) {
      final thisMondayOffset = now.weekday - 1;
      final lastMonday = today.subtract(Duration(days: thisMondayOffset + 7));
      final lastSunday = lastMonday.add(const Duration(days: 6));
      return {'baslangic': lastMonday, 'bitis': lastSunday};
    }

    // Geçen ay
    if (text.contains('geçen ay') || text.contains('önceki ay')) {
      final gecenAyBas = DateTime(now.year, now.month - 1, 1);
      final gecenAySon = DateTime(now.year, now.month, 0);
      return {'baslangic': gecenAyBas, 'bitis': gecenAySon};
    }

    // Bu hafta
    if (text.contains('bu hafta')) {
      final thisMondayOffset = now.weekday - 1;
      final thisMonday = today.subtract(Duration(days: thisMondayOffset));
      return {'baslangic': thisMonday, 'bitis': today};
    }

    // Bu ay
    if (text.contains('bu ay')) {
      final buAyBas = DateTime(now.year, now.month, 1);
      return {'baslangic': buAyBas, 'bitis': today};
    }

    // Bu yıl
    if (text.contains('bu yıl') || text.contains('bu sene')) {
      final yilBas = DateTime(now.year, 1, 1);
      return {'baslangic': yilBas, 'bitis': today};
    }

    return null;
  }
}
