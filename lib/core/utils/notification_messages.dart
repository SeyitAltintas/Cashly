import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

/// Dinamik ve rastgele bildirim mesajları üreten yardımcı sınıf.
/// Tüm mesajlar AppLocalizations aracılığıyla dil desteğine sahiptir.
/// İçten ve samimi bir dil kullanır; isim arasıra kullanılır.
class NotificationMessages {
  static final _random = Random();

  static String _namePrefix(String? userName) {
    if (userName != null && userName.trim().isNotEmpty) {
      return "${userName.trim()}, ";
    }
    return "";
  }

  // Uygulama genelindeki lokalizasyon nesnesine erişim
  static AppLocalizations? _l10n(BuildContext? context) {
    if (context == null) return null;
    try {
      return AppLocalizations.of(context);
    } catch (_) {
      return null;
    }
  }

  static String _pick(List<String> list) => list[_random.nextInt(list.length)];

  /// Günlük seri hatırlatıcı başlığı
  static String getStreakReminderTitle([BuildContext? context]) {
    final l = _l10n(context);
    final titles = [
      l?.notifStreakReminderTitle1 ?? "🔥 Serini Koruma Zamanı!",
      l?.notifStreakReminderTitle2 ?? "⏰ Günlük Hatırlatma!",
      l?.notifStreakReminderTitle3 ?? "👋 Cashly'den Selamlar",
      l?.notifStreakReminderTitle4 ?? "🏃 İstikrar Her Şeydir",
      l?.notifStreakReminderTitle5 ?? "✨ Günü Boş Geçmeyelim",
    ];
    return _pick(titles);
  }

  /// Seri kırılma uyarısı başlığı
  static String getStreakBreakWarningTitle([BuildContext? context]) {
    final l = _l10n(context);
    final titles = [
      l?.notifStreakBreakWarnTitle1 ?? "🚨 Son Şansın!",
      l?.notifStreakBreakWarnTitle2 ?? "⚠️ Serin Tehlikede!",
      l?.notifStreakBreakWarnTitle3 ?? "⏳ Zaman Daralıyor!",
      l?.notifStreakBreakWarnTitle4 ?? "🥶 Emeğin Donmak Üzere!",
    ];
    return _pick(titles);
  }

  /// Serisi olan kullanıcı için gövde metni
  static String getStreakReminderWithStreak(int days, [String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifStreakWithStreak1(prefix, days) ?? "${prefix}bugün Cashly'e henüz uğramadın. $days günlük serini kaybetmek istemezsin, değil mi?",
      l?.notifStreakWithStreak2(days) ?? "Ateş sönmesin! 🔥 $days günlük serini korumak için hemen giriş yap.",
      l?.notifStreakWithStreak3(prefix, days) ?? "${prefix}tam $days gündür harikasın! Bugünkü girişini de yapıp seriyi uzatmaya ne dersin?",
      l?.notifStreakWithStreak4(days) ?? "İstikrar başarıyı getirir. $days günlük emeğine bir gün daha eklemeye hazır mısın?",
      l?.notifStreakWithStreak5(days) ?? "Günün bitmesine az kaldı! $days günlük harika gidişatını boşa harcama.",
      l?.notifStreakWithStreak6(days) ?? "$days gün boyunca tutarlılık gösterdin, bu küçük bir şey değil! Bugünkü ziyaretini bekliyoruz.",
      l?.notifStreakWithStreak7(days) ?? "Cashly günlük rutininin bir parçası olmayı seviyor. 🙌 $days günlük seride devam!",
    ];
    return _pick(messages);
  }

  /// Serisi olmayan kullanıcı için gövde metni
  static String getStreakReminderWithoutStreak([String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifStreakNoStreak1(prefix) ?? "${prefix}bugün Cashly'e henüz uğramadın. Serini hemen başlat!",
      l?.notifStreakNoStreak2 ?? "Yeni bir başlangıç yapmanın tam zamanı! Bütçeni kontrol etmek için uygulamaya göz at.",
      l?.notifStreakNoStreak3(prefix) ?? "${prefix}finansal kontrol senin elinde. Hadi bugün ilk adımını atarak yeni bir seri başlat!",
      l?.notifStreakNoStreak4 ?? "Harcamalarını takip etmek stresi azaltır. Bugün Cashly'de neler olduğuna bir bak.",
      l?.notifStreakNoStreak5 ?? "Her büyük seri bir günle başlar. Bugün o gün olabilir! 🌱",
      l?.notifStreakNoStreak6 ?? "Küçük bir adım, büyük bir fark. Bugün Cashly'ye uğramayı dene.",
    ];
    return _pick(messages);
  }

  /// Seri kırılma uyarısı gövde metni
  static String getStreakBreakWarning([String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifStreakBreakWarn1(prefix) ?? "${prefix}serin kırılmak üzere! Bugün Cashly'e girmeyi unutma lütfen.",
      l?.notifStreakBreakWarn2 ?? "Dikkat! Esneklik sürenin sonuna geldin. Serin sıfırlanmadan hemen giriş yap.",
      l?.notifStreakBreakWarn3(prefix) ?? "${prefix}son çağrı! Onca gündür biriktirdiğin emeğin çöpe gitmek üzere. Kurtarabilirsin!",
      l?.notifStreakBreakWarn4 ?? "Gidiyor, gitmek üzere... Serini son anda kurtarmak için sadece bir giriş yeterli!",
      l?.notifStreakBreakWarn5 ?? "Bu kadar emek boşa gitmesin. Birkaç saniyeni ayır, serini kurtar! ⚡",
      l?.notifStreakBreakWarn6 ?? "Bugün mü? Tam zamanı değil mi? Yine de uğra, serin sana muhtaç. 😅",
    ];
    return _pick(messages);
  }

