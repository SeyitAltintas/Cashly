// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cashly';

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle => 'Theme, animations and visual effects';

  @override
  String get appearanceSettings => 'Appearance Settings';

  @override
  String get appearanceSettingsDescription =>
      'Customize the app\'s visual preferences';

  @override
  String get animations => 'Animations';

  @override
  String get animationsSubtitle => 'Money animations and visual effects';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackSubtitle => 'Tap, action and warning vibrations';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Reminders and alert notifications';

  @override
  String get voiceAssistant => 'Voice Assistant';

  @override
  String get voiceAssistantSubtitle => 'Voice feedback and command list';

  @override
  String get expenses => 'Expenses';

  @override
  String get expensesSubtitle => 'Budget, categories and payment methods';

  @override
  String get incomes => 'Incomes';

  @override
  String get incomesSubtitle => 'Income categories and recurring incomes';

  @override
  String get moneyTransfers => 'Money Transfers';

  @override
  String get moneyTransfersSubtitle => 'Transaction history display settings';

  @override
  String get dataOperations => 'Data Operations';

  @override
  String get dataOperationsSubtitle => 'Backup, restore and reset';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Change the app language';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get languageSettingsDescription =>
      'Select the app\'s display language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get languageChangeRestart => 'Language change applied';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupDataSubtitle => 'Export all your data as JSON';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreDataSubtitle => 'Import data from a backup file';

  @override
  String get deleteAllData => 'Delete All My Data';

  @override
  String get deleteAllDataWarning => 'Warning! This action cannot be undone';

  @override
  String get backupSuccess => 'Backup file saved successfully ✅';

  @override
  String get backupCancelled => 'Backup cancelled';

  @override
  String get restoreLoading => 'Restoring data...';

  @override
  String get restoreSuccess => 'Restore completed successfully';

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get deleteErrorMessage => 'An error occurred while deleting data';

  @override
  String get warning => 'Warning!';

  @override
  String get backupSuggestion =>
      'We recommend backing up your data before deleting!';

  @override
  String get permanentDeleteWarning =>
      'All your data will be permanently deleted:';

  @override
  String get allExpenses => 'All expenses';

  @override
  String get allIncomes => 'All incomes';

  @override
  String get allAssets => 'All assets';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get transfers => 'Transfers';

  @override
  String get streakRecords => 'Streak records';

  @override
  String get irreversibleAction => 'This action cannot be undone!';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueAction => 'Continue';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data found';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get securityVerification => 'Security Verification';

  @override
  String get deleteConfirmInstruction =>
      'Enter the result to confirm deletion:';

  @override
  String get wrongCalculation => 'Wrong calculation. Deletion cancelled.';

  @override
  String get allDataDeleted => 'All data deleted ✅';

  @override
  String get appInitFailed => 'App failed to start';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get monthSummary => 'This Month Summary';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get net => 'Net';

  @override
  String get budgetStatus => 'Budget Status';

  @override
  String get budgetUsed => 'Used';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get noBudgetSet => 'No budget set';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get budgetExceeded => 'Budget Exceeded!';

  @override
  String get assetSummary => 'Asset Summary';

  @override
  String get totalAssets => 'Total Assets';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noRecentTransactions => 'No transactions yet';

  @override
  String get creditCardDebt => 'Credit Card Debt';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodNight => 'Good night';

  @override
  String get profile => 'Profile';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get accountInfo => 'Account Info';

  @override
  String get logout => 'Log Out';

  @override
  String get about => 'About';

  @override
  String get aboutAndSupport => 'About & Support';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get login => 'Log In';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordConfirm => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get loginSubtitle => 'Log in to continue';

  @override
  String get signupSubtitle => 'Start your financial journey';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordConfirmHint => 'Enter your password again';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseNote => 'Note';

  @override
  String get expensePaymentMethod => 'Payment Method';

  @override
  String get noExpenses => 'No expenses yet';

  @override
  String get monthlyExpense => 'Monthly Expense';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get incomeAmount => 'Amount';

  @override
  String get incomeCategory => 'Category';

  @override
  String get incomeDate => 'Date';

  @override
  String get incomeNote => 'Note';

  @override
  String get incomePaymentMethod => 'Account';

  @override
  String get noIncomes => 'No incomes yet';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get recurringIncomes => 'Recurring Incomes';

  @override
  String get addAsset => 'Add Asset';

  @override
  String get editAsset => 'Edit Asset';

  @override
  String get assetName => 'Asset Name';

  @override
  String get assetAmount => 'Amount';

  @override
  String get assetType => 'Type';

  @override
  String get assetCurrentPrice => 'Current Price';

  @override
  String get assetPurchasePrice => 'Purchase Price';

  @override
  String get assetPurchaseDate => 'Purchase Date';

  @override
  String get noAssets => 'No assets yet';

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get currency => 'Currency';

  @override
  String get stock => 'Stock';

  @override
  String get crypto => 'Crypto';

  @override
  String get other => 'Other';

  @override
  String get addPaymentMethod => 'Add Payment Method';

  @override
  String get editPaymentMethod => 'Edit Payment Method';

  @override
  String get paymentMethodName => 'Name';

  @override
  String get paymentMethodBalance => 'Balance';

  @override
  String get paymentMethodType => 'Type';

  @override
  String get noPaymentMethods => 'No payment methods yet';

  @override
  String get cash => 'Cash';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get balance => 'Balance';

  @override
  String get creditLimit => 'Credit Limit';

  @override
  String get availableLimit => 'Available Limit';

  @override
  String get currentDebt => 'Current Debt';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferFrom => 'From';

  @override
  String get transferTo => 'To';

  @override
  String get transferAmount => 'Amount';

  @override
  String get transferDate => 'Date';

  @override
  String get transferNote => 'Note';

  @override
  String get noTransfers => 'No transfers yet';

  @override
  String get category => 'Category';

  @override
  String get categories => 'Categories';

  @override
  String get categoryManagement => 'Category Management';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get noCategorySelected => 'No category selected';

  @override
  String get recycleBin => 'Recycle Bin';

  @override
  String get restore => 'Restore';

  @override
  String get permanentDelete => 'Permanently Delete';

  @override
  String get emptyRecycleBin => 'Recycle bin is empty';

  @override
  String get restoreItem => 'Restore item';

  @override
  String get permanentDeleteItem => 'Permanently delete';

  @override
  String get deletedItems => 'Deleted Items';

  @override
  String get budgetLimit => 'Budget Limit';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get categoryBudgets => 'Category Budgets';

  @override
  String get remainingBudget => 'Remaining Budget';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get recurringExpenses => 'Recurring Expenses';

  @override
  String get addRecurringExpense => 'Add Recurring Expense';

  @override
  String get editRecurringExpense => 'Edit Recurring Expense';

  @override
  String get frequency => 'Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get analysis => 'Analysis';

  @override
  String get analytics => 'Analytics';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get incomeByCategory => 'Income by Category';

  @override
  String get monthlyTrend => 'Monthly Trend';

  @override
  String get expenseDistribution => 'Expense Distribution';

  @override
  String get incomeDistribution => 'Income Distribution';

  @override
  String get financialReport => 'Financial Report';

  @override
  String get exportPdf => 'Export as PDF';

  @override
  String get exportCsv => 'Export as CSV';

  @override
  String get streak => 'Streak';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get streakGoal => 'Streak Goal';

  @override
  String get freezeAvailable => 'Freeze Available';

  @override
  String get useFreeze => 'Use Freeze';

  @override
  String get streakBroken => 'Streak broken!';

  @override
  String get streakContinued => 'Streak continued!';

  @override
  String get days => 'days';

  @override
  String get tools => 'Tools';

  @override
  String get calculator => 'Calculator';

  @override
  String get currencyConverter => 'Currency Converter';

  @override
  String get tipCalculator => 'Tip Calculator';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get budgetAlert => 'Budget Alert';

  @override
  String get streakReminder => 'Streak Reminder';

  @override
  String get voiceCommands => 'Voice Commands';

  @override
  String get voiceFeedback => 'Voice Feedback';

  @override
  String get hapticTap => 'Tap Vibration';

  @override
  String get hapticSuccess => 'Success Vibration';

  @override
  String get hapticWarning => 'Warning Vibration';

  @override
  String get hapticError => 'Error Vibration';

  @override
  String get moneyAnimation => 'Money Animation';

  @override
  String get moneyAnimationDescription =>
      'Money rain effect when adding expenses';

  @override
  String get animationPreferences => 'Animation Preferences';

  @override
  String get animationPreferencesDescription => 'Manage in-app animations';

  @override
  String get showMoneyRain => 'Show Money Rain';

  @override
  String get fileNotSelected => 'No file selected';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get customRange => 'Custom Range';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get selectYear => 'Select Year';

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String get accountNotFound => 'Account not found';

  @override
  String get scheduledTransferApplied => 'Scheduled transfer applied';

  @override
  String get scheduledTransferFailed => 'Scheduled transfer failed';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get description => 'Description';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get total => 'Total';

  @override
  String get average => 'Average';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get count => 'Count';

  @override
  String get percentage => 'Percentage';

  @override
  String get spent => 'spent';

  @override
  String get limit => 'limit';

  @override
  String get unknown => 'Unknown';

  @override
  String get totalAsset => 'Total Assets';

  @override
  String get widgetError => 'An error occurred while building the widget.';

  @override
  String appCouldNotStart(String error) {
    return 'App could not start:\n$error';
  }

  @override
  String spentAmount(String amount) {
    return '$amount spent';
  }

  @override
  String limitAmount(String amount) {
    return '$amount limit';
  }

  @override
  String nDays(int count) {
    return '$count days';
  }

  @override
  String get hapticSettingsTitle => 'Haptic Feedback';

  @override
  String get hapticSettingsDescription =>
      'Get vibration feedback on important actions';

  @override
  String get hapticInfoText =>
      'For haptic feedback to work, make sure \"Touch feedback\" or \"Vibration\" is enabled in your device settings.';

  @override
  String get hapticNoVibrator =>
      'Vibration feature not detected on this device.';

  @override
  String get hapticEnable => 'Enable Vibration';

  @override
  String get hapticAllOn => 'All vibrations are on';

  @override
  String get hapticAllOff => 'All vibrations are off';

  @override
  String get hapticButtonTaps => 'Button Taps';

  @override
  String get hapticButtonTapsDesc => 'When you tap buttons';

  @override
  String get hapticNavigation => 'Navigation';

  @override
  String get hapticNavigationDesc => 'Page transitions and picker scrolls';

  @override
  String get hapticDelete => 'Delete Actions';

  @override
  String get hapticDeleteDesc => 'When you delete items';

  @override
  String get hapticSuccessNotif => 'Success Notification';

  @override
  String get hapticSuccessNotifDesc => 'When an action succeeds';

  @override
  String get hapticErrorNotif => 'Error Notification';

  @override
  String get hapticErrorNotifDesc => 'When an error occurs';

  @override
  String get hapticCelebration => 'Streak Celebration';

  @override
  String get hapticCelebrationDesc =>
      'Celebration vibration when streak increases';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get notificationSettingsDesc =>
      'Manage financial reminders and alerts';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationPermDenied => 'Notification permission denied';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get notificationScenarios => 'Notification Scenarios';

  @override
  String get scheduleSettings => 'Schedule Settings';

  @override
  String get turnOffAll => 'Turn Off All';

  @override
  String get turnOnAll => 'Turn On All';

  @override
  String get recurringReminder => 'Recurring Transaction Reminder';

  @override
  String get recurringReminderDesc => '1 day before payment/bill due date';

  @override
  String get streakReminderTitle => 'Streak Reminder';

  @override
  String get streakReminderDesc => 'Daily transaction entry reminder';

  @override
  String get lastChanceWarning => 'Last Chance Warning';

  @override
  String get lastChanceWarningDesc => 'Every day at 22:00 - streak break risk';

  @override
  String get monthlySummary => 'Monthly Summary';

  @override
  String get monthlySummaryDesc => 'Financial summary on the last day of month';

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get weeklyReportDesc => 'Every Sunday 18:00 - top spending category';

  @override
  String get streakReminderTime => 'Streak Reminder Time';

  @override
  String get monthlySummaryTime => 'Monthly Summary Time';

  @override
  String get lastDayOfMonth => 'Last day of each month';

  @override
  String get voiceAssistantTitle => 'Voice Assistant';

  @override
  String get voiceAssistantDesc => 'Manage voice command and feedback settings';

  @override
  String get voiceFeedbackLabel => 'Voice Feedback';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get viewAllVoiceCommands => 'View All Voice Commands';

  @override
  String get voiceCommandsTitle => 'Voice Commands';

  @override
  String get voiceCommandsInfo =>
      'You can use the following commands with the voice assistant.';

  @override
  String get voiceCommandsTip =>
      'Tip: Speak commands naturally. The voice assistant can understand different phrasings.';

  @override
  String get profileSettingsTitle => 'Profile Settings';

  @override
  String get userNotFound => 'User not found';

  @override
  String get userLoadError => 'Could not load user information';

  @override
  String get biometricEnabled => 'Biometric login enabled';

  @override
  String get biometricDisabled => 'Biometric login disabled';

  @override
  String get unknownDate => 'Unknown';

  @override
  String get aboutSupportTitle => 'About & Support';

  @override
  String get aboutSupportDesc => 'App information, support and contact';

  @override
  String get appVersion => 'App Version';

  @override
  String get developer => 'Developer';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get licenses => 'Licenses';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get legal => 'Legal';

  @override
  String get support => 'Support';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get privacyPolicyDesc => 'Learn how we protect your data';

  @override
  String get termsOfServiceDesc => 'Application terms and conditions';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get openSourceLicensesDesc => 'Libraries and their licenses';

  @override
  String get shareAppDesc => 'Share Cashly with your friends';

  @override
  String get appSlogan => 'Your Smart Budget Tracking Assistant';

  @override
  String get footerMessage => 'Take control of your budget with Cashly 💰';

  @override
  String get copyright => '© 2026 Cashly. All rights reserved.';

  @override
  String get lastUpdated => 'Last updated: February 17, 2026';

  @override
  String get shareText =>
      'Track your budget easily with Cashly! 💰\nManage your expenses, income and assets in one place.\n\n📲 Try it now!';

  @override
  String get expenseSettingsTitle => 'Expense Settings';

  @override
  String get expenseSettingsDesc =>
      'Manage your budget and spending preferences';

  @override
  String budgetUpdated(String amount) {
    return 'Your Budget Limit has been updated to $amount TL.';
  }

  @override
  String get defaultPaymentUpdated => 'Default payment method updated ✅';

  @override
  String get transferSettingsTitle => 'Transfer Settings';

  @override
  String get transferSettingsPageTitle => 'Money Transfers';

  @override
  String get transferSettingsDesc =>
      'Manage transfer settings and display preferences';

  @override
  String get transactionHistoryLimit => 'Transaction History Limit';

  @override
  String get transactionHistoryLimitDesc =>
      'Number of transactions to show on the transfer page';

  @override
  String historyLimitSaved(int limit) {
    return 'Transaction history limit saved as $limit ✅';
  }

  @override
  String get select => 'Select';

  @override
  String get useFirstPaymentMethod => 'Use first payment method';

  @override
  String get manageRecurringExpenses => 'Manage Recurring Expenses';

  @override
  String get autoPayBillsSubscriptions =>
      'Automatically paid bills and subscriptions';

  @override
  String get customizeExpenseCategories => 'Customize expense categories';

  @override
  String get addEditDeleteCategories => 'Add, edit or delete categories';

  @override
  String get setCategoryLimits => 'Set category-specific limits';

  @override
  String get noLimitSet => 'No limit set yet';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get editPhoto => 'Edit';

  @override
  String get pin => 'PIN';

  @override
  String get memberSince => 'Member Since';

  @override
  String get lastLogin => 'Last Login';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get biometricDesc => 'Sign in with fingerprint or face recognition';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDesc => 'All your data will be permanently deleted';

  @override
  String get deleteAccountConfirmTitle =>
      'Are You Sure You Want to Delete Your Account?';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get defaultPaymentMethod => 'Default Payment Method';

  @override
  String get noPaymentMethodAdded =>
      'No payment method added yet. You can add from the Tools page.';

  @override
  String categoryBudgetActive(int count) {
    return 'Limits set for $count categories';
  }

  @override
  String get monthlyIncomeBudgetLimit => 'Monthly Income (Budget Limit)';

  @override
  String get myExpenses => 'My Expenses';

  @override
  String get myIncomes => 'My Incomes';

  @override
  String get searchExpense => 'Search expense...';

  @override
  String get searchIncome => 'Search income...';

  @override
  String get goToToday => 'Go to today';

  @override
  String get recycleBinTooltip => 'Recycle Bin';

  @override
  String get voiceInputTooltip => 'Voice Input';

  @override
  String get homePage => 'Home';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get year => 'Year';

  @override
  String get month => 'Month';

  @override
  String get allDataUpToDate => 'All data is up to date';

  @override
  String get user => 'User';

  @override
  String get account => 'Account';

  @override
  String get userInfo => 'User Info';

  @override
  String get userInfoSubtitle => 'Name, email and profile picture';

  @override
  String get settingsSubtitle => 'Appearance, voice assistant and expenses';

  @override
  String get aboutAndSupportSubtitle => 'Version, FAQ and legal information';

  @override
  String get session => 'Session';

  @override
  String get logoutSubtitle => 'Safely log out of your account';

  @override
  String get assets => 'Assets';

  @override
  String get transactions => 'Transactions';

  @override
  String get allTransactions => 'All Transactions';
}
