import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

/// Harcama hesaplama yardımcı sınıfı
/// VoiceInputSheet callback'lerinde kullanılan hesaplama mantığını içerir
class ExpenseCalculationHelper {
  final List<Map<String, dynamic>> tumHarcamalar;
  final List<Map<String, dynamic>> gosterilenHarcamalar;
  final DateTime secilenAy;
  final double butceLimiti;

  ExpenseCalculationHelper({
    required this.tumHarcamalar,
    required this.gosterilenHarcamalar,
    required this.secilenAy,
    required this.butceLimiti,
  });

  /// Tutarı hedef para birimine çevirir
  double _convert(Map<String, dynamic> h) {
    final cur = getIt<CurrencyService>();
    final tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
    final pb = h['paraBirimi']?.toString() ?? 'TRY';
    return cur.convert(tutar, pb, cur.currentCurrency);
  }

  /// Aylık toplam harcamayı hesaplar
  double get toplamTutar {
    double toplam = 0;
    for (var h in gosterilenHarcamalar) {
      toplam += _convert(h);
    }
    return toplam;
  }

  /// Bu ayın harcamalarını sıralı olarak döndürür
  List<Map<String, dynamic>> get buAyHarcamalari {
    final liste = tumHarcamalar.where((h) {
      if (h['silindi'] == true) return false;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih == null) return false;
      return tarih.year == secilenAy.year && tarih.month == secilenAy.month;
    }).toList();

    liste.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    return liste;
  }

  /// En çok harcama yapılan kategoriyi bulur
  Map<String, dynamic>? getTopCategory() {
    Map<String, double> kategoriToplamlari = {};
    for (var h in gosterilenHarcamalar) {
      String kat = h['kategori'] ?? "Diğer";
      double tutar = _convert(h);
      kategoriToplamlari[kat] = (kategoriToplamlari[kat] ?? 0) + tutar;
    }
    if (kategoriToplamlari.isEmpty) return null;

    String? enCokKategori;
    double enYuksekTutar = 0;
    kategoriToplamlari.forEach((kategori, tutar) {
      if (tutar > enYuksekTutar) {
        enYuksekTutar = tutar;
        enCokKategori = kategori;
      }
    });

    if (enCokKategori == null || enYuksekTutar == 0) return null;
    return {'kategori': enCokKategori, 'tutar': enYuksekTutar};
  }

  /// Haftalık toplam harcamayı hesaplar
  double getWeeklyTotal() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    double haftalikToplam = 0;

    for (var h in tumHarcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null &&
          tarih.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          tarih.isBefore(now.add(const Duration(days: 1)))) {
        haftalikToplam += _convert(h);
      }
    }
    return haftalikToplam;
  }

  /// Günlük toplam harcamayı hesaplar
  double getDailyTotal() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    double gunlukToplam = 0;

    for (var h in tumHarcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        final harcamaTarihi = DateTime(tarih.year, tarih.month, tarih.day);
        if (harcamaTarihi.isAtSameMomentAs(today)) {
          gunlukToplam += _convert(h);
        }
      }
    }
    return gunlukToplam;
  }

  /// Son 5 harcamayı döndürür
  List<Map<String, dynamic>> getLastExpenses() {
    return buAyHarcamalari.take(5).toList();
  }

  /// Bütçe durumunu kontrol eder
  Map<String, dynamic> checkBudget() {
    double kalanLimit = butceLimiti - toplamTutar;
    double asilanMiktar = toplamTutar - butceLimiti;
    return {
      'kalanLimit': kalanLimit > 0 ? kalanLimit : 0,
      'asilanMiktar': asilanMiktar,
      'butceLimiti': butceLimiti,
    };
  }

  /// Belirli bir kategorinin toplam tutarını hesaplar
  double getCategoryTotal(String kategori) {
    double toplam = 0;
    for (var h in gosterilenHarcamalar) {
      if (h['kategori'] == kategori) {
        toplam += _convert(h);
      }
    }
    return toplam;
  }

  /// Tarih aralığındaki toplam harcamayı hesaplar
  double getDateRangeTotal(DateTime baslangic, DateTime bitis) {
    double toplam = 0;
    final baslangicGun = DateTime(
      baslangic.year,
      baslangic.month,
      baslangic.day,
    );
    final bitisGun = DateTime(bitis.year, bitis.month, bitis.day);

    for (var h in tumHarcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        final harcamaTarihi = DateTime(tarih.year, tarih.month, tarih.day);
        if ((harcamaTarihi.isAtSameMomentAs(baslangicGun) ||
                harcamaTarihi.isAfter(baslangicGun)) &&
            (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                harcamaTarihi.isBefore(bitisGun))) {
          toplam += _convert(h);
        }
      }
    }
    return toplam;
  }

  /// Tarih aralığındaki belirli bir kategorinin toplam tutarını hesaplar
  double getDateRangeCategoryTotal(
    DateTime baslangic,
    DateTime bitis,
    String kategori,
  ) {
    double toplam = 0;
    final baslangicGun = DateTime(
      baslangic.year,
      baslangic.month,
      baslangic.day,
    );
    final bitisGun = DateTime(bitis.year, bitis.month, bitis.day);

    for (var h in tumHarcamalar) {
      if (h['silindi'] == true) continue;
      if (h['kategori'] != kategori) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        final harcamaTarihi = DateTime(tarih.year, tarih.month, tarih.day);
        if ((harcamaTarihi.isAtSameMomentAs(baslangicGun) ||
                harcamaTarihi.isAfter(baslangicGun)) &&
            (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                harcamaTarihi.isBefore(bitisGun))) {
          toplam += _convert(h);
        }
      }
    }
    return toplam;
  }
}
