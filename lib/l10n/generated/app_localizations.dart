import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cashly'**
  String get appTitle;

  /// No description provided for @transferOutTitle.
  ///
  /// In tr, this message translates to:
  /// **'{accountName} hesabına giden transfer'**
  String transferOutTitle(String accountName);

  /// No description provided for @transferInTitle.
  ///
  /// In tr, this message translates to:
  /// **'{accountName} hesabından gelen transfer'**
  String transferInTitle(String accountName);

  /// No description provided for @noTransactionsFoundThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ayda işlem bulunamadı'**
  String get noTransactionsFoundThisMonth;

  /// No description provided for @limitLabel.
  ///
  /// In tr, this message translates to:
  /// **'Limit'**
  String get limitLabel;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @appSettings.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Ayarları'**
  String get appSettings;

  /// No description provided for @appearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema, animasyon ve görsel efektler'**
  String get appearanceSubtitle;

  /// No description provided for @appearanceSettings.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm Ayarları'**
  String get appearanceSettings;

  /// No description provided for @appearanceSettingsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın görsel tercihlerini özelleştirin'**
  String get appearanceSettingsDescription;

  /// No description provided for @animations.
  ///
  /// In tr, this message translates to:
  /// **'Animasyonlar'**
  String get animations;

  /// No description provided for @animationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Para animasyonu ve görsel efektler'**
  String get animationsSubtitle;

  /// No description provided for @hapticFeedback.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim Geri Bildirimi'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tıklama, işlem ve uyarı titreşimleri'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcılar ve uyarı bildirimleri'**
  String get notificationsSubtitle;

  /// No description provided for @voiceAssistant.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Asistan'**
  String get voiceAssistant;

  /// No description provided for @voiceAssistantSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sesli geri bildirim ve komut listesi'**
  String get voiceAssistantSubtitle;

  /// No description provided for @expenses.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalar'**
  String get expenses;

  /// No description provided for @expensesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe, kategori ve ödeme yöntemleri'**
  String get expensesSubtitle;

  /// No description provided for @incomes.
  ///
  /// In tr, this message translates to:
  /// **'Gelirler'**
  String get incomes;

  /// No description provided for @incomesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelir kategorileri ve düzenli gelirler'**
  String get incomesSubtitle;

  /// No description provided for @moneyTransfers.
  ///
  /// In tr, this message translates to:
  /// **'Para Transferleri'**
  String get moneyTransfers;

  /// No description provided for @moneyTransfersSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İşlem geçmişi görüntüleme ayarları'**
  String get moneyTransfersSubtitle;

  /// No description provided for @dataOperations.
  ///
  /// In tr, this message translates to:
  /// **'Veri İşlemleri'**
  String get dataOperations;

  /// No description provided for @dataOperationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme, geri yükleme ve sıfırlama'**
  String get dataOperationsSubtitle;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini değiştirin'**
  String get languageSubtitle;

  /// No description provided for @languageSettings.
  ///
  /// In tr, this message translates to:
  /// **'Dil Ayarları'**
  String get languageSettings;

  /// No description provided for @languageSettingsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın kullanım dilini seçin'**
  String get languageSettingsDescription;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçin'**
  String get selectLanguage;

  /// No description provided for @currentLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Dil'**
  String get currentLanguage;

  /// No description provided for @languageChangeRestart.
  ///
  /// In tr, this message translates to:
  /// **'Dil değişikliği uygulandı'**
  String get languageChangeRestart;

  /// No description provided for @backupData.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Yedekle'**
  String get backupData;

  /// No description provided for @backupDataSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verilerinizi JSON olarak dışa aktarın'**
  String get backupDataSubtitle;

  /// No description provided for @restoreData.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Geri Yükle'**
  String get restoreData;

  /// No description provided for @restoreDataSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yedek dosyasından verileri içe aktarın'**
  String get restoreDataSubtitle;

  /// No description provided for @deleteAllData.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Verilerimi Sil'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataWarning.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat! Bu işlem geri alınamaz'**
  String get deleteAllDataWarning;

  /// No description provided for @backupSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Yedek dosyası başarıyla kaydedildi ✅'**
  String get backupSuccess;

  /// No description provided for @backupCancelled.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme iptal edildi'**
  String get backupCancelled;

  /// No description provided for @restoreLoading.
  ///
  /// In tr, this message translates to:
  /// **'Veriler geri yükleniyor...'**
  String get restoreLoading;

  /// No description provided for @restoreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Geri yükleme başarı ile tamamlandı'**
  String get restoreSuccess;

  /// No description provided for @unexpectedError.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen hata: {error}'**
  String unexpectedError(String error);

  /// No description provided for @deleteErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Veriler silinirken bir hata oluştu'**
  String get deleteErrorMessage;

  /// No description provided for @warning.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat!'**
  String get warning;

  /// No description provided for @backupSuggestion.
  ///
  /// In tr, this message translates to:
  /// **'Silmeden önce verilerinizi yedeklemenizi öneririz!'**
  String get backupSuggestion;

  /// No description provided for @permanentDeleteWarning.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verileriniz kalıcı olarak silinecek:'**
  String get permanentDeleteWarning;

  /// No description provided for @allExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Tüm harcamalar'**
  String get allExpenses;

  /// No description provided for @allIncomes.
  ///
  /// In tr, this message translates to:
  /// **'Tüm gelirler'**
  String get allIncomes;

  /// No description provided for @allAssets.
  ///
  /// In tr, this message translates to:
  /// **'Tüm varlıklar'**
  String get allAssets;

  /// No description provided for @paymentMethods.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme yöntemleri'**
  String get paymentMethods;

  /// No description provided for @transfers.
  ///
  /// In tr, this message translates to:
  /// **'Transferler'**
  String get transfers;

  /// No description provided for @streakRecords.
  ///
  /// In tr, this message translates to:
  /// **'Seri kayıtları'**
  String get streakRecords;

  /// No description provided for @irreversibleAction.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz!'**
  String get irreversibleAction;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @continueAction.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueAction;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In tr, this message translates to:
  /// **'Veri bulunamadı'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get success;

  /// No description provided for @securityVerification.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Doğrulaması'**
  String get securityVerification;

  /// No description provided for @deleteConfirmInstruction.
  ///
  /// In tr, this message translates to:
  /// **'Silme işlemini onaylamak için sonucu yazın:'**
  String get deleteConfirmInstruction;

  /// No description provided for @wrongCalculation.
  ///
  /// In tr, this message translates to:
  /// **'Hatalı işlem sonucu. Silme iptal edildi.'**
  String get wrongCalculation;

  /// No description provided for @allDataDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm veriler silindi ✅'**
  String get allDataDeleted;

  /// No description provided for @appInitFailed.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama başlatılamadı'**
  String get appInitFailed;

  /// No description provided for @totalBalance.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Bakiye'**
  String get totalBalance;

  /// No description provided for @monthSummary.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay Özeti'**
  String get monthSummary;

  /// No description provided for @expense.
  ///
  /// In tr, this message translates to:
  /// **'Harcama'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get income;

  /// No description provided for @net.
  ///
  /// In tr, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @budgetStatus.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Durumu'**
  String get budgetStatus;

  /// No description provided for @budgetUsed.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıldı'**
  String get budgetUsed;

  /// No description provided for @budgetRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get budgetRemaining;

  /// No description provided for @noBudgetSet.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe belirlenmemiş'**
  String get noBudgetSet;

  /// No description provided for @setBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Belirle'**
  String get setBudget;

  /// No description provided for @budgetExceeded.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Aşıldı!'**
  String get budgetExceeded;

  /// No description provided for @assetSummary.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Özeti'**
  String get assetSummary;

  /// No description provided for @totalAssets.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Varlıklar'**
  String get totalAssets;

  /// No description provided for @recentTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Son İşlemler'**
  String get recentTransactions;

  /// No description provided for @noRecentTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Henüz işlem yok'**
  String get noRecentTransactions;

  /// No description provided for @creditCardDebt.
  ///
  /// In tr, this message translates to:
  /// **'Kredi Kartı Borcu'**
  String get creditCardDebt;

  /// No description provided for @goodMorning.
  ///
  /// In tr, this message translates to:
  /// **'Günaydın'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'İyi günler'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi akşamlar'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In tr, this message translates to:
  /// **'İyi geceler'**
  String get goodNight;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @profileSettings.
  ///
  /// In tr, this message translates to:
  /// **'Profil Ayarları'**
  String get profileSettings;

  /// No description provided for @accountInfo.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Bilgileri'**
  String get accountInfo;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @aboutAndSupport.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında & Destek'**
  String get aboutAndSupport;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @passwordConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get passwordConfirm;

  /// No description provided for @name.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get name;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Hoş Geldiniz!'**
  String get welcomeBack;

  /// No description provided for @createNewAccount.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Hesap Oluştur'**
  String get createNewAccount;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için giriş yapın'**
  String get loginSubtitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Finansal yolculuğunuza başlayın'**
  String get signupSubtitle;

  /// No description provided for @nameHint.
  ///
  /// In tr, this message translates to:
  /// **'Adınızı girin'**
  String get nameHint;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi girin'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi girin'**
  String get passwordHint;

  /// No description provided for @passwordConfirmHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi tekrar girin'**
  String get passwordConfirmHint;

  /// No description provided for @addExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Ekle'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcamayı Düzenle'**
  String get editExpense;

  /// No description provided for @expenseAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get expenseAmount;

  /// No description provided for @expenseCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get expenseCategory;

  /// No description provided for @expenseDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get expenseDate;

  /// No description provided for @expenseNote.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get expenseNote;

  /// No description provided for @expensePaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemi'**
  String get expensePaymentMethod;

  /// No description provided for @noExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Henüz harcama yok'**
  String get noExpenses;

  /// No description provided for @monthlyExpense.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Harcama'**
  String get monthlyExpense;

  /// No description provided for @dailyAverage.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Ortalama'**
  String get dailyAverage;

  /// No description provided for @totalExpense.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Harcama'**
  String get totalExpense;

  /// No description provided for @addIncome.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Ekle'**
  String get addIncome;

  /// No description provided for @editIncome.
  ///
  /// In tr, this message translates to:
  /// **'Geliri Düzenle'**
  String get editIncome;

  /// No description provided for @incomeAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get incomeAmount;

  /// No description provided for @incomeCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get incomeCategory;

  /// No description provided for @incomeDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get incomeDate;

  /// No description provided for @incomeNote.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get incomeNote;

  /// No description provided for @incomePaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get incomePaymentMethod;

  /// No description provided for @noIncomes.
  ///
  /// In tr, this message translates to:
  /// **'Henüz gelir yok'**
  String get noIncomes;

  /// No description provided for @monthlyIncome.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Gelir'**
  String get monthlyIncome;

  /// No description provided for @totalIncome.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Gelir'**
  String get totalIncome;

  /// No description provided for @recurringIncomes.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli Gelirler'**
  String get recurringIncomes;

  /// No description provided for @addAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Ekle'**
  String get addAsset;

  /// No description provided for @editAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlığı Düzenle'**
  String get editAsset;

  /// No description provided for @assetName.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Adı'**
  String get assetName;

  /// No description provided for @assetAmount.
  ///
  /// In tr, this message translates to:
  /// **'Miktar'**
  String get assetAmount;

  /// No description provided for @assetType.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get assetType;

  /// No description provided for @assetCurrentPrice.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Fiyat'**
  String get assetCurrentPrice;

  /// No description provided for @assetPurchasePrice.
  ///
  /// In tr, this message translates to:
  /// **'Alış Fiyatı'**
  String get assetPurchasePrice;

  /// No description provided for @assetPurchaseDate.
  ///
  /// In tr, this message translates to:
  /// **'Alış Tarihi'**
  String get assetPurchaseDate;

  /// No description provided for @assetCurrentValue.
  ///
  /// In tr, this message translates to:
  /// **'Şuanki Değer'**
  String get assetCurrentValue;

  /// No description provided for @assetUnitPurchasePrice.
  ///
  /// In tr, this message translates to:
  /// **'Birim Alış Fiyatı'**
  String get assetUnitPurchasePrice;

  /// No description provided for @assetUnitCurrentPrice.
  ///
  /// In tr, this message translates to:
  /// **'Birim Güncel Fiyat'**
  String get assetUnitCurrentPrice;

  /// No description provided for @assetProfitLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kar'**
  String get assetProfitLabel;

  /// No description provided for @assetLossLabel.
  ///
  /// In tr, this message translates to:
  /// **'Zarar'**
  String get assetLossLabel;

  /// No description provided for @assetInflationDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesaplama enflasyon etkisini içermez'**
  String get assetInflationDisclaimer;

  /// No description provided for @assetQuantityUnit.
  ///
  /// In tr, this message translates to:
  /// **'{count} adet'**
  String assetQuantityUnit(String count);

  /// No description provided for @noAssets.
  ///
  /// In tr, this message translates to:
  /// **'Henüz varlık yok'**
  String get noAssets;

  /// No description provided for @gold.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get gold;

  /// No description provided for @silver.
  ///
  /// In tr, this message translates to:
  /// **'Gümüş'**
  String get silver;

  /// No description provided for @currency.
  ///
  /// In tr, this message translates to:
  /// **'Döviz'**
  String get currency;

  /// No description provided for @stock.
  ///
  /// In tr, this message translates to:
  /// **'Hisse'**
  String get stock;

  /// No description provided for @crypto.
  ///
  /// In tr, this message translates to:
  /// **'Kripto'**
  String get crypto;

  /// No description provided for @other.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get other;

  /// No description provided for @hisseSenedi.
  ///
  /// In tr, this message translates to:
  /// **'Hisse Senedi'**
  String get hisseSenedi;

  /// No description provided for @banka.
  ///
  /// In tr, this message translates to:
  /// **'Banka'**
  String get banka;

  /// No description provided for @goldGram.
  ///
  /// In tr, this message translates to:
  /// **'Gram'**
  String get goldGram;

  /// No description provided for @goldQuarter.
  ///
  /// In tr, this message translates to:
  /// **'Çeyrek'**
  String get goldQuarter;

  /// No description provided for @goldHalf.
  ///
  /// In tr, this message translates to:
  /// **'Yarım'**
  String get goldHalf;

  /// No description provided for @goldFull.
  ///
  /// In tr, this message translates to:
  /// **'Tam'**
  String get goldFull;

  /// No description provided for @goldRepublic.
  ///
  /// In tr, this message translates to:
  /// **'Cumhuriyet'**
  String get goldRepublic;

  /// No description provided for @goldAta.
  ///
  /// In tr, this message translates to:
  /// **'Ata'**
  String get goldAta;

  /// No description provided for @goldOunce.
  ///
  /// In tr, this message translates to:
  /// **'Ons'**
  String get goldOunce;

  /// No description provided for @silverGram.
  ///
  /// In tr, this message translates to:
  /// **'Gram'**
  String get silverGram;

  /// No description provided for @silverOunce.
  ///
  /// In tr, this message translates to:
  /// **'Ons'**
  String get silverOunce;

  /// No description provided for @currencyUSD.
  ///
  /// In tr, this message translates to:
  /// **'Amerikan Doları (USD)'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In tr, this message translates to:
  /// **'Euro (EUR)'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In tr, this message translates to:
  /// **'İngiliz Sterlini (GBP)'**
  String get currencyGBP;

  /// No description provided for @currencyCHF.
  ///
  /// In tr, this message translates to:
  /// **'İsviçre Frangı (CHF)'**
  String get currencyCHF;

  /// No description provided for @currencyJPY.
  ///
  /// In tr, this message translates to:
  /// **'Japon Yeni (JPY)'**
  String get currencyJPY;

  /// No description provided for @currencyCAD.
  ///
  /// In tr, this message translates to:
  /// **'Kanada Doları (CAD)'**
  String get currencyCAD;

  /// No description provided for @addPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemi Ekle'**
  String get addPaymentMethod;

  /// No description provided for @editPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemini Düzenle'**
  String get editPaymentMethod;

  /// No description provided for @paymentMethodName.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get paymentMethodName;

  /// No description provided for @paymentMethodBalance.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye'**
  String get paymentMethodBalance;

  /// No description provided for @paymentMethodType.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get paymentMethodType;

  /// No description provided for @noPaymentMethods.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ödeme yöntemi yok'**
  String get noPaymentMethods;

  /// No description provided for @cash.
  ///
  /// In tr, this message translates to:
  /// **'Nakit'**
  String get cash;

  /// No description provided for @bankAccount.
  ///
  /// In tr, this message translates to:
  /// **'Banka Hesabı'**
  String get bankAccount;

  /// No description provided for @creditCard.
  ///
  /// In tr, this message translates to:
  /// **'Kredi Kartı'**
  String get creditCard;

  /// No description provided for @balance.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye'**
  String get balance;

  /// No description provided for @creditLimit.
  ///
  /// In tr, this message translates to:
  /// **'Kredi Limiti'**
  String get creditLimit;

  /// No description provided for @availableLimit.
  ///
  /// In tr, this message translates to:
  /// **'Kullanılabilir Limit'**
  String get availableLimit;

  /// No description provided for @currentDebt.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Borç'**
  String get currentDebt;

  /// No description provided for @transfer.
  ///
  /// In tr, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @transferFrom.
  ///
  /// In tr, this message translates to:
  /// **'Gönderen'**
  String get transferFrom;

  /// No description provided for @transferTo.
  ///
  /// In tr, this message translates to:
  /// **'Alıcı'**
  String get transferTo;

  /// No description provided for @transferAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get transferAmount;

  /// No description provided for @transferDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get transferDate;

  /// No description provided for @transferNote.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get transferNote;

  /// No description provided for @noTransfers.
  ///
  /// In tr, this message translates to:
  /// **'Henüz transfer yok'**
  String get noTransfers;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categories;

  /// No description provided for @categoryManagement.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Yönetimi'**
  String get categoryManagement;

  /// No description provided for @addCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Ekle'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriyi Düzenle'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Adı'**
  String get categoryName;

  /// No description provided for @noCategorySelected.
  ///
  /// In tr, this message translates to:
  /// **'Kategori seçilmedi'**
  String get noCategorySelected;

  /// No description provided for @recycleBin.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get recycleBin;

  /// No description provided for @restore.
  ///
  /// In tr, this message translates to:
  /// **'Geri Yükle'**
  String get restore;

  /// No description provided for @permanentDelete.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Sil'**
  String get permanentDelete;

  /// No description provided for @emptyRecycleBin.
  ///
  /// In tr, this message translates to:
  /// **'Çöp kutusu boş'**
  String get emptyRecycleBin;

  /// No description provided for @restoreItem.
  ///
  /// In tr, this message translates to:
  /// **'Geri Yükle'**
  String get restoreItem;

  /// No description provided for @permanentDeleteItem.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı olarak sil'**
  String get permanentDeleteItem;

  /// No description provided for @deletedItems.
  ///
  /// In tr, this message translates to:
  /// **'Silinen Öğeler'**
  String get deletedItems;

  /// No description provided for @budgetLimit.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Limiti'**
  String get budgetLimit;

  /// No description provided for @monthlyBudget.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Bütçe'**
  String get monthlyBudget;

  /// No description provided for @categoryBudgets.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Bütçeleri'**
  String get categoryBudgets;

  /// No description provided for @remainingBudget.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Bütçe'**
  String get remainingBudget;

  /// No description provided for @overBudget.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Aşımı'**
  String get overBudget;

  /// No description provided for @recurringExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Sabit Giderler'**
  String get recurringExpenses;

  /// No description provided for @addRecurringExpense.
  ///
  /// In tr, this message translates to:
  /// **'Sabit Gider Ekle'**
  String get addRecurringExpense;

  /// No description provided for @editRecurringExpense.
  ///
  /// In tr, this message translates to:
  /// **'Sabit Gideri Düzenle'**
  String get editRecurringExpense;

  /// No description provided for @frequency.
  ///
  /// In tr, this message translates to:
  /// **'Sıklık'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get daily;

  /// No description provided for @cumulativeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Birikimli'**
  String get cumulativeLabel;

  /// No description provided for @weekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get yearly;

  /// No description provided for @startDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Tarihi'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Tarihi'**
  String get endDate;

  /// No description provided for @analysis.
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get analysis;

  /// No description provided for @analytics.
  ///
  /// In tr, this message translates to:
  /// **'Analitik'**
  String get analytics;

  /// No description provided for @spendingByCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriye Göre Harcama'**
  String get spendingByCategory;

  /// No description provided for @incomeByCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriye Göre Gelir'**
  String get incomeByCategory;

  /// No description provided for @monthlyTrend.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Trend'**
  String get monthlyTrend;

  /// No description provided for @expenseDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Dağılımı'**
  String get expenseDistribution;

  /// No description provided for @incomeDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Dağılımı'**
  String get incomeDistribution;

  /// No description provided for @distributionByAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesaba Göre Dağılım'**
  String get distributionByAccount;

  /// No description provided for @topExpenses.
  ///
  /// In tr, this message translates to:
  /// **'En Büyük Harcamalar'**
  String get topExpenses;

  /// No description provided for @topExpensesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay tek seferde yaptığınız en yüksek 3 harcama (Sabit giderler hariç).'**
  String get topExpensesDescription;

  /// No description provided for @topIncomes.
  ///
  /// In tr, this message translates to:
  /// **'En Büyük Gelirler'**
  String get topIncomes;

  /// No description provided for @topIncomesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu dönemde elde ettiğiniz en yüksek 3 gelir (Düzenli gelirler hariç).'**
  String get topIncomesDescription;

  /// No description provided for @topIncomesAllSalary.
  ///
  /// In tr, this message translates to:
  /// **'Bu dönemde tüm gelirleriniz düzenli kaynaklardan oluşuyor.'**
  String get topIncomesAllSalary;

  /// No description provided for @incomeStability.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Kararlılığı'**
  String get incomeStability;

  /// No description provided for @regularIncome.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli'**
  String get regularIncome;

  /// No description provided for @variableIncome.
  ///
  /// In tr, this message translates to:
  /// **'Değişken'**
  String get variableIncome;

  /// No description provided for @singleSourceWarning.
  ///
  /// In tr, this message translates to:
  /// **'Gelirinizin tamamı tek bir kaynağa bağlı. Ek gelir kaynakları finansal güvenliğinizi artırır.'**
  String get singleSourceWarning;

  /// No description provided for @stableIncomeNote.
  ///
  /// In tr, this message translates to:
  /// **'Geliriniz çeşitlendirilmiş ve kararlı görünüyor.'**
  String get stableIncomeNote;

  /// No description provided for @dailyEarningRate.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kazanç Hızı'**
  String get dailyEarningRate;

  /// No description provided for @daysElapsed.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get daysElapsed;

  /// No description provided for @incomeTransactions.
  ///
  /// In tr, this message translates to:
  /// **'gelir kaydı'**
  String get incomeTransactions;

  /// No description provided for @savingsPotential.
  ///
  /// In tr, this message translates to:
  /// **'Tasarruf Potansiyeli'**
  String get savingsPotential;

  /// No description provided for @savingsPotentialPositive.
  ///
  /// In tr, this message translates to:
  /// **'Gelirinizin {percent}\'i hâlâ duruyor. Harika gidiyorsunuz!'**
  String savingsPotentialPositive(String percent);

  /// No description provided for @savingsPotentialNegative.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalarınız gelirinizi aştı. Bütçenizi gözden geçirmelisiniz.'**
  String get savingsPotentialNegative;

  /// No description provided for @savingsPotentialNoExpense.
  ///
  /// In tr, this message translates to:
  /// **'Bu dönemde henüz harcama kaydınız yok. Tüm geliriniz elinizde!'**
  String get savingsPotentialNoExpense;

  /// No description provided for @detailInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı Bilgi'**
  String get detailInfoTitle;

  /// No description provided for @topIncomesDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'En Büyük Gelirler Nedir?'**
  String get topIncomesDetailTitle;

  /// No description provided for @topIncomesDetailBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kart, seçili dönemde elde ettiğiniz en yüksek 3 geliri gösterir. Dönem içinde 2 veya daha fazla kez tekrarlayan gelir kategorileri (maaş, kira geliri gibi düzenli kaynaklar) bu listeden otomatik olarak hariç tutulur. Böylece prim, ikramiye, freelance ödeme gibi ekstra gelirlerinizi net görebilirsiniz. Eğer tüm gelirleriniz düzenli kaynaklardan oluşuyorsa, size bunu bildiren özel bir mesaj gösterilir.'**
  String get topIncomesDetailBody;

  /// No description provided for @incomeStabilityDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Kararlılığı Nedir?'**
  String get incomeStabilityDetailTitle;

  /// No description provided for @incomeStabilityDetailBody.
  ///
  /// In tr, this message translates to:
  /// **'Gelir kararlılığı, gelirlerinizin ne kadarının düzenli ve ne kadarının değişken olduğunu gösterir. Dönem içinde aynı kategoride 2 veya daha fazla işlem varsa o kategori \'düzenli\', tek seferlik işlemler ise \'değişken\' olarak sınıflandırılır.\n\nNeden önemli? Gelirinizin tamamı tek bir kaynağa bağlıysa, o kaynak kesildiğinde finansal güvenceniz riske girer. Gelir kaynaklarınızı çeşitlendirmek finansal güvenliğinizi artırır.'**
  String get incomeStabilityDetailBody;

  /// No description provided for @dailyEarningRateDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kazanç Hızı Nedir?'**
  String get dailyEarningRateDetailTitle;

  /// No description provided for @dailyEarningRateDetailBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kart, seçili dönemdeki toplam gelirinizi dönemin toplam gün sayısına bölerek günlük ortalama kazanç hızınızı hesaplar.\n\nÖrneğin: Bu ay toplam 30.000₺ kazandıysanız ve ay 31 günse, günlük ortalamanız yaklaşık 968₺ olur. Bu hesaplama, maaşınızı ayın hangi günü aldığınızdan bağımsız olarak doğru sonuç verir.'**
  String get dailyEarningRateDetailBody;

  /// No description provided for @savingsPotentialDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tasarruf Potansiyeli Nedir?'**
  String get savingsPotentialDetailTitle;

  /// No description provided for @savingsPotentialDetailBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kart, seçili dönemdeki toplam gelirinizden toplam harcamanızı çıkararak elinizde ne kadar para kaldığını gösterir.\n\nÜç durum vardır:\n• Yeşil: Geliriniz harcamalarınızdan fazla, harika gidiyorsunuz!\n• Kırmızı: Harcamalarınız gelirinizi aştı, bütçenizi gözden geçirin.\n• Henüz harcama yoksa: Tüm geliriniz elinizde!'**
  String get savingsPotentialDetailBody;

  /// No description provided for @topPerformers.
  ///
  /// In tr, this message translates to:
  /// **'Kârlılık Liderleri'**
  String get topPerformers;

  /// No description provided for @topPerformersDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım getirisi (ROI) en yüksek varlıklarınız.'**
  String get topPerformersDesc;

  /// No description provided for @topPerformersAllLoss.
  ///
  /// In tr, this message translates to:
  /// **'Şu an kârdaki varlığınız bulunmuyor.'**
  String get topPerformersAllLoss;

  /// No description provided for @topPerformersDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kârlılık Liderleri Nedir?'**
  String get topPerformersDetailTitle;

  /// No description provided for @topPerformersDetailBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kart, varlıklarınız arasında yatırım getirisi (ROI) en yüksek olan 3 tanesini gösterir.\n\nHesaplama: (Güncel Değer - Alış Değeri) / Alış Değeri × 100\n\nÖrneğin 1.000₺\'ye aldığınız altın şu an 1.500₺ değerindeyse, ROI oranı %50\'dir.'**
  String get topPerformersDetailBody;

  /// No description provided for @roi.
  ///
  /// In tr, this message translates to:
  /// **'ROI'**
  String get roi;

  /// No description provided for @profit.
  ///
  /// In tr, this message translates to:
  /// **'Kâr'**
  String get profit;

  /// No description provided for @loss.
  ///
  /// In tr, this message translates to:
  /// **'Zarar'**
  String get loss;

  /// No description provided for @portfolioDiversification.
  ///
  /// In tr, this message translates to:
  /// **'Portföy Çeşitliliği'**
  String get portfolioDiversification;

  /// No description provided for @diversifiedPortfolio.
  ///
  /// In tr, this message translates to:
  /// **'Çeşitlendirilmiş Portföy'**
  String get diversifiedPortfolio;

  /// No description provided for @diversifiedPortfolioDesc.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklarınız farklı türlere dağılmış durumda. Bu, riskinizi azaltır.'**
  String get diversifiedPortfolioDesc;

  /// No description provided for @concentratedPortfolio.
  ///
  /// In tr, this message translates to:
  /// **'Yoğunlaşmış Portföy'**
  String get concentratedPortfolio;

  /// No description provided for @concentratedPortfolioDesc.
  ///
  /// In tr, this message translates to:
  /// **'{category} toplam portföyünüzün %{percent}\'ini oluşturuyor. Riskinizi dağıtmak için çeşitlendirmeyi düşünebilirsiniz.'**
  String concentratedPortfolioDesc(String category, String percent);

  /// No description provided for @singleAssetType.
  ///
  /// In tr, this message translates to:
  /// **'Tek Tür Portföy'**
  String get singleAssetType;

  /// No description provided for @singleAssetTypeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm varlıklarınız tek bir türde. Farklı varlık türlerine yatırım yaparak riskinizi dağıtabilirsiniz.'**
  String get singleAssetTypeDesc;

  /// No description provided for @portfolioDiversificationDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Portföy Çeşitliliği Nedir?'**
  String get portfolioDiversificationDetailTitle;

  /// No description provided for @portfolioDiversificationDetailBody.
  ///
  /// In tr, this message translates to:
  /// **'Portföy çeşitliliği, yatırımlarınızın farklı varlık türlerine ne kadar dengeli dağıldığını gösterir.\n\nİdeal durum: Hiçbir varlık türü toplam portföyün %70\'inden fazlasını oluşturmamalıdır.'**
  String get portfolioDiversificationDetailBody;

  /// No description provided for @liquidityCheck.
  ///
  /// In tr, this message translates to:
  /// **'Likidite Durumu'**
  String get liquidityCheck;

  /// No description provided for @highLiquidity.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Likidite'**
  String get highLiquidity;

  /// No description provided for @lowLiquidity.
  ///
  /// In tr, this message translates to:
  /// **'Düşük Likidite'**
  String get lowLiquidity;

  /// No description provided for @liquidityHealthy.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklarınızın %{percent}\'i hızlıca nakde çevrilebilir durumda.'**
  String liquidityHealthy(String percent);

  /// No description provided for @liquidityWarning.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklarınızın büyük kısmı düşük likiditeli. Acil durumda nakde çevirmek zor olabilir.'**
  String get liquidityWarning;

  /// No description provided for @liquidityDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Likidite Durumu Nedir?'**
  String get liquidityDetailTitle;

  /// No description provided for @liquidityDetailBody.
  ///
  /// In tr, this message translates to:
  /// **'Likidite, bir varlığın ne kadar hızlı nakde çevrilebileceğini gösterir.\n\nYüksek: Altın, Döviz, Kripto, Banka.\nDüşük: Gayrimenkul, Araç, Hisse Senedi.\n\nAcil durumda erişebileceğiniz varlıkların oranını bilmek önemlidir.'**
  String get liquidityDetailBody;

  /// No description provided for @financialReport.
  ///
  /// In tr, this message translates to:
  /// **'Finansal Rapor'**
  String get financialReport;

  /// No description provided for @exportPdf.
  ///
  /// In tr, this message translates to:
  /// **'PDF Olarak Dışa Aktar'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In tr, this message translates to:
  /// **'CSV Olarak Dışa Aktar'**
  String get exportCsv;

  /// No description provided for @streak.
  ///
  /// In tr, this message translates to:
  /// **'Seri'**
  String get streak;

  /// No description provided for @currentStreak.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Seri'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In tr, this message translates to:
  /// **'En Uzun Seri'**
  String get longestStreak;

  /// No description provided for @streakGoal.
  ///
  /// In tr, this message translates to:
  /// **'Seri Hedefi'**
  String get streakGoal;

  /// No description provided for @freezeAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Dondurma Hakkı'**
  String get freezeAvailable;

  /// No description provided for @useFreeze.
  ///
  /// In tr, this message translates to:
  /// **'Dondurma Kullan'**
  String get useFreeze;

  /// No description provided for @streakBroken.
  ///
  /// In tr, this message translates to:
  /// **'Seri kırıldı!'**
  String get streakBroken;

  /// No description provided for @streakContinued.
  ///
  /// In tr, this message translates to:
  /// **'Seri devam ediyor!'**
  String get streakContinued;

  /// No description provided for @days.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get days;

  /// No description provided for @tools.
  ///
  /// In tr, this message translates to:
  /// **'Araçlar'**
  String get tools;

  /// No description provided for @calculator.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Makinesi'**
  String get calculator;

  /// No description provided for @currencyConverter.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Çevirici'**
  String get currencyConverter;

  /// No description provided for @tipCalculator.
  ///
  /// In tr, this message translates to:
  /// **'Bahşiş Hesaplama'**
  String get tipCalculator;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @dailyReminder.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hatırlatıcı'**
  String get dailyReminder;

  /// No description provided for @budgetAlert.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Uyarısı'**
  String get budgetAlert;

  /// No description provided for @streakReminder.
  ///
  /// In tr, this message translates to:
  /// **'Seri Hatırlatıcı'**
  String get streakReminder;

  /// No description provided for @voiceCommands.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Komutlar'**
  String get voiceCommands;

  /// No description provided for @voiceFeedback.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Geri Bildirim'**
  String get voiceFeedback;

  /// No description provided for @hapticTap.
  ///
  /// In tr, this message translates to:
  /// **'Dokunma Titreşimi'**
  String get hapticTap;

  /// No description provided for @hapticSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başarı Titreşimi'**
  String get hapticSuccess;

  /// No description provided for @hapticWarning.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı Titreşimi'**
  String get hapticWarning;

  /// No description provided for @hapticError.
  ///
  /// In tr, this message translates to:
  /// **'Hata Titreşimi'**
  String get hapticError;

  /// No description provided for @moneyAnimation.
  ///
  /// In tr, this message translates to:
  /// **'Para Animasyonu'**
  String get moneyAnimation;

  /// No description provided for @moneyAnimationDescription.
  ///
  /// In tr, this message translates to:
  /// **'Harcama eklerken para yağmuru efekti'**
  String get moneyAnimationDescription;

  /// No description provided for @animationPreferences.
  ///
  /// In tr, this message translates to:
  /// **'Animasyon Tercihleri'**
  String get animationPreferences;

  /// No description provided for @animationPreferencesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama içi animasyonları yönetin'**
  String get animationPreferencesDescription;

  /// No description provided for @showMoneyRain.
  ///
  /// In tr, this message translates to:
  /// **'Para Yağmuru Göster'**
  String get showMoneyRain;

  /// No description provided for @fileNotSelected.
  ///
  /// In tr, this message translates to:
  /// **'Dosya seçilmedi'**
  String get fileNotSelected;

  /// No description provided for @january.
  ///
  /// In tr, this message translates to:
  /// **'Ocak'**
  String get january;

  /// No description provided for @february.
  ///
  /// In tr, this message translates to:
  /// **'Şubat'**
  String get february;

  /// No description provided for @march.
  ///
  /// In tr, this message translates to:
  /// **'Mart'**
  String get march;

  /// No description provided for @april.
  ///
  /// In tr, this message translates to:
  /// **'Nisan'**
  String get april;

  /// No description provided for @may.
  ///
  /// In tr, this message translates to:
  /// **'Mayıs'**
  String get may;

  /// No description provided for @june.
  ///
  /// In tr, this message translates to:
  /// **'Haziran'**
  String get june;

  /// No description provided for @july.
  ///
  /// In tr, this message translates to:
  /// **'Temmuz'**
  String get july;

  /// No description provided for @august.
  ///
  /// In tr, this message translates to:
  /// **'Ağustos'**
  String get august;

  /// No description provided for @september.
  ///
  /// In tr, this message translates to:
  /// **'Eylül'**
  String get september;

  /// No description provided for @october.
  ///
  /// In tr, this message translates to:
  /// **'Ekim'**
  String get october;

  /// No description provided for @november.
  ///
  /// In tr, this message translates to:
  /// **'Kasım'**
  String get november;

  /// No description provided for @december.
  ///
  /// In tr, this message translates to:
  /// **'Aralık'**
  String get december;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen Ay'**
  String get lastMonth;

  /// No description provided for @last3Months.
  ///
  /// In tr, this message translates to:
  /// **'Son 3 Ay'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In tr, this message translates to:
  /// **'Son 6 Ay'**
  String get last6Months;

  /// No description provided for @thisYear.
  ///
  /// In tr, this message translates to:
  /// **'Bu Yıl'**
  String get thisYear;

  /// No description provided for @last1Year.
  ///
  /// In tr, this message translates to:
  /// **'Son 1 Yıl'**
  String get last1Year;

  /// No description provided for @customRange.
  ///
  /// In tr, this message translates to:
  /// **'Özel Aralık'**
  String get customRange;

  /// No description provided for @selectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seçin'**
  String get selectDate;

  /// No description provided for @selectMonth.
  ///
  /// In tr, this message translates to:
  /// **'Ay Seçin'**
  String get selectMonth;

  /// No description provided for @selectYear.
  ///
  /// In tr, this message translates to:
  /// **'Yıl Seçin'**
  String get selectYear;

  /// No description provided for @insufficientBalance.
  ///
  /// In tr, this message translates to:
  /// **'Yetersiz bakiye'**
  String get insufficientBalance;

  /// No description provided for @accountNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Hesap bulunamadı'**
  String get accountNotFound;

  /// No description provided for @scheduledTransferApplied.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlanmış transfer uygulandı'**
  String get scheduledTransferApplied;

  /// No description provided for @scheduledTransferFailed.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlanmış transfer başarısız'**
  String get scheduledTransferFailed;

  /// No description provided for @amount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @note.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get note;

  /// No description provided for @description.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  /// No description provided for @type.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get type;

  /// No description provided for @status.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get status;

  /// No description provided for @total.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get total;

  /// No description provided for @average.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama'**
  String get average;

  /// No description provided for @minimum.
  ///
  /// In tr, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum'**
  String get maximum;

  /// No description provided for @count.
  ///
  /// In tr, this message translates to:
  /// **'Adet'**
  String get count;

  /// No description provided for @percentage.
  ///
  /// In tr, this message translates to:
  /// **'Yüzde'**
  String get percentage;

  /// No description provided for @spent.
  ///
  /// In tr, this message translates to:
  /// **'harcandı'**
  String get spent;

  /// No description provided for @limit.
  ///
  /// In tr, this message translates to:
  /// **'limit'**
  String get limit;

  /// No description provided for @unknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get unknown;

  /// No description provided for @totalAsset.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Varlık'**
  String get totalAsset;

  /// No description provided for @widgetError.
  ///
  /// In tr, this message translates to:
  /// **'Widget oluşturulurken bir hata oluştu.'**
  String get widgetError;

  /// No description provided for @appCouldNotStart.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama başlatılamadı:\n{error}'**
  String appCouldNotStart(String error);

  /// No description provided for @spentAmount.
  ///
  /// In tr, this message translates to:
  /// **'Harcanan: {amount}'**
  String spentAmount(String amount);

  /// No description provided for @limitAmount.
  ///
  /// In tr, this message translates to:
  /// **'{amount} limit'**
  String limitAmount(String amount);

  /// No description provided for @nDays.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün'**
  String nDays(int count);

  /// No description provided for @hapticSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dokunsal Geri Bildirim'**
  String get hapticSettingsTitle;

  /// No description provided for @hapticSettingsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Önemli işlemlerde titreşim geri bildirimi alın'**
  String get hapticSettingsDescription;

  /// No description provided for @hapticInfoText.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim geri bildiriminin çalışabilmesi için cihazınızın ayarlarından \"Dokunma geri bildirimi\" veya \"Titreşim\" özelliğinin açık olması gerekmektedir.'**
  String get hapticInfoText;

  /// No description provided for @hapticNoVibrator.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazda titreşim özelliği algılanamadı.'**
  String get hapticNoVibrator;

  /// No description provided for @hapticEnable.
  ///
  /// In tr, this message translates to:
  /// **'Titreşimi Etkinleştir'**
  String get hapticEnable;

  /// No description provided for @hapticAllOn.
  ///
  /// In tr, this message translates to:
  /// **'Tüm titreşimler açık'**
  String get hapticAllOn;

  /// No description provided for @hapticAllOff.
  ///
  /// In tr, this message translates to:
  /// **'Tüm titreşimler kapalı'**
  String get hapticAllOff;

  /// No description provided for @hapticButtonTaps.
  ///
  /// In tr, this message translates to:
  /// **'Buton Tıklamaları'**
  String get hapticButtonTaps;

  /// No description provided for @hapticButtonTapsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Butonlara dokunduğunuzda'**
  String get hapticButtonTapsDesc;

  /// No description provided for @hapticNavigation.
  ///
  /// In tr, this message translates to:
  /// **'Navigasyon'**
  String get hapticNavigation;

  /// No description provided for @hapticNavigationDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa geçişleri ve seçici kaydırmaları'**
  String get hapticNavigationDesc;

  /// No description provided for @hapticDelete.
  ///
  /// In tr, this message translates to:
  /// **'Silme İşlemleri'**
  String get hapticDelete;

  /// No description provided for @hapticDeleteDesc.
  ///
  /// In tr, this message translates to:
  /// **'Öğe sildiğinizde'**
  String get hapticDeleteDesc;

  /// No description provided for @hapticSuccessNotif.
  ///
  /// In tr, this message translates to:
  /// **'Başarı Bildirimi'**
  String get hapticSuccessNotif;

  /// No description provided for @hapticSuccessNotifDesc.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarılı olduğunda'**
  String get hapticSuccessNotifDesc;

  /// No description provided for @hapticErrorNotif.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildirimi'**
  String get hapticErrorNotif;

  /// No description provided for @hapticErrorNotifDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hata oluştuğunda'**
  String get hapticErrorNotifDesc;

  /// No description provided for @hapticCelebration.
  ///
  /// In tr, this message translates to:
  /// **'Seri Kutlama'**
  String get hapticCelebration;

  /// No description provided for @hapticCelebrationDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seri arttığında kutlama titreşimi'**
  String get hapticCelebrationDesc;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Finansal hatırlatmalar ve uyarıları yönetin'**
  String get notificationSettingsDesc;

  /// No description provided for @notificationsEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler etkinleştirildi'**
  String get notificationsEnabled;

  /// No description provided for @notificationPermDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verilmedi'**
  String get notificationPermDenied;

  /// No description provided for @openSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Aç'**
  String get openSettings;

  /// No description provided for @notificationScenarios.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Senaryoları'**
  String get notificationScenarios;

  /// No description provided for @scheduleSettings.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlama Ayarları'**
  String get scheduleSettings;

  /// No description provided for @turnOffAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Kapat'**
  String get turnOffAll;

  /// No description provided for @turnOnAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Aç'**
  String get turnOnAll;

  /// No description provided for @recurringReminder.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan İşlem Hatırlatıcı'**
  String get recurringReminder;

  /// No description provided for @recurringReminderDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme/fatura gününden 1 gün önce'**
  String get recurringReminderDesc;

  /// No description provided for @streakReminderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seri Hatırlatıcı'**
  String get streakReminderTitle;

  /// No description provided for @streakReminderDesc.
  ///
  /// In tr, this message translates to:
  /// **'Günlük işlem girişi hatırlatması'**
  String get streakReminderDesc;

  /// No description provided for @lastChanceWarning.
  ///
  /// In tr, this message translates to:
  /// **'Son Şans Uyarısı'**
  String get lastChanceWarning;

  /// No description provided for @lastChanceWarningDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her gün 22:00 - seri kırılma riski'**
  String get lastChanceWarningDesc;

  /// No description provided for @monthlySummary.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Özet'**
  String get monthlySummary;

  /// No description provided for @monthlySummaryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her ayın son günü finansal özet'**
  String get monthlySummaryDesc;

  /// No description provided for @weeklyReport.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Rapor'**
  String get weeklyReport;

  /// No description provided for @weeklyReportDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Pazar 18:00 - en çok harcama kategorisi'**
  String get weeklyReportDesc;

  /// No description provided for @streakReminderTime.
  ///
  /// In tr, this message translates to:
  /// **'Seri Hatırlatıcı Saati'**
  String get streakReminderTime;

  /// No description provided for @monthlySummaryTime.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Özet Saati'**
  String get monthlySummaryTime;

  /// No description provided for @lastDayOfMonth.
  ///
  /// In tr, this message translates to:
  /// **'Her ayın son günü'**
  String get lastDayOfMonth;

  /// No description provided for @voiceAssistantTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Asistan'**
  String get voiceAssistantTitle;

  /// No description provided for @voiceAssistantDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sesli komut ve geri bildirim ayarlarını yönetin'**
  String get voiceAssistantDesc;

  /// No description provided for @voiceFeedbackLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Geri Bildirim'**
  String get voiceFeedbackLabel;

  /// No description provided for @on.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get on;

  /// No description provided for @off.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get off;

  /// No description provided for @viewAllVoiceCommands.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Sesli Komutları Görüntüle'**
  String get viewAllVoiceCommands;

  /// No description provided for @voiceCommandsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Komutlar'**
  String get voiceCommandsTitle;

  /// No description provided for @voiceCommandsInfo.
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdaki komutları sesli asistanla kullanabilirsiniz.'**
  String get voiceCommandsInfo;

  /// No description provided for @voiceCommandsTip.
  ///
  /// In tr, this message translates to:
  /// **'İpucu: Komutları denerken doğal konuşmaya çalışın. Uygulama farklı varyasyonları anlayabilir.'**
  String get voiceCommandsTip;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil Ayarları'**
  String get profileSettingsTitle;

  /// No description provided for @userNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı'**
  String get userNotFound;

  /// No description provided for @userLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bilgileri yüklenemedi'**
  String get userLoadError;

  /// No description provided for @biometricEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik giriş aktifleştirildi'**
  String get biometricEnabled;

  /// No description provided for @biometricDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik giriş kapatıldı'**
  String get biometricDisabled;

  /// No description provided for @unknownDate.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get unknownDate;

  /// No description provided for @aboutSupportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında & Destek'**
  String get aboutSupportTitle;

  /// No description provided for @aboutSupportDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama bilgileri, destek ve iletişim'**
  String get aboutSupportDesc;

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Versiyonu'**
  String get appVersion;

  /// No description provided for @developer.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici'**
  String get developer;

  /// No description provided for @contactUs.
  ///
  /// In tr, this message translates to:
  /// **'Bize Ulaşın'**
  String get contactUs;

  /// No description provided for @rateApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Değerlendir'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Paylaş'**
  String get shareApp;

  /// No description provided for @licenses.
  ///
  /// In tr, this message translates to:
  /// **'Lisanslar'**
  String get licenses;

  /// No description provided for @termsOfService.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get termsOfService;

  /// No description provided for @legal.
  ///
  /// In tr, this message translates to:
  /// **'Yasal'**
  String get legal;

  /// No description provided for @support.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get support;

  /// No description provided for @faq.
  ///
  /// In tr, this message translates to:
  /// **'Sıkça Sorulan Sorular'**
  String get faq;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi nasıl koruduğumuzu öğrenin'**
  String get privacyPolicyDesc;

  /// No description provided for @termsOfServiceDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama kullanım şartları ve kurallar'**
  String get termsOfServiceDesc;

  /// No description provided for @openSourceLicenses.
  ///
  /// In tr, this message translates to:
  /// **'Açık Kaynak Lisansları'**
  String get openSourceLicenses;

  /// No description provided for @openSourceLicensesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kullanılan kütüphaneler ve lisansları'**
  String get openSourceLicensesDesc;

  /// No description provided for @shareAppDesc.
  ///
  /// In tr, this message translates to:
  /// **'Cashly\'i arkadaşlarınla paylaş'**
  String get shareAppDesc;

  /// No description provided for @appSlogan.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Bütçe Takip Asistanın'**
  String get appSlogan;

  /// No description provided for @footerMessage.
  ///
  /// In tr, this message translates to:
  /// **'Cashly ile bütçeni kontrol altına al 💰'**
  String get footerMessage;

  /// No description provided for @copyright.
  ///
  /// In tr, this message translates to:
  /// **'© 2026 Cashly. Tüm hakları saklıdır.'**
  String get copyright;

  /// No description provided for @lastUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: 17 Şubat 2026'**
  String get lastUpdated;

  /// No description provided for @shareText.
  ///
  /// In tr, this message translates to:
  /// **'Cashly ile bütçeni kolayca takip et! 💰\nHarcamalarını, gelirlerini ve varlıklarını tek bir yerden yönet.\n\n📲 Hemen dene!'**
  String get shareText;

  /// No description provided for @expenseSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gider Ayarları'**
  String get expenseSettingsTitle;

  /// No description provided for @expenseSettingsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bütçenizi ve harcama tercihlerinizi yönetin'**
  String get expenseSettingsDesc;

  /// No description provided for @budgetUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Limitiniz {amount} TL olarak güncellendi.'**
  String budgetUpdated(String amount);

  /// No description provided for @defaultPaymentUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan ödeme yöntemi güncellendi ✅'**
  String get defaultPaymentUpdated;

  /// No description provided for @transferSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Transfer Ayarları'**
  String get transferSettingsTitle;

  /// No description provided for @transferSettingsPageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Para Transferleri'**
  String get transferSettingsPageTitle;

  /// No description provided for @transferSettingsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Transfer ayarlarını ve görüntüleme tercihlerinizi yönetin'**
  String get transferSettingsDesc;

  /// No description provided for @transactionHistoryLimit.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Geçmişi Limiti'**
  String get transactionHistoryLimit;

  /// No description provided for @transactionHistoryLimitDesc.
  ///
  /// In tr, this message translates to:
  /// **'Transfer sayfasında gösterilecek işlem geçmişi sayısı'**
  String get transactionHistoryLimitDesc;

  /// No description provided for @historyLimitSaved.
  ///
  /// In tr, this message translates to:
  /// **'İşlem geçmişi limiti {limit} olarak kaydedildi ✅'**
  String historyLimitSaved(int limit);

  /// No description provided for @select.
  ///
  /// In tr, this message translates to:
  /// **'Seçiniz'**
  String get select;

  /// No description provided for @useFirstPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'İlk ödeme yöntemini kullan'**
  String get useFirstPaymentMethod;

  /// No description provided for @manageRecurringExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan Giderleri Yönet'**
  String get manageRecurringExpenses;

  /// No description provided for @autoPayBillsSubscriptions.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik ödenen fatura ve abonelikler'**
  String get autoPayBillsSubscriptions;

  /// No description provided for @customizeExpenseCategories.
  ///
  /// In tr, this message translates to:
  /// **'Harcama kategorilerini özelleştirin'**
  String get customizeExpenseCategories;

  /// No description provided for @addEditDeleteCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategorileri ekleyin, düzenleyin veya silin'**
  String get addEditDeleteCategories;

  /// No description provided for @setCategoryLimits.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Limitleri Belirle'**
  String get setCategoryLimits;

  /// No description provided for @noLimitSet.
  ///
  /// In tr, this message translates to:
  /// **'Limit belirlenmemiş'**
  String get noLimitSet;

  /// No description provided for @enterAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar girin'**
  String get enterAmount;

  /// No description provided for @profilePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Profil Fotoğrafı'**
  String get profilePhoto;

  /// No description provided for @editPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get editPhoto;

  /// No description provided for @pin.
  ///
  /// In tr, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @memberSince.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik Tarihi'**
  String get memberSince;

  /// No description provided for @lastLogin.
  ///
  /// In tr, this message translates to:
  /// **'Son Giriş'**
  String get lastLogin;

  /// No description provided for @biometricLogin.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik Giriş'**
  String get biometricLogin;

  /// No description provided for @biometricDesc.
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi veya yüz tanıma ile giriş yapın'**
  String get biometricDesc;

  /// No description provided for @dangerZone.
  ///
  /// In tr, this message translates to:
  /// **'Tehlikeli Bölge'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verileriniz kalıcı olarak silinir'**
  String get deleteAccountDesc;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Silmek İstediğinize Emin Misiniz?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.'**
  String get deleteAccountWarning;

  /// No description provided for @defaultPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan Ödeme Yöntemi'**
  String get defaultPaymentMethod;

  /// No description provided for @noPaymentMethodAdded.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ödeme yöntemi eklemediniz. Araçlar sayfasından ekleyebilirsiniz.'**
  String get noPaymentMethodAdded;

  /// No description provided for @categoryBudgetActive.
  ///
  /// In tr, this message translates to:
  /// **'{count} aktif limit'**
  String categoryBudgetActive(int count);

  /// No description provided for @monthlyIncomeBudgetLimit.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Gelir (Bütçe Limiti)'**
  String get monthlyIncomeBudgetLimit;

  /// No description provided for @myExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalarım'**
  String get myExpenses;

  /// No description provided for @myIncomes.
  ///
  /// In tr, this message translates to:
  /// **'Gelirlerim'**
  String get myIncomes;

  /// No description provided for @searchExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcama ara...'**
  String get searchExpense;

  /// No description provided for @searchIncome.
  ///
  /// In tr, this message translates to:
  /// **'Gelir ara...'**
  String get searchIncome;

  /// No description provided for @goToToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugüne git'**
  String get goToToday;

  /// No description provided for @recycleBinTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get recycleBinTooltip;

  /// No description provided for @voiceInputTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Giriş'**
  String get voiceInputTooltip;

  /// No description provided for @homePage.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get homePage;

  /// No description provided for @selectPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Dönem Seç'**
  String get selectPeriod;

  /// No description provided for @year.
  ///
  /// In tr, this message translates to:
  /// **'Yıl'**
  String get year;

  /// No description provided for @month.
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get month;

  /// No description provided for @allDataUpToDate.
  ///
  /// In tr, this message translates to:
  /// **'Tüm veriler güncel'**
  String get allDataUpToDate;

  /// No description provided for @canRefreshIn.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} sn sonra yenilenebilir'**
  String canRefreshIn(int seconds);

  /// No description provided for @user.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get user;

  /// No description provided for @account.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account;

  /// No description provided for @userInfo.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Bilgileri'**
  String get userInfo;

  /// No description provided for @userInfoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ad, e-posta ve profil resmi'**
  String get userInfoSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm, sesli asistan ve harcamalar'**
  String get settingsSubtitle;

  /// No description provided for @aboutAndSupportSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon, SSS ve yasal bilgiler'**
  String get aboutAndSupportSubtitle;

  /// No description provided for @session.
  ///
  /// In tr, this message translates to:
  /// **'Oturum'**
  String get session;

  /// No description provided for @logoutSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabından güvenli çıkış yap'**
  String get logoutSubtitle;

  /// No description provided for @assets.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklar'**
  String get assets;

  /// No description provided for @transactions.
  ///
  /// In tr, this message translates to:
  /// **'İşlemler'**
  String get transactions;

  /// No description provided for @allTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Tüm İşlemler'**
  String get allTransactions;

  /// No description provided for @newRecurringExpense.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Tekrarlayan Gider'**
  String get newRecurringExpense;

  /// No description provided for @editTransaction.
  ///
  /// In tr, this message translates to:
  /// **'İşlemi Düzenle'**
  String get editTransaction;

  /// No description provided for @transactionName.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Adı'**
  String get transactionName;

  /// No description provided for @transactionNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'İşlem adı gerekli'**
  String get transactionNameRequired;

  /// No description provided for @amountWithCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Tutar (₺)'**
  String get amountWithCurrency;

  /// No description provided for @amountRequired.
  ///
  /// In tr, this message translates to:
  /// **'Tutar gerekli'**
  String get amountRequired;

  /// No description provided for @enterValidAmount.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar girin'**
  String get enterValidAmount;

  /// No description provided for @everyMonthOn.
  ///
  /// In tr, this message translates to:
  /// **'Her ayın:'**
  String get everyMonthOn;

  /// No description provided for @dayOfMonth.
  ///
  /// In tr, this message translates to:
  /// **'{day}. günü'**
  String dayOfMonth(int day);

  /// No description provided for @paymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemi'**
  String get paymentMethod;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemi Seçin'**
  String get selectPaymentMethod;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @transactionUpdated.
  ///
  /// In tr, this message translates to:
  /// **'İşlem güncellendi'**
  String get transactionUpdated;

  /// No description provided for @transactionAdded.
  ///
  /// In tr, this message translates to:
  /// **'İşlem eklendi'**
  String get transactionAdded;

  /// No description provided for @errorWhileSaving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetme sırasında bir hata oluştu'**
  String get errorWhileSaving;

  /// No description provided for @notSpecified.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmemiş'**
  String get notSpecified;

  /// No description provided for @recurringTransactionsInfo.
  ///
  /// In tr, this message translates to:
  /// **'Tanımladığınız işlemler her ayın belirlediğiniz gününde otomatik olarak harcamalarınıza eklenir.'**
  String get recurringTransactionsInfo;

  /// No description provided for @noRecurringTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tekrarlayan işlem yok'**
  String get noRecurringTransactions;

  /// No description provided for @tapPlusToAdd.
  ///
  /// In tr, this message translates to:
  /// **'Eklemek için + butonuna tıklayın'**
  String get tapPlusToAdd;

  /// No description provided for @deleteTransaction.
  ///
  /// In tr, this message translates to:
  /// **'İşlemi Sil'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{name} işlemini silmek istiyor musunuz?'**
  String deleteTransactionConfirm(String name);

  /// No description provided for @unnamed.
  ///
  /// In tr, this message translates to:
  /// **'İsimsiz'**
  String get unnamed;

  /// No description provided for @everyMonthDayOf.
  ///
  /// In tr, this message translates to:
  /// **'Her ayın {day}. günü • {method}'**
  String everyMonthDayOf(int day, String method);

  /// No description provided for @categoryBasedUsage.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Bazlı Kullanım'**
  String get categoryBasedUsage;

  /// No description provided for @unlimitedCategories.
  ///
  /// In tr, this message translates to:
  /// **'Limitsiz Kategoriler'**
  String get unlimitedCategories;

  /// No description provided for @totalBudget.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Bütçe'**
  String get totalBudget;

  /// No description provided for @exceeded.
  ///
  /// In tr, this message translates to:
  /// **'Aşım: {amount}'**
  String exceeded(String amount);

  /// No description provided for @remaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan: {amount}'**
  String remaining(String amount);

  /// No description provided for @exceededPercent.
  ///
  /// In tr, this message translates to:
  /// **'Aşıldı! {percent}%'**
  String exceededPercent(String percent);

  /// No description provided for @categoryBudgetInfo.
  ///
  /// In tr, this message translates to:
  /// **'Her kategori için aylık harcama limiti belirleyin. Limit yaklaştığında veya aşıldığında ana sayfada uyarı göreceksiniz.'**
  String get categoryBudgetInfo;

  /// No description provided for @categoryBudgetDialogInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategori için aylık harcama limiti belirleyin. Limit aşıldığında ana sayfada uyarı görürsünüz.'**
  String get categoryBudgetDialogInfo;

  /// No description provided for @monthlyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Limit'**
  String get monthlyLimit;

  /// No description provided for @noLimit.
  ///
  /// In tr, this message translates to:
  /// **'Limitsiz'**
  String get noLimit;

  /// No description provided for @zeroNoLimit.
  ///
  /// In tr, this message translates to:
  /// **'0 = Limitsiz'**
  String get zeroNoLimit;

  /// No description provided for @limitNotSet.
  ///
  /// In tr, this message translates to:
  /// **'Limit belirlenmemiş'**
  String get limitNotSet;

  /// No description provided for @monthlyLimitAmount.
  ///
  /// In tr, this message translates to:
  /// **'{amount}₺ aylık limit'**
  String monthlyLimitAmount(String amount);

  /// No description provided for @removeLimit.
  ///
  /// In tr, this message translates to:
  /// **'Limiti Kaldır'**
  String get removeLimit;

  /// No description provided for @limitRemoved.
  ///
  /// In tr, this message translates to:
  /// **'{category} limiti kaldırıldı'**
  String limitRemoved(String category);

  /// No description provided for @maxLimitWarning.
  ///
  /// In tr, this message translates to:
  /// **'Maximum 10 milyar ₺ limit belirleyebilirsiniz'**
  String get maxLimitWarning;

  /// No description provided for @limitSet.
  ///
  /// In tr, this message translates to:
  /// **'{category} limiti {amount}₺ olarak ayarlandı'**
  String limitSet(String category, String amount);

  /// No description provided for @activeBudgets.
  ///
  /// In tr, this message translates to:
  /// **'{count} aktif'**
  String activeBudgets(int count);

  /// No description provided for @expenseDetail.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Detayı'**
  String get expenseDetail;

  /// No description provided for @expenseInfo.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Bilgileri'**
  String get expenseInfo;

  /// No description provided for @spentAmountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harcanan Tutar'**
  String get spentAmountLabel;

  /// No description provided for @deleteExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcamayı Sil'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" harcamasını silmek istediğinize emin misiniz?'**
  String deleteExpenseConfirm(String name);

  /// No description provided for @expenseCategories.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Kategorileri'**
  String get expenseCategories;

  /// No description provided for @editPhotoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Düzenle'**
  String get editPhotoTitle;

  /// No description provided for @resetAllEffects.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Efektleri Sıfırla'**
  String get resetAllEffects;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @tryAgainShort.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden'**
  String get tryAgainShort;

  /// No description provided for @scheduledTransfersFailed.
  ///
  /// In tr, this message translates to:
  /// **'Şu işlemler gerçekleştirilemedi: {reasons}'**
  String scheduledTransfersFailed(String reasons);

  /// No description provided for @senderAccountNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Gönderen hesap bulunamadı'**
  String get senderAccountNotFound;

  /// No description provided for @receiverAccountNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Alıcı hesap bulunamadı'**
  String get receiverAccountNotFound;

  /// No description provided for @accountDeleted.
  ///
  /// In tr, this message translates to:
  /// **'{account} silinmiş'**
  String accountDeleted(String account);

  /// No description provided for @insufficientBalanceAccount.
  ///
  /// In tr, this message translates to:
  /// **'{accountName} hesabında yetersiz bakiye'**
  String insufficientBalanceAccount(String accountName);

  /// No description provided for @noDebtToPay.
  ///
  /// In tr, this message translates to:
  /// **'{accountName} kapatılacak borç yok'**
  String noDebtToPay(String accountName);

  /// No description provided for @voiceCmdAddExpenseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Ekleme'**
  String get voiceCmdAddExpenseTitle;

  /// No description provided for @voiceCmdAddExpenseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tutarı, kategoriyi ve opsiyonel olarak tarihi söyleyerek harcama ekleyin.'**
  String get voiceCmdAddExpenseDesc;

  /// No description provided for @voiceCmdAddExpenseExamples.
  ///
  /// In tr, this message translates to:
  /// **'100 lira market|50 TL kahve|Dün 80 lira market|Geçen pazartesi 200 TL benzin|Önceki gün 150 lira yemek'**
  String get voiceCmdAddExpenseExamples;

  /// No description provided for @voiceCmdDeleteExpenseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Silme'**
  String get voiceCmdDeleteExpenseTitle;

  /// No description provided for @voiceCmdDeleteExpenseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Son eklediğiniz harcamayı silin.'**
  String get voiceCmdDeleteExpenseDesc;

  /// No description provided for @voiceCmdDeleteExpenseExamples.
  ///
  /// In tr, this message translates to:
  /// **'Son harcamayı sil|Sonuncuyu sil|Son eklediğimi sil|Son kaydı sil'**
  String get voiceCmdDeleteExpenseExamples;

  /// No description provided for @voiceCmdEditExpenseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Düzenleme'**
  String get voiceCmdEditExpenseTitle;

  /// No description provided for @voiceCmdEditExpenseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Son harcamanızın tutarını değiştirin.'**
  String get voiceCmdEditExpenseDesc;

  /// No description provided for @voiceCmdEditExpenseExamples.
  ///
  /// In tr, this message translates to:
  /// **'Son harcamayı 100 lira yap|Sonuncuyu 50 TL yap|Son harcamayı 200 lira güncelle|Son kaydı 75 lira değiştir'**
  String get voiceCmdEditExpenseExamples;

  /// No description provided for @voiceCmdTotalQueryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Harcama Sorgulama'**
  String get voiceCmdTotalQueryTitle;

  /// No description provided for @voiceCmdTotalQueryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Aylık, haftalık veya günlük toplam harcamanızı öğrenin.'**
  String get voiceCmdTotalQueryDesc;

  /// No description provided for @voiceCmdTotalQueryExamples.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay ne kadar harcadım?|Bu hafta ne kadar harcadım?|Bugün ne kadar harcadım?|Toplam harcamam ne kadar?|Haftalık harcamam|Bugünkü harcamam'**
  String get voiceCmdTotalQueryExamples;

  /// No description provided for @voiceCmdCategoryAnalysisTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Analizi'**
  String get voiceCmdCategoryAnalysisTitle;

  /// No description provided for @voiceCmdCategoryAnalysisDesc.
  ///
  /// In tr, this message translates to:
  /// **'En çok harcama yaptığınız kategoriyi öğrenin.'**
  String get voiceCmdCategoryAnalysisDesc;

  /// No description provided for @voiceCmdCategoryAnalysisExamples.
  ///
  /// In tr, this message translates to:
  /// **'En çok hangi kategoride harcamışım?|En çok nereye harcadım?|En fazla harcama nerede?'**
  String get voiceCmdCategoryAnalysisExamples;

  /// No description provided for @voiceCmdCategoryQueryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriye Göre Harcama'**
  String get voiceCmdCategoryQueryTitle;

  /// No description provided for @voiceCmdCategoryQueryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Belirli bir kategorideki toplam harcamanızı öğrenin.'**
  String get voiceCmdCategoryQueryDesc;

  /// No description provided for @voiceCmdCategoryQueryExamples.
  ///
  /// In tr, this message translates to:
  /// **'Markete ne kadar harcadım?|Yemek kategorisinde ne kadar?|Ulaşıma ne kadar harcamışım?|Spor kategorisinde kaç lira?'**
  String get voiceCmdCategoryQueryExamples;

  /// No description provided for @voiceCmdLastExpensesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son Harcamaları Listeleme'**
  String get voiceCmdLastExpensesTitle;

  /// No description provided for @voiceCmdLastExpensesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Son yaptığınız harcamaları listeleyin.'**
  String get voiceCmdLastExpensesDesc;

  /// No description provided for @voiceCmdLastExpensesExamples.
  ///
  /// In tr, this message translates to:
  /// **'Son harcamalarım neler?|Son harcamalarımı söyle|Son 5 harcamam|Son harcamalarımı listele'**
  String get voiceCmdLastExpensesExamples;

  /// No description provided for @voiceCmdBudgetStatusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Durumu'**
  String get voiceCmdBudgetStatusTitle;

  /// No description provided for @voiceCmdBudgetStatusDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bütçenizin durumunu kontrol edin.'**
  String get voiceCmdBudgetStatusDesc;

  /// No description provided for @voiceCmdBudgetStatusExamples.
  ///
  /// In tr, this message translates to:
  /// **'Bütçemi aştım mı?|Limit durumum ne?|Limiti geçtim mi?|Bütçe durumu'**
  String get voiceCmdBudgetStatusExamples;

  /// No description provided for @voiceCmdRemainingBudgetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Bütçe Sorgulama'**
  String get voiceCmdRemainingBudgetTitle;

  /// No description provided for @voiceCmdRemainingBudgetDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bütçenizden ne kadar kaldığını öğrenin.'**
  String get voiceCmdRemainingBudgetDesc;

  /// No description provided for @voiceCmdRemainingBudgetExamples.
  ///
  /// In tr, this message translates to:
  /// **'Kalan bütçem ne kadar?|Ne kadar harcayabilirim?|Kalan limitim|Bütçemden ne kadar kaldı?'**
  String get voiceCmdRemainingBudgetExamples;

  /// No description provided for @voiceCmdSetLimitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Limiti Belirleme'**
  String get voiceCmdSetLimitTitle;

  /// No description provided for @voiceCmdSetLimitDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sesli olarak aylık bütçenizi güncelleyin.'**
  String get voiceCmdSetLimitDesc;

  /// No description provided for @voiceCmdSetLimitExamples.
  ///
  /// In tr, this message translates to:
  /// **'Aylık limitimi 10000 lira yap|Bütçemi 5000 lira olarak ayarla|Limitimi 8000 lira güncelle|Aylık bütçe 15000 lira olsun'**
  String get voiceCmdSetLimitExamples;

  /// No description provided for @voiceCmdSavingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tasarruf Hesaplama'**
  String get voiceCmdSavingsTitle;

  /// No description provided for @voiceCmdSavingsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay ne kadar tasarruf ettiğinizi öğrenin.'**
  String get voiceCmdSavingsDesc;

  /// No description provided for @voiceCmdSavingsExamples.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay ne kadar tasarruf ettim?|Tasarrufum ne kadar?|Ne kadar biriktirdim?|Artıda mıyım?'**
  String get voiceCmdSavingsExamples;

  /// No description provided for @voiceCmdAddFixedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sabit Giderleri Ekle'**
  String get voiceCmdAddFixedTitle;

  /// No description provided for @voiceCmdAddFixedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlardan tanımladığınız sabit giderleri bu aya ekleyin.'**
  String get voiceCmdAddFixedDesc;

  /// No description provided for @voiceCmdAddFixedExamples.
  ///
  /// In tr, this message translates to:
  /// **'Sabit giderleri ekle|Sabit giderleri bu aya ekle|Faturaları ekle|Düzenli giderleri ekle'**
  String get voiceCmdAddFixedExamples;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In tr, this message translates to:
  /// **'1. Giriş\n\nBu Gizlilik Politikası, Cashly uygulamasının (\"Uygulama\") kullanıcılarının kişisel verilerinin nasıl toplandığını, saklandığını ve korunduğunu açıklamaktadır. Uygulamayı kullanarak bu politikayı kabul etmiş sayılırsınız.\n\nSon güncelleme: 17 Şubat 2026\n\n2. Veri Toplama ve Kullanım\n\nCashly, tüm verilerinizi yalnızca cihazınızda (yerel olarak) saklar. Sunucularımıza herhangi bir kişisel veri gönderilmez, aktarılmaz veya iletilmez.\n\nToplanan ve cihazda saklanan veriler:\n• Kullanıcı bilgileri (isim ve e-posta adresi)\n• Harcama ve gelir kayıtları (tutar, kategori, tarih, açıklama)\n• Varlık bilgileri (tür, miktar, değer)\n• Ödeme yöntemleri ve bakiye bilgileri\n• Transfer kayıtları\n• Bütçe limitleri ve kategori bütçeleri\n• Profil fotoğrafı (isteğe bağlı)\n• Uygulama tercihleri ve ayarları\n• Seri (streak) kayıtları\n\nBu veriler yalnızca uygulamanın temel işlevlerini sağlamak amacıyla kullanılır.\n\n3. Veri Güvenliği\n\nVerilerinizin güvenliği bizim için en önemli önceliktir:\n\n• Tüm veriler cihazınızda yerel veritabanında saklanır.\n• 4 haneli PIN kodu ile uygulamaya erişim korunur.\n• Biyometrik doğrulama (parmak izi / yüz tanıma) desteği mevcuttur.\n• Güvenlik sorusu ile ek koruma katmanı sağlanır.\n• Uygulama arka plana alındığında otomatik kilit devreye girer.\n• Uygulama dışarıya herhangi bir ağ bağlantısı kurmaz.\n\n4. Üçüncü Taraf Paylaşımı\n\nCashly, topladığı hiçbir veriyi üçüncü taraflarla paylaşmaz, satmaz veya kiralamaz. Verileriniz tamamen size aittir. Uygulama içinde üçüncü taraf analitik veya reklam araçları kullanılmamaktadır.\n\n5. Veri Yedekleme ve Aktarım\n\n• Yedekleme işlemi tamamen kullanıcı kontrolündedir ve isteğe bağlıdır.\n• Yedek dosyaları JSON formatında cihazınıza dışa aktarılır.\n• Yedek dosyasının güvenliği ve saklanması kullanıcının sorumluluğundadır.\n• Yedek dosyası; harcamalar, gelirler, varlıklar, ödeme yöntemleri, transferler ve profil bilgilerini içerir.\n• Geri yükleme işlemi mevcut verilerin üzerine yazar.\n\n6. Veri Saklama Süresi\n\nVerileriniz, hesabınızı silene kadar cihazınızda saklanır. Uygulamayı kaldırmanız durumunda tüm veriler otomatik olarak silinir.\n\n7. Veri Silme Hakkı\n\nHesabınızı ve tüm verilerinizi istediğiniz zaman kalıcı olarak silebilirsiniz:\n• Profil > Kullanıcı Bilgileri > Hesabı Sil seçeneğini kullanın.\n• Silme işlemi güvenlik doğrulaması gerektirir.\n• Silinen veriler geri getirilemez.\n• Silme öncesi yedek almanız önerilir.\n\n8. Çocukların Gizliliği\n\nCashly, 13 yaşın altındaki çocuklara yönelik değildir. 13 yaşın altındaki kullanıcılardan bilerek veri toplamıyoruz.\n\n9. Politika Değişiklikleri\n\nBu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinden bildirilecektir.\n\n10. İletişim\n\nGizlilik politikamız hakkında sorularınız veya talepleriniz için uygulama içinden bizimle iletişime geçebilirsiniz.'**
  String get privacyPolicyContent;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In tr, this message translates to:
  /// **'1. Kabul ve Kapsam\n\nCashly uygulamasını (\"Uygulama\") indirerek, kurarak veya kullanarak bu Kullanım Koşullarını kabul etmiş olursunuz. Bu koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayınız.\n\nSon güncelleme: 17 Şubat 2026\n\n2. Hizmet Tanımı\n\nCashly, kişisel bütçe takibi ve finansal yönetim aracıdır. Uygulama aşağıdaki hizmetleri sunar:\n\n• Harcama ve gelir takibi (manuel ve sesli giriş)\n• Varlık yönetimi (altın, döviz, kripto, banka hesabı)\n• Bütçe planlama ve kategori bazlı limit belirleme\n• Ödeme yöntemi yönetimi ve bakiye takibi\n• Hesaplar arası transfer kayıtları\n• Düzenli gelir/gider tanımlama\n• Sesli asistan ile doğal dil komutları\n• Veri yedekleme ve geri yükleme\n• İstatistik ve grafik raporları\n\n3. Hesap ve Güvenlik\n\n• Hesabınızı oluştururken doğru bilgiler girmeniz gerekmektedir.\n• PIN kodunuz hesabınızın güvenlik anahtarıdır; kimseyle paylaşmayınız.\n• Biyometrik giriş ve güvenlik sorusu ek koruma katmanlarıdır.\n• Hesabınıza yetkisiz erişimden siz sorumlusunuz.\n• Şüpheli bir durum fark ederseniz PIN kodunuzu değiştirmeniz önerilir.\n\n4. Kullanıcı Sorumlulukları\n\n• Girdiğiniz finansal veriler tamamen size aittir ve doğruluğundan siz sorumlusunuz.\n• Uygulamayı yasa dışı amaçlarla kullanamazsınız.\n• Düzenli veri yedeklemesi yapmanız önerilir.\n• Yedek dosyalarınızın güvenliğinden siz sorumlusunuz.\n• Uygulamayı tersine mühendislik, kaynak kod çıkarma veya değiştirme girişiminde bulunamazsınız.\n\n5. Sorumluluk Reddi\n\nÖNEMLİ - Lütfen dikkatlice okuyunuz:\n\n• Cashly bir finansal danışmanlık, yatırım tavsiyesi veya muhasebe aracı değildir.\n• Uygulama, herhangi bir yatırım, tasarruf veya harcama tavsiyesi vermez.\n• Finansal kararlarınızdan Cashly sorumlu tutulamaz.\n• Uygulama \"olduğu gibi\" sunulmaktadır; kesintisiz veya hatasız çalışacağı garanti edilmez.\n• Cihaz arızası, yazılım hatası veya kullanıcı kaynaklı veri kaybından dolayı sorumluluk kabul edilmez.\n• Güncel döviz kurları ve varlık fiyatları bilgi amaçlıdır; gerçek piyasa değerlerinden farklılık gösterebilir.\n\n6. Veri ve İçerik\n\n• Uygulamaya girdiğiniz tüm veriler cihazınızda saklanır.\n• Verilerin doğruluğu, bütünlüğü ve güncelliğinden siz sorumlusunuz.\n• Hesap silme işlemi geri alınamaz; tüm verileriniz kalıcı olarak kaldırılır.\n\n7. Fikri Mülkiyet\n\n• Cashly uygulaması, tasarımı, logoları ve tüm içeriği telif hakkı ile korunmaktadır.\n• Uygulama kodunun, görsellerinin ve tasarımının izinsiz kopyalanması, dağıtılması veya türev çalışma oluşturulması yasaktır.\n• \"Cashly\" ismi ve logosu tescilli markadır.\n\n8. Hizmet Değişiklikleri\n\n• Uygulama özellikleri önceden haber verilmeksizin eklenebilir, değiştirilebilir veya kaldırılabilir.\n• Güncellemeler, hata düzeltmeleri ve iyileştirmeler düzenli olarak yapılabilir.\n\n9. Koşul Değişiklikleri\n\nBu kullanım koşulları zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinden bildirilecektir. Güncellemelerden sonra uygulamayı kullanmaya devam etmeniz, yeni koşulları kabul ettiğiniz anlamına gelir.\n\n10. Geçerli Hukuk\n\nBu koşullar Türkiye Cumhuriyeti yasalarına tabidir. Uyuşmazlıklarda Türkiye mahkemeleri yetkilidir.\n\n11. İletişim\n\nKullanım koşullarımız hakkında sorularınız için uygulama içinden bizimle iletişime geçebilirsiniz.'**
  String get termsOfServiceContent;

  /// No description provided for @faqSafetyQ.
  ///
  /// In tr, this message translates to:
  /// **'Verilerim güvende mi?'**
  String get faqSafetyQ;

  /// No description provided for @faqSafetyA.
  ///
  /// In tr, this message translates to:
  /// **'Kesinlikle! Cashly, gizliliğinizi en üst düzeyde korur:\n\n• Tüm verileriniz yalnızca cihazınızda saklanır, hiçbir sunucuya gönderilmez.\n• 4 haneli PIN kodu ile uygulamaya erişim korunur.\n• Biyometrik giriş (parmak izi / yüz tanıma) desteği mevcuttur.\n• Güvenlik sorusu ile ek koruma katmanı ekleyebilirsiniz.\n\nVerileriniz tamamen size aittir ve hiçbir üçüncü tarafla paylaşılmaz.'**
  String get faqSafetyA;

  /// No description provided for @faqOfflineQ.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı gerekli mi?'**
  String get faqOfflineQ;

  /// No description provided for @faqOfflineA.
  ///
  /// In tr, this message translates to:
  /// **'Hayır! Cashly tamamen çevrimdışı çalışacak şekilde tasarlanmıştır.\n\n• Harcama ve gelir ekleme, düzenleme, silme\n• Varlık yönetimi ve takibi\n• Bütçe planlama ve kategori yönetimi\n• Sesli asistan ile komut verme\n• Veri yedekleme ve geri yükleme\n\nTüm bu özellikler internet olmadan sorunsuz çalışır. Yalnızca güncel döviz/altın kurları için internet bağlantısı gerekebilir.'**
  String get faqOfflineA;

  /// No description provided for @faqBackupQ.
  ///
  /// In tr, this message translates to:
  /// **'Verilerimi nasıl yedekleyebilirim?'**
  String get faqBackupQ;

  /// No description provided for @faqBackupA.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi güvence altına almak için düzenli yedekleme yapmanızı öneririz:\n\n1. Profil > Ayarlar > Veri İşlemleri bölümüne gidin.\n2. \"Verileri Yedekle\" seçeneğine dokunun.\n3. Tüm verileriniz JSON formatında bir dosyaya aktarılır.\n4. Dosyayı Google Drive, e-posta veya istediğiniz bir yere kaydedin.\n\nYedek dosyası; harcamalarınızı, gelirlerinizi, varlıklarınızı, ödeme yöntemlerinizi, transferlerinizi ve profil bilgilerinizi içerir.'**
  String get faqBackupA;

  /// No description provided for @faqRestoreQ.
  ///
  /// In tr, this message translates to:
  /// **'Yedeğimi nasıl geri yüklerim?'**
  String get faqRestoreQ;

  /// No description provided for @faqRestoreA.
  ///
  /// In tr, this message translates to:
  /// **'Daha önce aldığınız yedeği geri yüklemek için:\n\n1. Profil > Ayarlar > Veri İşlemleri bölümüne gidin.\n2. \"Verileri Geri Yükle\" seçeneğine dokunun.\n3. Daha önce kaydettiğiniz JSON yedek dosyasını seçin.\n4. İşlem tamamlandığında uygulama otomatik olarak yenilenir.\n\nDikkat: Geri yükleme işlemi mevcut verilerinizi yedekteki verilerle değiştirir. Mevcut verilerinizi kaybetmemek için önce yeni bir yedek almanızı öneririz.'**
  String get faqRestoreA;

  /// No description provided for @faqVoiceAssisQ.
  ///
  /// In tr, this message translates to:
  /// **'Sesli asistan nasıl çalışır?'**
  String get faqVoiceAssisQ;

  /// No description provided for @faqVoiceAssisA.
  ///
  /// In tr, this message translates to:
  /// **'Cashly\'nin sesli asistanı, doğal dil ile harcama ve gelir eklemenizi sağlar:\n\n• Ana ekrandaki mikrofon ikonuna dokunun.\n• Doğal bir şekilde komut verin, örneğin:\n  - \"50 lira market harcaması ekle\"\n  - \"1500 lira maaş geliri ekle\"\n  - \"200 lira yemek harcaması ekle nakit ile\"\n\nAsistan, tutarı, kategoriyi ve ödeme yöntemini otomatik olarak algılar. Sesli geri bildirim ile işlemin başarılı olduğunu onaylar. Komut listesinin tamamını Ayarlar > Sesli Asistan bölümünden görebilirsiniz.'**
  String get faqVoiceAssisA;

  /// No description provided for @faqBudgetLimitQ.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe limitimi nasıl belirlerim?'**
  String get faqBudgetLimitQ;

  /// No description provided for @faqBudgetLimitA.
  ///
  /// In tr, this message translates to:
  /// **'Aylık harcama bütçenizi kontrol altında tutmak için:\n\n1. Profil > Ayarlar > Harcamalar bölümüne gidin.\n2. \"Aylık Bütçe Limiti\" alanına toplam aylık bütçenizi girin.\n3. Kaydet butonuna dokunun.\n\nBütçe limitinizi belirledikten sonra:\n• Ana ekranda bütçe doluluk oranınızı görebilirsiniz.\n• Limiti aşmaya yaklaştığınızda görsel uyarı alırsınız.\n• Renk kodları ile durumunuzu anlık takip edebilirsiniz (yeşil: güvenli, sarı: dikkat, kırmızı: limit aşıldı).'**
  String get faqBudgetLimitA;

  /// No description provided for @faqCategoryBudgetQ.
  ///
  /// In tr, this message translates to:
  /// **'Kategori bazında bütçe limiti nedir?'**
  String get faqCategoryBudgetQ;

  /// No description provided for @faqCategoryBudgetA.
  ///
  /// In tr, this message translates to:
  /// **'Genel bütçe limitinin yanı sıra her kategori için ayrı limit belirleyebilirsiniz:\n\n1. Profil > Ayarlar > Harcamalar > Kategori Bütçeleri bölümüne gidin.\n2. İstediğiniz kategoriye dokunun (örn. Yemek & Kafe).\n3. O kategori için aylık limit belirleyin.\n\nÖrnek kullanım:\n• Yemek & Kafe: 2.000₺\n• Ulaşım: 500₺\n• Eğlence: 1.000₺\n\nBu sayede harcamalarınızı kategori bazında detaylı kontrol edebilir ve hangi alanda tasarruf yapabileceğinizi görebilirsiniz.'**
  String get faqCategoryBudgetA;

  /// No description provided for @faqRecurringQ.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli gelir/gider nedir?'**
  String get faqRecurringQ;

  /// No description provided for @faqRecurringA.
  ///
  /// In tr, this message translates to:
  /// **'Her ay düzenli olarak tekrarlayan gelir veya giderlerinizi tanımlayabilirsiniz:\n\nDüzenli gelir örnekleri: Maaş, kira geliri, yan gelir\nDüzenli gider örnekleri: Kira, internet, telefon faturası, abonelikler\n\nNasıl eklenir:\n1. Ayarlar > Harcamalar veya Gelirler bölümüne gidin.\n2. \"Düzenli İşlemler\" seçeneğine dokunun.\n3. Tutar, kategori ve tekrar sıklığını belirleyin.\n\nDüzenli işlemler her ay otomatik olarak kaydedilir, böylece her seferinde manuel ekleme yapmanıza gerek kalmaz.'**
  String get faqRecurringA;

  /// No description provided for @faqAssetTrackingQ.
  ///
  /// In tr, this message translates to:
  /// **'Varlık takibi nasıl yapılır?'**
  String get faqAssetTrackingQ;

  /// No description provided for @faqAssetTrackingA.
  ///
  /// In tr, this message translates to:
  /// **'Cashly ile finansal varlıklarınızı tek bir yerden takip edebilirsiniz:\n\nDesteklenen varlık türleri:\n• Altın (gram, çeyrek, yarım, tam)\n• Döviz (USD, EUR vb.)\n• Kripto para\n• Banka hesapları\n• Gümüş\n\nVarlıklarınızı ekleyin, miktarını ve alış fiyatını girin. Toplam portföy değerinizi, kazanç/kayıp durumunuzu ve varlık dağılımınızı grafiklerle takip edin.'**
  String get faqAssetTrackingA;

  /// No description provided for @faqPaymentMethodsQ.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme yöntemlerimi nasıl yönetirim?'**
  String get faqPaymentMethodsQ;

  /// No description provided for @faqPaymentMethodsA.
  ///
  /// In tr, this message translates to:
  /// **'Farklı ödeme yöntemlerinizi tanımlayarak harcamalarınızı detaylı takip edin:\n\n• Nakit\n• Banka/kredi kartları\n• Dijital cüzdanlar\n\nHer ödeme yöntemine bakiye tanımlayabilir ve harcama yaptıkça bakiyenin otomatik güncellenmesini sağlayabilirsiniz. Bu sayede hangi karttan ne kadar harcadığınızı veya kasanızda ne kadar nakit kaldığını anlık görebilirsiniz.'**
  String get faqPaymentMethodsA;

  /// No description provided for @faqTransferQ.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplar arası transfer nasıl yapılır?'**
  String get faqTransferQ;

  /// No description provided for @faqTransferA.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme yöntemleriniz arasında para transferi kaydedebilirsiniz:\n\nÖrnek senaryolar:\n• Bankadan nakit çekme\n• Kredi kartı borcunu ödeme\n• Bir hesaptan diğerine aktarım\n\nTransfer işlemi, kaynak hesaptan tutarı düşer ve hedef hesaba ekler. Böylece tüm hesaplarınızın bakiyesi her zaman güncel kalır. Transfer geçmişinizi Ayarlar > Para Transferleri bölümünden görüntüleyebilirsiniz.'**
  String get faqTransferA;

  /// No description provided for @faqNotificationsQ.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler ne işe yarar?'**
  String get faqNotificationsQ;

  /// No description provided for @faqNotificationsA.
  ///
  /// In tr, this message translates to:
  /// **'Cashly, finansal hedeflerinizi takip etmeniz için çeşitli bildirimler sunar:\n\n• Günlük hatırlatıcı: Harcamalarınızı girmeyi unutmayın.\n• Bütçe uyarısı: Aylık limitinize yaklaştığınızda uyarı alın.\n• Düzenli işlem bildirimi: Tekrarlayan gelir/giderler kaydedildiğinde bilgilenin.\n\nTüm bildirim ayarlarını Profil > Ayarlar > Bildirimler bölümünden istediğiniz gibi açıp kapatabilir ve saatlerini özelleştirebilirsiniz.'**
  String get faqNotificationsA;

  /// No description provided for @faqStreakQ.
  ///
  /// In tr, this message translates to:
  /// **'Seri sistemi nedir?'**
  String get faqStreakQ;

  /// No description provided for @faqStreakA.
  ///
  /// In tr, this message translates to:
  /// **'Seri sistemi, düzenli kullanım alışkanlığı oluşturmanıza yardımcı olan bir motivasyon aracıdır:\n\n• Her gün uygulamayı kullanarak serinizi sürdürün.\n• Ardışık gün sayınız arttıkça seri seviyeniz yükselir.\n• Belirli seviyelere ulaştığınızda kutlama animasyonu görürsünüz.\n• Bir gün kaçırırsanız seriniz sıfırlanır.\n\nSeri sistemi, harcamalarınızı düzenli takip etme alışkanlığı kazanmanıza yardımcı olur. En yüksek serinizi kırmaya çalışın!'**
  String get faqStreakA;

  /// No description provided for @faqProfilePhotoQ.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafımı nasıl değiştiririm?'**
  String get faqProfilePhotoQ;

  /// No description provided for @faqProfilePhotoA.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafınızı değiştirmek için:\n\n1. Profil > Kullanıcı Bilgileri sayfasına gidin.\n2. Profil fotoğrafınızın üzerindeki düzenleme ikonuna dokunun.\n3. Galeriden fotoğraf seçin veya hazır avatarlardan birini kullanın.\n4. Seçtiğiniz fotoğrafı kırpın, döndürün ve filtre uygulayın.\n\nFotoğraf düzenleyici ile fotoğrafınızı tam istediğiniz gibi ayarlayabilirsiniz.'**
  String get faqProfilePhotoA;

  /// No description provided for @faqForgotPinQ.
  ///
  /// In tr, this message translates to:
  /// **'PIN kodumu unutursam ne yapmalıyım?'**
  String get faqForgotPinQ;

  /// No description provided for @faqForgotPinA.
  ///
  /// In tr, this message translates to:
  /// **'PIN kodunuzu unuttuysanız, giriş ekranında güvenlik sorunuzu kullanarak sıfırlama yapabilirsiniz. Bunun için önceden bir güvenlik sorusu ve cevabı belirlemiş olmanız gerekir.\n\nGüvenlik sorunuzu ayarlamak için:\nProfil > Kullanıcı Bilgileri > Güvenlik bölümünü kullanabilirsiniz.\n\nGüvenlik sorusu belirlememişseniz ve PIN\'inizi unuttuysanız, uygulamayı yeniden kurmanız gerekebilir. Bu durumda yedeğiniz varsa verilerinizi geri yükleyebilirsiniz.'**
  String get faqForgotPinA;

  /// No description provided for @faqDeleteAccountQ.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı silersem ne olur?'**
  String get faqDeleteAccountQ;

  /// No description provided for @faqDeleteAccountA.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silme işlemi kalıcıdır ve geri alınamaz. Silinen veriler:\n\n• Tüm harcama kayıtları\n• Tüm gelir kayıtları\n• Varlıklarınız\n• Ödeme yöntemleri ve bakiyeleri\n• Transfer geçmişi\n• Seri kayıtları\n• Profil bilgileri ve fotoğrafınız\n\nSilmeden önce mutlaka verilerinizi yedeklemenizi öneririz. Hesap silme işlemi güvenlik doğrulaması (matematik sorusu) gerektirir ve iki aşamalı onay ile gerçekleştirilir.'**
  String get faqDeleteAccountA;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get done;

  /// No description provided for @selectTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat Seç'**
  String get selectTime;

  /// No description provided for @selectMonthAndYear.
  ///
  /// In tr, this message translates to:
  /// **'Ay ve Yıl Seç'**
  String get selectMonthAndYear;

  /// No description provided for @selectDateAndTime.
  ///
  /// In tr, this message translates to:
  /// **'Tarih ve Saat Seç'**
  String get selectDateAndTime;

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Bir Hata Oluştu'**
  String get errorOccurred;

  /// No description provided for @unexpectedErrorRestart.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik bir hata meydana geldi.\nLütfen uygulamayı yeniden başlatın.'**
  String get unexpectedErrorRestart;

  /// No description provided for @technicalDetails.
  ///
  /// In tr, this message translates to:
  /// **'Teknik Detaylar'**
  String get technicalDetails;

  /// No description provided for @anErrorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get anErrorOccurred;

  /// No description provided for @componentLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Bu bileşen yüklenirken bir sorun oluştu.'**
  String get componentLoadError;

  /// No description provided for @pageLoadError.
  ///
  /// In tr, this message translates to:
  /// **'{pageName} sayfası yüklenirken bir hata oluştu.'**
  String pageLoadError(String pageName);

  /// No description provided for @operationSuccessful.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarılı!'**
  String get operationSuccessful;

  /// No description provided for @limitWarning.
  ///
  /// In tr, this message translates to:
  /// **'Limit Uyarısı'**
  String get limitWarning;

  /// No description provided for @balanceWarning.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye Uyarısı'**
  String get balanceWarning;

  /// No description provided for @continueAnyway.
  ///
  /// In tr, this message translates to:
  /// **'Yine de devam etmek istiyor musunuz?'**
  String get continueAnyway;

  /// No description provided for @remainingLimitLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Limit'**
  String get remainingLimitLabel;

  /// No description provided for @currentBalanceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Bakiye'**
  String get currentBalanceLabel;

  /// No description provided for @expenseAmountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Tutarı'**
  String get expenseAmountLabel;

  /// No description provided for @offlineMode.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı Mod'**
  String get offlineMode;

  /// No description provided for @noInternetConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get noInternetConnection;

  /// No description provided for @unavailableFeatures.
  ///
  /// In tr, this message translates to:
  /// **'Çalışmayan Özellikler'**
  String get unavailableFeatures;

  /// No description provided for @assetPriceUpdates.
  ///
  /// In tr, this message translates to:
  /// **'Varlık fiyat güncellemeleri'**
  String get assetPriceUpdates;

  /// No description provided for @realTimeExchangeRates.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek zamanlı döviz kurları'**
  String get realTimeExchangeRates;

  /// No description provided for @limitedFeatures.
  ///
  /// In tr, this message translates to:
  /// **'Kısıtlı Özellikler'**
  String get limitedFeatures;

  /// No description provided for @assetValuesLastKnown.
  ///
  /// In tr, this message translates to:
  /// **'Varlık değerleri bilinen son fiyatlarla gösterilir'**
  String get assetValuesLastKnown;

  /// No description provided for @assetInsightTitle.
  ///
  /// In tr, this message translates to:
  /// **'Net Varlık Gelişimi'**
  String get assetInsightTitle;

  /// No description provided for @assetIncrease.
  ///
  /// In tr, this message translates to:
  /// **'%{percent} Kur/Piyasa artışı'**
  String assetIncrease(String percent);

  /// No description provided for @assetDecrease.
  ///
  /// In tr, this message translates to:
  /// **'%{percent} Kur/Piyasa azalışı'**
  String assetDecrease(String percent);

  /// No description provided for @assetNoChange.
  ///
  /// In tr, this message translates to:
  /// **'Değer değişmedi'**
  String get assetNoChange;

  /// No description provided for @fxImpactNotice.
  ///
  /// In tr, this message translates to:
  /// **'Piyasa ve kur farkı'**
  String get fxImpactNotice;

  /// No description provided for @fullyWorkingFeatures.
  ///
  /// In tr, this message translates to:
  /// **'Tam Çalışan Özellikler'**
  String get fullyWorkingFeatures;

  /// No description provided for @addEditIncomeExpense.
  ///
  /// In tr, this message translates to:
  /// **'Gelir/Gider ekleme ve düzenleme'**
  String get addEditIncomeExpense;

  /// No description provided for @backupAndRestore.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme ve geri yükleme'**
  String get backupAndRestore;

  /// No description provided for @chartsAndReports.
  ///
  /// In tr, this message translates to:
  /// **'Grafikler ve raporlar'**
  String get chartsAndReports;

  /// No description provided for @allLocalData.
  ///
  /// In tr, this message translates to:
  /// **'Tüm yerel veriler'**
  String get allLocalData;

  /// No description provided for @understood.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get understood;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-posta adresinizi girin'**
  String get pleaseEnterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin'**
  String get enterValidEmail;

  /// No description provided for @pleaseSetPin.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir PIN belirleyin'**
  String get pleaseSetPin;

  /// No description provided for @pinLengthError.
  ///
  /// In tr, this message translates to:
  /// **'PIN 4 ile 6 rakam arasında olmalıdır'**
  String get pinLengthError;

  /// No description provided for @pinDigitsOnly.
  ///
  /// In tr, this message translates to:
  /// **'PIN sadece rakamlardan oluşmalıdır'**
  String get pinDigitsOnly;

  /// No description provided for @pleaseEnterName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir isim girin'**
  String get pleaseEnterName;

  /// No description provided for @nameMinLength.
  ///
  /// In tr, this message translates to:
  /// **'İsim en az 2 karakter olmalı'**
  String get nameMinLength;

  /// No description provided for @nameMaxLength.
  ///
  /// In tr, this message translates to:
  /// **'İsminiz en fazla 50 karakter olabilir'**
  String get nameMaxLength;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tutar girin'**
  String get pleaseEnterAmount;

  /// No description provided for @enterValidNumber.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir sayı girin'**
  String get enterValidNumber;

  /// No description provided for @amountMustBePositive.
  ///
  /// In tr, this message translates to:
  /// **'Tutar pozitif bir sayı olmalıdır'**
  String get amountMustBePositive;

  /// No description provided for @pleaseEnterQuantity.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen miktar girin'**
  String get pleaseEnterQuantity;

  /// No description provided for @enterValidNumberFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir sayı formatı girin'**
  String get enterValidNumberFormat;

  /// No description provided for @quantityCannotBeNegative.
  ///
  /// In tr, this message translates to:
  /// **'Miktar negatif olamaz'**
  String get quantityCannotBeNegative;

  /// No description provided for @quantityMustBeGreaterThanZero.
  ///
  /// In tr, this message translates to:
  /// **'Miktar 0\'dan büyük olmalıdır'**
  String get quantityMustBeGreaterThanZero;

  /// No description provided for @pleaseEnterCardName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen kart adını girin'**
  String get pleaseEnterCardName;

  /// No description provided for @cardNameMinLength.
  ///
  /// In tr, this message translates to:
  /// **'Kart adı en az 2 karakter olmalıdır'**
  String get cardNameMinLength;

  /// No description provided for @cardNameMaxLength.
  ///
  /// In tr, this message translates to:
  /// **'Kart adı en fazla 30 karakter olabilir'**
  String get cardNameMaxLength;

  /// No description provided for @pleaseEnterLastFourDigits.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen son 4 haneyi girin'**
  String get pleaseEnterLastFourDigits;

  /// No description provided for @lastFourDigitsLength.
  ///
  /// In tr, this message translates to:
  /// **'Son 4 hane tam 4 rakam olmalıdır'**
  String get lastFourDigitsLength;

  /// No description provided for @lastFourDigitsOnly.
  ///
  /// In tr, this message translates to:
  /// **'Son 4 hane sadece rakamlardan oluşmalıdır'**
  String get lastFourDigitsOnly;

  /// No description provided for @pleaseEnterDebtAmount.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen borç tutarını girin'**
  String get pleaseEnterDebtAmount;

  /// No description provided for @pleaseEnterBalanceAmount.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bakiye girin'**
  String get pleaseEnterBalanceAmount;

  /// No description provided for @invalidAmountFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz tutar formatı'**
  String get invalidAmountFormat;

  /// No description provided for @amountCannotBeNegative.
  ///
  /// In tr, this message translates to:
  /// **'Tutar negatif olamaz'**
  String get amountCannotBeNegative;

  /// No description provided for @limitMustBeGreaterThanZero.
  ///
  /// In tr, this message translates to:
  /// **'Limit 0\'dan büyük olmalı'**
  String get limitMustBeGreaterThanZero;

  /// No description provided for @limitLessThanDebt.
  ///
  /// In tr, this message translates to:
  /// **'Limit mevcut borçtan küçük olamaz'**
  String get limitLessThanDebt;

  /// No description provided for @genericError.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu. Lütfen tekrar deneyin.'**
  String get genericError;

  /// No description provided for @dataNotFoundError.
  ///
  /// In tr, this message translates to:
  /// **'Veri bulunamadı'**
  String get dataNotFoundError;

  /// No description provided for @connectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası. İnternet bağlantınızı kontrol edin.'**
  String get connectionError;

  /// No description provided for @timeoutError.
  ///
  /// In tr, this message translates to:
  /// **'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.'**
  String get timeoutError;

  /// No description provided for @permissionError.
  ///
  /// In tr, this message translates to:
  /// **'Erişim izni hatası'**
  String get permissionError;

  /// No description provided for @priceFetchFailed.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat çekilemedi, lütfen manuel giriniz.'**
  String get priceFetchFailed;

  /// No description provided for @priceFetchError.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alınırken hata oluştu. Lütfen manuel giriniz.'**
  String get priceFetchError;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm gerekli alanları doldurun'**
  String get pleaseFillRequiredFields;

  /// No description provided for @currentPriceButton.
  ///
  /// In tr, this message translates to:
  /// **'Güncel'**
  String get currentPriceButton;

  /// No description provided for @amountTL.
  ///
  /// In tr, this message translates to:
  /// **'Miktar (TL)'**
  String get amountTL;

  /// No description provided for @purchaseInfo.
  ///
  /// In tr, this message translates to:
  /// **'Alış Bilgileri'**
  String get purchaseInfo;

  /// No description provided for @purchasePriceTL.
  ///
  /// In tr, this message translates to:
  /// **'Alış Fiyatı (TL)'**
  String get purchasePriceTL;

  /// No description provided for @enterValidPrice.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir fiyat giriniz'**
  String get enterValidPrice;

  /// No description provided for @purchasePriceNegative.
  ///
  /// In tr, this message translates to:
  /// **'Alış fiyatı negatif olamaz'**
  String get purchasePriceNegative;

  /// No description provided for @purchasePriceMustBePositive.
  ///
  /// In tr, this message translates to:
  /// **'Alış fiyatı 0\'dan büyük olmalı'**
  String get purchasePriceMustBePositive;

  /// No description provided for @minPurchasePrice.
  ///
  /// In tr, this message translates to:
  /// **'Minimum alış fiyatı 0,01 ₺ olmalı'**
  String get minPurchasePrice;

  /// No description provided for @maxPurchasePrice.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum alış fiyatı 100 milyon ₺ olabilir'**
  String get maxPurchasePrice;

  /// No description provided for @quantityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Adet'**
  String get quantityLabel;

  /// No description provided for @stockNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hisse Adı'**
  String get stockNameLabel;

  /// No description provided for @currencyNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Döviz İsmi'**
  String get currencyNameLabel;

  /// No description provided for @cryptoNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kripto İsmi'**
  String get cryptoNameLabel;

  /// No description provided for @bankNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Banka Adı'**
  String get bankNameLabel;

  /// No description provided for @assetNameField.
  ///
  /// In tr, this message translates to:
  /// **'Varlık İsmi'**
  String get assetNameField;

  /// No description provided for @profileUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme başarısız: {error}'**
  String updateFailed(String error);

  /// No description provided for @profileImageUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profil resmi güncellendi'**
  String get profileImageUpdated;

  /// No description provided for @selectProfileImage.
  ///
  /// In tr, this message translates to:
  /// **'Profil Resmi Seç'**
  String get selectProfileImage;

  /// No description provided for @galleryOrCameraDesc.
  ///
  /// In tr, this message translates to:
  /// **'Galerinizden bir fotoğraf seçerek ya da kameradan fotoğraf çekerek profil resminizi değiştirebilirsiniz.'**
  String get galleryOrCameraDesc;

  /// No description provided for @cameraLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get cameraLabel;

  /// No description provided for @takePhotoLabel.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Çek'**
  String get takePhotoLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get galleryLabel;

  /// No description provided for @selectPhotoLabel.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Seç'**
  String get selectPhotoLabel;

  /// No description provided for @changeName.
  ///
  /// In tr, this message translates to:
  /// **'İsim Değiştir'**
  String get changeName;

  /// No description provided for @newNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İsim'**
  String get newNameLabel;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In tr, this message translates to:
  /// **'İsim boş olamaz'**
  String get nameCannotBeEmpty;

  /// No description provided for @nameUpdated.
  ///
  /// In tr, this message translates to:
  /// **'İsim Soyisim Güncellendi'**
  String get nameUpdated;

  /// No description provided for @currentPinLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut PIN'**
  String get currentPinLabel;

  /// No description provided for @newPinLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni PIN'**
  String get newPinLabel;

  /// No description provided for @newPinRepeatLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni PIN (Tekrar)'**
  String get newPinRepeatLabel;

  /// No description provided for @enterPinDigits.
  ///
  /// In tr, this message translates to:
  /// **'4-6 haneli PIN giriniz'**
  String get enterPinDigits;

  /// No description provided for @pinIncorrect.
  ///
  /// In tr, this message translates to:
  /// **'PIN hatalı'**
  String get pinIncorrect;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'PIN\'ler eşleşmiyor'**
  String get pinsDoNotMatch;

  /// No description provided for @pinUpdated.
  ///
  /// In tr, this message translates to:
  /// **'PIN Güncellendi'**
  String get pinUpdated;

  /// No description provided for @pinVerification.
  ///
  /// In tr, this message translates to:
  /// **'PIN Doğrulama'**
  String get pinVerification;

  /// No description provided for @biometricPinVerificationDesc.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik girişi aktifleştirmek için PIN\'inizi doğrulayın'**
  String get biometricPinVerificationDesc;

  /// No description provided for @activateBiometric.
  ///
  /// In tr, this message translates to:
  /// **'Biyometriği Aktifleştir'**
  String get activateBiometric;

  /// No description provided for @finalConfirmation.
  ///
  /// In tr, this message translates to:
  /// **'Son Onay'**
  String get finalConfirmation;

  /// No description provided for @permanentDeleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz?'**
  String get permanentDeleteAccountConfirm;

  /// No description provided for @yesDelete.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Sil'**
  String get yesDelete;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız başarıyla silindi'**
  String get accountDeletedSuccess;

  /// No description provided for @accountDeleteError.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinirken hata oluştu: {error}'**
  String accountDeleteError(String error);

  /// No description provided for @deletePermanently.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Sil'**
  String get deletePermanently;

  /// No description provided for @pinVerificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'PIN Doğrulaması'**
  String get pinVerificationTitle;

  /// No description provided for @forwardButton.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get forwardButton;

  /// No description provided for @thisActionIrreversibleWarning.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecektir.'**
  String get thisActionIrreversibleWarning;

  /// No description provided for @expenseMovedToTrash.
  ///
  /// In tr, this message translates to:
  /// **'Harcama çöp kutusuna taşındı 🗑️'**
  String get expenseMovedToTrash;

  /// No description provided for @expenseRestored.
  ///
  /// In tr, this message translates to:
  /// **'Harcama geri yüklendi '**
  String get expenseRestored;

  /// No description provided for @noSearchResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noSearchResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir arama terimi deneyin'**
  String get tryDifferentSearch;

  /// No description provided for @emptyTrashTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çöpü Boşalt'**
  String get emptyTrashTitle;

  /// No description provided for @emptyTrashConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm silinen harcamalar kalıcı olarak yok edilecek. Emin misin?'**
  String get emptyTrashConfirm;

  /// No description provided for @trashEmptied.
  ///
  /// In tr, this message translates to:
  /// **'Çöp kutusu temizlendi.'**
  String get trashEmptied;

  /// No description provided for @restoreAllTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Geri Yükle'**
  String get restoreAllTitle;

  /// No description provided for @restoreAllConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{count} harcama geri yüklenecek. Onaylıyor musun?'**
  String restoreAllConfirm(int count);

  /// No description provided for @yesRestore.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Geri Yükle'**
  String get yesRestore;

  /// No description provided for @allExpensesRestored.
  ///
  /// In tr, this message translates to:
  /// **'Tüm harcamalar geri yüklendi '**
  String get allExpensesRestored;

  /// No description provided for @noDeletedExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Silinen harcama yok.'**
  String get noDeletedExpenses;

  /// No description provided for @expensePermanentlyDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Harcama kalıcı olarak silindi '**
  String get expensePermanentlyDeleted;

  /// No description provided for @expenseRestoredRecycled.
  ///
  /// In tr, this message translates to:
  /// **'Harcama geri yüklendi ♻️'**
  String get expenseRestoredRecycled;

  /// No description provided for @deleteCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriyi Sil'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" kategorisini silmek istediğinizden emin misiniz?'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @categoryDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kategori silindi'**
  String get categoryDeleted;

  /// No description provided for @categoryAdded.
  ///
  /// In tr, this message translates to:
  /// **'Kategori eklendi '**
  String get categoryAdded;

  /// No description provided for @systemCategoryCannotDelete.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" sistem kategorisidir ve silinemez'**
  String systemCategoryCannotDelete(String name);

  /// No description provided for @resetToDefault.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılana Dön'**
  String get resetToDefault;

  /// No description provided for @resetCategoriesConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm özel kategorileriniz silinecek ve varsayılan kategoriler yüklenecek. Emin misiniz?'**
  String get resetCategoriesConfirm;

  /// No description provided for @yesReset.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Sıfırla'**
  String get yesReset;

  /// No description provided for @defaultCategoriesLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan kategoriler yüklendi'**
  String get defaultCategoriesLoaded;

  /// No description provided for @addNewCategory.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kategori Ekle'**
  String get addNewCategory;

  /// No description provided for @myCategories.
  ///
  /// In tr, this message translates to:
  /// **'KATEGORİLERİM'**
  String get myCategories;

  /// No description provided for @addNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Ekle'**
  String get addNew;

  /// No description provided for @selectIconLabel.
  ///
  /// In tr, this message translates to:
  /// **'İkon Seç:'**
  String get selectIconLabel;

  /// No description provided for @categoryOrderUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Kategori sırası güncellendi'**
  String get categoryOrderUpdated;

  /// No description provided for @micPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Mikrofon izni verilemedi veya cihaz desteklemiyor.'**
  String get micPermissionDenied;

  /// No description provided for @expenseDeletion.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Silme'**
  String get expenseDeletion;

  /// No description provided for @deleteLastExpenseConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Son eklenen harcamayı silmek istediğinizden emin misiniz?'**
  String get deleteLastExpenseConfirm;

  /// No description provided for @commandNotSupported.
  ///
  /// In tr, this message translates to:
  /// **'Bu komut henüz desteklenmiyor'**
  String get commandNotSupported;

  /// No description provided for @noExpenseFoundYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz harcama bulunmuyor'**
  String get noExpenseFoundYet;

  /// No description provided for @categoryNotUnderstood.
  ///
  /// In tr, this message translates to:
  /// **'Kategori anlaşılamadı'**
  String get categoryNotUnderstood;

  /// No description provided for @addRecurringToMonthConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tanımlı tekrarlayan işlemleri bu aya eklemek istiyor musunuz?'**
  String get addRecurringToMonthConfirm;

  /// No description provided for @expenseEditingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Düzenleme'**
  String get expenseEditingTitle;

  /// No description provided for @newAmountNotUnderstood.
  ///
  /// In tr, this message translates to:
  /// **'Yeni tutarı anlayamadım. Örneğin \"Son harcamayı 100 lira yap\" diyebilirsiniz.'**
  String get newAmountNotUnderstood;

  /// No description provided for @budgetLimitUpdateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Limiti Güncelleme'**
  String get budgetLimitUpdateTitle;

  /// No description provided for @limitUpdateError.
  ///
  /// In tr, this message translates to:
  /// **'Limit güncellenirken bir hata oluştu'**
  String get limitUpdateError;

  /// No description provided for @commandProcessing.
  ///
  /// In tr, this message translates to:
  /// **'Komut işleniyor...'**
  String get commandProcessing;

  /// No description provided for @heardLabel.
  ///
  /// In tr, this message translates to:
  /// **'Duyulan:'**
  String get heardLabel;

  /// No description provided for @howToUse.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl kullanılır?'**
  String get howToUse;

  /// No description provided for @voiceAssistantCapabilities.
  ///
  /// In tr, this message translates to:
  /// **'Sesli asistan ile şunları yapabilirsiniz:'**
  String get voiceAssistantCapabilities;

  /// No description provided for @addingExpenseLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harcama ekleme'**
  String get addingExpenseLabel;

  /// No description provided for @deletingExpenseLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harcama silme'**
  String get deletingExpenseLabel;

  /// No description provided for @queryExpenseLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harcama sorgulama'**
  String get queryExpenseLabel;

  /// No description provided for @categoryAnalysisLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori analizi'**
  String get categoryAnalysisLabel;

  /// No description provided for @budgetControlLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe kontrolü'**
  String get budgetControlLabel;

  /// No description provided for @detailedCommandListInfo.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı komut listesi için:\nAyarlar → Sesli Asistan → Tüm Komutlar'**
  String get detailedCommandListInfo;

  /// No description provided for @voiceIncomeInput.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Gelir Girişi'**
  String get voiceIncomeInput;

  /// No description provided for @voiceExpenseInput.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Harcama Girişi'**
  String get voiceExpenseInput;

  /// No description provided for @micPreparing.
  ///
  /// In tr, this message translates to:
  /// **'Mikrofon hazırlanıyor...'**
  String get micPreparing;

  /// No description provided for @micListening.
  ///
  /// In tr, this message translates to:
  /// **'Dinliyorum...'**
  String get micListening;

  /// No description provided for @tapToSpeakAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar konuşmak için dokunun'**
  String get tapToSpeakAgain;

  /// No description provided for @tapToStopMic.
  ///
  /// In tr, this message translates to:
  /// **'Durdurmak için mikrofona dokunun'**
  String get tapToStopMic;

  /// No description provided for @pdfReportGenerated.
  ///
  /// In tr, this message translates to:
  /// **'PDF raporu oluşturuldu'**
  String get pdfReportGenerated;

  /// No description provided for @pdfGenerationError.
  ///
  /// In tr, this message translates to:
  /// **'PDF oluşturulurken hata: {error}'**
  String pdfGenerationError(String error);

  /// No description provided for @expenseNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Adı'**
  String get expenseNameLabel;

  /// No description provided for @whatDidYouBuy.
  ///
  /// In tr, this message translates to:
  /// **'Ne aldın? (Örn: Kahve)'**
  String get whatDidYouBuy;

  /// No description provided for @expenseDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Tarihi'**
  String get expenseDateLabel;

  /// No description provided for @selectPaymentMethodHint.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemi Seçin'**
  String get selectPaymentMethodHint;

  /// No description provided for @enterValidAmountError.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar girin'**
  String get enterValidAmountError;

  /// No description provided for @recurringTransactionsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan İşlemler'**
  String get recurringTransactionsLabel;

  /// No description provided for @recurringItemsAdded.
  ///
  /// In tr, this message translates to:
  /// **'{count} adet tekrarlayan işlem eklendi!'**
  String recurringItemsAdded(int count);

  /// No description provided for @expenseAddedVoice.
  ///
  /// In tr, this message translates to:
  /// **'Harcama eklendi: {name} - {amount} ₺'**
  String expenseAddedVoice(String name, String amount);

  /// No description provided for @monthlyBudgetUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Aylık bütçe {amount} ₺ olarak güncellendi'**
  String monthlyBudgetUpdated(String amount);

  /// No description provided for @limitNotUnderstood.
  ///
  /// In tr, this message translates to:
  /// **'Limit tutarını anlayamadım. Örneğin \"Aylık limitimi 10000 lira yap\" diyebilirsiniz.'**
  String get limitNotUnderstood;

  /// No description provided for @updateExpenseConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Son harcamayı {amount} ₺ olarak güncellemek istiyor musunuz?'**
  String updateExpenseConfirm(String amount);

  /// No description provided for @expenseUpdatedVoice.
  ///
  /// In tr, this message translates to:
  /// **'{name} güncellendi: {amount} ₺'**
  String expenseUpdatedVoice(String name, String amount);

  /// No description provided for @monthlyBudgetUpdateConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Aylık bütçeniz {amount} ₺ olarak güncellensin mi?'**
  String monthlyBudgetUpdateConfirm(String amount);

  /// No description provided for @maxAmountError.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum tutar {amount} ₺ olabilir'**
  String maxAmountError(String amount);

  /// No description provided for @descriptionMaxLength.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama en fazla {maxLength} karakter olabilir'**
  String descriptionMaxLength(int maxLength);

  /// No description provided for @itemNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'{itemType} adı gereklidir'**
  String itemNameRequired(String itemType);

  /// No description provided for @fieldRequired.
  ///
  /// In tr, this message translates to:
  /// **'{fieldName} gereklidir'**
  String fieldRequired(String fieldName);

  /// No description provided for @quantityTooSmall.
  ///
  /// In tr, this message translates to:
  /// **'Miktar çok küçük (min: {min})'**
  String quantityTooSmall(String min);

  /// No description provided for @quantityTooLarge.
  ///
  /// In tr, this message translates to:
  /// **'Miktar çok büyük (max: {max})'**
  String quantityTooLarge(String max);

  /// No description provided for @maxDecimalPlaces.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {count} ondalık basamak girebilirsiniz'**
  String maxDecimalPlaces(int count);

  /// No description provided for @maxBalanceError.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum tutar {amount} olabilir'**
  String maxBalanceError(String amount);

  /// No description provided for @minLimitError.
  ///
  /// In tr, this message translates to:
  /// **'Minimum limit {amount} ₺ olmalı'**
  String minLimitError(String amount);

  /// No description provided for @maxLimitError.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum limit {amount} olabilir'**
  String maxLimitError(String amount);

  /// No description provided for @streakInfo.
  ///
  /// In tr, this message translates to:
  /// **'Seri Bilgileri'**
  String get streakInfo;

  /// No description provided for @howStreakWorks.
  ///
  /// In tr, this message translates to:
  /// **'Seri Nasıl Çalışır?'**
  String get howStreakWorks;

  /// No description provided for @editPhotoBtn.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Düzenle'**
  String get editPhotoBtn;

  /// No description provided for @cropError.
  ///
  /// In tr, this message translates to:
  /// **'Kırpma hatası: {error}'**
  String cropError(String error);

  /// No description provided for @saveError.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetme hatası: {error}'**
  String saveError(String error);

  /// No description provided for @myPaymentMethods.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemlerim'**
  String get myPaymentMethods;

  /// No description provided for @myIncomesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelirlerim'**
  String get myIncomesTitle;

  /// No description provided for @enterValidAmountAndName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli tutar ve isim girin'**
  String get enterValidAmountAndName;

  /// No description provided for @tryAgainAction.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgainAction;

  /// No description provided for @incomeRecycleBin.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Çöp Kutusu'**
  String get incomeRecycleBin;

  /// No description provided for @incomeCategories.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Kategorileri'**
  String get incomeCategories;

  /// No description provided for @incomeSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Ayarları'**
  String get incomeSettingsTitle;

  /// No description provided for @recurringIncomesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan Gelirler'**
  String get recurringIncomesTitle;

  /// No description provided for @expenseCategoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Kategorileri'**
  String get expenseCategoriesTitle;

  /// No description provided for @myExpensesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalarım'**
  String get myExpensesTitle;

  /// No description provided for @assetRecycleBin.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Çöp Kutusu'**
  String get assetRecycleBin;

  /// No description provided for @assetDetail.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Detayı'**
  String get assetDetail;

  /// No description provided for @deleteAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlığı Sil'**
  String get deleteAsset;

  /// No description provided for @deleteAssetConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" varlığını silmek istediğinize emin misiniz?'**
  String deleteAssetConfirm(String name);

  /// No description provided for @myAssets.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklarım'**
  String get myAssets;

  /// No description provided for @analysisAndReports.
  ///
  /// In tr, this message translates to:
  /// **'Analiz ve Raporlar'**
  String get analysisAndReports;

  /// No description provided for @expenseTab.
  ///
  /// In tr, this message translates to:
  /// **'Harcama'**
  String get expenseTab;

  /// No description provided for @incomeTab.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get incomeTab;

  /// No description provided for @assetTab.
  ///
  /// In tr, this message translates to:
  /// **'Varlık'**
  String get assetTab;

  /// No description provided for @widgetCreationError.
  ///
  /// In tr, this message translates to:
  /// **'Widget oluşturulurken bir hata oluştu.'**
  String get widgetCreationError;

  /// No description provided for @appInitializationFailedMsg.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama başlatılamadı\\n{error}'**
  String appInitializationFailedMsg(String error);

  /// No description provided for @manageFinancialTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Finansal işlemlerinizi yönetin'**
  String get manageFinancialTransactions;

  /// No description provided for @cashFlow.
  ///
  /// In tr, this message translates to:
  /// **'Nakit Akışı'**
  String get cashFlow;

  /// No description provided for @myWallet.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdanım'**
  String get myWallet;

  /// No description provided for @otherTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Diğer İşlemler'**
  String get otherTransactions;

  /// No description provided for @moneyTransfer.
  ///
  /// In tr, this message translates to:
  /// **'Para Transferi'**
  String get moneyTransfer;

  /// No description provided for @assetsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Altın, döviz, kripto ve diğer varlıklar'**
  String get assetsSubtitle;

  /// No description provided for @paymentMethodsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Banka kartları ve nakit hesapları'**
  String get paymentMethodsSubtitle;

  /// No description provided for @analysisSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama ve gelir istatistikleri'**
  String get analysisSubtitle;

  /// No description provided for @transferSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplar arası para aktarımı'**
  String get transferSubtitle;

  /// No description provided for @cardType.
  ///
  /// In tr, this message translates to:
  /// **'Kart Tipi'**
  String get cardType;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get nameLabel;

  /// No description provided for @bankCardName.
  ///
  /// In tr, this message translates to:
  /// **'Banka/Kart Adı'**
  String get bankCardName;

  /// No description provided for @lastFourDigits.
  ///
  /// In tr, this message translates to:
  /// **'Son 4 Hane (Opsiyonel)'**
  String get lastFourDigits;

  /// No description provided for @cardLimit.
  ///
  /// In tr, this message translates to:
  /// **'Kart Limiti'**
  String get cardLimit;

  /// No description provided for @cardColor.
  ///
  /// In tr, this message translates to:
  /// **'Kart Rengi'**
  String get cardColor;

  /// No description provided for @swipeForMoreColors.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla renk için sağa kaydırın →'**
  String get swipeForMoreColors;

  /// No description provided for @nameMustContainLetter.
  ///
  /// In tr, this message translates to:
  /// **'İsim en az bir harf içermeli'**
  String get nameMustContainLetter;

  /// No description provided for @mustBeFourDigits.
  ///
  /// In tr, this message translates to:
  /// **'Tam 4 rakam girmelisiniz'**
  String get mustBeFourDigits;

  /// No description provided for @invalidCardNumber.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kart numarası'**
  String get invalidCardNumber;

  /// No description provided for @pleaseEnterDebt.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen borç tutarını girin (0 olabilir)'**
  String get pleaseEnterDebt;

  /// No description provided for @pleaseEnterBalance.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bakiye girin'**
  String get pleaseEnterBalance;

  /// No description provided for @maxAmountLimit.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum tutar 100 milyon ₺ olabilir'**
  String get maxAmountLimit;

  /// No description provided for @limitCannotBeLessThanDebt.
  ///
  /// In tr, this message translates to:
  /// **'Limit mevcut borçtan küçük olamaz'**
  String get limitCannotBeLessThanDebt;

  /// No description provided for @minLimitWarning.
  ///
  /// In tr, this message translates to:
  /// **'Minimum limit 100 ₺ olmalı'**
  String get minLimitWarning;

  /// No description provided for @foodAndCafe.
  ///
  /// In tr, this message translates to:
  /// **'Yemek ve Kafe'**
  String get foodAndCafe;

  /// No description provided for @groceryAndSnacks.
  ///
  /// In tr, this message translates to:
  /// **'Market ve Atıştırmalık'**
  String get groceryAndSnacks;

  /// No description provided for @vehicleAndTransport.
  ///
  /// In tr, this message translates to:
  /// **'Araç ve Ulaşım'**
  String get vehicleAndTransport;

  /// No description provided for @giftAndSpecial.
  ///
  /// In tr, this message translates to:
  /// **'Hediye ve Özel'**
  String get giftAndSpecial;

  /// No description provided for @fixedExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Sabit Giderler'**
  String get fixedExpenses;

  /// No description provided for @categoryOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get categoryOther;

  /// No description provided for @salary.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get salary;

  /// No description provided for @freelance.
  ///
  /// In tr, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// No description provided for @investment.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım'**
  String get investment;

  /// No description provided for @rentalIncome.
  ///
  /// In tr, this message translates to:
  /// **'Kira Geliri'**
  String get rentalIncome;

  /// No description provided for @gift.
  ///
  /// In tr, this message translates to:
  /// **'Hediye'**
  String get gift;

  /// No description provided for @ziraatBank.
  ///
  /// In tr, this message translates to:
  /// **'Ziraat Bankası'**
  String get ziraatBank;

  /// No description provided for @searchPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme yöntemi ara...'**
  String get searchPaymentMethod;

  /// No description provided for @trashBin.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get trashBin;

  /// No description provided for @noResultsFound.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResultsFound;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir arama terimi deneyin'**
  String get tryDifferentSearchTerm;

  /// No description provided for @noPaymentMethodYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ödeme yöntemi yok'**
  String get noPaymentMethodYet;

  /// No description provided for @startByAddingFirstPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'İlk ödeme yönteminizi ekleyerek başlayın'**
  String get startByAddingFirstPaymentMethod;

  /// No description provided for @debt.
  ///
  /// In tr, this message translates to:
  /// **'Borç'**
  String get debt;

  /// No description provided for @balanceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bakiye'**
  String get balanceLabel;

  /// No description provided for @addCard.
  ///
  /// In tr, this message translates to:
  /// **'Kart Ekle'**
  String get addCard;

  /// No description provided for @cashWalletExample.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Cüzdan'**
  String get cashWalletExample;

  /// No description provided for @ziraatBankExample.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Ziraat Bankası'**
  String get ziraatBankExample;

  /// No description provided for @expensesThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ayki harcamalar'**
  String get expensesThisMonth;

  /// No description provided for @incomesThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ayki gelirler'**
  String get incomesThisMonth;

  /// No description provided for @totalLimit.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Limit'**
  String get totalLimit;

  /// No description provided for @daysCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün'**
  String daysCount(int count);

  /// No description provided for @todayLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get todayLabel;

  /// No description provided for @less.
  ///
  /// In tr, this message translates to:
  /// **'az'**
  String get less;

  /// No description provided for @more.
  ///
  /// In tr, this message translates to:
  /// **'fazla'**
  String get more;

  /// No description provided for @dailyAverageLabel.
  ///
  /// In tr, this message translates to:
  /// **'GÜNLÜK ORTALAMA'**
  String get dailyAverageLabel;

  /// No description provided for @budgetStatusLabel.
  ///
  /// In tr, this message translates to:
  /// **'BÜTÇE DURUMU'**
  String get budgetStatusLabel;

  /// No description provided for @totalExpenseLabel.
  ///
  /// In tr, this message translates to:
  /// **'TOPLAM HARCAMA'**
  String get totalExpenseLabel;

  /// No description provided for @totalIncomeLabel.
  ///
  /// In tr, this message translates to:
  /// **'TOPLAM GELİR'**
  String get totalIncomeLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get remainingLabel;

  /// No description provided for @validAmountRequired.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar girin'**
  String get validAmountRequired;

  /// No description provided for @expenseNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Ne aldın? (Örn: Kahve)'**
  String get expenseNameHint;

  /// No description provided for @updateButton.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get updateButton;

  /// No description provided for @yesterdayLabel.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterdayLabel;

  /// No description provided for @movedToTrash.
  ///
  /// In tr, this message translates to:
  /// **'çöp kutusuna taşındı'**
  String get movedToTrash;

  /// No description provided for @restored.
  ///
  /// In tr, this message translates to:
  /// **'geri yüklendi'**
  String get restored;

  /// No description provided for @voiceInput.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Giriş'**
  String get voiceInput;

  /// No description provided for @added.
  ///
  /// In tr, this message translates to:
  /// **'eklendi'**
  String get added;

  /// No description provided for @monthlyIncomeCount.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay {count} gelir kaydı'**
  String monthlyIncomeCount(int count);

  /// No description provided for @incomeNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Adı'**
  String get incomeNameLabel;

  /// No description provided for @incomeNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Nereden geldi? (Örn: Borç Ödemesi)'**
  String get incomeNameHint;

  /// No description provided for @selectAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Seçin'**
  String get selectAccount;

  /// No description provided for @searchAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık ara...'**
  String get searchAsset;

  /// No description provided for @totalAssetLabel.
  ///
  /// In tr, this message translates to:
  /// **'TOPLAM VARLIK'**
  String get totalAssetLabel;

  /// No description provided for @totalAssetCount.
  ///
  /// In tr, this message translates to:
  /// **'Toplam {count} adet varlık kaydı'**
  String totalAssetCount(int count);

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı güncellendi'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUpdateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı güncellenirken hata oluştu: {error}'**
  String profilePhotoUpdateFailed(String error);

  /// No description provided for @budgetLimitSaved.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe limiti kaydedildi!'**
  String get budgetLimitSaved;

  /// No description provided for @categoryListUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Kategori listesi güncellendi!'**
  String get categoryListUpdated;

  /// No description provided for @changesSaved.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kaydedildi'**
  String get changesSaved;

  /// No description provided for @trashBinEmptied.
  ///
  /// In tr, this message translates to:
  /// **'Çöp kutusu temizlendi.'**
  String get trashBinEmptied;

  /// No description provided for @incomeRestored.
  ///
  /// In tr, this message translates to:
  /// **'Gelir geri yüklendi '**
  String get incomeRestored;

  /// No description provided for @incomePermanentlyDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Gelir kalıcı olarak silindi '**
  String get incomePermanentlyDeleted;

  /// No description provided for @allIncomesRestored.
  ///
  /// In tr, this message translates to:
  /// **'Tüm gelirler geri yüklendi '**
  String get allIncomesRestored;

  /// No description provided for @expenseDeletedWithName.
  ///
  /// In tr, this message translates to:
  /// **'{name} silindi'**
  String expenseDeletedWithName(String name);

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin.'**
  String get pleaseEnterValidEmail;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik doğrulama başarısız: {error}'**
  String biometricAuthFailed(String error);

  /// No description provided for @emptyTrashBin.
  ///
  /// In tr, this message translates to:
  /// **'Çöpü Boşalt'**
  String get emptyTrashBin;

  /// No description provided for @confirmEmptyTrashBin.
  ///
  /// In tr, this message translates to:
  /// **'Tüm silinen öğeler kalıcı olarak yok edilecek. Emin misin?'**
  String get confirmEmptyTrashBin;

  /// No description provided for @restoreAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Geri Yükle'**
  String get restoreAll;

  /// No description provided for @confirmRestoreAllExpenses.
  ///
  /// In tr, this message translates to:
  /// **'{count} harcama geri yüklenecek. Onaylıyor musun?'**
  String confirmRestoreAllExpenses(int count);

  /// No description provided for @confirmRestoreAllIncomes.
  ///
  /// In tr, this message translates to:
  /// **'{count} gelir geri yüklenecek. Onaylıyor musun?'**
  String confirmRestoreAllIncomes(int count);

  /// No description provided for @confirmRestoreAllAssets.
  ///
  /// In tr, this message translates to:
  /// **'{count} varlık geri yüklenecek. Onaylıyor musun?'**
  String confirmRestoreAllAssets(int count);

  /// No description provided for @noDeletedIncomes.
  ///
  /// In tr, this message translates to:
  /// **'Silinen gelir yok.'**
  String get noDeletedIncomes;

  /// No description provided for @noDeletedAssets.
  ///
  /// In tr, this message translates to:
  /// **'Çöp kutusu boş.'**
  String get noDeletedAssets;

  /// No description provided for @expenseAddedDetailed.
  ///
  /// In tr, this message translates to:
  /// **'Harcama eklendi: {name} - {amount} ₺'**
  String expenseAddedDetailed(String name, String amount);

  /// No description provided for @accountDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinirken hata oluştu: {error}'**
  String accountDeleteFailed(String error);

  /// No description provided for @profileAccountDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız başarıyla silindi'**
  String get profileAccountDeleted;

  /// No description provided for @janShort.
  ///
  /// In tr, this message translates to:
  /// **'OCA'**
  String get janShort;

  /// No description provided for @febShort.
  ///
  /// In tr, this message translates to:
  /// **'ŞUB'**
  String get febShort;

  /// No description provided for @marShort.
  ///
  /// In tr, this message translates to:
  /// **'MAR'**
  String get marShort;

  /// No description provided for @aprShort.
  ///
  /// In tr, this message translates to:
  /// **'NİS'**
  String get aprShort;

  /// No description provided for @mayShort.
  ///
  /// In tr, this message translates to:
  /// **'MAY'**
  String get mayShort;

  /// No description provided for @junShort.
  ///
  /// In tr, this message translates to:
  /// **'HAZ'**
  String get junShort;

  /// No description provided for @julShort.
  ///
  /// In tr, this message translates to:
  /// **'TEM'**
  String get julShort;

  /// No description provided for @augShort.
  ///
  /// In tr, this message translates to:
  /// **'AĞU'**
  String get augShort;

  /// No description provided for @sepShort.
  ///
  /// In tr, this message translates to:
  /// **'EYL'**
  String get sepShort;

  /// No description provided for @octShort.
  ///
  /// In tr, this message translates to:
  /// **'EKİ'**
  String get octShort;

  /// No description provided for @novShort.
  ///
  /// In tr, this message translates to:
  /// **'KAS'**
  String get novShort;

  /// No description provided for @decShort.
  ///
  /// In tr, this message translates to:
  /// **'ARA'**
  String get decShort;

  /// No description provided for @transferPageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Para Transferi'**
  String get transferPageTitle;

  /// No description provided for @pleaseSelectAccounts.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen hesapları seçin'**
  String get pleaseSelectAccounts;

  /// No description provided for @cannotTransferToSameAccount.
  ///
  /// In tr, this message translates to:
  /// **'Aynı hesaba transfer yapılamaz'**
  String get cannotTransferToSameAccount;

  /// No description provided for @noDebtOnCreditCard.
  ///
  /// In tr, this message translates to:
  /// **'Bu kredi kartında borç bulunmuyor. Transfer yapılamaz.'**
  String get noDebtOnCreditCard;

  /// No description provided for @creditCardDebtLimit.
  ///
  /// In tr, this message translates to:
  /// **'Kredi kartı borcu {amount}, en fazla bu kadar gönderebilirsiniz'**
  String creditCardDebtLimit(String amount);

  /// No description provided for @scheduledTransferMessage.
  ///
  /// In tr, this message translates to:
  /// **'{fromAccount} ➔ {toAccount}\n{amount} {date} tarihinde transfer edilmek üzere zamanlandı.'**
  String scheduledTransferMessage(
    String fromAccount,
    String toAccount,
    String amount,
    String date,
  );

  /// No description provided for @completedTransferMessage.
  ///
  /// In tr, this message translates to:
  /// **'{fromAccount} ➔ {toAccount}\n{amount} saat {time}\'de başarıyla transfer edildi.'**
  String completedTransferMessage(
    String fromAccount,
    String toAccount,
    String amount,
    String time,
  );

  /// No description provided for @sender.
  ///
  /// In tr, this message translates to:
  /// **'GÖNDEREN'**
  String get sender;

  /// No description provided for @receiver.
  ///
  /// In tr, this message translates to:
  /// **'ALAN'**
  String get receiver;

  /// No description provided for @amountToSend.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilecek Tutar'**
  String get amountToSend;

  /// No description provided for @enterAmountHint.
  ///
  /// In tr, this message translates to:
  /// **'Tutar giriniz'**
  String get enterAmountHint;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In tr, this message translates to:
  /// **'Tutar 0\'dan büyük olmalı'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @maximumAmountExceeded.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum tutar aşıldı'**
  String get maximumAmountExceeded;

  /// No description provided for @payAllDebt.
  ///
  /// In tr, this message translates to:
  /// **'Tüm borcu öde ({amount})'**
  String payAllDebt(String amount);

  /// No description provided for @scheduledTransferInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bu transfer {date} saat {time}\'de gerçekleştirilecek.'**
  String scheduledTransferInfo(String date, String time);

  /// No description provided for @scheduleTransferButton.
  ///
  /// In tr, this message translates to:
  /// **'Transferi Zamanla'**
  String get scheduleTransferButton;

  /// No description provided for @makeTransferButton.
  ///
  /// In tr, this message translates to:
  /// **'Transfer Yap'**
  String get makeTransferButton;

  /// No description provided for @transactionHistory.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Geçmişi'**
  String get transactionHistory;

  /// No description provided for @pendingTransfers.
  ///
  /// In tr, this message translates to:
  /// **'⏳ Bekleyen ({count})'**
  String pendingTransfers(int count);

  /// No description provided for @failedTransfers.
  ///
  /// In tr, this message translates to:
  /// **'✗ Başarısız ({count})'**
  String failedTransfers(int count);

  /// No description provided for @completedTransfersLabel.
  ///
  /// In tr, this message translates to:
  /// **'✓ Tamamlanan ({count})'**
  String completedTransfersLabel(int count);

  /// No description provided for @noTransferHistory.
  ///
  /// In tr, this message translates to:
  /// **'Henüz transfer işlemi yok'**
  String get noTransferHistory;

  /// No description provided for @unknownAccount.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get unknownAccount;

  /// No description provided for @downloadReportTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Rapor İndir'**
  String get downloadReportTooltip;

  /// No description provided for @noExpenseDataForThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay için harcama verisi yok.'**
  String get noExpenseDataForThisMonth;

  /// No description provided for @highestExpense.
  ///
  /// In tr, this message translates to:
  /// **'En çok harcama'**
  String get highestExpense;

  /// No description provided for @categoryDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Dağılımı'**
  String get categoryDistribution;

  /// No description provided for @noIncomeDataForThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay için gelir verisi bulunmuyor.'**
  String get noIncomeDataForThisMonth;

  /// No description provided for @highestIncome.
  ///
  /// In tr, this message translates to:
  /// **'En fazla gelir'**
  String get highestIncome;

  /// No description provided for @noAssetsAddedYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz varlık eklenmemiş.'**
  String get noAssetsAddedYet;

  /// No description provided for @mostValuableType.
  ///
  /// In tr, this message translates to:
  /// **'En değerli tür'**
  String get mostValuableType;

  /// No description provided for @searchTransactions.
  ///
  /// In tr, this message translates to:
  /// **'İşlemlerde ara...'**
  String get searchTransactions;

  /// No description provided for @assetTypes.
  ///
  /// In tr, this message translates to:
  /// **'Varlık Türleri'**
  String get assetTypes;

  /// No description provided for @distributionByPaymentMethod.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Yöntemine Göre Dağılım'**
  String get distributionByPaymentMethod;

  /// No description provided for @otherStr.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get otherStr;

  /// No description provided for @pdfReportTitle.
  ///
  /// In tr, this message translates to:
  /// **'PDF Raporu'**
  String get pdfReportTitle;

  /// No description provided for @selectSectionsToInclude.
  ///
  /// In tr, this message translates to:
  /// **'Dahil edilecek bölümleri seçin'**
  String get selectSectionsToInclude;

  /// No description provided for @reportPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Rapor Dönemi'**
  String get reportPeriod;

  /// No description provided for @reportOptions.
  ///
  /// In tr, this message translates to:
  /// **'Rapor Seçenekleri'**
  String get reportOptions;

  /// No description provided for @selectAll.
  ///
  /// In tr, this message translates to:
  /// **'Hepsi'**
  String get selectAll;

  /// No description provided for @includeAllVisualSummaries.
  ///
  /// In tr, this message translates to:
  /// **'Tüm görsel özet seçeneklerini dahil et'**
  String get includeAllVisualSummaries;

  /// No description provided for @financialSummaryCards.
  ///
  /// In tr, this message translates to:
  /// **'Finansal Özet Kartları'**
  String get financialSummaryCards;

  /// No description provided for @expenseIncomeAssetTotals.
  ///
  /// In tr, this message translates to:
  /// **'Harcama, gelir ve varlık toplamları'**
  String get expenseIncomeAssetTotals;

  /// No description provided for @netStatusCards.
  ///
  /// In tr, this message translates to:
  /// **'Net Durum Kartları'**
  String get netStatusCards;

  /// No description provided for @monthlyNetStatusAndSavings.
  ///
  /// In tr, this message translates to:
  /// **'Aylık net durum ve tasarruf oranı'**
  String get monthlyNetStatusAndSavings;

  /// No description provided for @pieChartAndDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Pasta Grafiği ve Dağılım'**
  String get pieChartAndDistribution;

  /// No description provided for @expenseIncomeAssetDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Harcama/gelir/varlık dağılım grafiği'**
  String get expenseIncomeAssetDistribution;

  /// No description provided for @budgetStatusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Durumu'**
  String get budgetStatusTitle;

  /// No description provided for @budgetProgressBarAndLimit.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe ilerleme çubuğu ve limit bilgisi'**
  String get budgetProgressBarAndLimit;

  /// No description provided for @statisticsCards.
  ///
  /// In tr, this message translates to:
  /// **'İstatistik Kartları'**
  String get statisticsCards;

  /// No description provided for @dailyAverageAndPreviousMonthComparison.
  ///
  /// In tr, this message translates to:
  /// **'Günlük ortalama ve geçen ay karşılaştırma'**
  String get dailyAverageAndPreviousMonthComparison;

  /// No description provided for @top5Expenses.
  ///
  /// In tr, this message translates to:
  /// **'En Yüksek 5 Harcama'**
  String get top5Expenses;

  /// No description provided for @top5ExpensesListDescription.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek tutarlı 5 harcama listesi'**
  String get top5ExpensesListDescription;

  /// No description provided for @tablesToIncludeInReport.
  ///
  /// In tr, this message translates to:
  /// **'Rapora Dahil Edilecek Tablolar'**
  String get tablesToIncludeInReport;

  /// No description provided for @monthlyExpenseDetails.
  ///
  /// In tr, this message translates to:
  /// **'Aylık harcama detayları'**
  String get monthlyExpenseDetails;

  /// No description provided for @monthlyIncomeDetails.
  ///
  /// In tr, this message translates to:
  /// **'Aylık gelir detayları'**
  String get monthlyIncomeDetails;

  /// No description provided for @assetListAndValues.
  ///
  /// In tr, this message translates to:
  /// **'Varlık listesi ve değerleri'**
  String get assetListAndValues;

  /// No description provided for @selectAtLeastOneTable.
  ///
  /// In tr, this message translates to:
  /// **'En az bir tablo seçmelisiniz'**
  String get selectAtLeastOneTable;

  /// No description provided for @preparing.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlanıyor...'**
  String get preparing;

  /// No description provided for @createAndSharePdf.
  ///
  /// In tr, this message translates to:
  /// **'PDF Oluştur ve Paylaş'**
  String get createAndSharePdf;

  /// No description provided for @daysText.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get daysText;

  /// No description provided for @dailyStreak.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Seri 🔥'**
  String get dailyStreak;

  /// No description provided for @freezeUsed.
  ///
  /// In tr, this message translates to:
  /// **'Koruyucu kullanıldı'**
  String get freezeUsed;

  /// No description provided for @totalLogins.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Giriş'**
  String get totalLogins;

  /// No description provided for @streakFreeze.
  ///
  /// In tr, this message translates to:
  /// **'Seri Koruyucu'**
  String get streakFreeze;

  /// No description provided for @protectsStreakEvenIfSkipped.
  ///
  /// In tr, this message translates to:
  /// **'Bir gün atlasan bile serini korur'**
  String get protectsStreakEvenIfSkipped;

  /// No description provided for @streakFreezeUsedToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün seri koruyucu kullanıldı!'**
  String get streakFreezeUsedToday;

  /// No description provided for @nextFreezeIn.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki koruyucu: {days} gün sonra'**
  String nextFreezeIn(int days);

  /// No description provided for @nextBadgeIs.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Rozet: {badgeName}'**
  String nextBadgeIs(String badgeName);

  /// No description provided for @daysRemainingForBadge.
  ///
  /// In tr, this message translates to:
  /// **'{remaining} gün kaldı'**
  String daysRemainingForBadge(int remaining);

  /// No description provided for @badges.
  ///
  /// In tr, this message translates to:
  /// **'Rozetler'**
  String get badges;

  /// No description provided for @badgeFireStarterName.
  ///
  /// In tr, this message translates to:
  /// **'Ateş Başlangıcı'**
  String get badgeFireStarterName;

  /// No description provided for @badgeFireStarterDesc.
  ///
  /// In tr, this message translates to:
  /// **'3 gün üst üste giriş yaptın!'**
  String get badgeFireStarterDesc;

  /// No description provided for @badgeWeeklyStarName.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Yıldız'**
  String get badgeWeeklyStarName;

  /// No description provided for @badgeWeeklyStarDesc.
  ///
  /// In tr, this message translates to:
  /// **'7 gün üst üste giriş yaptın!'**
  String get badgeWeeklyStarDesc;

  /// No description provided for @badgeSteadyName.
  ///
  /// In tr, this message translates to:
  /// **'Kararlı'**
  String get badgeSteadyName;

  /// No description provided for @badgeSteadyDesc.
  ///
  /// In tr, this message translates to:
  /// **'2 hafta boyunca her gün giriş yaptın!'**
  String get badgeSteadyDesc;

  /// No description provided for @badgeMonthlyChampName.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Şampiyon'**
  String get badgeMonthlyChampName;

  /// No description provided for @badgeMonthlyChampDesc.
  ///
  /// In tr, this message translates to:
  /// **'1 ay boyunca her gün giriş yaptın!'**
  String get badgeMonthlyChampDesc;

  /// No description provided for @badgeSuperStreakName.
  ///
  /// In tr, this message translates to:
  /// **'Süper Seri'**
  String get badgeSuperStreakName;

  /// No description provided for @badgeSuperStreakDesc.
  ///
  /// In tr, this message translates to:
  /// **'2 ay boyunca her gün giriş yaptın!'**
  String get badgeSuperStreakDesc;

  /// No description provided for @badgeStreakMasterName.
  ///
  /// In tr, this message translates to:
  /// **'Seri Ustası'**
  String get badgeStreakMasterName;

  /// No description provided for @badgeStreakMasterDesc.
  ///
  /// In tr, this message translates to:
  /// **'100 gün üst üste giriş yaptın!'**
  String get badgeStreakMasterDesc;

  /// No description provided for @badgeLegendName.
  ///
  /// In tr, this message translates to:
  /// **'Efsane'**
  String get badgeLegendName;

  /// No description provided for @badgeLegendDesc.
  ///
  /// In tr, this message translates to:
  /// **'1 yıl boyunca her gün giriş yaptın!'**
  String get badgeLegendDesc;

  /// No description provided for @achievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar'**
  String get achievements;

  /// No description provided for @dShort.
  ///
  /// In tr, this message translates to:
  /// **'g'**
  String get dShort;

  /// No description provided for @earned.
  ///
  /// In tr, this message translates to:
  /// **'✓ Kazanıldı'**
  String get earned;

  /// No description provided for @requiredStreakDays.
  ///
  /// In tr, this message translates to:
  /// **'{requiredStreak} günlük seri gerekli'**
  String requiredStreakDays(int requiredStreak);

  /// No description provided for @streakWhatIsIt.
  ///
  /// In tr, this message translates to:
  /// **'Seri Nedir?'**
  String get streakWhatIsIt;

  /// No description provided for @streakDescription.
  ///
  /// In tr, this message translates to:
  /// **'Seri, uygulamayı art arda kaç gün açtığınızı gösteren bir sayaçtır.\n\n• Her gün uygulamayı açtığınızda seriniz 1 artar\n• Bir gün atlarsanız seriniz sıfırlanır\n• Gün içinde birden fazla giriş yapmanız sadece 1 giriş olarak sayılır\n\nSeri sistemi, finansal alışkanlıklarınızı takip etmenizi ve düzenli olmanızı teşvik eder.'**
  String get streakDescription;

  /// No description provided for @streakFreezeWhatIsIt.
  ///
  /// In tr, this message translates to:
  /// **'Seri Koruyucu Nedir?'**
  String get streakFreezeWhatIsIt;

  /// No description provided for @streakFreezeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Seri Koruyucu, bir gün uygulamayı açmayı unutsanız bile serinizi koruyan özel bir özelliktir.\n\n• Yeni kullanıcılar 1 seri koruyucu ile başlar\n• Her 7 günlük seride 1 yeni koruyucu kazanırsınız\n• Maksimum 3 koruyucu biriktirebilirsiniz\n• 1 gün atlarsanız otomatik olarak kullanılır\n• 2 veya daha fazla gün atlarsanız seri sıfırlanır'**
  String get streakFreezeDescription;

  /// No description provided for @badgesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Belirli seri hedeflerine ulaştığınızda rozetler kazanırsınız:\n\n🔥 Ateş Başlangıcı - 3 günlük seri\n⭐ Haftalık Yıldız - 7 günlük seri\n💪 Kararlı - 14 günlük seri\n🏅 Aylık Şampiyon - 30 günlük seri\n💎 Süper Seri - 60 günlük seri\n👑 Seri Ustası - 100 günlük seri\n🏆 Efsane - 365 günlük seri\n\nRozetler kalıcıdır, seri sıfırlansa bile kaybolmaz!'**
  String get badgesDescription;

  /// No description provided for @achievementsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar, uygulamayı kullanırken elde ettiğiniz özel hedeflerdir:\n\n✓ İlk Adım - Uygulamayı ilk kez açın\n✓ Seri Başlatıcı - 3 günlük seri oluşturun\n✓ Seri Koruyucu - Bir seri koruyucu kullanın\n✓ Düzenli Kullanıcı - Toplam 10 gün giriş yapın\n✓ Süreklilik Ustası - 30 günlük seri oluşturun\n✓ Finansal Guru - Toplam 100 gün giriş yapın\n\nBaşarıları tamamladığınızda yeşil onay işareti görürsünüz.'**
  String get achievementsDescription;

  /// No description provided for @statisticsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statisticsTitle;

  /// No description provided for @statisticsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Seri sayfasında aşağıdaki istatistikleri görebilirsiniz:\n\n📊 Mevcut Seri - Şu anki ardışık giriş sayınız\n🏆 En Uzun Seri - Şimdiye kadarki en yüksek seriniz\n📅 Toplam Giriş - Uygulamayı açtığınız toplam gün sayısı\n❄️ Seri Koruyucu - Elinizdeki koruyucu sayısı\n\nBu istatistikler ilerlemenizi takip etmenize yardımcı olur.'**
  String get statisticsDescription;

  /// No description provided for @tipsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İpuçları'**
  String get tipsTitle;

  /// No description provided for @tipsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Serinizi korumak için bazı ipuçları:\n\n💡 Her gün aynı saatte uygulamayı açmayı alışkanlık haline getirin\n💡 Bildirimler açıksa günlük hatırlatıcı alabilirsiniz\n💡 Seri koruyucularınızı tatil veya yoğun günler için saklayın\n💡 7, 14, 30 gibi hedefler belirleyin\n💡 En uzun seri rekorunuzu kırmaya çalışın\n\nDüzenli finansal takip, daha iyi para yönetimi demektir!'**
  String get tipsDescription;

  /// No description provided for @streakSystem.
  ///
  /// In tr, this message translates to:
  /// **'Seri Sistemi'**
  String get streakSystem;

  /// No description provided for @streakSystemSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Finansal alışkanlıklarınızı geliştirin ve\ndüzenli takip ödüllerini kazanın!'**
  String get streakSystemSubtitle;

  /// No description provided for @cropPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı Kırp'**
  String get cropPhoto;

  /// No description provided for @continueText.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueText;

  /// No description provided for @rotateLeft90.
  ///
  /// In tr, this message translates to:
  /// **'90° Sol'**
  String get rotateLeft90;

  /// No description provided for @rotateRight90.
  ///
  /// In tr, this message translates to:
  /// **'90° Sağ'**
  String get rotateRight90;

  /// No description provided for @flipHorizontal.
  ///
  /// In tr, this message translates to:
  /// **'Yatay'**
  String get flipHorizontal;

  /// No description provided for @flipVertical.
  ///
  /// In tr, this message translates to:
  /// **'Dikey'**
  String get flipVertical;

  /// No description provided for @compare.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştır'**
  String get compare;

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In tr, this message translates to:
  /// **'İleri Al'**
  String get redo;

  /// No description provided for @resetAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Sıfırla'**
  String get resetAll;

  /// No description provided for @rotation.
  ///
  /// In tr, this message translates to:
  /// **'Döndürme'**
  String get rotation;

  /// No description provided for @grid.
  ///
  /// In tr, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @apply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get apply;

  /// No description provided for @filters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreler'**
  String get filters;

  /// No description provided for @adjustments.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get adjustments;

  /// No description provided for @transform.
  ///
  /// In tr, this message translates to:
  /// **'Dönüşüm'**
  String get transform;

  /// No description provided for @text.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get text;

  /// No description provided for @emoji.
  ///
  /// In tr, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// No description provided for @frame.
  ///
  /// In tr, this message translates to:
  /// **'Çerçeve'**
  String get frame;

  /// No description provided for @intensity.
  ///
  /// In tr, this message translates to:
  /// **'Yoğunluk'**
  String get intensity;

  /// No description provided for @brightness.
  ///
  /// In tr, this message translates to:
  /// **'Parlaklık'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In tr, this message translates to:
  /// **'Kontrast'**
  String get contrast;

  /// No description provided for @saturation.
  ///
  /// In tr, this message translates to:
  /// **'Doygunluk'**
  String get saturation;

  /// No description provided for @temperature.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık'**
  String get temperature;

  /// No description provided for @tint.
  ///
  /// In tr, this message translates to:
  /// **'Renk Tonu'**
  String get tint;

  /// No description provided for @shadows.
  ///
  /// In tr, this message translates to:
  /// **'Gölgeler'**
  String get shadows;

  /// No description provided for @highlights.
  ///
  /// In tr, this message translates to:
  /// **'Parlaklıklar'**
  String get highlights;

  /// No description provided for @vignette.
  ///
  /// In tr, this message translates to:
  /// **'Vinyet'**
  String get vignette;

  /// No description provided for @selectProfilePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Profil Resmi Seç'**
  String get selectProfilePhoto;

  /// No description provided for @selectProfilePhotoDesc.
  ///
  /// In tr, this message translates to:
  /// **'Galerinizden bir fotoğraf seçerek ya da kameradan fotoğraf çekerek profil resminizi değiştirebilirsiniz.'**
  String get selectProfilePhotoDesc;

  /// No description provided for @camera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @takePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Çek'**
  String get takePhoto;

  /// No description provided for @gallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @choosePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Seç'**
  String get choosePhoto;

  /// No description provided for @day.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get day;

  /// No description provided for @securityPin.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik PIN\'i'**
  String get securityPin;

  /// No description provided for @fullName.
  ///
  /// In tr, this message translates to:
  /// **'İsim Soyisim'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get emailAddress;

  /// No description provided for @firstStep.
  ///
  /// In tr, this message translates to:
  /// **'İlk Adım'**
  String get firstStep;

  /// No description provided for @firstStepDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı ilk kez açtın'**
  String get firstStepDesc;

  /// No description provided for @streakStarter.
  ///
  /// In tr, this message translates to:
  /// **'Seri Başlatıcı'**
  String get streakStarter;

  /// No description provided for @streakStarterDesc.
  ///
  /// In tr, this message translates to:
  /// **'3 günlük seri oluştur'**
  String get streakStarterDesc;

  /// No description provided for @streakFreezeDescAction.
  ///
  /// In tr, this message translates to:
  /// **'Bir seri koruyucu kullan'**
  String get streakFreezeDescAction;

  /// No description provided for @regularUser.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli Kullanıcı'**
  String get regularUser;

  /// No description provided for @regularUserDesc.
  ///
  /// In tr, this message translates to:
  /// **'Toplam 10 gün giriş yap'**
  String get regularUserDesc;

  /// No description provided for @continuityMaster.
  ///
  /// In tr, this message translates to:
  /// **'Süreklilik Ustası'**
  String get continuityMaster;

  /// No description provided for @continuityMasterDesc.
  ///
  /// In tr, this message translates to:
  /// **'30 günlük seri oluştur'**
  String get continuityMasterDesc;

  /// No description provided for @financialGuru.
  ///
  /// In tr, this message translates to:
  /// **'Finansal Guru'**
  String get financialGuru;

  /// No description provided for @financialGuruDesc.
  ///
  /// In tr, this message translates to:
  /// **'Toplam 100 gün giriş yap'**
  String get financialGuruDesc;

  /// No description provided for @typeText.
  ///
  /// In tr, this message translates to:
  /// **'Metin yazın...'**
  String get typeText;

  /// No description provided for @sizeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Boyut:'**
  String get sizeLabel;

  /// No description provided for @thickness.
  ///
  /// In tr, this message translates to:
  /// **'Kalınlık'**
  String get thickness;

  /// No description provided for @rotateLeft.
  ///
  /// In tr, this message translates to:
  /// **'Sola'**
  String get rotateLeft;

  /// No description provided for @rotateRight.
  ///
  /// In tr, this message translates to:
  /// **'Sağa'**
  String get rotateRight;

  /// No description provided for @horizontal.
  ///
  /// In tr, this message translates to:
  /// **'Yatay'**
  String get horizontal;

  /// No description provided for @vertical.
  ///
  /// In tr, this message translates to:
  /// **'Dikey'**
  String get vertical;

  /// No description provided for @signupSubtitleExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalarınızı yönetmeye başlamak için kayıt olun.'**
  String get signupSubtitleExpense;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get emailLabel;

  /// No description provided for @pinLabel.
  ///
  /// In tr, this message translates to:
  /// **'PIN (4-6 Rakam)'**
  String get pinLabel;

  /// No description provided for @securityQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Sorusu'**
  String get securityQuestion;

  /// No description provided for @securityQuestionAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Sorusu Cevabı'**
  String get securityQuestionAnswer;

  /// No description provided for @signupSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Hoş geldiniz! 🎉'**
  String get signupSuccess;

  /// No description provided for @signupError.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin.'**
  String get signupError;

  /// No description provided for @loginWithAnotherAccount.
  ///
  /// In tr, this message translates to:
  /// **'Başka hesap ile giriş yap'**
  String get loginWithAnotherAccount;

  /// No description provided for @loginWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get loginWithGoogle;

  /// No description provided for @verifyIdentity.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapmak için kimliğinizi doğrulayın'**
  String get verifyIdentity;

  /// No description provided for @loginFailed.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılamadı: {error}'**
  String loginFailed(String error);

  /// No description provided for @tapAndSpeak.
  ///
  /// In tr, this message translates to:
  /// **'Mikrofona dokunun ve konuşun'**
  String get tapAndSpeak;

  /// No description provided for @voiceExampleIncome.
  ///
  /// In tr, this message translates to:
  /// **'Örnek: \"500 lira maaş\"'**
  String get voiceExampleIncome;

  /// No description provided for @heard.
  ///
  /// In tr, this message translates to:
  /// **'Duyulan: '**
  String get heard;

  /// No description provided for @amountTl.
  ///
  /// In tr, this message translates to:
  /// **'Tutar (₺)'**
  String get amountTl;

  /// No description provided for @incomeName.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Adı'**
  String get incomeName;

  /// No description provided for @orDivider.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get orDivider;

  /// No description provided for @biometricLoginFailed.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik giriş başarısız'**
  String get biometricLoginFailed;

  /// No description provided for @enterRegisteredEmail.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı e-posta adresinizi girin'**
  String get enterRegisteredEmail;

  /// No description provided for @userNotFoundWithEmail.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı'**
  String get userNotFoundWithEmail;

  /// No description provided for @noSecurityQuestionDefined.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap için güvenlik sorusu tanımlanmamış'**
  String get noSecurityQuestionDefined;

  /// No description provided for @wrongAnswerTryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış cevap! Lütfen tekrar deneyin.'**
  String get wrongAnswerTryAgain;

  /// No description provided for @setNewPin.
  ///
  /// In tr, this message translates to:
  /// **'Yeni PIN Belirle'**
  String get setNewPin;

  /// No description provided for @enterNewPinDigits.
  ///
  /// In tr, this message translates to:
  /// **'4-6 haneli yeni PIN kodunuzu girin'**
  String get enterNewPinDigits;

  /// No description provided for @pinUpdatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'PIN başarıyla güncellendi! ✓'**
  String get pinUpdatedSuccess;

  /// No description provided for @yourAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Cevabınız'**
  String get yourAnswer;

  /// No description provided for @pleaseEnterAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen cevabınızı girin'**
  String get pleaseEnterAnswer;

  /// No description provided for @pleaseEnterNewPin.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen yeni PIN girin'**
  String get pleaseEnterNewPin;

  /// No description provided for @pinMinDigits.
  ///
  /// In tr, this message translates to:
  /// **'PIN en az 4 haneli olmalı'**
  String get pinMinDigits;

  /// No description provided for @pinOnlyNumbers.
  ///
  /// In tr, this message translates to:
  /// **'PIN sadece rakamlardan oluşmalı'**
  String get pinOnlyNumbers;

  /// No description provided for @pleaseRepeatPin.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen PIN\'i tekrar girin'**
  String get pleaseRepeatPin;

  /// No description provided for @pinRepeatLabel.
  ///
  /// In tr, this message translates to:
  /// **'PIN Tekrar'**
  String get pinRepeatLabel;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueButton;

  /// No description provided for @verifyButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get verifyButton;

  /// No description provided for @updatePinButton.
  ///
  /// In tr, this message translates to:
  /// **'PIN\'i Güncelle'**
  String get updatePinButton;

  /// No description provided for @expenseDeleted.
  ///
  /// In tr, this message translates to:
  /// **'{name} silindi'**
  String expenseDeleted(String name);

  /// No description provided for @updateExpenseAmountMsg.
  ///
  /// In tr, this message translates to:
  /// **'Son harcamayı {amount} ₺ olarak güncellemek istiyor musunuz?'**
  String updateExpenseAmountMsg(String amount);

  /// No description provided for @lastWeek.
  ///
  /// In tr, this message translates to:
  /// **'Geçen hafta'**
  String get lastWeek;

  /// No description provided for @users.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar'**
  String get users;

  /// No description provided for @noRegisteredUsers.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kullanıcı yok.'**
  String get noRegisteredUsers;

  /// No description provided for @addNewUser.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kullanıcı Ekle'**
  String get addNewUser;

  /// No description provided for @welcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoşgeldiniz'**
  String get welcome;

  /// No description provided for @accountCreatedDate.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluşturulma Tarihi'**
  String get accountCreatedDate;

  /// No description provided for @lastLoginDate.
  ///
  /// In tr, this message translates to:
  /// **'Son Giriş Tarihi'**
  String get lastLoginDate;

  /// No description provided for @totalDebt.
  ///
  /// In tr, this message translates to:
  /// **'TOPLAM BORÇ'**
  String get totalDebt;

  /// No description provided for @limitUsage.
  ///
  /// In tr, this message translates to:
  /// **'Limit Kullanımı'**
  String get limitUsage;

  /// No description provided for @usedAmount.
  ///
  /// In tr, this message translates to:
  /// **'Kullanılan'**
  String get usedAmount;

  /// No description provided for @mainCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Ana Para Birimi'**
  String get mainCurrency;

  /// No description provided for @mainCurrencySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama para birimi: ₺, \$, vs.'**
  String get mainCurrencySubtitle;

  /// No description provided for @currencySettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Para Birimi Ayarları'**
  String get currencySettingsTitle;

  /// No description provided for @currencyDescription.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın genel para birimini buradan seçebilirsiniz. Seçiminiz anında tüm sayfalara yansıyacaktır.'**
  String get currencyDescription;

  /// No description provided for @currenciesLabel.
  ///
  /// In tr, this message translates to:
  /// **'PARA BİRİMLERİ'**
  String get currenciesLabel;

  /// No description provided for @currentRateInfo.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Kur: 1 {currency} = {rate} ₺'**
  String currentRateInfo(String currency, String rate);

  /// No description provided for @frameNone.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get frameNone;

  /// No description provided for @frameWhite.
  ///
  /// In tr, this message translates to:
  /// **'Beyaz'**
  String get frameWhite;

  /// No description provided for @frameBlack.
  ///
  /// In tr, this message translates to:
  /// **'Siyah'**
  String get frameBlack;

  /// No description provided for @framePolaroid.
  ///
  /// In tr, this message translates to:
  /// **'Polaroid'**
  String get framePolaroid;

  /// No description provided for @frameGold.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get frameGold;

  /// No description provided for @frameSilver.
  ///
  /// In tr, this message translates to:
  /// **'Gümüş'**
  String get frameSilver;

  /// No description provided for @frameNeon.
  ///
  /// In tr, this message translates to:
  /// **'Neon'**
  String get frameNeon;

  /// No description provided for @frameNeonPink.
  ///
  /// In tr, this message translates to:
  /// **'Neon Pembe'**
  String get frameNeonPink;

  /// No description provided for @frameOcean.
  ///
  /// In tr, this message translates to:
  /// **'Okyanus'**
  String get frameOcean;

  /// No description provided for @frameSunset.
  ///
  /// In tr, this message translates to:
  /// **'Günbatımı'**
  String get frameSunset;

  /// No description provided for @frameRetro.
  ///
  /// In tr, this message translates to:
  /// **'Retro'**
  String get frameRetro;

  /// No description provided for @frameVintage.
  ///
  /// In tr, this message translates to:
  /// **'Vintage'**
  String get frameVintage;

  /// No description provided for @frameMint.
  ///
  /// In tr, this message translates to:
  /// **'Mint'**
  String get frameMint;

  /// No description provided for @frameLavender.
  ///
  /// In tr, this message translates to:
  /// **'Lavanta'**
  String get frameLavender;

  /// No description provided for @frameRoseGold.
  ///
  /// In tr, this message translates to:
  /// **'Rose Gold'**
  String get frameRoseGold;

  /// No description provided for @frameBronze.
  ///
  /// In tr, this message translates to:
  /// **'Bronz'**
  String get frameBronze;

  /// No description provided for @frameIce.
  ///
  /// In tr, this message translates to:
  /// **'Buz'**
  String get frameIce;

  /// No description provided for @frameForest.
  ///
  /// In tr, this message translates to:
  /// **'Orman'**
  String get frameForest;

  /// No description provided for @frameCoral.
  ///
  /// In tr, this message translates to:
  /// **'Mercan'**
  String get frameCoral;

  /// No description provided for @frameNight.
  ///
  /// In tr, this message translates to:
  /// **'Gece'**
  String get frameNight;

  /// No description provided for @frameChampagne.
  ///
  /// In tr, this message translates to:
  /// **'Şampanya'**
  String get frameChampagne;

  /// No description provided for @frameRuby.
  ///
  /// In tr, this message translates to:
  /// **'Yakut'**
  String get frameRuby;

  /// No description provided for @assetNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Gram Altın'**
  String get assetNameHint;

  /// No description provided for @customCategoryNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Antika Saat'**
  String get customCategoryNameHint;

  /// No description provided for @stockNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. THYAO, SASA'**
  String get stockNameHint;

  /// No description provided for @customCurrencyHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. SEK, NOK'**
  String get customCurrencyHint;

  /// No description provided for @customCryptoHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. DOGE, SHIB'**
  String get customCryptoHint;

  /// No description provided for @bankNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Garanti, Ziraat'**
  String get bankNameHint;

  /// No description provided for @quantityHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. 1.0'**
  String get quantityHint;

  /// No description provided for @quickCurrencyChangeInfo.
  ///
  /// In tr, this message translates to:
  /// **'İpucu: Anasayfadaki Toplam Bakiye tutarının üzerine dokunarak da para birimleri arasında hızlıca geçiş yapabilirsiniz.'**
  String get quickCurrencyChangeInfo;

  /// No description provided for @startByAddingFirstExpense.
  ///
  /// In tr, this message translates to:
  /// **'İlk harcamanızı ekleyerek başlayın'**
  String get startByAddingFirstExpense;

  /// No description provided for @startByAddingFirstIncome.
  ///
  /// In tr, this message translates to:
  /// **'İlk gelirinizi ekleyerek başlayın'**
  String get startByAddingFirstIncome;

  /// No description provided for @startTrackingYourAssets.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklarınızı takip etmeye başlayın'**
  String get startTrackingYourAssets;

  /// No description provided for @noTransactionsForThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay için işlem bulunmuyor'**
  String get noTransactionsForThisMonth;

  /// No description provided for @monthlyInsight.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Gidişat'**
  String get monthlyInsight;

  /// No description provided for @spentMoreThanLastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen aya göre %{percent} daha fazla harcadınız.'**
  String spentMoreThanLastMonth(String percent);

  /// No description provided for @spentLessThanLastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen aya göre %{percent} daha az harcadınız. Harika!'**
  String spentLessThanLastMonth(String percent);

  /// No description provided for @spentSameAsLastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen ayla aynı oranda harcıyorsunuz.'**
  String get spentSameAsLastMonth;

  /// No description provided for @earnedMoreThanLastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen aya göre %{percent} daha fazla kazandınız. Harika!'**
  String earnedMoreThanLastMonth(String percent);

  /// No description provided for @earnedLessThanLastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen aya göre %{percent} daha az kazandınız.'**
  String earnedLessThanLastMonth(String percent);

  /// No description provided for @earnedSameAsLastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen ayla aynı oranda kazanıyorsunuz.'**
  String get earnedSameAsLastMonth;

  /// No description provided for @noDetailsFound.
  ///
  /// In tr, this message translates to:
  /// **'Detay bulunamadı.'**
  String get noDetailsFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
