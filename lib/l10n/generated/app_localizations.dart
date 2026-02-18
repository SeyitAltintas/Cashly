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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  /// **'Öğeyi geri yükle'**
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

  /// No description provided for @thisYear.
  ///
  /// In tr, this message translates to:
  /// **'Bu Yıl'**
  String get thisYear;

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
  /// **'{amount} ₺ harcandı'**
  String spentAmount(String amount);

  /// No description provided for @limitAmount.
  ///
  /// In tr, this message translates to:
  /// **'{amount} ₺ limit'**
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
  /// **'İpucu: Komutları doğal bir şekilde söyleyin. Sesli asistan farklı söyleyişleri de anlayabilir.'**
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
  /// **'Kategorilere özel limit belirleyin'**
  String get setCategoryLimits;

  /// No description provided for @noLimitSet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz limit belirlenmemiş'**
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
  /// **'{count} kategori için limit belirlenmiş'**
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
