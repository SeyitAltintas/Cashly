// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Cashly';

  @override
  String transferOutTitle(String accountName) {
    return '$accountName hesabına giden transfer';
  }

  @override
  String transferInTitle(String accountName) {
    return '$accountName hesabından gelen transfer';
  }

  @override
  String get noTransactionsFoundThisMonth => 'Bu ayda işlem bulunamadı';

  @override
  String get limitLabel => 'Limit';

  @override
  String get settings => 'Ayarlar';

  @override
  String get appSettings => 'Uygulama Ayarları';

  @override
  String get appearance => 'Görünüm';

  @override
  String get appearanceSubtitle => 'Tema, animasyon ve görsel efektler';

  @override
  String get appearanceSettings => 'Görünüm Ayarları';

  @override
  String get appearanceSettingsDescription =>
      'Uygulamanın görsel tercihlerini özelleştirin';

  @override
  String get animations => 'Animasyonlar';

  @override
  String get animationsSubtitle => 'Para animasyonu ve görsel efektler';

  @override
  String get hapticFeedback => 'Titreşim Geri Bildirimi';

  @override
  String get hapticFeedbackSubtitle => 'Tıklama, işlem ve uyarı titreşimleri';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationsSubtitle => 'Hatırlatıcılar ve uyarı bildirimleri';

  @override
  String get voiceAssistant => 'Sesli Asistan';

  @override
  String get voiceAssistantSubtitle => 'Sesli geri bildirim ve komut listesi';

  @override
  String get expenses => 'Harcamalar';

  @override
  String get expensesSubtitle => 'Bütçe, kategori ve ödeme yöntemleri';

  @override
  String get incomes => 'Gelirler';

  @override
  String get incomesSubtitle => 'Gelir kategorileri ve düzenli gelirler';

  @override
  String get moneyTransfers => 'Para Transferleri';

  @override
  String get moneyTransfersSubtitle => 'İşlem geçmişi görüntüleme ayarları';

  @override
  String get dataOperations => 'Veri İşlemleri';

  @override
  String get dataOperationsSubtitle => 'Yedekleme, geri yükleme ve sıfırlama';

  @override
  String get language => 'Dil';

  @override
  String get languageSubtitle => 'Uygulama dilini değiştirin';

  @override
  String get languageSettings => 'Dil Ayarları';

  @override
  String get languageSettingsDescription => 'Uygulamanın kullanım dilini seçin';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get currentLanguage => 'Mevcut Dil';

  @override
  String get languageChangeRestart => 'Dil değişikliği uygulandı';

  @override
  String get backupData => 'Verileri Yedekle';

  @override
  String get backupDataSubtitle => 'Tüm verilerinizi JSON olarak dışa aktarın';

  @override
  String get restoreData => 'Verileri Geri Yükle';

  @override
  String get restoreDataSubtitle => 'Yedek dosyasından verileri içe aktarın';

  @override
  String get deleteAllData => 'Tüm Verilerimi Sil';

  @override
  String get deleteAllDataWarning => 'Dikkat! Bu işlem geri alınamaz';

  @override
  String get backupSuccess => 'Yedek dosyası başarıyla kaydedildi ✅';

  @override
  String get backupCancelled => 'Yedekleme iptal edildi';

  @override
  String get restoreLoading => 'Veriler geri yükleniyor...';

  @override
  String get restoreSuccess => 'Geri yükleme başarı ile tamamlandı';

  @override
  String unexpectedError(String error) {
    return 'Beklenmeyen hata: $error';
  }

  @override
  String get deleteErrorMessage => 'Veriler silinirken bir hata oluştu';

  @override
  String get warning => 'Dikkat!';

  @override
  String get backupSuggestion =>
      'Silmeden önce verilerinizi yedeklemenizi öneririz!';

  @override
  String get permanentDeleteWarning =>
      'Tüm verileriniz kalıcı olarak silinecek:';

  @override
  String get allExpenses => 'Tüm harcamalar';

  @override
  String get allIncomes => 'Tüm gelirler';

  @override
  String get allAssets => 'Tüm varlıklar';

  @override
  String get paymentMethods => 'Ödeme yöntemleri';

  @override
  String get transfers => 'Transferler';

  @override
  String get streakRecords => 'Seri kayıtları';

  @override
  String get irreversibleAction => 'Bu işlem geri alınamaz!';

  @override
  String get cancel => 'İptal';

  @override
  String get continueAction => 'Devam Et';

  @override
  String get delete => 'Sil';

  @override
  String get save => 'Kaydet';

  @override
  String get edit => 'Düzenle';

  @override
  String get add => 'Ekle';

  @override
  String get close => 'Kapat';

  @override
  String get ok => 'Tamam';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get search => 'Ara';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get noData => 'Veri bulunamadı';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get securityVerification => 'Güvenlik Doğrulaması';

  @override
  String get deleteConfirmInstruction =>
      'Silme işlemini onaylamak için sonucu yazın:';

  @override
  String get wrongCalculation => 'Hatalı işlem sonucu. Silme iptal edildi.';

  @override
  String get allDataDeleted => 'Tüm veriler silindi ✅';

  @override
  String get appInitFailed => 'Uygulama başlatılamadı';

  @override
  String get totalBalance => 'Toplam Bakiye';

  @override
  String get monthSummary => 'Bu Ay Özeti';

  @override
  String get expense => 'Harcama';

  @override
  String get income => 'Gelir';

  @override
  String get net => 'Net';

  @override
  String get budgetStatus => 'Bütçe Durumu';

  @override
  String get budgetUsed => 'Kullanıldı';

  @override
  String get budgetRemaining => 'Kalan';

  @override
  String get noBudgetSet => 'Bütçe belirlenmemiş';

  @override
  String get setBudget => 'Bütçe Belirle';

  @override
  String get budgetExceeded => 'Bütçe Aşıldı!';

  @override
  String get assetSummary => 'Varlık Özeti';

  @override
  String get totalAssets => 'Toplam Varlıklar';

  @override
  String get recentTransactions => 'Son İşlemler';

  @override
  String get noRecentTransactions => 'Henüz işlem yok';

  @override
  String get creditCardDebt => 'Kredi Kartı Borcu';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get goodAfternoon => 'İyi günler';

  @override
  String get goodEvening => 'İyi akşamlar';

  @override
  String get goodNight => 'İyi geceler';

  @override
  String get profile => 'Profil';

  @override
  String get profileSettings => 'Profil Ayarları';

  @override
  String get accountInfo => 'Hesap Bilgileri';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get about => 'Hakkında';

  @override
  String get aboutAndSupport => 'Hakkında & Destek';

  @override
  String get version => 'Versiyon';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get login => 'Giriş Yap';

  @override
  String get signup => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get passwordConfirm => 'Şifre Tekrar';

  @override
  String get name => 'İsim';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldiniz!';

  @override
  String get createNewAccount => 'Yeni Hesap Oluştur';

  @override
  String get loginSubtitle => 'Devam etmek için giriş yapın';

  @override
  String get signupSubtitle => 'Finansal yolculuğunuza başlayın';

  @override
  String get nameHint => 'Adınızı girin';

  @override
  String get emailHint => 'E-posta adresinizi girin';

  @override
  String get passwordHint => 'Şifrenizi girin';

  @override
  String get passwordConfirmHint => 'Şifrenizi tekrar girin';

  @override
  String get addExpense => 'Harcama Ekle';

  @override
  String get editExpense => 'Harcamayı Düzenle';

  @override
  String get expenseAmount => 'Tutar';

  @override
  String get expenseCategory => 'Kategori';

  @override
  String get expenseDate => 'Tarih';

  @override
  String get expenseNote => 'Not';

  @override
  String get expensePaymentMethod => 'Ödeme Yöntemi';

  @override
  String get noExpenses => 'Henüz harcama yok';

  @override
  String get monthlyExpense => 'Aylık Harcama';

  @override
  String get dailyAverage => 'Günlük Ortalama';

  @override
  String get totalExpense => 'Toplam Harcama';

  @override
  String get addIncome => 'Gelir Ekle';

  @override
  String get editIncome => 'Geliri Düzenle';

  @override
  String get incomeAmount => 'Tutar';

  @override
  String get incomeCategory => 'Kategori';

  @override
  String get incomeDate => 'Tarih';

  @override
  String get incomeNote => 'Not';

  @override
  String get incomePaymentMethod => 'Hesap';

  @override
  String get noIncomes => 'Henüz gelir yok';

  @override
  String get monthlyIncome => 'Aylık Gelir';

  @override
  String get totalIncome => 'Toplam Gelir';

  @override
  String get recurringIncomes => 'Düzenli Gelirler';

  @override
  String get addAsset => 'Varlık Ekle';

  @override
  String get editAsset => 'Varlığı Düzenle';

  @override
  String get assetName => 'Varlık Adı';

  @override
  String get assetAmount => 'Miktar';

  @override
  String get assetType => 'Tür';

  @override
  String get assetCurrentPrice => 'Güncel Fiyat';

  @override
  String get assetPurchasePrice => 'Alış Fiyatı';

  @override
  String get assetPurchaseDate => 'Alış Tarihi';

  @override
  String get assetCurrentValue => 'Şuanki Değer';

  @override
  String get assetUnitPurchasePrice => 'Birim Alış Fiyatı';

  @override
  String get assetUnitCurrentPrice => 'Birim Güncel Fiyat';

  @override
  String get assetProfitLabel => 'Kar';

  @override
  String get assetLossLabel => 'Zarar';

  @override
  String get assetInflationDisclaimer =>
      'Bu hesaplama enflasyon etkisini içermez';

  @override
  String assetQuantityUnit(String count) {
    return '$count adet';
  }

  @override
  String get noAssets => 'Henüz varlık yok';

  @override
  String get gold => 'Altın';

  @override
  String get silver => 'Gümüş';

  @override
  String get currency => 'Döviz';

  @override
  String get stock => 'Hisse';

  @override
  String get crypto => 'Kripto';

  @override
  String get other => 'Diğer';

  @override
  String get hisseSenedi => 'Hisse Senedi';

  @override
  String get banka => 'Banka';

  @override
  String get goldGram => 'Gram';

  @override
  String get goldQuarter => 'Çeyrek';

  @override
  String get goldHalf => 'Yarım';

  @override
  String get goldFull => 'Tam';

  @override
  String get goldRepublic => 'Cumhuriyet';

  @override
  String get goldAta => 'Ata';

  @override
  String get goldOunce => 'Ons';

  @override
  String get silverGram => 'Gram';

  @override
  String get silverOunce => 'Ons';

  @override
  String get currencyUSD => 'Amerikan Doları (USD)';

  @override
  String get currencyEUR => 'Euro (EUR)';

  @override
  String get currencyGBP => 'İngiliz Sterlini (GBP)';

  @override
  String get currencyCHF => 'İsviçre Frangı (CHF)';

  @override
  String get currencyJPY => 'Japon Yeni (JPY)';

  @override
  String get currencyCAD => 'Kanada Doları (CAD)';

  @override
  String get addPaymentMethod => 'Ödeme Yöntemi Ekle';

  @override
  String get editPaymentMethod => 'Ödeme Yöntemini Düzenle';

  @override
  String get paymentMethodName => 'İsim';

  @override
  String get paymentMethodBalance => 'Bakiye';

  @override
  String get paymentMethodType => 'Tür';

  @override
  String get noPaymentMethods => 'Henüz ödeme yöntemi yok';

  @override
  String get cash => 'Nakit';

  @override
  String get bankAccount => 'Banka Hesabı';

  @override
  String get creditCard => 'Kredi Kartı';

  @override
  String get balance => 'Bakiye';

  @override
  String get creditLimit => 'Kredi Limiti';

  @override
  String get availableLimit => 'Kullanılabilir Limit';

  @override
  String get currentDebt => 'Mevcut Borç';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferFrom => 'Gönderen';

  @override
  String get transferTo => 'Alıcı';

  @override
  String get transferAmount => 'Tutar';

  @override
  String get transferDate => 'Tarih';

  @override
  String get transferNote => 'Not';

  @override
  String get noTransfers => 'Henüz transfer yok';

  @override
  String get category => 'Kategori';

  @override
  String get categories => 'Kategoriler';

  @override
  String get categoryManagement => 'Kategori Yönetimi';

  @override
  String get addCategory => 'Kategori Ekle';

  @override
  String get editCategory => 'Kategoriyi Düzenle';

  @override
  String get categoryName => 'Kategori Adı';

  @override
  String get noCategorySelected => 'Kategori seçilmedi';

  @override
  String get recycleBin => 'Çöp Kutusu';

  @override
  String get restore => 'Geri Yükle';

  @override
  String get permanentDelete => 'Kalıcı Sil';

  @override
  String get emptyRecycleBin => 'Çöp kutusu boş';

  @override
  String get restoreItem => 'Geri Yükle';

  @override
  String get permanentDeleteItem => 'Kalıcı olarak sil';

  @override
  String get deletedItems => 'Silinen Öğeler';

  @override
  String get budgetLimit => 'Bütçe Limiti';

  @override
  String get monthlyBudget => 'Aylık Bütçe';

  @override
  String get categoryBudgets => 'Kategori Bütçeleri';

  @override
  String get remainingBudget => 'Kalan Bütçe';

  @override
  String get overBudget => 'Bütçe Aşımı';

  @override
  String get recurringExpenses => 'Sabit Giderler';

  @override
  String get addRecurringExpense => 'Sabit Gider Ekle';

  @override
  String get editRecurringExpense => 'Sabit Gideri Düzenle';

  @override
  String get frequency => 'Sıklık';

  @override
  String get daily => 'Günlük';

  @override
  String get weekly => 'Haftalık';

  @override
  String get monthly => 'Aylık';

  @override
  String get yearly => 'Yıllık';

  @override
  String get startDate => 'Başlangıç Tarihi';

  @override
  String get endDate => 'Bitiş Tarihi';

  @override
  String get analysis => 'Analiz';

  @override
  String get analytics => 'Analitik';

  @override
  String get spendingByCategory => 'Kategoriye Göre Harcama';

  @override
  String get incomeByCategory => 'Kategoriye Göre Gelir';

  @override
  String get monthlyTrend => 'Aylık Trend';

  @override
  String get expenseDistribution => 'Harcama Dağılımı';

  @override
  String get incomeDistribution => 'Gelir Dağılımı';

  @override
  String get financialReport => 'Finansal Rapor';

  @override
  String get exportPdf => 'PDF Olarak Dışa Aktar';

  @override
  String get exportCsv => 'CSV Olarak Dışa Aktar';

  @override
  String get streak => 'Seri';

  @override
  String get currentStreak => 'Mevcut Seri';

  @override
  String get longestStreak => 'En Uzun Seri';

  @override
  String get streakGoal => 'Seri Hedefi';

  @override
  String get freezeAvailable => 'Dondurma Hakkı';

  @override
  String get useFreeze => 'Dondurma Kullan';

  @override
  String get streakBroken => 'Seri kırıldı!';

  @override
  String get streakContinued => 'Seri devam ediyor!';

  @override
  String get days => 'gün';

  @override
  String get tools => 'Araçlar';

  @override
  String get calculator => 'Hesap Makinesi';

  @override
  String get currencyConverter => 'Döviz Çevirici';

  @override
  String get tipCalculator => 'Bahşiş Hesaplama';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get dailyReminder => 'Günlük Hatırlatıcı';

  @override
  String get budgetAlert => 'Bütçe Uyarısı';

  @override
  String get streakReminder => 'Seri Hatırlatıcı';

  @override
  String get voiceCommands => 'Sesli Komutlar';

  @override
  String get voiceFeedback => 'Sesli Geri Bildirim';

  @override
  String get hapticTap => 'Dokunma Titreşimi';

  @override
  String get hapticSuccess => 'Başarı Titreşimi';

  @override
  String get hapticWarning => 'Uyarı Titreşimi';

  @override
  String get hapticError => 'Hata Titreşimi';

  @override
  String get moneyAnimation => 'Para Animasyonu';

  @override
  String get moneyAnimationDescription =>
      'Harcama eklerken para yağmuru efekti';

  @override
  String get animationPreferences => 'Animasyon Tercihleri';

  @override
  String get animationPreferencesDescription =>
      'Uygulama içi animasyonları yönetin';

  @override
  String get showMoneyRain => 'Para Yağmuru Göster';

  @override
  String get fileNotSelected => 'Dosya seçilmedi';

  @override
  String get january => 'Ocak';

  @override
  String get february => 'Şubat';

  @override
  String get march => 'Mart';

  @override
  String get april => 'Nisan';

  @override
  String get may => 'Mayıs';

  @override
  String get june => 'Haziran';

  @override
  String get july => 'Temmuz';

  @override
  String get august => 'Ağustos';

  @override
  String get september => 'Eylül';

  @override
  String get october => 'Ekim';

  @override
  String get november => 'Kasım';

  @override
  String get december => 'Aralık';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get lastMonth => 'Geçen Ay';

  @override
  String get last3Months => 'Son 3 Ay';

  @override
  String get last6Months => 'Son 6 Ay';

  @override
  String get thisYear => 'Bu Yıl';

  @override
  String get last1Year => 'Son 1 Yıl';

  @override
  String get customRange => 'Özel Aralık';

  @override
  String get selectDate => 'Tarih Seçin';

  @override
  String get selectMonth => 'Ay Seçin';

  @override
  String get selectYear => 'Yıl Seçin';

  @override
  String get insufficientBalance => 'Yetersiz bakiye';

  @override
  String get accountNotFound => 'Hesap bulunamadı';

  @override
  String get scheduledTransferApplied => 'Zamanlanmış transfer uygulandı';

  @override
  String get scheduledTransferFailed => 'Zamanlanmış transfer başarısız';

  @override
  String get amount => 'Tutar';

  @override
  String get date => 'Tarih';

  @override
  String get note => 'Not';

  @override
  String get description => 'Açıklama';

  @override
  String get type => 'Tür';

  @override
  String get status => 'Durum';

  @override
  String get total => 'Toplam';

  @override
  String get average => 'Ortalama';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maksimum';

  @override
  String get count => 'Adet';

  @override
  String get percentage => 'Yüzde';

  @override
  String get spent => 'harcandı';

  @override
  String get limit => 'limit';

  @override
  String get unknown => 'Bilinmeyen';

  @override
  String get totalAsset => 'Toplam Varlık';

  @override
  String get widgetError => 'Widget oluşturulurken bir hata oluştu.';

  @override
  String appCouldNotStart(String error) {
    return 'Uygulama başlatılamadı:\n$error';
  }

  @override
  String spentAmount(String amount) {
    return 'Harcanan: $amount';
  }

  @override
  String limitAmount(String amount) {
    return '$amount limit';
  }

  @override
  String nDays(int count) {
    return '$count gün';
  }

  @override
  String get hapticSettingsTitle => 'Dokunsal Geri Bildirim';

  @override
  String get hapticSettingsDescription =>
      'Önemli işlemlerde titreşim geri bildirimi alın';

  @override
  String get hapticInfoText =>
      'Titreşim geri bildiriminin çalışabilmesi için cihazınızın ayarlarından \"Dokunma geri bildirimi\" veya \"Titreşim\" özelliğinin açık olması gerekmektedir.';

  @override
  String get hapticNoVibrator => 'Bu cihazda titreşim özelliği algılanamadı.';

  @override
  String get hapticEnable => 'Titreşimi Etkinleştir';

  @override
  String get hapticAllOn => 'Tüm titreşimler açık';

  @override
  String get hapticAllOff => 'Tüm titreşimler kapalı';

  @override
  String get hapticButtonTaps => 'Buton Tıklamaları';

  @override
  String get hapticButtonTapsDesc => 'Butonlara dokunduğunuzda';

  @override
  String get hapticNavigation => 'Navigasyon';

  @override
  String get hapticNavigationDesc => 'Sayfa geçişleri ve seçici kaydırmaları';

  @override
  String get hapticDelete => 'Silme İşlemleri';

  @override
  String get hapticDeleteDesc => 'Öğe sildiğinizde';

  @override
  String get hapticSuccessNotif => 'Başarı Bildirimi';

  @override
  String get hapticSuccessNotifDesc => 'İşlem başarılı olduğunda';

  @override
  String get hapticErrorNotif => 'Hata Bildirimi';

  @override
  String get hapticErrorNotifDesc => 'Hata oluştuğunda';

  @override
  String get hapticCelebration => 'Seri Kutlama';

  @override
  String get hapticCelebrationDesc => 'Seri arttığında kutlama titreşimi';

  @override
  String get notificationSettingsTitle => 'Bildirim Ayarları';

  @override
  String get notificationSettingsDesc =>
      'Finansal hatırlatmalar ve uyarıları yönetin';

  @override
  String get notificationsEnabled => 'Bildirimler etkinleştirildi';

  @override
  String get notificationPermDenied => 'Bildirim izni verilmedi';

  @override
  String get openSettings => 'Ayarları Aç';

  @override
  String get notificationScenarios => 'Bildirim Senaryoları';

  @override
  String get scheduleSettings => 'Zamanlama Ayarları';

  @override
  String get turnOffAll => 'Tümünü Kapat';

  @override
  String get turnOnAll => 'Tümünü Aç';

  @override
  String get recurringReminder => 'Tekrarlayan İşlem Hatırlatıcı';

  @override
  String get recurringReminderDesc => 'Ödeme/fatura gününden 1 gün önce';

  @override
  String get streakReminderTitle => 'Seri Hatırlatıcı';

  @override
  String get streakReminderDesc => 'Günlük işlem girişi hatırlatması';

  @override
  String get lastChanceWarning => 'Son Şans Uyarısı';

  @override
  String get lastChanceWarningDesc => 'Her gün 22:00 - seri kırılma riski';

  @override
  String get monthlySummary => 'Aylık Özet';

  @override
  String get monthlySummaryDesc => 'Her ayın son günü finansal özet';

  @override
  String get weeklyReport => 'Haftalık Rapor';

  @override
  String get weeklyReportDesc => 'Her Pazar 18:00 - en çok harcama kategorisi';

  @override
  String get streakReminderTime => 'Seri Hatırlatıcı Saati';

  @override
  String get monthlySummaryTime => 'Aylık Özet Saati';

  @override
  String get lastDayOfMonth => 'Her ayın son günü';

  @override
  String get voiceAssistantTitle => 'Sesli Asistan';

  @override
  String get voiceAssistantDesc =>
      'Sesli komut ve geri bildirim ayarlarını yönetin';

  @override
  String get voiceFeedbackLabel => 'Sesli Geri Bildirim';

  @override
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get viewAllVoiceCommands => 'Tüm Sesli Komutları Görüntüle';

  @override
  String get voiceCommandsTitle => 'Sesli Komutlar';

  @override
  String get voiceCommandsInfo =>
      'Aşağıdaki komutları sesli asistanla kullanabilirsiniz.';

  @override
  String get voiceCommandsTip =>
      'İpucu: Komutları denerken doğal konuşmaya çalışın. Uygulama farklı varyasyonları anlayabilir.';

  @override
  String get profileSettingsTitle => 'Profil Ayarları';

  @override
  String get userNotFound => 'Kullanıcı bulunamadı';

  @override
  String get userLoadError => 'Kullanıcı bilgileri yüklenemedi';

  @override
  String get biometricEnabled => 'Biyometrik giriş aktifleştirildi';

  @override
  String get biometricDisabled => 'Biyometrik giriş kapatıldı';

  @override
  String get unknownDate => 'Bilinmiyor';

  @override
  String get aboutSupportTitle => 'Hakkında & Destek';

  @override
  String get aboutSupportDesc => 'Uygulama bilgileri, destek ve iletişim';

  @override
  String get appVersion => 'Uygulama Versiyonu';

  @override
  String get developer => 'Geliştirici';

  @override
  String get contactUs => 'Bize Ulaşın';

  @override
  String get rateApp => 'Uygulamayı Değerlendir';

  @override
  String get shareApp => 'Uygulamayı Paylaş';

  @override
  String get licenses => 'Lisanslar';

  @override
  String get termsOfService => 'Kullanım Koşulları';

  @override
  String get legal => 'Yasal';

  @override
  String get support => 'Destek';

  @override
  String get faq => 'Sıkça Sorulan Sorular';

  @override
  String get privacyPolicyDesc => 'Verilerinizi nasıl koruduğumuzu öğrenin';

  @override
  String get termsOfServiceDesc => 'Uygulama kullanım şartları ve kurallar';

  @override
  String get openSourceLicenses => 'Açık Kaynak Lisansları';

  @override
  String get openSourceLicensesDesc => 'Kullanılan kütüphaneler ve lisansları';

  @override
  String get shareAppDesc => 'Cashly\'i arkadaşlarınla paylaş';

  @override
  String get appSlogan => 'Akıllı Bütçe Takip Asistanın';

  @override
  String get footerMessage => 'Cashly ile bütçeni kontrol altına al 💰';

  @override
  String get copyright => '© 2026 Cashly. Tüm hakları saklıdır.';

  @override
  String get lastUpdated => 'Son güncelleme: 17 Şubat 2026';

  @override
  String get shareText =>
      'Cashly ile bütçeni kolayca takip et! 💰\nHarcamalarını, gelirlerini ve varlıklarını tek bir yerden yönet.\n\n📲 Hemen dene!';

  @override
  String get expenseSettingsTitle => 'Gider Ayarları';

  @override
  String get expenseSettingsDesc =>
      'Bütçenizi ve harcama tercihlerinizi yönetin';

  @override
  String budgetUpdated(String amount) {
    return 'Bütçe Limitiniz $amount TL olarak güncellendi.';
  }

  @override
  String get defaultPaymentUpdated => 'Varsayılan ödeme yöntemi güncellendi ✅';

  @override
  String get transferSettingsTitle => 'Transfer Ayarları';

  @override
  String get transferSettingsPageTitle => 'Para Transferleri';

  @override
  String get transferSettingsDesc =>
      'Transfer ayarlarını ve görüntüleme tercihlerinizi yönetin';

  @override
  String get transactionHistoryLimit => 'İşlem Geçmişi Limiti';

  @override
  String get transactionHistoryLimitDesc =>
      'Transfer sayfasında gösterilecek işlem geçmişi sayısı';

  @override
  String historyLimitSaved(int limit) {
    return 'İşlem geçmişi limiti $limit olarak kaydedildi ✅';
  }

  @override
  String get select => 'Seçiniz';

  @override
  String get useFirstPaymentMethod => 'İlk ödeme yöntemini kullan';

  @override
  String get manageRecurringExpenses => 'Tekrarlayan Giderleri Yönet';

  @override
  String get autoPayBillsSubscriptions =>
      'Otomatik ödenen fatura ve abonelikler';

  @override
  String get customizeExpenseCategories =>
      'Harcama kategorilerini özelleştirin';

  @override
  String get addEditDeleteCategories =>
      'Kategorileri ekleyin, düzenleyin veya silin';

  @override
  String get setCategoryLimits => 'Kategori Limitleri Belirle';

  @override
  String get noLimitSet => 'Limit belirlenmemiş';

  @override
  String get enterAmount => 'Tutar girin';

  @override
  String get profilePhoto => 'Profil Fotoğrafı';

  @override
  String get editPhoto => 'Düzenle';

  @override
  String get pin => 'PIN';

  @override
  String get memberSince => 'Üyelik Tarihi';

  @override
  String get lastLogin => 'Son Giriş';

  @override
  String get biometricLogin => 'Biyometrik Giriş';

  @override
  String get biometricDesc => 'Parmak izi veya yüz tanıma ile giriş yapın';

  @override
  String get dangerZone => 'Tehlikeli Bölge';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountDesc => 'Tüm verileriniz kalıcı olarak silinir';

  @override
  String get deleteAccountConfirmTitle =>
      'Hesabı Silmek İstediğinize Emin Misiniz?';

  @override
  String get deleteAccountWarning =>
      'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.';

  @override
  String get defaultPaymentMethod => 'Varsayılan Ödeme Yöntemi';

  @override
  String get noPaymentMethodAdded =>
      'Henüz ödeme yöntemi eklemediniz. Araçlar sayfasından ekleyebilirsiniz.';

  @override
  String categoryBudgetActive(int count) {
    return '$count aktif limit';
  }

  @override
  String get monthlyIncomeBudgetLimit => 'Aylık Gelir (Bütçe Limiti)';

  @override
  String get myExpenses => 'Harcamalarım';

  @override
  String get myIncomes => 'Gelirlerim';

  @override
  String get searchExpense => 'Harcama ara...';

  @override
  String get searchIncome => 'Gelir ara...';

  @override
  String get goToToday => 'Bugüne git';

  @override
  String get recycleBinTooltip => 'Çöp Kutusu';

  @override
  String get voiceInputTooltip => 'Sesli Giriş';

  @override
  String get homePage => 'Ana Sayfa';

  @override
  String get selectPeriod => 'Dönem Seç';

  @override
  String get year => 'Yıl';

  @override
  String get month => 'Ay';

  @override
  String get allDataUpToDate => 'Tüm veriler güncel';

  @override
  String get user => 'Kullanıcı';

  @override
  String get account => 'Hesap';

  @override
  String get userInfo => 'Kullanıcı Bilgileri';

  @override
  String get userInfoSubtitle => 'Ad, e-posta ve profil resmi';

  @override
  String get settingsSubtitle => 'Görünüm, sesli asistan ve harcamalar';

  @override
  String get aboutAndSupportSubtitle => 'Versiyon, SSS ve yasal bilgiler';

  @override
  String get session => 'Oturum';

  @override
  String get logoutSubtitle => 'Hesabından güvenli çıkış yap';

  @override
  String get assets => 'Varlıklar';

  @override
  String get transactions => 'İşlemler';

  @override
  String get allTransactions => 'Tüm İşlemler';

  @override
  String get newRecurringExpense => 'Yeni Tekrarlayan Gider';

  @override
  String get editTransaction => 'İşlemi Düzenle';

  @override
  String get transactionName => 'İşlem Adı';

  @override
  String get transactionNameRequired => 'İşlem adı gerekli';

  @override
  String get amountWithCurrency => 'Tutar (₺)';

  @override
  String get amountRequired => 'Tutar gerekli';

  @override
  String get enterValidAmount => 'Geçerli bir tutar girin';

  @override
  String get everyMonthOn => 'Her ayın:';

  @override
  String dayOfMonth(int day) {
    return '$day. günü';
  }

  @override
  String get paymentMethod => 'Ödeme Yöntemi';

  @override
  String get selectPaymentMethod => 'Ödeme Yöntemi Seçin';

  @override
  String get update => 'Güncelle';

  @override
  String get transactionUpdated => 'İşlem güncellendi';

  @override
  String get transactionAdded => 'İşlem eklendi';

  @override
  String get errorWhileSaving => 'Kaydetme sırasında bir hata oluştu';

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String get recurringTransactionsInfo =>
      'Tanımladığınız işlemler her ayın belirlediğiniz gününde otomatik olarak harcamalarınıza eklenir.';

  @override
  String get noRecurringTransactions => 'Henüz tekrarlayan işlem yok';

  @override
  String get tapPlusToAdd => 'Eklemek için + butonuna tıklayın';

  @override
  String get deleteTransaction => 'İşlemi Sil';

  @override
  String deleteTransactionConfirm(String name) {
    return '$name işlemini silmek istiyor musunuz?';
  }

  @override
  String get unnamed => 'İsimsiz';

  @override
  String everyMonthDayOf(int day, String method) {
    return 'Her ayın $day. günü • $method';
  }

  @override
  String get categoryBasedUsage => 'Kategori Bazlı Kullanım';

  @override
  String get unlimitedCategories => 'Limitsiz Kategoriler';

  @override
  String get totalBudget => 'Toplam Bütçe';

  @override
  String exceeded(String amount) {
    return 'Aşım: $amount';
  }

  @override
  String remaining(String amount) {
    return 'Kalan: $amount';
  }

  @override
  String exceededPercent(String percent) {
    return 'Aşıldı! $percent%';
  }

  @override
  String get categoryBudgetInfo =>
      'Her kategori için aylık harcama limiti belirleyin. Limit yaklaştığında veya aşıldığında ana sayfada uyarı göreceksiniz.';

  @override
  String get categoryBudgetDialogInfo =>
      'Bu kategori için aylık harcama limiti belirleyin. Limit aşıldığında ana sayfada uyarı görürsünüz.';

  @override
  String get monthlyLimit => 'Aylık Limit';

  @override
  String get noLimit => 'Limitsiz';

  @override
  String get zeroNoLimit => '0 = Limitsiz';

  @override
  String get limitNotSet => 'Limit belirlenmemiş';

  @override
  String monthlyLimitAmount(String amount) {
    return '$amount₺ aylık limit';
  }

  @override
  String get removeLimit => 'Limiti Kaldır';

  @override
  String limitRemoved(String category) {
    return '$category limiti kaldırıldı';
  }

  @override
  String get maxLimitWarning => 'Maximum 10 milyar ₺ limit belirleyebilirsiniz';

  @override
  String limitSet(String category, String amount) {
    return '$category limiti $amount₺ olarak ayarlandı';
  }

  @override
  String activeBudgets(int count) {
    return '$count aktif';
  }

  @override
  String get expenseDetail => 'Harcama Detayı';

  @override
  String get expenseInfo => 'Harcama Bilgileri';

  @override
  String get spentAmountLabel => 'Harcanan Tutar';

  @override
  String get deleteExpense => 'Harcamayı Sil';

  @override
  String deleteExpenseConfirm(String name) {
    return '\"$name\" harcamasını silmek istediğinize emin misiniz?';
  }

  @override
  String get expenseCategories => 'Harcama Kategorileri';

  @override
  String get editPhotoTitle => 'Fotoğraf Düzenle';

  @override
  String get resetAllEffects => 'Tüm Efektleri Sıfırla';

  @override
  String get confirm => 'Onayla';

  @override
  String get tryAgainShort => 'Yeniden';

  @override
  String scheduledTransfersFailed(String reasons) {
    return 'Şu işlemler gerçekleştirilemedi: $reasons';
  }

  @override
  String get senderAccountNotFound => 'Gönderen hesap bulunamadı';

  @override
  String get receiverAccountNotFound => 'Alıcı hesap bulunamadı';

  @override
  String accountDeleted(String account) {
    return '$account silinmiş';
  }

  @override
  String insufficientBalanceAccount(String accountName) {
    return '$accountName hesabında yetersiz bakiye';
  }

  @override
  String noDebtToPay(String accountName) {
    return '$accountName kapatılacak borç yok';
  }

  @override
  String get voiceCmdAddExpenseTitle => 'Harcama Ekleme';

  @override
  String get voiceCmdAddExpenseDesc =>
      'Tutarı, kategoriyi ve opsiyonel olarak tarihi söyleyerek harcama ekleyin.';

  @override
  String get voiceCmdAddExpenseExamples =>
      '100 lira market|50 TL kahve|Dün 80 lira market|Geçen pazartesi 200 TL benzin|Önceki gün 150 lira yemek';

  @override
  String get voiceCmdDeleteExpenseTitle => 'Harcama Silme';

  @override
  String get voiceCmdDeleteExpenseDesc => 'Son eklediğiniz harcamayı silin.';

  @override
  String get voiceCmdDeleteExpenseExamples =>
      'Son harcamayı sil|Sonuncuyu sil|Son eklediğimi sil|Son kaydı sil';

  @override
  String get voiceCmdEditExpenseTitle => 'Harcama Düzenleme';

  @override
  String get voiceCmdEditExpenseDesc => 'Son harcamanızın tutarını değiştirin.';

  @override
  String get voiceCmdEditExpenseExamples =>
      'Son harcamayı 100 lira yap|Sonuncuyu 50 TL yap|Son harcamayı 200 lira güncelle|Son kaydı 75 lira değiştir';

  @override
  String get voiceCmdTotalQueryTitle => 'Toplam Harcama Sorgulama';

  @override
  String get voiceCmdTotalQueryDesc =>
      'Aylık, haftalık veya günlük toplam harcamanızı öğrenin.';

  @override
  String get voiceCmdTotalQueryExamples =>
      'Bu ay ne kadar harcadım?|Bu hafta ne kadar harcadım?|Bugün ne kadar harcadım?|Toplam harcamam ne kadar?|Haftalık harcamam|Bugünkü harcamam';

  @override
  String get voiceCmdCategoryAnalysisTitle => 'Kategori Analizi';

  @override
  String get voiceCmdCategoryAnalysisDesc =>
      'En çok harcama yaptığınız kategoriyi öğrenin.';

  @override
  String get voiceCmdCategoryAnalysisExamples =>
      'En çok hangi kategoride harcamışım?|En çok nereye harcadım?|En fazla harcama nerede?';

  @override
  String get voiceCmdCategoryQueryTitle => 'Kategoriye Göre Harcama';

  @override
  String get voiceCmdCategoryQueryDesc =>
      'Belirli bir kategorideki toplam harcamanızı öğrenin.';

  @override
  String get voiceCmdCategoryQueryExamples =>
      'Markete ne kadar harcadım?|Yemek kategorisinde ne kadar?|Ulaşıma ne kadar harcamışım?|Spor kategorisinde kaç lira?';

  @override
  String get voiceCmdLastExpensesTitle => 'Son Harcamaları Listeleme';

  @override
  String get voiceCmdLastExpensesDesc =>
      'Son yaptığınız harcamaları listeleyin.';

  @override
  String get voiceCmdLastExpensesExamples =>
      'Son harcamalarım neler?|Son harcamalarımı söyle|Son 5 harcamam|Son harcamalarımı listele';

  @override
  String get voiceCmdBudgetStatusTitle => 'Bütçe Durumu';

  @override
  String get voiceCmdBudgetStatusDesc => 'Bütçenizin durumunu kontrol edin.';

  @override
  String get voiceCmdBudgetStatusExamples =>
      'Bütçemi aştım mı?|Limit durumum ne?|Limiti geçtim mi?|Bütçe durumu';

  @override
  String get voiceCmdRemainingBudgetTitle => 'Kalan Bütçe Sorgulama';

  @override
  String get voiceCmdRemainingBudgetDesc =>
      'Bütçenizden ne kadar kaldığını öğrenin.';

  @override
  String get voiceCmdRemainingBudgetExamples =>
      'Kalan bütçem ne kadar?|Ne kadar harcayabilirim?|Kalan limitim|Bütçemden ne kadar kaldı?';

  @override
  String get voiceCmdSetLimitTitle => 'Bütçe Limiti Belirleme';

  @override
  String get voiceCmdSetLimitDesc =>
      'Sesli olarak aylık bütçenizi güncelleyin.';

  @override
  String get voiceCmdSetLimitExamples =>
      'Aylık limitimi 10000 lira yap|Bütçemi 5000 lira olarak ayarla|Limitimi 8000 lira güncelle|Aylık bütçe 15000 lira olsun';

  @override
  String get voiceCmdSavingsTitle => 'Tasarruf Hesaplama';

  @override
  String get voiceCmdSavingsDesc =>
      'Bu ay ne kadar tasarruf ettiğinizi öğrenin.';

  @override
  String get voiceCmdSavingsExamples =>
      'Bu ay ne kadar tasarruf ettim?|Tasarrufum ne kadar?|Ne kadar biriktirdim?|Artıda mıyım?';

  @override
  String get voiceCmdAddFixedTitle => 'Sabit Giderleri Ekle';

  @override
  String get voiceCmdAddFixedDesc =>
      'Ayarlardan tanımladığınız sabit giderleri bu aya ekleyin.';

  @override
  String get voiceCmdAddFixedExamples =>
      'Sabit giderleri ekle|Sabit giderleri bu aya ekle|Faturaları ekle|Düzenli giderleri ekle';

  @override
  String get privacyPolicyContent =>
      '1. Giriş\n\nBu Gizlilik Politikası, Cashly uygulamasının (\"Uygulama\") kullanıcılarının kişisel verilerinin nasıl toplandığını, saklandığını ve korunduğunu açıklamaktadır. Uygulamayı kullanarak bu politikayı kabul etmiş sayılırsınız.\n\nSon güncelleme: 17 Şubat 2026\n\n2. Veri Toplama ve Kullanım\n\nCashly, tüm verilerinizi yalnızca cihazınızda (yerel olarak) saklar. Sunucularımıza herhangi bir kişisel veri gönderilmez, aktarılmaz veya iletilmez.\n\nToplanan ve cihazda saklanan veriler:\n• Kullanıcı bilgileri (isim ve e-posta adresi)\n• Harcama ve gelir kayıtları (tutar, kategori, tarih, açıklama)\n• Varlık bilgileri (tür, miktar, değer)\n• Ödeme yöntemleri ve bakiye bilgileri\n• Transfer kayıtları\n• Bütçe limitleri ve kategori bütçeleri\n• Profil fotoğrafı (isteğe bağlı)\n• Uygulama tercihleri ve ayarları\n• Seri (streak) kayıtları\n\nBu veriler yalnızca uygulamanın temel işlevlerini sağlamak amacıyla kullanılır.\n\n3. Veri Güvenliği\n\nVerilerinizin güvenliği bizim için en önemli önceliktir:\n\n• Tüm veriler cihazınızda yerel veritabanında saklanır.\n• 4 haneli PIN kodu ile uygulamaya erişim korunur.\n• Biyometrik doğrulama (parmak izi / yüz tanıma) desteği mevcuttur.\n• Güvenlik sorusu ile ek koruma katmanı sağlanır.\n• Uygulama arka plana alındığında otomatik kilit devreye girer.\n• Uygulama dışarıya herhangi bir ağ bağlantısı kurmaz.\n\n4. Üçüncü Taraf Paylaşımı\n\nCashly, topladığı hiçbir veriyi üçüncü taraflarla paylaşmaz, satmaz veya kiralamaz. Verileriniz tamamen size aittir. Uygulama içinde üçüncü taraf analitik veya reklam araçları kullanılmamaktadır.\n\n5. Veri Yedekleme ve Aktarım\n\n• Yedekleme işlemi tamamen kullanıcı kontrolündedir ve isteğe bağlıdır.\n• Yedek dosyaları JSON formatında cihazınıza dışa aktarılır.\n• Yedek dosyasının güvenliği ve saklanması kullanıcının sorumluluğundadır.\n• Yedek dosyası; harcamalar, gelirler, varlıklar, ödeme yöntemleri, transferler ve profil bilgilerini içerir.\n• Geri yükleme işlemi mevcut verilerin üzerine yazar.\n\n6. Veri Saklama Süresi\n\nVerileriniz, hesabınızı silene kadar cihazınızda saklanır. Uygulamayı kaldırmanız durumunda tüm veriler otomatik olarak silinir.\n\n7. Veri Silme Hakkı\n\nHesabınızı ve tüm verilerinizi istediğiniz zaman kalıcı olarak silebilirsiniz:\n• Profil > Kullanıcı Bilgileri > Hesabı Sil seçeneğini kullanın.\n• Silme işlemi güvenlik doğrulaması gerektirir.\n• Silinen veriler geri getirilemez.\n• Silme öncesi yedek almanız önerilir.\n\n8. Çocukların Gizliliği\n\nCashly, 13 yaşın altındaki çocuklara yönelik değildir. 13 yaşın altındaki kullanıcılardan bilerek veri toplamıyoruz.\n\n9. Politika Değişiklikleri\n\nBu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinden bildirilecektir.\n\n10. İletişim\n\nGizlilik politikamız hakkında sorularınız veya talepleriniz için uygulama içinden bizimle iletişime geçebilirsiniz.';

  @override
  String get termsOfServiceContent =>
      '1. Kabul ve Kapsam\n\nCashly uygulamasını (\"Uygulama\") indirerek, kurarak veya kullanarak bu Kullanım Koşullarını kabul etmiş olursunuz. Bu koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayınız.\n\nSon güncelleme: 17 Şubat 2026\n\n2. Hizmet Tanımı\n\nCashly, kişisel bütçe takibi ve finansal yönetim aracıdır. Uygulama aşağıdaki hizmetleri sunar:\n\n• Harcama ve gelir takibi (manuel ve sesli giriş)\n• Varlık yönetimi (altın, döviz, kripto, banka hesabı)\n• Bütçe planlama ve kategori bazlı limit belirleme\n• Ödeme yöntemi yönetimi ve bakiye takibi\n• Hesaplar arası transfer kayıtları\n• Düzenli gelir/gider tanımlama\n• Sesli asistan ile doğal dil komutları\n• Veri yedekleme ve geri yükleme\n• İstatistik ve grafik raporları\n\n3. Hesap ve Güvenlik\n\n• Hesabınızı oluştururken doğru bilgiler girmeniz gerekmektedir.\n• PIN kodunuz hesabınızın güvenlik anahtarıdır; kimseyle paylaşmayınız.\n• Biyometrik giriş ve güvenlik sorusu ek koruma katmanlarıdır.\n• Hesabınıza yetkisiz erişimden siz sorumlusunuz.\n• Şüpheli bir durum fark ederseniz PIN kodunuzu değiştirmeniz önerilir.\n\n4. Kullanıcı Sorumlulukları\n\n• Girdiğiniz finansal veriler tamamen size aittir ve doğruluğundan siz sorumlusunuz.\n• Uygulamayı yasa dışı amaçlarla kullanamazsınız.\n• Düzenli veri yedeklemesi yapmanız önerilir.\n• Yedek dosyalarınızın güvenliğinden siz sorumlusunuz.\n• Uygulamayı tersine mühendislik, kaynak kod çıkarma veya değiştirme girişiminde bulunamazsınız.\n\n5. Sorumluluk Reddi\n\nÖNEMLİ - Lütfen dikkatlice okuyunuz:\n\n• Cashly bir finansal danışmanlık, yatırım tavsiyesi veya muhasebe aracı değildir.\n• Uygulama, herhangi bir yatırım, tasarruf veya harcama tavsiyesi vermez.\n• Finansal kararlarınızdan Cashly sorumlu tutulamaz.\n• Uygulama \"olduğu gibi\" sunulmaktadır; kesintisiz veya hatasız çalışacağı garanti edilmez.\n• Cihaz arızası, yazılım hatası veya kullanıcı kaynaklı veri kaybından dolayı sorumluluk kabul edilmez.\n• Güncel döviz kurları ve varlık fiyatları bilgi amaçlıdır; gerçek piyasa değerlerinden farklılık gösterebilir.\n\n6. Veri ve İçerik\n\n• Uygulamaya girdiğiniz tüm veriler cihazınızda saklanır.\n• Verilerin doğruluğu, bütünlüğü ve güncelliğinden siz sorumlusunuz.\n• Hesap silme işlemi geri alınamaz; tüm verileriniz kalıcı olarak kaldırılır.\n\n7. Fikri Mülkiyet\n\n• Cashly uygulaması, tasarımı, logoları ve tüm içeriği telif hakkı ile korunmaktadır.\n• Uygulama kodunun, görsellerinin ve tasarımının izinsiz kopyalanması, dağıtılması veya türev çalışma oluşturulması yasaktır.\n• \"Cashly\" ismi ve logosu tescilli markadır.\n\n8. Hizmet Değişiklikleri\n\n• Uygulama özellikleri önceden haber verilmeksizin eklenebilir, değiştirilebilir veya kaldırılabilir.\n• Güncellemeler, hata düzeltmeleri ve iyileştirmeler düzenli olarak yapılabilir.\n\n9. Koşul Değişiklikleri\n\nBu kullanım koşulları zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinden bildirilecektir. Güncellemelerden sonra uygulamayı kullanmaya devam etmeniz, yeni koşulları kabul ettiğiniz anlamına gelir.\n\n10. Geçerli Hukuk\n\nBu koşullar Türkiye Cumhuriyeti yasalarına tabidir. Uyuşmazlıklarda Türkiye mahkemeleri yetkilidir.\n\n11. İletişim\n\nKullanım koşullarımız hakkında sorularınız için uygulama içinden bizimle iletişime geçebilirsiniz.';

  @override
  String get faqSafetyQ => 'Verilerim güvende mi?';

  @override
  String get faqSafetyA =>
      'Kesinlikle! Cashly, gizliliğinizi en üst düzeyde korur:\n\n• Tüm verileriniz yalnızca cihazınızda saklanır, hiçbir sunucuya gönderilmez.\n• 4 haneli PIN kodu ile uygulamaya erişim korunur.\n• Biyometrik giriş (parmak izi / yüz tanıma) desteği mevcuttur.\n• Güvenlik sorusu ile ek koruma katmanı ekleyebilirsiniz.\n\nVerileriniz tamamen size aittir ve hiçbir üçüncü tarafla paylaşılmaz.';

  @override
  String get faqOfflineQ => 'İnternet bağlantısı gerekli mi?';

  @override
  String get faqOfflineA =>
      'Hayır! Cashly tamamen çevrimdışı çalışacak şekilde tasarlanmıştır.\n\n• Harcama ve gelir ekleme, düzenleme, silme\n• Varlık yönetimi ve takibi\n• Bütçe planlama ve kategori yönetimi\n• Sesli asistan ile komut verme\n• Veri yedekleme ve geri yükleme\n\nTüm bu özellikler internet olmadan sorunsuz çalışır. Yalnızca güncel döviz/altın kurları için internet bağlantısı gerekebilir.';

  @override
  String get faqBackupQ => 'Verilerimi nasıl yedekleyebilirim?';

  @override
  String get faqBackupA =>
      'Verilerinizi güvence altına almak için düzenli yedekleme yapmanızı öneririz:\n\n1. Profil > Ayarlar > Veri İşlemleri bölümüne gidin.\n2. \"Verileri Yedekle\" seçeneğine dokunun.\n3. Tüm verileriniz JSON formatında bir dosyaya aktarılır.\n4. Dosyayı Google Drive, e-posta veya istediğiniz bir yere kaydedin.\n\nYedek dosyası; harcamalarınızı, gelirlerinizi, varlıklarınızı, ödeme yöntemlerinizi, transferlerinizi ve profil bilgilerinizi içerir.';

  @override
  String get faqRestoreQ => 'Yedeğimi nasıl geri yüklerim?';

  @override
  String get faqRestoreA =>
      'Daha önce aldığınız yedeği geri yüklemek için:\n\n1. Profil > Ayarlar > Veri İşlemleri bölümüne gidin.\n2. \"Verileri Geri Yükle\" seçeneğine dokunun.\n3. Daha önce kaydettiğiniz JSON yedek dosyasını seçin.\n4. İşlem tamamlandığında uygulama otomatik olarak yenilenir.\n\nDikkat: Geri yükleme işlemi mevcut verilerinizi yedekteki verilerle değiştirir. Mevcut verilerinizi kaybetmemek için önce yeni bir yedek almanızı öneririz.';

  @override
  String get faqVoiceAssisQ => 'Sesli asistan nasıl çalışır?';

  @override
  String get faqVoiceAssisA =>
      'Cashly\'nin sesli asistanı, doğal dil ile harcama ve gelir eklemenizi sağlar:\n\n• Ana ekrandaki mikrofon ikonuna dokunun.\n• Doğal bir şekilde komut verin, örneğin:\n  - \"50 lira market harcaması ekle\"\n  - \"1500 lira maaş geliri ekle\"\n  - \"200 lira yemek harcaması ekle nakit ile\"\n\nAsistan, tutarı, kategoriyi ve ödeme yöntemini otomatik olarak algılar. Sesli geri bildirim ile işlemin başarılı olduğunu onaylar. Komut listesinin tamamını Ayarlar > Sesli Asistan bölümünden görebilirsiniz.';

  @override
  String get faqBudgetLimitQ => 'Bütçe limitimi nasıl belirlerim?';

  @override
  String get faqBudgetLimitA =>
      'Aylık harcama bütçenizi kontrol altında tutmak için:\n\n1. Profil > Ayarlar > Harcamalar bölümüne gidin.\n2. \"Aylık Bütçe Limiti\" alanına toplam aylık bütçenizi girin.\n3. Kaydet butonuna dokunun.\n\nBütçe limitinizi belirledikten sonra:\n• Ana ekranda bütçe doluluk oranınızı görebilirsiniz.\n• Limiti aşmaya yaklaştığınızda görsel uyarı alırsınız.\n• Renk kodları ile durumunuzu anlık takip edebilirsiniz (yeşil: güvenli, sarı: dikkat, kırmızı: limit aşıldı).';

  @override
  String get faqCategoryBudgetQ => 'Kategori bazında bütçe limiti nedir?';

  @override
  String get faqCategoryBudgetA =>
      'Genel bütçe limitinin yanı sıra her kategori için ayrı limit belirleyebilirsiniz:\n\n1. Profil > Ayarlar > Harcamalar > Kategori Bütçeleri bölümüne gidin.\n2. İstediğiniz kategoriye dokunun (örn. Yemek & Kafe).\n3. O kategori için aylık limit belirleyin.\n\nÖrnek kullanım:\n• Yemek & Kafe: 2.000₺\n• Ulaşım: 500₺\n• Eğlence: 1.000₺\n\nBu sayede harcamalarınızı kategori bazında detaylı kontrol edebilir ve hangi alanda tasarruf yapabileceğinizi görebilirsiniz.';

  @override
  String get faqRecurringQ => 'Düzenli gelir/gider nedir?';

  @override
  String get faqRecurringA =>
      'Her ay düzenli olarak tekrarlayan gelir veya giderlerinizi tanımlayabilirsiniz:\n\nDüzenli gelir örnekleri: Maaş, kira geliri, yan gelir\nDüzenli gider örnekleri: Kira, internet, telefon faturası, abonelikler\n\nNasıl eklenir:\n1. Ayarlar > Harcamalar veya Gelirler bölümüne gidin.\n2. \"Düzenli İşlemler\" seçeneğine dokunun.\n3. Tutar, kategori ve tekrar sıklığını belirleyin.\n\nDüzenli işlemler her ay otomatik olarak kaydedilir, böylece her seferinde manuel ekleme yapmanıza gerek kalmaz.';

  @override
  String get faqAssetTrackingQ => 'Varlık takibi nasıl yapılır?';

  @override
  String get faqAssetTrackingA =>
      'Cashly ile finansal varlıklarınızı tek bir yerden takip edebilirsiniz:\n\nDesteklenen varlık türleri:\n• Altın (gram, çeyrek, yarım, tam)\n• Döviz (USD, EUR vb.)\n• Kripto para\n• Banka hesapları\n• Gümüş\n\nVarlıklarınızı ekleyin, miktarını ve alış fiyatını girin. Toplam portföy değerinizi, kazanç/kayıp durumunuzu ve varlık dağılımınızı grafiklerle takip edin.';

  @override
  String get faqPaymentMethodsQ => 'Ödeme yöntemlerimi nasıl yönetirim?';

  @override
  String get faqPaymentMethodsA =>
      'Farklı ödeme yöntemlerinizi tanımlayarak harcamalarınızı detaylı takip edin:\n\n• Nakit\n• Banka/kredi kartları\n• Dijital cüzdanlar\n\nHer ödeme yöntemine bakiye tanımlayabilir ve harcama yaptıkça bakiyenin otomatik güncellenmesini sağlayabilirsiniz. Bu sayede hangi karttan ne kadar harcadığınızı veya kasanızda ne kadar nakit kaldığını anlık görebilirsiniz.';

  @override
  String get faqTransferQ => 'Hesaplar arası transfer nasıl yapılır?';

  @override
  String get faqTransferA =>
      'Ödeme yöntemleriniz arasında para transferi kaydedebilirsiniz:\n\nÖrnek senaryolar:\n• Bankadan nakit çekme\n• Kredi kartı borcunu ödeme\n• Bir hesaptan diğerine aktarım\n\nTransfer işlemi, kaynak hesaptan tutarı düşer ve hedef hesaba ekler. Böylece tüm hesaplarınızın bakiyesi her zaman güncel kalır. Transfer geçmişinizi Ayarlar > Para Transferleri bölümünden görüntüleyebilirsiniz.';

  @override
  String get faqNotificationsQ => 'Bildirimler ne işe yarar?';

  @override
  String get faqNotificationsA =>
      'Cashly, finansal hedeflerinizi takip etmeniz için çeşitli bildirimler sunar:\n\n• Günlük hatırlatıcı: Harcamalarınızı girmeyi unutmayın.\n• Bütçe uyarısı: Aylık limitinize yaklaştığınızda uyarı alın.\n• Düzenli işlem bildirimi: Tekrarlayan gelir/giderler kaydedildiğinde bilgilenin.\n\nTüm bildirim ayarlarını Profil > Ayarlar > Bildirimler bölümünden istediğiniz gibi açıp kapatabilir ve saatlerini özelleştirebilirsiniz.';

  @override
  String get faqStreakQ => 'Seri sistemi nedir?';

  @override
  String get faqStreakA =>
      'Seri sistemi, düzenli kullanım alışkanlığı oluşturmanıza yardımcı olan bir motivasyon aracıdır:\n\n• Her gün uygulamayı kullanarak serinizi sürdürün.\n• Ardışık gün sayınız arttıkça seri seviyeniz yükselir.\n• Belirli seviyelere ulaştığınızda kutlama animasyonu görürsünüz.\n• Bir gün kaçırırsanız seriniz sıfırlanır.\n\nSeri sistemi, harcamalarınızı düzenli takip etme alışkanlığı kazanmanıza yardımcı olur. En yüksek serinizi kırmaya çalışın!';

  @override
  String get faqProfilePhotoQ => 'Profil fotoğrafımı nasıl değiştiririm?';

  @override
  String get faqProfilePhotoA =>
      'Profil fotoğrafınızı değiştirmek için:\n\n1. Profil > Kullanıcı Bilgileri sayfasına gidin.\n2. Profil fotoğrafınızın üzerindeki düzenleme ikonuna dokunun.\n3. Galeriden fotoğraf seçin veya hazır avatarlardan birini kullanın.\n4. Seçtiğiniz fotoğrafı kırpın, döndürün ve filtre uygulayın.\n\nFotoğraf düzenleyici ile fotoğrafınızı tam istediğiniz gibi ayarlayabilirsiniz.';

  @override
  String get faqForgotPinQ => 'PIN kodumu unutursam ne yapmalıyım?';

  @override
  String get faqForgotPinA =>
      'PIN kodunuzu unuttuysanız, giriş ekranında güvenlik sorunuzu kullanarak sıfırlama yapabilirsiniz. Bunun için önceden bir güvenlik sorusu ve cevabı belirlemiş olmanız gerekir.\n\nGüvenlik sorunuzu ayarlamak için:\nProfil > Kullanıcı Bilgileri > Güvenlik bölümünü kullanabilirsiniz.\n\nGüvenlik sorusu belirlememişseniz ve PIN\'inizi unuttuysanız, uygulamayı yeniden kurmanız gerekebilir. Bu durumda yedeğiniz varsa verilerinizi geri yükleyebilirsiniz.';

  @override
  String get faqDeleteAccountQ => 'Hesabımı silersem ne olur?';

  @override
  String get faqDeleteAccountA =>
      'Hesap silme işlemi kalıcıdır ve geri alınamaz. Silinen veriler:\n\n• Tüm harcama kayıtları\n• Tüm gelir kayıtları\n• Varlıklarınız\n• Ödeme yöntemleri ve bakiyeleri\n• Transfer geçmişi\n• Seri kayıtları\n• Profil bilgileri ve fotoğrafınız\n\nSilmeden önce mutlaka verilerinizi yedeklemenizi öneririz. Hesap silme işlemi güvenlik doğrulaması (matematik sorusu) gerektirir ve iki aşamalı onay ile gerçekleştirilir.';

  @override
  String get done => 'Bitti';

  @override
  String get selectTime => 'Saat Seç';

  @override
  String get selectMonthAndYear => 'Ay ve Yıl Seç';

  @override
  String get selectDateAndTime => 'Tarih ve Saat Seç';

  @override
  String get errorOccurred => 'Bir Hata Oluştu';

  @override
  String get unexpectedErrorRestart =>
      'Beklenmedik bir hata meydana geldi.\nLütfen uygulamayı yeniden başlatın.';

  @override
  String get technicalDetails => 'Teknik Detaylar';

  @override
  String get anErrorOccurred => 'Bir hata oluştu';

  @override
  String get componentLoadError => 'Bu bileşen yüklenirken bir sorun oluştu.';

  @override
  String pageLoadError(String pageName) {
    return '$pageName sayfası yüklenirken bir hata oluştu.';
  }

  @override
  String get operationSuccessful => 'İşlem başarılı!';

  @override
  String get limitWarning => 'Limit Uyarısı';

  @override
  String get balanceWarning => 'Bakiye Uyarısı';

  @override
  String get continueAnyway => 'Yine de devam etmek istiyor musunuz?';

  @override
  String get remainingLimitLabel => 'Kalan Limit';

  @override
  String get currentBalanceLabel => 'Mevcut Bakiye';

  @override
  String get expenseAmountLabel => 'Harcama Tutarı';

  @override
  String get offlineMode => 'Çevrimdışı Mod';

  @override
  String get noInternetConnection => 'İnternet bağlantısı yok';

  @override
  String get unavailableFeatures => 'Çalışmayan Özellikler';

  @override
  String get assetPriceUpdates => 'Varlık fiyat güncellemeleri';

  @override
  String get realTimeExchangeRates => 'Gerçek zamanlı döviz kurları';

  @override
  String get limitedFeatures => 'Kısıtlı Özellikler';

  @override
  String get assetValuesLastKnown =>
      'Varlık değerleri bilinen son fiyatlarla gösterilir';

  @override
  String get assetInsightTitle => 'Net Varlık Gelişimi';

  @override
  String assetIncrease(Object percent) {
    return '%$percent Kur/Piyasa artışı';
  }

  @override
  String assetDecrease(Object percent) {
    return '%$percent Kur/Piyasa azalışı';
  }

  @override
  String get assetNoChange => 'Değer değişmedi';

  @override
  String get fxImpactNotice => 'Piyasa ve kur farkı';

  @override
  String get fullyWorkingFeatures => 'Tam Çalışan Özellikler';

  @override
  String get addEditIncomeExpense => 'Gelir/Gider ekleme ve düzenleme';

  @override
  String get backupAndRestore => 'Yedekleme ve geri yükleme';

  @override
  String get chartsAndReports => 'Grafikler ve raporlar';

  @override
  String get allLocalData => 'Tüm yerel veriler';

  @override
  String get understood => 'Anladım';

  @override
  String get pleaseEnterEmail => 'Lütfen e-posta adresinizi girin';

  @override
  String get enterValidEmail => 'Geçerli bir e-posta adresi girin';

  @override
  String get pleaseSetPin => 'Lütfen bir PIN belirleyin';

  @override
  String get pinLengthError => 'PIN 4 ile 6 rakam arasında olmalıdır';

  @override
  String get pinDigitsOnly => 'PIN sadece rakamlardan oluşmalıdır';

  @override
  String get pleaseEnterName => 'Lütfen bir isim girin';

  @override
  String get nameMinLength => 'İsim en az 2 karakter olmalı';

  @override
  String get nameMaxLength => 'İsminiz en fazla 50 karakter olabilir';

  @override
  String get pleaseEnterAmount => 'Lütfen tutar girin';

  @override
  String get enterValidNumber => 'Geçerli bir sayı girin';

  @override
  String get amountMustBePositive => 'Tutar pozitif bir sayı olmalıdır';

  @override
  String get pleaseEnterQuantity => 'Lütfen miktar girin';

  @override
  String get enterValidNumberFormat => 'Geçerli bir sayı formatı girin';

  @override
  String get quantityCannotBeNegative => 'Miktar negatif olamaz';

  @override
  String get quantityMustBeGreaterThanZero => 'Miktar 0\'dan büyük olmalıdır';

  @override
  String get pleaseEnterCardName => 'Lütfen kart adını girin';

  @override
  String get cardNameMinLength => 'Kart adı en az 2 karakter olmalıdır';

  @override
  String get cardNameMaxLength => 'Kart adı en fazla 30 karakter olabilir';

  @override
  String get pleaseEnterLastFourDigits => 'Lütfen son 4 haneyi girin';

  @override
  String get lastFourDigitsLength => 'Son 4 hane tam 4 rakam olmalıdır';

  @override
  String get lastFourDigitsOnly => 'Son 4 hane sadece rakamlardan oluşmalıdır';

  @override
  String get pleaseEnterDebtAmount => 'Lütfen borç tutarını girin';

  @override
  String get pleaseEnterBalanceAmount => 'Lütfen bakiye girin';

  @override
  String get invalidAmountFormat => 'Geçersiz tutar formatı';

  @override
  String get amountCannotBeNegative => 'Tutar negatif olamaz';

  @override
  String get limitMustBeGreaterThanZero => 'Limit 0\'dan büyük olmalı';

  @override
  String get limitLessThanDebt => 'Limit mevcut borçtan küçük olamaz';

  @override
  String get genericError => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get dataNotFoundError => 'Veri bulunamadı';

  @override
  String get connectionError =>
      'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';

  @override
  String get timeoutError =>
      'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get permissionError => 'Erişim izni hatası';

  @override
  String get priceFetchFailed => 'Fiyat çekilemedi, lütfen manuel giriniz.';

  @override
  String get priceFetchError =>
      'Fiyat alınırken hata oluştu. Lütfen manuel giriniz.';

  @override
  String get pleaseFillRequiredFields => 'Lütfen tüm gerekli alanları doldurun';

  @override
  String get currentPriceButton => 'Güncel';

  @override
  String get amountTL => 'Miktar (TL)';

  @override
  String get purchaseInfo => 'Alış Bilgileri';

  @override
  String get purchasePriceTL => 'Alış Fiyatı (TL)';

  @override
  String get enterValidPrice => 'Geçerli bir fiyat giriniz';

  @override
  String get purchasePriceNegative => 'Alış fiyatı negatif olamaz';

  @override
  String get purchasePriceMustBePositive => 'Alış fiyatı 0\'dan büyük olmalı';

  @override
  String get minPurchasePrice => 'Minimum alış fiyatı 0,01 ₺ olmalı';

  @override
  String get maxPurchasePrice => 'Maksimum alış fiyatı 100 milyon ₺ olabilir';

  @override
  String get quantityLabel => 'Adet';

  @override
  String get stockNameLabel => 'Hisse Adı';

  @override
  String get currencyNameLabel => 'Döviz İsmi';

  @override
  String get cryptoNameLabel => 'Kripto İsmi';

  @override
  String get bankNameLabel => 'Banka Adı';

  @override
  String get assetNameField => 'Varlık İsmi';

  @override
  String get profileUpdated => 'Profil güncellendi';

  @override
  String updateFailed(String error) {
    return 'Güncelleme başarısız: $error';
  }

  @override
  String get profileImageUpdated => 'Profil resmi güncellendi';

  @override
  String get selectProfileImage => 'Profil Resmi Seç';

  @override
  String get galleryOrCameraDesc =>
      'Galerinizden bir fotoğraf seçerek ya da kameradan fotoğraf çekerek profil resminizi değiştirebilirsiniz.';

  @override
  String get cameraLabel => 'Kamera';

  @override
  String get takePhotoLabel => 'Fotoğraf Çek';

  @override
  String get galleryLabel => 'Galeri';

  @override
  String get selectPhotoLabel => 'Fotoğraf Seç';

  @override
  String get changeName => 'İsim Değiştir';

  @override
  String get newNameLabel => 'Yeni İsim';

  @override
  String get nameCannotBeEmpty => 'İsim boş olamaz';

  @override
  String get nameUpdated => 'İsim Soyisim Güncellendi';

  @override
  String get currentPinLabel => 'Mevcut PIN';

  @override
  String get newPinLabel => 'Yeni PIN';

  @override
  String get newPinRepeatLabel => 'Yeni PIN (Tekrar)';

  @override
  String get enterPinDigits => '4-6 haneli PIN giriniz';

  @override
  String get pinIncorrect => 'PIN hatalı';

  @override
  String get pinsDoNotMatch => 'PIN\'ler eşleşmiyor';

  @override
  String get pinUpdated => 'PIN Güncellendi';

  @override
  String get pinVerification => 'PIN Doğrulama';

  @override
  String get biometricPinVerificationDesc =>
      'Biyometrik girişi aktifleştirmek için PIN\'inizi doğrulayın';

  @override
  String get activateBiometric => 'Biyometriği Aktifleştir';

  @override
  String get finalConfirmation => 'Son Onay';

  @override
  String get permanentDeleteAccountConfirm =>
      'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz?';

  @override
  String get yesDelete => 'Evet, Sil';

  @override
  String get accountDeletedSuccess => 'Hesabınız başarıyla silindi';

  @override
  String accountDeleteError(String error) {
    return 'Hesap silinirken hata oluştu: $error';
  }

  @override
  String get deletePermanently => 'Kalıcı Sil';

  @override
  String get pinVerificationTitle => 'PIN Doğrulaması';

  @override
  String get forwardButton => 'İleri';

  @override
  String get thisActionIrreversibleWarning =>
      'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecektir.';

  @override
  String get expenseMovedToTrash => 'Harcama çöp kutusuna taşındı 🗑️';

  @override
  String get expenseRestored => 'Harcama geri yüklendi ';

  @override
  String get noSearchResults => 'Sonuç bulunamadı';

  @override
  String get tryDifferentSearch => 'Farklı bir arama terimi deneyin';

  @override
  String get emptyTrashTitle => 'Çöpü Boşalt';

  @override
  String get emptyTrashConfirm =>
      'Tüm silinen harcamalar kalıcı olarak yok edilecek. Emin misin?';

  @override
  String get trashEmptied => 'Çöp kutusu temizlendi.';

  @override
  String get restoreAllTitle => 'Tümünü Geri Yükle';

  @override
  String restoreAllConfirm(int count) {
    return '$count harcama geri yüklenecek. Onaylıyor musun?';
  }

  @override
  String get yesRestore => 'Evet, Geri Yükle';

  @override
  String get allExpensesRestored => 'Tüm harcamalar geri yüklendi ';

  @override
  String get noDeletedExpenses => 'Silinen harcama yok.';

  @override
  String get expensePermanentlyDeleted => 'Harcama kalıcı olarak silindi ';

  @override
  String get expenseRestoredRecycled => 'Harcama geri yüklendi ♻️';

  @override
  String get deleteCategory => 'Kategoriyi Sil';

  @override
  String deleteCategoryConfirm(String name) {
    return '\"$name\" kategorisini silmek istediğinizden emin misiniz?';
  }

  @override
  String get categoryDeleted => 'Kategori silindi';

  @override
  String get categoryAdded => 'Kategori eklendi ';

  @override
  String systemCategoryCannotDelete(String name) {
    return '\"$name\" sistem kategorisidir ve silinemez';
  }

  @override
  String get resetToDefault => 'Varsayılana Dön';

  @override
  String get resetCategoriesConfirm =>
      'Tüm özel kategorileriniz silinecek ve varsayılan kategoriler yüklenecek. Emin misiniz?';

  @override
  String get yesReset => 'Evet, Sıfırla';

  @override
  String get defaultCategoriesLoaded => 'Varsayılan kategoriler yüklendi';

  @override
  String get addNewCategory => 'Yeni Kategori Ekle';

  @override
  String get myCategories => 'KATEGORİLERİM';

  @override
  String get addNew => 'Yeni Ekle';

  @override
  String get selectIconLabel => 'İkon Seç:';

  @override
  String get categoryOrderUpdated => 'Kategori sırası güncellendi';

  @override
  String get micPermissionDenied =>
      'Mikrofon izni verilemedi veya cihaz desteklemiyor.';

  @override
  String get expenseDeletion => 'Harcama Silme';

  @override
  String get deleteLastExpenseConfirm =>
      'Son eklenen harcamayı silmek istediğinizden emin misiniz?';

  @override
  String get commandNotSupported => 'Bu komut henüz desteklenmiyor';

  @override
  String get noExpenseFoundYet => 'Henüz harcama bulunmuyor';

  @override
  String get categoryNotUnderstood => 'Kategori anlaşılamadı';

  @override
  String get addRecurringToMonthConfirm =>
      'Tanımlı tekrarlayan işlemleri bu aya eklemek istiyor musunuz?';

  @override
  String get expenseEditingTitle => 'Harcama Düzenleme';

  @override
  String get newAmountNotUnderstood =>
      'Yeni tutarı anlayamadım. Örneğin \"Son harcamayı 100 lira yap\" diyebilirsiniz.';

  @override
  String get budgetLimitUpdateTitle => 'Bütçe Limiti Güncelleme';

  @override
  String get limitUpdateError => 'Limit güncellenirken bir hata oluştu';

  @override
  String get commandProcessing => 'Komut işleniyor...';

  @override
  String get heardLabel => 'Duyulan:';

  @override
  String get howToUse => 'Nasıl kullanılır?';

  @override
  String get voiceAssistantCapabilities =>
      'Sesli asistan ile şunları yapabilirsiniz:';

  @override
  String get addingExpenseLabel => 'Harcama ekleme';

  @override
  String get deletingExpenseLabel => 'Harcama silme';

  @override
  String get queryExpenseLabel => 'Harcama sorgulama';

  @override
  String get categoryAnalysisLabel => 'Kategori analizi';

  @override
  String get budgetControlLabel => 'Bütçe kontrolü';

  @override
  String get detailedCommandListInfo =>
      'Detaylı komut listesi için:\nAyarlar → Sesli Asistan → Tüm Komutlar';

  @override
  String get voiceIncomeInput => 'Sesli Gelir Girişi';

  @override
  String get voiceExpenseInput => 'Sesli Harcama Girişi';

  @override
  String get micPreparing => 'Mikrofon hazırlanıyor...';

  @override
  String get micListening => 'Dinliyorum...';

  @override
  String get tapToSpeakAgain => 'Tekrar konuşmak için dokunun';

  @override
  String get tapToStopMic => 'Durdurmak için mikrofona dokunun';

  @override
  String get pdfReportGenerated => 'PDF raporu oluşturuldu';

  @override
  String pdfGenerationError(String error) {
    return 'PDF oluşturulurken hata: $error';
  }

  @override
  String get expenseNameLabel => 'Harcama Adı';

  @override
  String get whatDidYouBuy => 'Ne aldın? (Örn: Kahve)';

  @override
  String get expenseDateLabel => 'Harcama Tarihi';

  @override
  String get selectPaymentMethodHint => 'Ödeme Yöntemi Seçin';

  @override
  String get enterValidAmountError => 'Geçerli bir tutar girin';

  @override
  String get recurringTransactionsLabel => 'Tekrarlayan İşlemler';

  @override
  String recurringItemsAdded(int count) {
    return '$count adet tekrarlayan işlem eklendi!';
  }

  @override
  String expenseAddedVoice(String name, String amount) {
    return 'Harcama eklendi: $name - $amount ₺';
  }

  @override
  String monthlyBudgetUpdated(String amount) {
    return 'Aylık bütçe $amount ₺ olarak güncellendi';
  }

  @override
  String get limitNotUnderstood =>
      'Limit tutarını anlayamadım. Örneğin \"Aylık limitimi 10000 lira yap\" diyebilirsiniz.';

  @override
  String updateExpenseConfirm(String amount) {
    return 'Son harcamayı $amount ₺ olarak güncellemek istiyor musunuz?';
  }

  @override
  String expenseUpdatedVoice(String name, String amount) {
    return '$name güncellendi: $amount ₺';
  }

  @override
  String monthlyBudgetUpdateConfirm(String amount) {
    return 'Aylık bütçeniz $amount ₺ olarak güncellensin mi?';
  }

  @override
  String maxAmountError(String amount) {
    return 'Maksimum tutar $amount ₺ olabilir';
  }

  @override
  String descriptionMaxLength(int maxLength) {
    return 'Açıklama en fazla $maxLength karakter olabilir';
  }

  @override
  String itemNameRequired(String itemType) {
    return '$itemType adı gereklidir';
  }

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName gereklidir';
  }

  @override
  String quantityTooSmall(String min) {
    return 'Miktar çok küçük (min: $min)';
  }

  @override
  String quantityTooLarge(String max) {
    return 'Miktar çok büyük (max: $max)';
  }

  @override
  String maxDecimalPlaces(int count) {
    return 'En fazla $count ondalık basamak girebilirsiniz';
  }

  @override
  String maxBalanceError(String amount) {
    return 'Maksimum tutar $amount olabilir';
  }

  @override
  String minLimitError(String amount) {
    return 'Minimum limit $amount ₺ olmalı';
  }

  @override
  String maxLimitError(String amount) {
    return 'Maksimum limit $amount olabilir';
  }

  @override
  String get streakInfo => 'Seri Bilgileri';

  @override
  String get howStreakWorks => 'Seri Nasıl Çalışır?';

  @override
  String get editPhotoBtn => 'Fotoğraf Düzenle';

  @override
  String cropError(String error) {
    return 'Kırpma hatası: $error';
  }

  @override
  String saveError(String error) {
    return 'Kaydetme hatası: $error';
  }

  @override
  String get myPaymentMethods => 'Ödeme Yöntemlerim';

  @override
  String get myIncomesTitle => 'Gelirlerim';

  @override
  String get enterValidAmountAndName => 'Lütfen geçerli tutar ve isim girin';

  @override
  String get tryAgainAction => 'Tekrar Dene';

  @override
  String get incomeRecycleBin => 'Gelir Çöp Kutusu';

  @override
  String get incomeCategories => 'Gelir Kategorileri';

  @override
  String get incomeSettingsTitle => 'Gelir Ayarları';

  @override
  String get recurringIncomesTitle => 'Tekrarlayan Gelirler';

  @override
  String get expenseCategoriesTitle => 'Harcama Kategorileri';

  @override
  String get myExpensesTitle => 'Harcamalarım';

  @override
  String get assetRecycleBin => 'Varlık Çöp Kutusu';

  @override
  String get assetDetail => 'Varlık Detayı';

  @override
  String get deleteAsset => 'Varlığı Sil';

  @override
  String deleteAssetConfirm(String name) {
    return '\"$name\" varlığını silmek istediğinize emin misiniz?';
  }

  @override
  String get myAssets => 'Varlıklarım';

  @override
  String get analysisAndReports => 'Analiz ve Raporlar';

  @override
  String get expenseTab => 'Harcama';

  @override
  String get incomeTab => 'Gelir';

  @override
  String get assetTab => 'Varlık';

  @override
  String get widgetCreationError => 'Widget oluşturulurken bir hata oluştu.';

  @override
  String appInitializationFailedMsg(String error) {
    return 'Uygulama başlatılamadı\\n$error';
  }

  @override
  String get manageFinancialTransactions => 'Finansal işlemlerinizi yönetin';

  @override
  String get cashFlow => 'Nakit Akışı';

  @override
  String get myWallet => 'Cüzdanım';

  @override
  String get otherTransactions => 'Diğer İşlemler';

  @override
  String get moneyTransfer => 'Para Transferi';

  @override
  String get assetsSubtitle => 'Altın, döviz, kripto ve diğer varlıklar';

  @override
  String get paymentMethodsSubtitle => 'Banka kartları ve nakit hesapları';

  @override
  String get analysisSubtitle => 'Harcama ve gelir istatistikleri';

  @override
  String get transferSubtitle => 'Hesaplar arası para aktarımı';

  @override
  String get cardType => 'Kart Tipi';

  @override
  String get nameLabel => 'İsim';

  @override
  String get bankCardName => 'Banka/Kart Adı';

  @override
  String get lastFourDigits => 'Son 4 Hane (Opsiyonel)';

  @override
  String get cardLimit => 'Kart Limiti';

  @override
  String get cardColor => 'Kart Rengi';

  @override
  String get swipeForMoreColors => 'Daha fazla renk için sağa kaydırın →';

  @override
  String get nameMustContainLetter => 'İsim en az bir harf içermeli';

  @override
  String get mustBeFourDigits => 'Tam 4 rakam girmelisiniz';

  @override
  String get invalidCardNumber => 'Geçersiz kart numarası';

  @override
  String get pleaseEnterDebt => 'Lütfen borç tutarını girin (0 olabilir)';

  @override
  String get pleaseEnterBalance => 'Lütfen bakiye girin';

  @override
  String get maxAmountLimit => 'Maksimum tutar 100 milyon ₺ olabilir';

  @override
  String get limitCannotBeLessThanDebt => 'Limit mevcut borçtan küçük olamaz';

  @override
  String get minLimitWarning => 'Minimum limit 100 ₺ olmalı';

  @override
  String get foodAndCafe => 'Yemek ve Kafe';

  @override
  String get groceryAndSnacks => 'Market ve Atıştırmalık';

  @override
  String get vehicleAndTransport => 'Araç ve Ulaşım';

  @override
  String get giftAndSpecial => 'Hediye ve Özel';

  @override
  String get fixedExpenses => 'Sabit Giderler';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get salary => 'Maaş';

  @override
  String get freelance => 'Freelance';

  @override
  String get investment => 'Yatırım';

  @override
  String get rentalIncome => 'Kira Geliri';

  @override
  String get gift => 'Hediye';

  @override
  String get ziraatBank => 'Ziraat Bankası';

  @override
  String get searchPaymentMethod => 'Ödeme yöntemi ara...';

  @override
  String get trashBin => 'Çöp Kutusu';

  @override
  String get noResultsFound => 'Sonuç bulunamadı';

  @override
  String get tryDifferentSearchTerm => 'Farklı bir arama terimi deneyin';

  @override
  String get noPaymentMethodYet => 'Henüz ödeme yöntemi yok';

  @override
  String get startByAddingFirstPaymentMethod =>
      'İlk ödeme yönteminizi ekleyerek başlayın';

  @override
  String get debt => 'Borç';

  @override
  String get balanceLabel => 'Bakiye';

  @override
  String get addCard => 'Kart Ekle';

  @override
  String get cashWalletExample => 'Örn: Cüzdan';

  @override
  String get ziraatBankExample => 'Örn: Ziraat Bankası';

  @override
  String get expensesThisMonth => 'Bu ayki harcamalar';

  @override
  String get incomesThisMonth => 'Bu ayki gelirler';

  @override
  String get totalLimit => 'Toplam Limit';

  @override
  String daysCount(int count) {
    return '$count gün';
  }

  @override
  String get todayLabel => 'Bugün';

  @override
  String get less => 'az';

  @override
  String get more => 'fazla';

  @override
  String get dailyAverageLabel => 'GÜNLÜK ORTALAMA';

  @override
  String get budgetStatusLabel => 'BÜTÇE DURUMU';

  @override
  String get totalExpenseLabel => 'TOPLAM HARCAMA';

  @override
  String get totalIncomeLabel => 'TOPLAM GELİR';

  @override
  String get remainingLabel => 'Kalan';

  @override
  String get validAmountRequired => 'Geçerli bir tutar girin';

  @override
  String get expenseNameHint => 'Ne aldın? (Örn: Kahve)';

  @override
  String get updateButton => 'Güncelle';

  @override
  String get yesterdayLabel => 'Dün';

  @override
  String get movedToTrash => 'çöp kutusuna taşındı';

  @override
  String get restored => 'geri yüklendi';

  @override
  String get voiceInput => 'Sesli Giriş';

  @override
  String get added => 'eklendi';

  @override
  String monthlyIncomeCount(int count) {
    return 'Bu ay $count gelir kaydı';
  }

  @override
  String get incomeNameLabel => 'Gelir Adı';

  @override
  String get incomeNameHint => 'Nereden geldi? (Örn: Borç Ödemesi)';

  @override
  String get selectAccount => 'Hesap Seçin';

  @override
  String get searchAsset => 'Varlık ara...';

  @override
  String get totalAssetLabel => 'TOPLAM VARLIK';

  @override
  String totalAssetCount(int count) {
    return 'Toplam $count adet varlık kaydı';
  }

  @override
  String get profilePhotoUpdated => 'Profil fotoğrafı güncellendi';

  @override
  String profilePhotoUpdateFailed(String error) {
    return 'Profil fotoğrafı güncellenirken hata oluştu: $error';
  }

  @override
  String get budgetLimitSaved => 'Bütçe limiti kaydedildi!';

  @override
  String get categoryListUpdated => 'Kategori listesi güncellendi!';

  @override
  String get changesSaved => 'Değişiklikler kaydedildi';

  @override
  String get trashBinEmptied => 'Çöp kutusu temizlendi.';

  @override
  String get incomeRestored => 'Gelir geri yüklendi ';

  @override
  String get incomePermanentlyDeleted => 'Gelir kalıcı olarak silindi ';

  @override
  String get allIncomesRestored => 'Tüm gelirler geri yüklendi ';

  @override
  String expenseDeletedWithName(String name) {
    return '$name silindi';
  }

  @override
  String get pleaseEnterValidEmail =>
      'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String biometricAuthFailed(String error) {
    return 'Biyometrik doğrulama başarısız: $error';
  }

  @override
  String get emptyTrashBin => 'Çöpü Boşalt';

  @override
  String get confirmEmptyTrashBin =>
      'Tüm silinen öğeler kalıcı olarak yok edilecek. Emin misin?';

  @override
  String get restoreAll => 'Tümünü Geri Yükle';

  @override
  String confirmRestoreAllExpenses(int count) {
    return '$count harcama geri yüklenecek. Onaylıyor musun?';
  }

  @override
  String confirmRestoreAllIncomes(int count) {
    return '$count gelir geri yüklenecek. Onaylıyor musun?';
  }

  @override
  String confirmRestoreAllAssets(int count) {
    return '$count varlık geri yüklenecek. Onaylıyor musun?';
  }

  @override
  String get noDeletedIncomes => 'Silinen gelir yok.';

  @override
  String get noDeletedAssets => 'Çöp kutusu boş.';

  @override
  String expenseAddedDetailed(String name, String amount) {
    return 'Harcama eklendi: $name - $amount ₺';
  }

  @override
  String accountDeleteFailed(String error) {
    return 'Hesap silinirken hata oluştu: $error';
  }

  @override
  String get profileAccountDeleted => 'Hesabınız başarıyla silindi';

  @override
  String get janShort => 'OCA';

  @override
  String get febShort => 'ŞUB';

  @override
  String get marShort => 'MAR';

  @override
  String get aprShort => 'NİS';

  @override
  String get mayShort => 'MAY';

  @override
  String get junShort => 'HAZ';

  @override
  String get julShort => 'TEM';

  @override
  String get augShort => 'AĞU';

  @override
  String get sepShort => 'EYL';

  @override
  String get octShort => 'EKİ';

  @override
  String get novShort => 'KAS';

  @override
  String get decShort => 'ARA';

  @override
  String get transferPageTitle => 'Para Transferi';

  @override
  String get pleaseSelectAccounts => 'Lütfen hesapları seçin';

  @override
  String get cannotTransferToSameAccount => 'Aynı hesaba transfer yapılamaz';

  @override
  String get noDebtOnCreditCard =>
      'Bu kredi kartında borç bulunmuyor. Transfer yapılamaz.';

  @override
  String creditCardDebtLimit(String amount) {
    return 'Kredi kartı borcu $amount, en fazla bu kadar gönderebilirsiniz';
  }

  @override
  String scheduledTransferMessage(
    String fromAccount,
    String toAccount,
    String amount,
    String date,
  ) {
    return '$fromAccount ➔ $toAccount\n$amount $date tarihinde transfer edilmek üzere zamanlandı.';
  }

  @override
  String completedTransferMessage(
    String fromAccount,
    String toAccount,
    String amount,
    String time,
  ) {
    return '$fromAccount ➔ $toAccount\n$amount saat $time\'de başarıyla transfer edildi.';
  }

  @override
  String get sender => 'GÖNDEREN';

  @override
  String get receiver => 'ALAN';

  @override
  String get amountToSend => 'Gönderilecek Tutar';

  @override
  String get enterAmountHint => 'Tutar giriniz';

  @override
  String get amountMustBeGreaterThanZero => 'Tutar 0\'dan büyük olmalı';

  @override
  String get maximumAmountExceeded => 'Maksimum tutar aşıldı';

  @override
  String payAllDebt(String amount) {
    return 'Tüm borcu öde ($amount)';
  }

  @override
  String scheduledTransferInfo(String date, String time) {
    return 'Bu transfer $date saat $time\'de gerçekleştirilecek.';
  }

  @override
  String get scheduleTransferButton => 'Transferi Zamanla';

  @override
  String get makeTransferButton => 'Transfer Yap';

  @override
  String get transactionHistory => 'İşlem Geçmişi';

  @override
  String pendingTransfers(int count) {
    return '⏳ Bekleyen ($count)';
  }

  @override
  String failedTransfers(int count) {
    return '✗ Başarısız ($count)';
  }

  @override
  String completedTransfersLabel(int count) {
    return '✓ Tamamlanan ($count)';
  }

  @override
  String get noTransferHistory => 'Henüz transfer işlemi yok';

  @override
  String get unknownAccount => 'Bilinmeyen';

  @override
  String get downloadReportTooltip => 'Rapor İndir';

  @override
  String get noExpenseDataForThisMonth => 'Bu ay için harcama verisi yok.';

  @override
  String get highestExpense => 'En çok harcama';

  @override
  String get categoryDistribution => 'Kategori Dağılımı';

  @override
  String get noIncomeDataForThisMonth => 'Bu ay için gelir verisi bulunmuyor.';

  @override
  String get highestIncome => 'En fazla gelir';

  @override
  String get noAssetsAddedYet => 'Henüz varlık eklenmemiş.';

  @override
  String get mostValuableType => 'En değerli tür';

  @override
  String get searchTransactions => 'İşlemlerde ara...';

  @override
  String get assetTypes => 'Varlık Türleri';

  @override
  String get distributionByPaymentMethod => 'Ödeme Yöntemine Göre Dağılım';

  @override
  String get otherStr => 'Diğer';

  @override
  String get pdfReportTitle => 'PDF Raporu';

  @override
  String get selectSectionsToInclude => 'Dahil edilecek bölümleri seçin';

  @override
  String get reportPeriod => 'Rapor Dönemi';

  @override
  String get reportOptions => 'Rapor Seçenekleri';

  @override
  String get selectAll => 'Hepsi';

  @override
  String get includeAllVisualSummaries =>
      'Tüm görsel özet seçeneklerini dahil et';

  @override
  String get financialSummaryCards => 'Finansal Özet Kartları';

  @override
  String get expenseIncomeAssetTotals => 'Harcama, gelir ve varlık toplamları';

  @override
  String get netStatusCards => 'Net Durum Kartları';

  @override
  String get monthlyNetStatusAndSavings => 'Aylık net durum ve tasarruf oranı';

  @override
  String get pieChartAndDistribution => 'Pasta Grafiği ve Dağılım';

  @override
  String get expenseIncomeAssetDistribution =>
      'Harcama/gelir/varlık dağılım grafiği';

  @override
  String get budgetStatusTitle => 'Bütçe Durumu';

  @override
  String get budgetProgressBarAndLimit =>
      'Bütçe ilerleme çubuğu ve limit bilgisi';

  @override
  String get statisticsCards => 'İstatistik Kartları';

  @override
  String get dailyAverageAndPreviousMonthComparison =>
      'Günlük ortalama ve geçen ay karşılaştırma';

  @override
  String get top5Expenses => 'En Yüksek 5 Harcama';

  @override
  String get top5ExpensesListDescription =>
      'En yüksek tutarlı 5 harcama listesi';

  @override
  String get tablesToIncludeInReport => 'Rapora Dahil Edilecek Tablolar';

  @override
  String get monthlyExpenseDetails => 'Aylık harcama detayları';

  @override
  String get monthlyIncomeDetails => 'Aylık gelir detayları';

  @override
  String get assetListAndValues => 'Varlık listesi ve değerleri';

  @override
  String get selectAtLeastOneTable => 'En az bir tablo seçmelisiniz';

  @override
  String get preparing => 'Hazırlanıyor...';

  @override
  String get createAndSharePdf => 'PDF Oluştur ve Paylaş';

  @override
  String get daysText => 'gün';

  @override
  String get dailyStreak => 'Günlük Seri 🔥';

  @override
  String get freezeUsed => 'Koruyucu kullanıldı';

  @override
  String get totalLogins => 'Toplam Giriş';

  @override
  String get streakFreeze => 'Seri Koruyucu';

  @override
  String get protectsStreakEvenIfSkipped => 'Bir gün atlasan bile serini korur';

  @override
  String get streakFreezeUsedToday => 'Bugün seri koruyucu kullanıldı!';

  @override
  String nextFreezeIn(int days) {
    return 'Sonraki koruyucu: $days gün sonra';
  }

  @override
  String nextBadgeIs(String badgeName) {
    return 'Sonraki Rozet: $badgeName';
  }

  @override
  String daysRemainingForBadge(int remaining) {
    return '$remaining gün kaldı';
  }

  @override
  String get badges => 'Rozetler';

  @override
  String get badgeFireStarterName => 'Ateş Başlangıcı';

  @override
  String get badgeFireStarterDesc => '3 gün üst üste giriş yaptın!';

  @override
  String get badgeWeeklyStarName => 'Haftalık Yıldız';

  @override
  String get badgeWeeklyStarDesc => '7 gün üst üste giriş yaptın!';

  @override
  String get badgeSteadyName => 'Kararlı';

  @override
  String get badgeSteadyDesc => '2 hafta boyunca her gün giriş yaptın!';

  @override
  String get badgeMonthlyChampName => 'Aylık Şampiyon';

  @override
  String get badgeMonthlyChampDesc => '1 ay boyunca her gün giriş yaptın!';

  @override
  String get badgeSuperStreakName => 'Süper Seri';

  @override
  String get badgeSuperStreakDesc => '2 ay boyunca her gün giriş yaptın!';

  @override
  String get badgeStreakMasterName => 'Seri Ustası';

  @override
  String get badgeStreakMasterDesc => '100 gün üst üste giriş yaptın!';

  @override
  String get badgeLegendName => 'Efsane';

  @override
  String get badgeLegendDesc => '1 yıl boyunca her gün giriş yaptın!';

  @override
  String get achievements => 'Başarılar';

  @override
  String get dShort => 'g';

  @override
  String get earned => '✓ Kazanıldı';

  @override
  String requiredStreakDays(int requiredStreak) {
    return '$requiredStreak günlük seri gerekli';
  }

  @override
  String get streakWhatIsIt => 'Seri Nedir?';

  @override
  String get streakDescription =>
      'Seri, uygulamayı art arda kaç gün açtığınızı gösteren bir sayaçtır.\n\n• Her gün uygulamayı açtığınızda seriniz 1 artar\n• Bir gün atlarsanız seriniz sıfırlanır\n• Gün içinde birden fazla giriş yapmanız sadece 1 giriş olarak sayılır\n\nSeri sistemi, finansal alışkanlıklarınızı takip etmenizi ve düzenli olmanızı teşvik eder.';

  @override
  String get streakFreezeWhatIsIt => 'Seri Koruyucu Nedir?';

  @override
  String get streakFreezeDescription =>
      'Seri Koruyucu, bir gün uygulamayı açmayı unutsanız bile serinizi koruyan özel bir özelliktir.\n\n• Yeni kullanıcılar 1 seri koruyucu ile başlar\n• Her 7 günlük seride 1 yeni koruyucu kazanırsınız\n• Maksimum 3 koruyucu biriktirebilirsiniz\n• 1 gün atlarsanız otomatik olarak kullanılır\n• 2 veya daha fazla gün atlarsanız seri sıfırlanır';

  @override
  String get badgesDescription =>
      'Belirli seri hedeflerine ulaştığınızda rozetler kazanırsınız:\n\n🔥 Ateş Başlangıcı - 3 günlük seri\n⭐ Haftalık Yıldız - 7 günlük seri\n💪 Kararlı - 14 günlük seri\n🏅 Aylık Şampiyon - 30 günlük seri\n💎 Süper Seri - 60 günlük seri\n👑 Seri Ustası - 100 günlük seri\n🏆 Efsane - 365 günlük seri\n\nRozetler kalıcıdır, seri sıfırlansa bile kaybolmaz!';

  @override
  String get achievementsDescription =>
      'Başarılar, uygulamayı kullanırken elde ettiğiniz özel hedeflerdir:\n\n✓ İlk Adım - Uygulamayı ilk kez açın\n✓ Seri Başlatıcı - 3 günlük seri oluşturun\n✓ Seri Koruyucu - Bir seri koruyucu kullanın\n✓ Düzenli Kullanıcı - Toplam 10 gün giriş yapın\n✓ Süreklilik Ustası - 30 günlük seri oluşturun\n✓ Finansal Guru - Toplam 100 gün giriş yapın\n\nBaşarıları tamamladığınızda yeşil onay işareti görürsünüz.';

  @override
  String get statisticsTitle => 'İstatistikler';

  @override
  String get statisticsDescription =>
      'Seri sayfasında aşağıdaki istatistikleri görebilirsiniz:\n\n📊 Mevcut Seri - Şu anki ardışık giriş sayınız\n🏆 En Uzun Seri - Şimdiye kadarki en yüksek seriniz\n📅 Toplam Giriş - Uygulamayı açtığınız toplam gün sayısı\n❄️ Seri Koruyucu - Elinizdeki koruyucu sayısı\n\nBu istatistikler ilerlemenizi takip etmenize yardımcı olur.';

  @override
  String get tipsTitle => 'İpuçları';

  @override
  String get tipsDescription =>
      'Serinizi korumak için bazı ipuçları:\n\n💡 Her gün aynı saatte uygulamayı açmayı alışkanlık haline getirin\n💡 Bildirimler açıksa günlük hatırlatıcı alabilirsiniz\n💡 Seri koruyucularınızı tatil veya yoğun günler için saklayın\n💡 7, 14, 30 gibi hedefler belirleyin\n💡 En uzun seri rekorunuzu kırmaya çalışın\n\nDüzenli finansal takip, daha iyi para yönetimi demektir!';

  @override
  String get streakSystem => 'Seri Sistemi';

  @override
  String get streakSystemSubtitle =>
      'Finansal alışkanlıklarınızı geliştirin ve\ndüzenli takip ödüllerini kazanın!';

  @override
  String get cropPhoto => 'Fotoğrafı Kırp';

  @override
  String get continueText => 'Devam';

  @override
  String get rotateLeft90 => '90° Sol';

  @override
  String get rotateRight90 => '90° Sağ';

  @override
  String get flipHorizontal => 'Yatay';

  @override
  String get flipVertical => 'Dikey';

  @override
  String get compare => 'Karşılaştır';

  @override
  String get undo => 'Geri Al';

  @override
  String get redo => 'İleri Al';

  @override
  String get resetAll => 'Tümünü Sıfırla';

  @override
  String get rotation => 'Döndürme';

  @override
  String get grid => 'Grid';

  @override
  String get apply => 'Uygula';

  @override
  String get filters => 'Filtreler';

  @override
  String get adjustments => 'Ayarlar';

  @override
  String get transform => 'Dönüşüm';

  @override
  String get text => 'Metin';

  @override
  String get emoji => 'Emoji';

  @override
  String get frame => 'Çerçeve';

  @override
  String get intensity => 'Yoğunluk';

  @override
  String get brightness => 'Parlaklık';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Doygunluk';

  @override
  String get temperature => 'Sıcaklık';

  @override
  String get tint => 'Renk Tonu';

  @override
  String get shadows => 'Gölgeler';

  @override
  String get highlights => 'Parlaklıklar';

  @override
  String get vignette => 'Vinyet';

  @override
  String get selectProfilePhoto => 'Profil Resmi Seç';

  @override
  String get selectProfilePhotoDesc =>
      'Galerinizden bir fotoğraf seçerek ya da kameradan fotoğraf çekerek profil resminizi değiştirebilirsiniz.';

  @override
  String get camera => 'Kamera';

  @override
  String get takePhoto => 'Fotoğraf Çek';

  @override
  String get gallery => 'Galeri';

  @override
  String get choosePhoto => 'Fotoğraf Seç';

  @override
  String get day => 'gün';

  @override
  String get securityPin => 'Güvenlik PIN\'i';

  @override
  String get fullName => 'İsim Soyisim';

  @override
  String get emailAddress => 'E-posta';

  @override
  String get firstStep => 'İlk Adım';

  @override
  String get firstStepDesc => 'Uygulamayı ilk kez açtın';

  @override
  String get streakStarter => 'Seri Başlatıcı';

  @override
  String get streakStarterDesc => '3 günlük seri oluştur';

  @override
  String get streakFreezeDescAction => 'Bir seri koruyucu kullan';

  @override
  String get regularUser => 'Düzenli Kullanıcı';

  @override
  String get regularUserDesc => 'Toplam 10 gün giriş yap';

  @override
  String get continuityMaster => 'Süreklilik Ustası';

  @override
  String get continuityMasterDesc => '30 günlük seri oluştur';

  @override
  String get financialGuru => 'Finansal Guru';

  @override
  String get financialGuruDesc => 'Toplam 100 gün giriş yap';

  @override
  String get typeText => 'Metin yazın...';

  @override
  String get sizeLabel => 'Boyut:';

  @override
  String get thickness => 'Kalınlık';

  @override
  String get rotateLeft => 'Sola';

  @override
  String get rotateRight => 'Sağa';

  @override
  String get horizontal => 'Yatay';

  @override
  String get vertical => 'Dikey';

  @override
  String get signupSubtitleExpense =>
      'Harcamalarınızı yönetmeye başlamak için kayıt olun.';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get pinLabel => 'PIN (4-6 Rakam)';

  @override
  String get securityQuestion => 'Güvenlik Sorusu';

  @override
  String get securityQuestionAnswer => 'Güvenlik Sorusu Cevabı';

  @override
  String get signupSuccess => 'Kayıt başarılı! Hoş geldiniz! 🎉';

  @override
  String get signupError =>
      'Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get loginWithAnotherAccount => 'Başka hesap ile giriş yap';

  @override
  String get loginWithGoogle => 'Google ile Giriş Yap';

  @override
  String get verifyIdentity => 'Giriş yapmak için kimliğinizi doğrulayın';

  @override
  String loginFailed(String error) {
    return 'Giriş yapılamadı: $error';
  }

  @override
  String get tapAndSpeak => 'Mikrofona dokunun ve konuşun';

  @override
  String get voiceExampleIncome => 'Örnek: \"500 lira maaş\"';

  @override
  String get heard => 'Duyulan: ';

  @override
  String get amountTl => 'Tutar (₺)';

  @override
  String get incomeName => 'Gelir Adı';

  @override
  String get orDivider => 'veya';

  @override
  String get biometricLoginFailed => 'Biyometrik giriş başarısız';

  @override
  String get enterRegisteredEmail => 'Kayıtlı e-posta adresinizi girin';

  @override
  String get userNotFoundWithEmail =>
      'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';

  @override
  String get noSecurityQuestionDefined =>
      'Bu hesap için güvenlik sorusu tanımlanmamış';

  @override
  String get wrongAnswerTryAgain => 'Yanlış cevap! Lütfen tekrar deneyin.';

  @override
  String get setNewPin => 'Yeni PIN Belirle';

  @override
  String get enterNewPinDigits => '4-6 haneli yeni PIN kodunuzu girin';

  @override
  String get pinUpdatedSuccess => 'PIN başarıyla güncellendi! ✓';

  @override
  String get yourAnswer => 'Cevabınız';

  @override
  String get pleaseEnterAnswer => 'Lütfen cevabınızı girin';

  @override
  String get pleaseEnterNewPin => 'Lütfen yeni PIN girin';

  @override
  String get pinMinDigits => 'PIN en az 4 haneli olmalı';

  @override
  String get pinOnlyNumbers => 'PIN sadece rakamlardan oluşmalı';

  @override
  String get pleaseRepeatPin => 'Lütfen PIN\'i tekrar girin';

  @override
  String get pinRepeatLabel => 'PIN Tekrar';

  @override
  String get continueButton => 'Devam';

  @override
  String get verifyButton => 'Doğrula';

  @override
  String get updatePinButton => 'PIN\'i Güncelle';

  @override
  String expenseDeleted(String name) {
    return '$name silindi';
  }

  @override
  String updateExpenseAmountMsg(String amount) {
    return 'Son harcamayı $amount ₺ olarak güncellemek istiyor musunuz?';
  }

  @override
  String get lastWeek => 'Geçen hafta';

  @override
  String get users => 'Kullanıcılar';

  @override
  String get noRegisteredUsers => 'Kayıtlı kullanıcı yok.';

  @override
  String get addNewUser => 'Yeni Kullanıcı Ekle';

  @override
  String get welcome => 'Hoşgeldiniz';

  @override
  String get accountCreatedDate => 'Hesap Oluşturulma Tarihi';

  @override
  String get lastLoginDate => 'Son Giriş Tarihi';

  @override
  String get totalDebt => 'TOPLAM BORÇ';

  @override
  String get limitUsage => 'Limit Kullanımı';

  @override
  String get usedAmount => 'Kullanılan';

  @override
  String get mainCurrency => 'Ana Para Birimi';

  @override
  String get mainCurrencySubtitle => 'Uygulama para birimi: ₺, \$, vs.';

  @override
  String get currencySettingsTitle => 'Para Birimi Ayarları';

  @override
  String get currencyDescription =>
      'Uygulamanın genel para birimini buradan seçebilirsiniz. Seçiminiz anında tüm sayfalara yansıyacaktır.';

  @override
  String get currenciesLabel => 'PARA BİRİMLERİ';

  @override
  String currentRateInfo(String currency, String rate) {
    return 'Güncel Kur: 1 $currency = $rate ₺';
  }

  @override
  String get frameNone => 'Yok';

  @override
  String get frameWhite => 'Beyaz';

  @override
  String get frameBlack => 'Siyah';

  @override
  String get framePolaroid => 'Polaroid';

  @override
  String get frameGold => 'Altın';

  @override
  String get frameSilver => 'Gümüş';

  @override
  String get frameNeon => 'Neon';

  @override
  String get frameNeonPink => 'Neon Pembe';

  @override
  String get frameOcean => 'Okyanus';

  @override
  String get frameSunset => 'Günbatımı';

  @override
  String get frameRetro => 'Retro';

  @override
  String get frameVintage => 'Vintage';

  @override
  String get frameMint => 'Mint';

  @override
  String get frameLavender => 'Lavanta';

  @override
  String get frameRoseGold => 'Rose Gold';

  @override
  String get frameBronze => 'Bronz';

  @override
  String get frameIce => 'Buz';

  @override
  String get frameForest => 'Orman';

  @override
  String get frameCoral => 'Mercan';

  @override
  String get frameNight => 'Gece';

  @override
  String get frameChampagne => 'Şampanya';

  @override
  String get frameRuby => 'Yakut';

  @override
  String get assetNameHint => 'Örn. Gram Altın';

  @override
  String get customCategoryNameHint => 'Örn. Antika Saat';

  @override
  String get stockNameHint => 'Örn. THYAO, SASA';

  @override
  String get customCurrencyHint => 'Örn. SEK, NOK';

  @override
  String get customCryptoHint => 'Örn. DOGE, SHIB';

  @override
  String get bankNameHint => 'Örn. Garanti, Ziraat';

  @override
  String get quantityHint => 'Örn. 1.0';

  @override
  String get quickCurrencyChangeInfo =>
      'İpucu: Anasayfadaki Toplam Bakiye tutarının üzerine dokunarak da para birimleri arasında hızlıca geçiş yapabilirsiniz.';

  @override
  String get startByAddingFirstExpense => 'İlk harcamanızı ekleyerek başlayın';

  @override
  String get startByAddingFirstIncome => 'İlk gelirinizi ekleyerek başlayın';

  @override
  String get startTrackingYourAssets => 'Varlıklarınızı takip etmeye başlayın';

  @override
  String get noTransactionsForThisMonth => 'Bu ay için işlem bulunmuyor';

  @override
  String get monthlyInsight => 'Aylık Gidişat';

  @override
  String spentMoreThanLastMonth(String percent) {
    return 'Geçen aya göre %$percent daha fazla harcadınız.';
  }

  @override
  String spentLessThanLastMonth(String percent) {
    return 'Geçen aya göre %$percent daha az harcadınız. Harika!';
  }

  @override
  String get spentSameAsLastMonth => 'Geçen ayla aynı oranda harcıyorsunuz.';

  @override
  String earnedMoreThanLastMonth(String percent) {
    return 'Geçen aya göre %$percent daha fazla kazandınız. Harika!';
  }

  @override
  String earnedLessThanLastMonth(String percent) {
    return 'Geçen aya göre %$percent daha az kazandınız.';
  }

  @override
  String get earnedSameAsLastMonth => 'Geçen ayla aynı oranda kazanıyorsunuz.';

  @override
  String get noDetailsFound => 'Detay bulunamadı.';
}
