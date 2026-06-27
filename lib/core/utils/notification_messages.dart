import 'dart:math';

/// Dinamik ve rastgele bildirim mesajları üreten yardımcı sınıf.
/// Bildirimlerin her zaman aynı metinle gelmesini engelleyerek
/// kullanıcı deneyimini zenginleştirir. İçten ve samimi bir dil kullanır.
class NotificationMessages {
  static final _random = Random();

  static String _namePrefix(String? userName) {
    if (userName != null && userName.trim().isNotEmpty) {
      return "${userName.trim()}, ";
    }
    return "";
  }

  /// Serisi devam eden (streak > 0) kullanıcılar için rastgele başlık
  static String getStreakReminderTitle() {
    final titles = [
      "🔥 Serini Koruma Zamanı!",
      "⏰ Günlük Hatırlatma!",
      "👋 Cashly'den Selamlar",
      "🏃‍♂️ İstikrar Her Şeydir",
      "✨ Günü Boş Geçmeyelim"
    ];
    return titles[_random.nextInt(titles.length)];
  }

  /// Serisi kırılmak üzere olan kullanıcılar için rastgele başlık
  static String getStreakBreakWarningTitle() {
    final titles = [
      "🚨 Son Şansın!",
      "⚠️ Serin Tehlikede!",
      "⏳ Zaman Daralıyor!",
      "🥶 Emeğin Donmak Üzere!"
    ];
    return titles[_random.nextInt(titles.length)];
  }

  /// Serisi olan kullanıcılar için içerik metni
  static String getStreakReminderWithStreak(int streakDays, [String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      "${prefix}bugün Cashly'e henüz uğramadın. $streakDays günlük serini kaybetmek istemezsin, değil mi?",
      "Ateş sönmesin! 🔥 $streakDays günlük serini korumak için hemen giriş yap.",
      "${prefix}tam $streakDays gündür harikasın! Bugünkü girişini de yapıp seriyi uzatmaya ne dersin?",
      "İstikrar başarıyı getirir. $streakDays günlük emeğine bir gün daha eklemeye hazır mısın?",
      "Günün bitmesine az kaldı! $streakDays günlük harika gidişatını boşa harcama.",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Serisi olmayan kullanıcılar için içerik metni
  static String getStreakReminderWithoutStreak([String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      prefix.isEmpty ? "Bugün Cashly'e henüz uğramadın. Serini hemen başlat!" : "${prefix}bugün Cashly'e henüz uğramadın. Serini hemen başlat!",
      "Yeni bir başlangıç yapmanın tam zamanı! Bütçeni kontrol etmek için uygulamaya göz at.",
      prefix.isEmpty ? "Finansal kontrol senin elinde. Hadi bugün ilk adımını atarak yeni bir seri başlat!" : "${prefix}finansal kontrol senin elinde. Hadi bugün ilk adımını atarak yeni bir seri başlat!",
      "Harcamalarını takip etmek stresi azaltır. Bugün Cashly'de neler olduğuna bir bak.",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Seri kırılma uyarısı için içerik metni
  static String getStreakBreakWarning([String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      "${prefix}serin kırılmak üzere! Bugün Cashly'e girmeyi unutma lütfen.",
      "Dikkat! Esneklik sürenin sonuna geldin. Serin sıfırlanmadan hemen giriş yap.",
      "${prefix}son çağrı! Onca gündür biriktirdiğin emeğin çöpe gitmek üzere. Kurtarabilirsin!",
      "Gidiyor, gitmek üzere... Serini son anda kurtarmak için sadece bir giriş yeterli!",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Harcaması olan aylık özet için içerik metni
  static String getMonthlySummaryWithSpending(String totalAmount, [String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      "${prefix}bu ay $totalAmount harcadın. Detaylı analiz için hemen tıkla.",
      "Aylık finansal raporun hazır! Toplam harcaman: $totalAmount. Göz atmak ister misin?",
      "Koca bir ay daha geride kaldı. Toplamda $totalAmount harcamışsın. Nerelere gittiğini merak ediyor musun?",
      "${prefix}işte bu ayın karnesi: $totalAmount harcama. Gelir-gider dengeni birlikte inceleyelim.",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Harcaması olmayan aylık özet için içerik metni
  static String getMonthlySummaryWithoutSpending([String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      "Bu ayki finansal durumunu görüntülemek için tıkla.",
      prefix.isEmpty ? "Aylık raporun hazır! Bu ay bütçeni nasıl yönettin? Görmek için dokun." : "${prefix}aylık raporun hazır! Bu ay bütçeni nasıl yönettin? Görmek için dokun.",
      "Yeni bir aya girmeden önce geride bıraktığın ayın genel bir değerlendirmesini yapalım.",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Harcaması olan haftalık özet için içerik metni
  static String getWeeklySummaryWithSpending(String category, String amount, [String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      "${prefix}bu hafta cüzdanını en çok $category ($amount) yormuş. Kontrol zamanı geldi sanki?",
      "Haftanın harcama şampiyonu belli oldu: $category kategorisinde toplam $amount harcadın.",
      "${prefix}geçen haftanın en büyük gider kalemi: $amount ile $category. Detayları incelemek ister misin?",
      "Haftalık özetine göre bu hafta $category kategorisine biraz fazla yüklenmişiz ($amount).",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Harcaması olmayan haftalık özet için içerik metni
  static String getWeeklySummaryWithoutSpending([String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      "Bu hafta en çok hangi kategoride harcama yaptığını gör!",
      prefix.isEmpty ? "Haftalık bütçe durumunu kontrol etme vakti. Neler değişmiş bir göz at." : "${prefix}haftalık bütçe durumunu kontrol etme vakti. Neler değişmiş bir göz at.",
      "Geçtiğimiz 7 günün finansal özeti Cashly'de seni bekliyor.",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  /// Tekrarlayan işlemler için içerik metni
  static String getRecurringReminder(String transactionName, String amount, [String? userName]) {
    final prefix = _namePrefix(userName);
    final messages = [
      "${prefix}$transactionName için $amount ödemen yarın. Şimdiden hatırlatayım dedim.",
      "Yarın $transactionName için $amount ödemen gerekiyor, gözden kaçmasın.",
      "$amount tutarındaki $transactionName işleminin zamanı geldi.",
      "${prefix}bütçeni buna göre ayarlamayı unutma: $transactionName ($amount) yarın gerçekleşecek.",
    ];
    return messages[_random.nextInt(messages.length)];
  }
}
