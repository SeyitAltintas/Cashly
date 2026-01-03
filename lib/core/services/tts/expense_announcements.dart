/// TTS Harcama Bildirimleri
/// TtsService'den ayrılmış harcama ile ilgili sesli bildirimler
library;

/// Harcama ile ilgili TTS bildirimlerini oluşturan mixin
mixin ExpenseAnnouncements {
  /// Harcama eklendi mesajı oluşturur
  String buildHarcamaEklendiMessage({
    required double tutar,
    required String harcamaIsmi,
    required String kategori,
    String tarihStr = '',
  }) {
    String tutarStr = tutar.toStringAsFixed(0);
    return '$tutarStr lira $harcamaIsmi $kategori kategorisine$tarihStr eklendi';
  }

  /// Harcama silindi mesajı oluşturur
  String buildHarcamaSilindiMessage({
    required String harcamaIsmi,
    required double tutar,
  }) {
    String tutarStr = tutar.toStringAsFixed(0);
    return '$harcamaIsmi, $tutarStr lira silindi';
  }

  /// Bu ay toplam harcama mesajı oluşturur
  String buildBuAyHarcamaMessage({required double toplam}) {
    String toplamStr = toplam.toStringAsFixed(0);
    return 'Bu ay toplam $toplamStr lira harcadınız';
  }

  /// En çok harcanan kategori mesajı oluşturur
  String buildEnCokKategoriMessage({
    required String kategori,
    required double tutar,
  }) {
    String tutarStr = tutar.toStringAsFixed(0);
    return 'En çok $kategori kategorisinde, $tutarStr lira harcadınız';
  }

  /// Bu hafta toplam harcama mesajı oluşturur
  String buildBuHaftaHarcamaMessage({required double toplam}) {
    String toplamStr = toplam.toStringAsFixed(0);
    return 'Bu hafta toplam $toplamStr lira harcadınız';
  }

  /// Bugün toplam harcama mesajı oluşturur
  String buildBugunHarcamaMessage({required double toplam}) {
    String toplamStr = toplam.toStringAsFixed(0);
    return toplam == 0
        ? 'Bugün henüz harcama yapmadınız'
        : 'Bugün toplam $toplamStr lira harcadınız';
  }

  /// Son harcamalar mesajı oluşturur
  String buildSonHarcamalarMessage({
    required List<Map<String, dynamic>> harcamalar,
  }) {
    if (harcamalar.isEmpty) {
      return 'Henüz harcama bulunmuyor';
    }

    int adet = harcamalar.length > 5 ? 5 : harcamalar.length;
    StringBuffer mesaj = StringBuffer('Son $adet harcamanız: ');

    for (int i = 0; i < adet; i++) {
      var h = harcamalar[i];
      String isim = h['isim'] ?? 'Harcama';
      double tutar = (h['tutar'] as num?)?.toDouble() ?? 0;
      mesaj.write('$isim ${tutar.toStringAsFixed(0)} lira');
      if (i < adet - 1) mesaj.write(', ');
    }

    return mesaj.toString();
  }

  /// Kategori bazlı harcama mesajı oluşturur
  String buildKategoriHarcamaMessage({
    required String kategori,
    required double toplam,
  }) {
    String toplamStr = toplam.toStringAsFixed(0);
    return toplam == 0
        ? '$kategori kategorisinde henüz harcama yok'
        : '$kategori kategorisinde toplam $toplamStr lira harcadınız';
  }

  /// Harcama düzenlendi mesajı oluşturur
  String buildHarcamaDuzenlendiMessage({
    required String harcamaIsmi,
    required double eskiTutar,
    required double yeniTutar,
  }) {
    String eskiStr = eskiTutar.toStringAsFixed(0);
    String yeniStr = yeniTutar.toStringAsFixed(0);
    return '$harcamaIsmi, $eskiStr liradan $yeniStr liraya güncellendi';
  }

  /// Dün toplam harcama mesajı oluşturur
  String buildDunHarcamaMessage({required double toplam}) {
    String toplamStr = toplam.toStringAsFixed(0);
    return toplam == 0
        ? 'Dün harcama yapmadınız'
        : 'Dün toplam $toplamStr lira harcadınız';
  }

  /// Geçen hafta toplam harcama mesajı oluşturur
  String buildGecenHaftaHarcamaMessage({required double toplam}) {
    String toplamStr = toplam.toStringAsFixed(0);
    return toplam == 0
        ? 'Geçen hafta harcama yapmadınız'
        : 'Geçen hafta toplam $toplamStr lira harcadınız';
  }

  /// Geçen ay toplam harcama mesajı oluşturur
  String buildGecenAyHarcamaMessage({required double toplam}) {
    String toplamStr = toplam.toStringAsFixed(0);
    return toplam == 0
        ? 'Geçen ay harcama yapmadınız'
        : 'Geçen ay toplam $toplamStr lira harcadınız';
  }

  /// Bu yıl toplam harcama mesajı oluşturur
  String buildBuYilHarcamaMessage({required double toplam}) {
    String toplamStr = toplam.toStringAsFixed(0);
    return toplam == 0
        ? 'Bu yıl henüz harcama yapmadınız'
        : 'Bu yıl toplam $toplamStr lira harcadınız';
  }

  /// Tarihli kategori harcama mesajı oluşturur
  String buildTarihliKategoriHarcamaMessage({
    required String donem,
    required String kategori,
    required double toplam,
  }) {
    String toplamStr = toplam.toStringAsFixed(0);
    return toplam == 0
        ? '$donem $kategori kategorisinde harcama yapmadınız'
        : '$donem $kategori kategorisinde $toplamStr lira harcadınız';
  }

  /// Tekrarlayan işlemler eklendi mesajı oluşturur
  String buildSabitGiderlerEklendiMessage({
    required int adet,
    required double toplam,
  }) {
    String toplamStr = toplam.toStringAsFixed(0);
    return adet == 0
        ? 'Eklenecek tekrarlayan işlem bulunamadı. Önce ayarlardan tekrarlayan işlem tanımlayın.'
        : '$adet adet tekrarlayan işlem eklendi. Toplam $toplamStr lira.';
  }
}
