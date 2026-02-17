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
  String get restoreItem => 'Öğeyi geri yükle';

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
  String get thisYear => 'Bu Yıl';

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
    return '$amount ₺ harcandı';
  }

  @override
  String limitAmount(String amount) {
    return '$amount ₺ limit';
  }

  @override
  String nDays(int count) {
    return '$count gün';
  }
}