  /// Harcaması olan aylık özet gövde metni
  static String getMonthlySummaryWithSpending(String amount, [String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifMonthlyWithSpending1(prefix, amount) ?? "${prefix}bu ay $amount harcadın. Detaylı analiz için hemen tıkla.",
      l?.notifMonthlyWithSpending2(amount) ?? "Aylık finansal raporun hazır! Toplam harcaman: $amount. Göz atmak ister misin?",
      l?.notifMonthlyWithSpending3(amount) ?? "Koca bir ay daha geride kaldı. Toplamda $amount harcamışsın. Nerelere gittiğini merak ediyor musun?",
      l?.notifMonthlyWithSpending4(prefix, amount) ?? "${prefix}işte bu ayın karnesi: $amount harcama. Gelir-gider dengeni birlikte inceleyelim.",
      l?.notifMonthlyWithSpending5(amount) ?? "Ay sona erdi. $amount harcandı. Bütçen nasıl? Bir bak.",
      l?.notifMonthlyWithSpending6(amount) ?? "Aylık özet hazır! Rakamlar seni şaşırtabilir — $amount harcadın bu ay.",
    ];
    return _pick(messages);
  }

  /// Harcaması olmayan aylık özet gövde metni
  static String getMonthlySummaryWithoutSpending([String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifMonthlyNoSpending1 ?? "Bu ayki finansal durumunu görüntülemek için tıkla.",
      l?.notifMonthlyNoSpending2(prefix) ?? "${prefix}aylık raporun hazır! Bu ay bütçeni nasıl yönettin? Görmek için dokun.",
      l?.notifMonthlyNoSpending3 ?? "Yeni bir aya girmeden önce geride bıraktığın ayın genel bir değerlendirmesini yapalım.",
      l?.notifMonthlyNoSpending4 ?? "Aylık özetin seni bekliyor. Nasıl geçti bu ay?",
    ];
    return _pick(messages);
  }

  /// Harcaması olan haftalık özet gövde metni
  static String getWeeklySummaryWithSpending(String category, String amount, [String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifWeeklyWithSpending1(prefix, category, amount) ?? "${prefix}bu hafta cüzdanını en çok $category ($amount) yormuş. Kontrol zamanı geldi sanki?",
      l?.notifWeeklyWithSpending2(category, amount) ?? "Haftanın harcama şampiyonu belli oldu: $category kategorisinde toplam $amount harcadın.",
      l?.notifWeeklyWithSpending3(prefix, category, amount) ?? "${prefix}geçen haftanın en büyük gider kalemi: $amount ile $category. Detayları incelemek ister misin?",
      l?.notifWeeklyWithSpending4(category, amount) ?? "Haftalık özetine göre bu hafta $category kategorisine biraz fazla yüklenmişiz ($amount).",
      l?.notifWeeklyWithSpending5(category, amount) ?? "7 günün özeti: $category liderliğinde $amount harcama. Sonraki haftaya hazır mısın?",
    ];
    return _pick(messages);
  }

  /// Harcaması olmayan haftalık özet gövde metni
  static String getWeeklySummaryWithoutSpending([String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifWeeklyNoSpending1 ?? "Bu hafta en çok hangi kategoride harcama yaptığını gör!",
      l?.notifWeeklyNoSpending2(prefix) ?? "${prefix}haftalık bütçe durumunu kontrol etme vakti. Neler değişmiş bir göz at.",
      l?.notifWeeklyNoSpending3 ?? "Geçtiğimiz 7 günün finansal özeti Cashly'de seni bekliyor.",
      l?.notifWeeklyNoSpending4 ?? "Haftalık rapor hazır! Nereye harcadın bu hafta?",
    ];
    return _pick(messages);
  }

  /// Tekrarlayan işlem hatırlatıcısı gövde metni
  static String getRecurringReminder(String name, String amount, [String? userName, BuildContext? context]) {
    final l = _l10n(context);
    final prefix = _namePrefix(userName);
    final messages = [
      l?.notifRecurring1(prefix, name, amount) ?? "$prefix$name için $amount ödemen yarın. Şimdiden hatırlatayım dedim.",
      l?.notifRecurring2(name, amount) ?? "Yarın $name için $amount ödemen gerekiyor, gözden kaçmasın.",
      l?.notifRecurring3(name, amount) ?? "$amount tutarındaki $name işleminin zamanı geldi.",
      l?.notifRecurring4(prefix, name, amount) ?? "${prefix}bütçeni buna göre ayarlamayı unutma: $name ($amount) yarın gerçekleşecek.",
      l?.notifRecurring5(name, amount) ?? "Ödeme zamanı yaklaşıyor! $name için $amount yarın hesabından çıkacak.",
    ];
    return _pick(messages);
  }
}
