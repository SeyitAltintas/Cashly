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
  String transferOutTitle(String accountName) {
    return 'Transfer to $accountName account';
  }

  @override
  String transferInTitle(String accountName) {
    return 'Transfer from $accountName account';
  }

  @override
  String get noTransactionsFoundThisMonth => 'No transactions found this month';

  @override
  String get limitLabel => 'Limit';

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
  String get restoreItem => 'Restore';

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
    return 'Spent: $amount';
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
      'Tip: Try to speak naturally when using commands. The app understands different variations.';

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
  String get setCategoryLimits => 'Set Category Limits';

  @override
  String get noLimitSet => 'No limit set';

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
    return '$count active limit(s)';
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

  @override
  String get newRecurringExpense => 'New Recurring Expense';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get transactionName => 'Transaction Name';

  @override
  String get transactionNameRequired => 'Transaction name is required';

  @override
  String get amountWithCurrency => 'Amount (₺)';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get everyMonthOn => 'Every month on:';

  @override
  String dayOfMonth(int day) {
    return 'Day $day';
  }

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get update => 'Update';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get errorWhileSaving => 'An error occurred while saving';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get recurringTransactionsInfo =>
      'The transactions you define will be automatically added to your expenses on the day you set each month.';

  @override
  String get noRecurringTransactions => 'No recurring transactions yet';

  @override
  String get tapPlusToAdd => 'Tap + button to add';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String deleteTransactionConfirm(String name) {
    return 'Do you want to delete the $name transaction?';
  }

  @override
  String get unnamed => 'Unnamed';

  @override
  String everyMonthDayOf(int day, String method) {
    return 'Day $day of every month • $method';
  }

  @override
  String get categoryBasedUsage => 'Category Based Usage';

  @override
  String get unlimitedCategories => 'Unlimited Categories';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String exceeded(String amount) {
    return 'Exceeded: $amount';
  }

  @override
  String remaining(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String exceededPercent(String percent) {
    return 'Exceeded! $percent%';
  }

  @override
  String get categoryBudgetInfo =>
      'Set monthly spending limits for each category. You will see warnings on the dashboard when limits are approached or exceeded.';

  @override
  String get categoryBudgetDialogInfo =>
      'Set a monthly spending limit for this category. You will see a warning on the dashboard when the limit is exceeded.';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get noLimit => 'Unlimited';

  @override
  String get zeroNoLimit => '0 = Unlimited';

  @override
  String get limitNotSet => 'No limit set';

  @override
  String monthlyLimitAmount(String amount) {
    return '$amount₺ monthly limit';
  }

  @override
  String get removeLimit => 'Remove Limit';

  @override
  String limitRemoved(String category) {
    return '$category limit removed';
  }

  @override
  String get maxLimitWarning => 'Maximum limit is 10 billion ₺';

  @override
  String limitSet(String category, String amount) {
    return '$category limit set to $amount₺';
  }

  @override
  String activeBudgets(int count) {
    return '$count active';
  }

  @override
  String get expenseDetail => 'Expense Detail';

  @override
  String get expenseInfo => 'Expense Information';

  @override
  String get spentAmountLabel => 'Amount Spent';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String deleteExpenseConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get expenseCategories => 'Expense Categories';

  @override
  String get editPhotoTitle => 'Edit Photo';

  @override
  String get resetAllEffects => 'Reset All Effects';

  @override
  String get confirm => 'Confirm';

  @override
  String get tryAgainShort => 'Again';

  @override
  String scheduledTransfersFailed(String reasons) {
    return 'The following transactions failed: $reasons';
  }

  @override
  String get senderAccountNotFound => 'Sender account not found';

  @override
  String get receiverAccountNotFound => 'Receiver account not found';

  @override
  String accountDeleted(String account) {
    return '$account deleted';
  }

  @override
  String insufficientBalanceAccount(String accountName) {
    return 'Insufficient balance in $accountName account';
  }

  @override
  String noDebtToPay(String accountName) {
    return 'No debt to pay for $accountName';
  }

  @override
  String get voiceCmdAddExpenseTitle => 'Adding Expense';

  @override
  String get voiceCmdAddExpenseDesc =>
      'Add expense by saying amount, category and optionally date.';

  @override
  String get voiceCmdAddExpenseExamples =>
      '100 dollars market|50 dollars coffee|Yesterday 80 dollars market|Last monday 200 dollars gas|Day before yesterday 150 dollars food';

  @override
  String get voiceCmdDeleteExpenseTitle => 'Deleting Expense';

  @override
  String get voiceCmdDeleteExpenseDesc => 'Delete the last added expense.';

  @override
  String get voiceCmdDeleteExpenseExamples =>
      'Delete last expense|Delete the last one|Remove last record';

  @override
  String get voiceCmdEditExpenseTitle => 'Editing Expense';

  @override
  String get voiceCmdEditExpenseDesc => 'Edit the amount of your last expense.';

  @override
  String get voiceCmdEditExpenseExamples =>
      'Make last expense 100 dollars|Update last one to 50 dollars|Change last record to 75 dollars';

  @override
  String get voiceCmdTotalQueryTitle => 'Total Expense Query';

  @override
  String get voiceCmdTotalQueryDesc =>
      'Learn your monthly, weekly or daily total expenses.';

  @override
  String get voiceCmdTotalQueryExamples =>
      'How much did I spend this month?|How much this week?|Spent today?|What is my total expense?|Weekly spending';

  @override
  String get voiceCmdCategoryAnalysisTitle => 'Category Analysis';

  @override
  String get voiceCmdCategoryAnalysisDesc =>
      'Learn which category you spent the most.';

  @override
  String get voiceCmdCategoryAnalysisExamples =>
      'Which category did I spend most?|Where did I spend most?';

  @override
  String get voiceCmdCategoryQueryTitle => 'Expense by Category';

  @override
  String get voiceCmdCategoryQueryDesc =>
      'Learn your total expense in a specific category.';

  @override
  String get voiceCmdCategoryQueryExamples =>
      'How much did I spend on market?|How much on food?|Spent on transport?';

  @override
  String get voiceCmdLastExpensesTitle => 'Listing Last Expenses';

  @override
  String get voiceCmdLastExpensesDesc => 'List your recent expenses.';

  @override
  String get voiceCmdLastExpensesExamples =>
      'What are my last expenses?|Tell me last expenses|Last 5 records';

  @override
  String get voiceCmdBudgetStatusTitle => 'Budget Status';

  @override
  String get voiceCmdBudgetStatusDesc => 'Check your budget status.';

  @override
  String get voiceCmdBudgetStatusExamples =>
      'Did I exceed my budget?|What is my limit status?|Budget status';

  @override
  String get voiceCmdRemainingBudgetTitle => 'Remaining Budget Query';

  @override
  String get voiceCmdRemainingBudgetDesc =>
      'Learn how much is left from your budget.';

  @override
  String get voiceCmdRemainingBudgetExamples =>
      'How much budget left?|How much can I spend?|Remaining limit';

  @override
  String get voiceCmdSetLimitTitle => 'Setting Budget Limit';

  @override
  String get voiceCmdSetLimitDesc => 'Update your monthly budget by voice.';

  @override
  String get voiceCmdSetLimitExamples =>
      'Set monthly limit to 10000 dollars|Update budget to 5000 dollars|Make budget 15000 dollars';

  @override
  String get voiceCmdSavingsTitle => 'Savings Calculation';

  @override
  String get voiceCmdSavingsDesc => 'Learn how much you saved this month.';

  @override
  String get voiceCmdSavingsExamples =>
      'How much did I save this month?|My savings?|Am I in plus?';

  @override
  String get voiceCmdAddFixedTitle => 'Add Fixed Expenses';

  @override
  String get voiceCmdAddFixedDesc =>
      'Add fixed expenses defined in settings to this month.';

  @override
  String get voiceCmdAddFixedExamples =>
      'Add fixed expenses|Add bills|Add regular expenses';

  @override
  String get privacyPolicyContent =>
      '1. Introduction\n\nThis Privacy Policy explains how the personal data of users of the Cashly application (\"App\") is collected, stored, and protected. By using the app, you agree to this policy.\n\nLast updated: February 17, 2026\n\n2. Data Collection and Usage\n\nCashly stores all your data locally on your device only. No personal data is sent, transferred, or transmitted to our servers.\n\nData collected and stored on the device:\n• User information (name and email address)\n• Expenses and income records (amount, category, date, description)\n• Asset information (type, quantity, value)\n• Payment methods and balance information\n• Transfer records\n• Budget limits and category budgets\n• Profile photo (optional)\n• App preferences and settings\n• Streak records\n\nThis data is used solely to provide the basic functions of the app.\n\n3. Data Security\n\nThe security of your data is our top priority:\n\n• All data is stored in a local database on your device.\n• Access to the app is protected by a 4-digit PIN code.\n• Biometric authentication (fingerprint / face recognition) support is available.\n• A security question provides an additional layer of protection.\n• Automatic lock engages when the app is backgrounded.\n• The app does not establish any external network connections.\n\n4. Third-Party Sharing\n\nCashly does not share, sell, or rent any collected data to third parties. Your data belongs entirely to you. No third-party analytics or advertising tools are used within the app.\n\n5. Data Backup and Transfer\n\n• The backup process is completely under user control and is optional.\n• Backup files are exported to your device in JSON format.\n• The security and storage of the backup file are the user\'s responsibility.\n• The backup file includes expenses, incomes, assets, payment methods, transfers, and profile information.\n• The restore process overwrites existing data.\n\n6. Data Retention Period\n\nYour data is stored on your device until you delete your account. If you uninstall the app, all data is automatically deleted.\n\n7. Right to Delete Data\n\nYou can permanently delete your account and all your data at any time:\n• Use the Profile > User Information > Delete Account option.\n• Deletion requires security verification.\n• Deleted data cannot be recovered.\n• It is recommended to take a backup before deletion.\n\n8. Children\'s Privacy\n\nCashly is not intended for children under 13. We do not knowingly collect data from users under 13.\n\n9. Policy Changes\n\nThis privacy policy may be updated from time to time. Significant changes will be notified within the app.\n\n10. Contact\n\nFor questions or requests regarding our privacy policy, you can contact us within the app.';

  @override
  String get termsOfServiceContent =>
      '1. Acceptance and Scope\n\nBy downloading, installing, or using the Cashly application (\"App\"), you agree to these Terms of Use. If you do not agree to these terms, please do not use the app.\n\nLast updated: February 17, 2026\n\n2. Service Description\n\nCashly is a personal budget tracking and financial management tool. The app offers the following services:\n\n• Expense and income tracking (manual and voice entry)\n• Asset management (gold, currency, crypto, bank account)\n• Budget planning and category-based limit setting\n• Payment method management and balance tracking\n• Transfer records between accounts\n• defining regular income/expenses\n• Natural language commands with voice assistant\n• Data backup and restore\n• Statistics and graph reports\n\n3. Account and Security\n\n• You must enter accurate information when creating your account.\n• Your PIN code is the security key of your account; do not share it with anyone.\n• Biometric login and security question are additional protection layers.\n• You are responsible for unauthorized access to your account.\n• If you notice suspicious activity, it is recommended to change your PIN code.\n\n4. User Responsibilities\n\n• The financial data you enter belongs entirely to you, and you are responsible for its accuracy.\n• You cannot use the app for illegal purposes.\n• It is recommended to perform regular data backups.\n• You are responsible for the security of your backup files.\n• You cannot attempt to reverse engineer, extract source code, or modify the app.\n\n5. Disclaimer\n\nIMPORTANT - Please read carefully:\n\n• Cashly is not a financial advisory, investment advice, or accounting tool.\n• The app does not provide any investment, savings, or spending advice.\n• Cashly cannot be held responsible for your financial decisions.\n• The app is provided \"as is\"; uninterrupted or error-free operation is not guaranteed.\n• No responsibility is accepted for device failure, software error, or user-caused data loss.\n• Up-to-date exchange rates and asset prices are for informational purposes; may differ from actual market values.\n\n6. Data and Content\n\n• All data you enter into the app is stored on your device.\n• You are responsible for the accuracy, integrity, and currency of the data.\n• Account deletion cannot be undone; all your data is permanently removed.\n\n7. Intellectual Property\n\n• The Cashly app, its design, logos, and all content are protected by copyright.\n• Unauthorized copying, distribution, or creation of derivative works of the app code, visuals, and design is prohibited.\n• The \"Cashly\" name and logo are registered trademarks.\n\n8. Service Changes\n\n• App features may be added, changed, or removed without prior notice.\n• Updates, bug fixes, and improvements may be made regularly.\n\n9. Term Changes\n\nThese terms of use may be updated from time to time. Significant changes will be notified within the app. Continuing to use the app after updates means you accept the new terms.\n\n10. Applicable Law\n\nThese terms are subject to the laws of the Republic of Turkey. Turkish courts are authorized for disputes.\n\n11. Contact\n\nFor questions about our terms of use, you can contact us within the app.';

  @override
  String get faqSafetyQ => 'Is my data safe?';

  @override
  String get faqSafetyA =>
      'Absolutely! Cashly protects your privacy at the highest level:\n\n• All your data resides only on your device, never sent to any server.\n• Access to the app is protected by a 4-digit PIN code.\n• Biometric login (fingerprint / face recognition) support is available.\n• You can add an extra protection layer with a security question.\n\nYour data belongs entirely to you and is not shared with any third party.';

  @override
  String get faqOfflineQ => 'Is internet connection required?';

  @override
  String get faqOfflineA =>
      'No! Cashly is designed to work completely offline.\n\n• Adding, editing, deleting expenses and incomes\n• Asset management and tracking\n• Budget planning and category management\n• Voice assistant commands\n• Data backup and restore\n\nAll these features work seamlessly without internet. Internet connection may only be required for up-to-date currency/gold rates.';

  @override
  String get faqBackupQ => 'How can I backup my data?';

  @override
  String get faqBackupA =>
      'We recommend regular backups to secure your data:\n\n1. Go to Profile > Settings > Data Operations.\n2. Tap on \"Backup Data\".\n3. All your data is exported to a file in JSON format.\n4. Save the file to Google Drive, email, or any location you prefer.\n\nThe backup file includes your expenses, incomes, assets, payment methods, transfers, and profile information.';

  @override
  String get faqRestoreQ => 'How do I restore my backup?';

  @override
  String get faqRestoreA =>
      'To restore a backup you took earlier:\n\n1. Go to Profile > Settings > Data Operations.\n2. Tap on \"Restore Data\".\n3. Select the JSON backup file you saved earlier.\n4. The app refreshes automatically when the process is complete.\n\nWarning: The restore process replaces your current data with the data in the backup. We recommend taking a new backup to avoid losing your current data.';

  @override
  String get faqVoiceAssisQ => 'How does the voice assistant work?';

  @override
  String get faqVoiceAssisA =>
      'Cashly\'s voice assistant allows you to add expenses and incomes using natural language:\n\n• Tap the microphone icon on the home screen.\n• Give a command naturally, for example:\n  - \"Add 50 dollars market expense\"\n  - \"Add 1500 dollars salary income\"\n  - \"Add 200 dollars food expense with cash\"\n\nThe assistant automatically detects the amount, category, and payment method. Voice feedback confirms the transaction is successful. You can see the full list of commands in Settings > Voice Assistant.';

  @override
  String get faqBudgetLimitQ => 'How do I set my budget limit?';

  @override
  String get faqBudgetLimitA =>
      'To keep your monthly spending budget under control:\n\n1. Go to Profile > Settings > Expenses.\n2. Enter your total monthly budget in the \"Monthly Budget Limit\" field.\n3. Tap the Save button.\n\nAfter setting your budget limit:\n• You can see your budget utilization rate on the home screen.\n• You receive a visual warning when you approach or exceed the limit.\n• You can instantly track your status with color codes (green: safe, yellow: caution, red: limit exceeded).';

  @override
  String get faqCategoryBudgetQ => 'What is category-based budget limit?';

  @override
  String get faqCategoryBudgetA =>
      'Besides the general budget limit, you can set separate limits for each category:\n\n1. Go to Profile > Settings > Expenses > Category Budgets.\n2. Tap on the category you want (e.g. Food & Cafe).\n3. Set a monthly limit for that category.\n\nExample usage:\n• Food & Cafe: 2,000₺\n• Transport: 500₺\n• Entertainment: 1,000₺\n\nThis way, you can control your expenses in detail on a category basis and see where you can save.';

  @override
  String get faqRecurringQ => 'What is regular income/expense?';

  @override
  String get faqRecurringA =>
      'You can define incomes or expenses that repeat regularly every month:\n\nRegular income examples: Salary, rental income, side income\nRegular expense examples: Rent, internet, phone bill, subscriptions\n\nHow to add:\n1. Go to Settings > Expenses or Incomes.\n2. Tap on \"Recurring Transactions\".\n3. Set the amount, category, and repetition frequency.\n\nRecurring transactions are automatically recorded every month, so you don\'t have to add them manually each time.';

  @override
  String get faqAssetTrackingQ => 'How is asset tracking done?';

  @override
  String get faqAssetTrackingA =>
      'You can track your financial assets from a single place with Cashly:\n\nSupported asset types:\n• Gold (gram, quarter, half, full)\n• Currency (USD, EUR, etc.)\n• Crypto currency\n• Bank accounts\n• Silver\n\nAdd your assets, enter the quantity and purchase price. Track your total portfolio value, profit/loss status, and asset distribution with charts.';

  @override
  String get faqPaymentMethodsQ => 'How do I manage my payment methods?';

  @override
  String get faqPaymentMethodsA =>
      'Track your expenses in detail by defining different payment methods:\n\n• Cash\n• Debit/Credit cards\n• Digital wallets\n\nYou can define a balance for each payment method and ensure the balance is automatically updated as you spend. This way, you can instantly see how much you spent from which card or how much cash is left in your safe.';

  @override
  String get faqTransferQ => 'How to make transfers between accounts?';

  @override
  String get faqTransferA =>
      'You can record money transfers between your payment methods:\n\nExample scenarios:\n• Withdrawing cash from bank\n• Paying credit card debt\n• Transfer from one account to another\n\nThe transfer transaction deducts the amount from the source account and adds it to the destination account. Thus, the balance of all your accounts remains up-to-date at all times. You can view your transfer history in Settings > Money Transfers.';

  @override
  String get faqNotificationsQ => 'What are notifications for?';

  @override
  String get faqNotificationsA =>
      'Cashly offers various notifications to keep you on track with your financial goals:\n\n• Daily reminder: Don\'t forget to enter your expenses.\n• Budget alert: Get notified when you approach your monthly limit.\n• Recurring transaction notification: Get informed when recurring income/expenses are recorded.\n\nYou can turn all notification settings on or off and customize their times as you wish from Profile > Settings > Notifications.';

  @override
  String get faqStreakQ => 'What is the streak system?';

  @override
  String get faqStreakA =>
      'The streak system is a motivation tool that helps you create a regular usage habit:\n\n• Keep your streak going by using the app every day.\n• Your streak level increases as your consecutive day count grows.\n• You see a celebration animation when you reach certain levels.\n• If you miss a day, your streak resets.\n\nThe streak system helps you gain the habit of tracking your expenses regularly. Try to break your highest streak!';

  @override
  String get faqProfilePhotoQ => 'How do I change my profile photo?';

  @override
  String get faqProfilePhotoA =>
      'To change your profile photo:\n\n1. Go to Profile > User Information page.\n2. Tap the edit icon on your profile photo.\n3. Select a photo from the gallery or use one of the ready avatars.\n4. Crop, rotate and apply filters to the selected photo.\n\nYou can adjust your photo exactly as you want with the photo editor.';

  @override
  String get faqForgotPinQ => 'What should I do if I forget my PIN?';

  @override
  String get faqForgotPinA =>
      'If you forgot your PIN code, you can reset it using your security question on the login screen. You must have set a security question and answer beforehand for this.\n\nTo set your security question:\nYou can use the Profile > User Information > Security section.\n\nIf you haven\'t set a security question and forgot your PIN, you may need to reinstall the app. In this case, if you have a backup, you can restore your data.';

  @override
  String get faqDeleteAccountQ => 'What happens if I delete my account?';

  @override
  String get faqDeleteAccountA =>
      'Account deletion is permanent and cannot be undone. Deleted data:\n\n• All expense records\n• All income records\n• Your assets\n• Payment methods and balances\n• Transfer history\n• Streak records\n• Profile information and photo\n\nWe strongly recommend backing up your data before deleting. Account deletion requires security verification (math question) and is performed with two-step confirmation.';

  @override
  String get done => 'Done';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectMonthAndYear => 'Select Month and Year';

  @override
  String get selectDateAndTime => 'Select Date and Time';

  @override
  String get errorOccurred => 'An Error Occurred';

  @override
  String get unexpectedErrorRestart =>
      'An unexpected error occurred.\nPlease restart the app.';

  @override
  String get technicalDetails => 'Technical Details';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get componentLoadError =>
      'A problem occurred while loading this component.';

  @override
  String pageLoadError(String pageName) {
    return 'An error occurred while loading $pageName page.';
  }

  @override
  String get operationSuccessful => 'Operation successful!';

  @override
  String get limitWarning => 'Limit Warning';

  @override
  String get balanceWarning => 'Balance Warning';

  @override
  String get continueAnyway => 'Do you still want to continue?';

  @override
  String get remainingLimitLabel => 'Remaining Limit';

  @override
  String get currentBalanceLabel => 'Current Balance';

  @override
  String get expenseAmountLabel => 'Expense Amount';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get unavailableFeatures => 'Unavailable Features';

  @override
  String get assetPriceUpdates => 'Asset price updates';

  @override
  String get realTimeExchangeRates => 'Real-time exchange rates';

  @override
  String get limitedFeatures => 'Limited Features';

  @override
  String get assetValuesLastKnown =>
      'Asset values are shown with last known prices';

  @override
  String get fullyWorkingFeatures => 'Fully Working Features';

  @override
  String get addEditIncomeExpense => 'Adding and editing income/expenses';

  @override
  String get backupAndRestore => 'Backup and restore';

  @override
  String get chartsAndReports => 'Charts and reports';

  @override
  String get allLocalData => 'All local data';

  @override
  String get understood => 'Understood';

  @override
  String get pleaseEnterEmail => 'Please enter your email address';

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get pleaseSetPin => 'Please set a PIN';

  @override
  String get pinLengthError => 'PIN must be between 4 and 6 digits';

  @override
  String get pinDigitsOnly => 'PIN must contain only digits';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get nameMaxLength => 'Name can be at most 50 characters';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get amountMustBePositive => 'Amount must be a positive number';

  @override
  String get pleaseEnterQuantity => 'Please enter a quantity';

  @override
  String get enterValidNumberFormat => 'Enter a valid number format';

  @override
  String get quantityCannotBeNegative => 'Quantity cannot be negative';

  @override
  String get quantityMustBeGreaterThanZero => 'Quantity must be greater than 0';

  @override
  String get pleaseEnterCardName => 'Please enter card name';

  @override
  String get cardNameMinLength => 'Card name must be at least 2 characters';

  @override
  String get cardNameMaxLength => 'Card name can be at most 30 characters';

  @override
  String get pleaseEnterLastFourDigits => 'Please enter the last 4 digits';

  @override
  String get lastFourDigitsLength => 'Last 4 digits must be exactly 4 digits';

  @override
  String get lastFourDigitsOnly => 'Last 4 digits must contain only numbers';

  @override
  String get pleaseEnterDebtAmount => 'Please enter debt amount';

  @override
  String get pleaseEnterBalanceAmount => 'Please enter balance';

  @override
  String get invalidAmountFormat => 'Invalid amount format';

  @override
  String get amountCannotBeNegative => 'Amount cannot be negative';

  @override
  String get limitMustBeGreaterThanZero => 'Limit must be greater than 0';

  @override
  String get limitLessThanDebt => 'Limit cannot be less than current debt';

  @override
  String get genericError => 'An error occurred. Please try again.';

  @override
  String get dataNotFoundError => 'Data not found';

  @override
  String get connectionError =>
      'Connection error. Check your internet connection.';

  @override
  String get timeoutError => 'Operation timed out. Please try again.';

  @override
  String get permissionError => 'Permission error';

  @override
  String get priceFetchFailed =>
      'Failed to fetch price, please enter manually.';

  @override
  String get priceFetchError => 'Error fetching price. Please enter manually.';

  @override
  String get pleaseFillRequiredFields => 'Please fill in all required fields';

  @override
  String get currentPriceButton => 'Current';

  @override
  String get amountTL => 'Amount (TL)';

  @override
  String get purchaseInfo => 'Purchase Information';

  @override
  String get purchasePriceTL => 'Purchase Price (TL)';

  @override
  String get enterValidPrice => 'Enter a valid price';

  @override
  String get purchasePriceNegative => 'Purchase price cannot be negative';

  @override
  String get purchasePriceMustBePositive =>
      'Purchase price must be greater than 0';

  @override
  String get minPurchasePrice => 'Minimum purchase price must be 0.01 TL';

  @override
  String get maxPurchasePrice => 'Maximum purchase price can be 100 million TL';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get stockNameLabel => 'Stock Name';

  @override
  String get currencyNameLabel => 'Currency Name';

  @override
  String get cryptoNameLabel => 'Crypto Name';

  @override
  String get bankNameLabel => 'Bank Name';

  @override
  String get assetNameField => 'Asset Name';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String updateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get profileImageUpdated => 'Profile image updated';

  @override
  String get selectProfileImage => 'Select Profile Image';

  @override
  String get galleryOrCameraDesc =>
      'You can change your profile picture by selecting a photo from your gallery or taking a photo with the camera.';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get takePhotoLabel => 'Take Photo';

  @override
  String get galleryLabel => 'Gallery';

  @override
  String get selectPhotoLabel => 'Select Photo';

  @override
  String get changeName => 'Change Name';

  @override
  String get newNameLabel => 'New Name';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get nameUpdated => 'Name Updated';

  @override
  String get currentPinLabel => 'Current PIN';

  @override
  String get newPinLabel => 'New PIN';

  @override
  String get newPinRepeatLabel => 'New PIN (Repeat)';

  @override
  String get enterPinDigits => 'Enter 4-6 digit PIN';

  @override
  String get pinIncorrect => 'PIN is incorrect';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get pinUpdated => 'PIN Updated';

  @override
  String get pinVerification => 'PIN Verification';

  @override
  String get biometricPinVerificationDesc =>
      'Verify your PIN to activate biometric login';

  @override
  String get activateBiometric => 'Activate Biometric';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get permanentDeleteAccountConfirm =>
      'Are you sure you want to permanently delete your account?';

  @override
  String get yesDelete => 'Yes, Delete';

  @override
  String get accountDeletedSuccess =>
      'Your account has been successfully deleted';

  @override
  String accountDeleteError(String error) {
    return 'Error deleting account: $error';
  }

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get pinVerificationTitle => 'PIN Verification';

  @override
  String get forwardButton => 'Next';

  @override
  String get thisActionIrreversibleWarning =>
      'This action cannot be undone! All your data will be permanently deleted.';

  @override
  String get expenseMovedToTrash => 'Expense moved to trash';

  @override
  String get expenseRestored => 'Expense restored ';

  @override
  String get noSearchResults => 'No results found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get emptyTrashTitle => 'Empty Trash';

  @override
  String get emptyTrashConfirm =>
      'All deleted expenses will be permanently destroyed. Are you sure?';

  @override
  String get trashEmptied => 'Trash emptied.';

  @override
  String get restoreAllTitle => 'Restore All';

  @override
  String restoreAllConfirm(int count) {
    return '$count expenses will be restored. Do you confirm?';
  }

  @override
  String get yesRestore => 'Yes, Restore';

  @override
  String get allExpensesRestored => 'All expenses restored ';

  @override
  String get noDeletedExpenses => 'No deleted expenses.';

  @override
  String get expensePermanentlyDeleted => 'Expense permanently deleted ';

  @override
  String get expenseRestoredRecycled => 'Expense restored';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Are you sure you want to delete the \"$name\" category?';
  }

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryAdded => 'Category added ';

  @override
  String systemCategoryCannotDelete(String name) {
    return '\"$name\" is a system category and cannot be deleted';
  }

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetCategoriesConfirm =>
      'All custom categories will be deleted and default categories will be loaded. Are you sure?';

  @override
  String get yesReset => 'Yes, Reset';

  @override
  String get defaultCategoriesLoaded => 'Default categories loaded';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get myCategories => 'MY CATEGORIES';

  @override
  String get addNew => 'Add New';

  @override
  String get selectIconLabel => 'Select Icon:';

  @override
  String get categoryOrderUpdated => 'Category order updated';

  @override
  String get micPermissionDenied =>
      'Microphone permission denied or device not supported.';

  @override
  String get expenseDeletion => 'Expense Deletion';

  @override
  String get deleteLastExpenseConfirm =>
      'Are you sure you want to delete the last added expense?';

  @override
  String get commandNotSupported => 'This command is not yet supported';

  @override
  String get noExpenseFoundYet => 'No expenses found yet';

  @override
  String get categoryNotUnderstood => 'Category not understood';

  @override
  String get addRecurringToMonthConfirm =>
      'Would you like to add defined recurring transactions to this month?';

  @override
  String get expenseEditingTitle => 'Expense Editing';

  @override
  String get newAmountNotUnderstood =>
      'Could not understand the new amount. For example, you can say \"Make last expense 100 dollars\".';

  @override
  String get budgetLimitUpdateTitle => 'Budget Limit Update';

  @override
  String get limitUpdateError => 'An error occurred while updating the limit';

  @override
  String get commandProcessing => 'Processing command...';

  @override
  String get heardLabel => 'Heard:';

  @override
  String get howToUse => 'How to use?';

  @override
  String get voiceAssistantCapabilities => 'With the voice assistant you can:';

  @override
  String get addingExpenseLabel => 'Add expenses';

  @override
  String get deletingExpenseLabel => 'Delete expenses';

  @override
  String get queryExpenseLabel => 'Query expenses';

  @override
  String get categoryAnalysisLabel => 'Category analysis';

  @override
  String get budgetControlLabel => 'Budget control';

  @override
  String get detailedCommandListInfo =>
      'For detailed command list:\nSettings -> Voice Assistant -> All Commands';

  @override
  String get voiceIncomeInput => 'Voice Income Input';

  @override
  String get voiceExpenseInput => 'Voice Expense Input';

  @override
  String get micPreparing => 'Microphone is preparing...';

  @override
  String get micListening => 'Listening...';

  @override
  String get tapToSpeakAgain => 'Tap to speak again';

  @override
  String get tapToStopMic => 'Tap the microphone to stop';

  @override
  String get pdfReportGenerated => 'PDF report generated';

  @override
  String pdfGenerationError(String error) {
    return 'Error generating PDF: $error';
  }

  @override
  String get expenseNameLabel => 'Expense Name';

  @override
  String get whatDidYouBuy => 'What did you buy? (e.g. Coffee)';

  @override
  String get expenseDateLabel => 'Expense Date';

  @override
  String get selectPaymentMethodHint => 'Select Payment Method';

  @override
  String get enterValidAmountError => 'Enter a valid amount';

  @override
  String get recurringTransactionsLabel => 'Recurring Transactions';

  @override
  String recurringItemsAdded(int count) {
    return '$count recurring transactions added!';
  }

  @override
  String expenseAddedVoice(String name, String amount) {
    return 'Expense added: $name - $amount TL';
  }

  @override
  String monthlyBudgetUpdated(String amount) {
    return 'Monthly budget updated to $amount TL';
  }

  @override
  String get limitNotUnderstood =>
      'Could not understand the limit amount. For example, you can say \"Set my monthly limit to 10000 dollars\".';

  @override
  String updateExpenseConfirm(String amount) {
    return 'Do you want to update the last expense to $amount TL?';
  }

  @override
  String expenseUpdatedVoice(String name, String amount) {
    return '$name updated: $amount TL';
  }

  @override
  String monthlyBudgetUpdateConfirm(String amount) {
    return 'Update your monthly budget to $amount TL?';
  }

  @override
  String maxAmountError(String amount) {
    return 'Maximum amount can be $amount TL';
  }

  @override
  String descriptionMaxLength(int maxLength) {
    return 'Description can be at most $maxLength characters';
  }

  @override
  String itemNameRequired(String itemType) {
    return '$itemType name is required';
  }

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String quantityTooSmall(String min) {
    return 'Quantity is too small (min: $min)';
  }

  @override
  String quantityTooLarge(String max) {
    return 'Quantity is too large (max: $max)';
  }

  @override
  String maxDecimalPlaces(int count) {
    return 'You can enter at most $count decimal places';
  }

  @override
  String maxBalanceError(String amount) {
    return 'Maximum amount can be $amount';
  }

  @override
  String minLimitError(String amount) {
    return 'Minimum limit must be $amount TL';
  }

  @override
  String maxLimitError(String amount) {
    return 'Maximum limit can be $amount';
  }

  @override
  String get streakInfo => 'Streak Information';

  @override
  String get howStreakWorks => 'How Streak Works?';

  @override
  String get editPhotoBtn => 'Edit Photo';

  @override
  String cropError(String error) {
    return 'Crop error: $error';
  }

  @override
  String saveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get myPaymentMethods => 'My Payment Methods';

  @override
  String get myIncomesTitle => 'My Incomes';

  @override
  String get enterValidAmountAndName => 'Please enter a valid amount and name';

  @override
  String get tryAgainAction => 'Try Again';

  @override
  String get incomeRecycleBin => 'Income Recycle Bin';

  @override
  String get incomeCategories => 'Income Categories';

  @override
  String get incomeSettingsTitle => 'Income Settings';

  @override
  String get recurringIncomesTitle => 'Recurring Incomes';

  @override
  String get expenseCategoriesTitle => 'Expense Categories';

  @override
  String get myExpensesTitle => 'My Expenses';

  @override
  String get assetRecycleBin => 'Asset Recycle Bin';

  @override
  String get assetDetail => 'Asset Detail';

  @override
  String get deleteAsset => 'Delete Asset';

  @override
  String get myAssets => 'My Assets';

  @override
  String get analysisAndReports => 'Analysis and Reports';

  @override
  String get expenseTab => 'Expense';

  @override
  String get incomeTab => 'Income';

  @override
  String get assetTab => 'Asset';

  @override
  String get widgetCreationError =>
      'An error occurred while creating the widget.';

  @override
  String appInitializationFailedMsg(String error) {
    return 'Failed to start the application\\n$error';
  }

  @override
  String get manageFinancialTransactions =>
      'Manage your financial transactions';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get otherTransactions => 'Other Transactions';

  @override
  String get moneyTransfer => 'Money Transfer';

  @override
  String get assetsSubtitle => 'Gold, currency, crypto and other assets';

  @override
  String get paymentMethodsSubtitle => 'Bank cards and cash accounts';

  @override
  String get analysisSubtitle => 'Expense and income statistics';

  @override
  String get transferSubtitle => 'Money transfer between accounts';

  @override
  String get cardType => 'Card Type';

  @override
  String get nameLabel => 'Name';

  @override
  String get bankCardName => 'Bank/Card Name';

  @override
  String get lastFourDigits => 'Last 4 Digits (Optional)';

  @override
  String get cardLimit => 'Card Limit';

  @override
  String get cardColor => 'Card Color';

  @override
  String get swipeForMoreColors => 'Swipe right for more colors →';

  @override
  String get nameMustContainLetter => 'Name must contain at least one letter';

  @override
  String get mustBeFourDigits => 'Must be exactly 4 digits';

  @override
  String get invalidCardNumber => 'Invalid card number';

  @override
  String get pleaseEnterDebt => 'Please enter debt amount (can be 0)';

  @override
  String get pleaseEnterBalance => 'Please enter balance';

  @override
  String get maxAmountLimit => 'Maximum amount can be 100 million ₺';

  @override
  String get limitCannotBeLessThanDebt =>
      'Limit cannot be less than current debt';

  @override
  String get minLimitWarning => 'Minimum limit is 100 ₺';

  @override
  String get foodAndCafe => 'Food & Cafe';

  @override
  String get groceryAndSnacks => 'Grocery & Snacks';

  @override
  String get vehicleAndTransport => 'Vehicle & Transport';

  @override
  String get giftAndSpecial => 'Gift & Special';

  @override
  String get fixedExpenses => 'Fixed Expenses';

  @override
  String get categoryOther => 'Other';

  @override
  String get salary => 'Salary';

  @override
  String get freelance => 'Freelance';

  @override
  String get investment => 'Investment';

  @override
  String get rentalIncome => 'Rental Income';

  @override
  String get gift => 'Gift';

  @override
  String get ziraatBank => 'Ziraat Bank';

  @override
  String get searchPaymentMethod => 'Search payment method...';

  @override
  String get trashBin => 'Trash Bin';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get noPaymentMethodYet => 'No payment method yet';

  @override
  String get startByAddingFirstPaymentMethod =>
      'Start by adding your first payment method';

  @override
  String get debt => 'Debt';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get addCard => 'Add Card';

  @override
  String get cashWalletExample => 'e.g. Wallet';

  @override
  String get ziraatBankExample => 'e.g. Ziraat Bank';

  @override
  String get expensesThisMonth => 'Expenses this month';

  @override
  String get incomesThisMonth => 'Incomes this month';

  @override
  String get totalLimit => 'Total Limit';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get todayLabel => 'Today';

  @override
  String get less => 'less';

  @override
  String get more => 'more';

  @override
  String get dailyAverageLabel => 'DAILY AVERAGE';

  @override
  String get budgetStatusLabel => 'BUDGET STATUS';

  @override
  String get totalExpenseLabel => 'TOTAL EXPENSE';

  @override
  String get totalIncomeLabel => 'TOTAL INCOME';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get validAmountRequired => 'Please enter a valid amount';

  @override
  String get expenseNameHint => 'What did you buy? (e.g. Coffee)';

  @override
  String get updateButton => 'Update';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get movedToTrash => 'moved to trash';

  @override
  String get restored => 'restored';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get added => 'added';

  @override
  String monthlyIncomeCount(int count) {
    return '$count income records this month';
  }

  @override
  String get incomeNameLabel => 'Income Name';

  @override
  String get incomeNameHint => 'Where did it come from? (e.g. Loan Repayment)';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get searchAsset => 'Search asset...';

  @override
  String get totalAssetLabel => 'TOTAL ASSET';

  @override
  String totalAssetCount(int count) {
    return 'Total $count asset records';
  }

  @override
  String get profilePhotoUpdated => 'Profile photo updated';

  @override
  String profilePhotoUpdateFailed(String error) {
    return 'Failed to update profile photo: $error';
  }

  @override
  String get budgetLimitSaved => 'Budget limit saved!';

  @override
  String get categoryListUpdated => 'Category list updated!';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get trashBinEmptied => 'Trash bin emptied.';

  @override
  String get incomeRestored => 'Income restored ';

  @override
  String get incomePermanentlyDeleted => 'Income permanently deleted ';

  @override
  String get allIncomesRestored => 'All incomes restored ';

  @override
  String expenseDeletedWithName(String name) {
    return '$name deleted';
  }

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address.';

  @override
  String biometricAuthFailed(String error) {
    return 'Biometric authentication failed: $error';
  }

  @override
  String get emptyTrashBin => 'Empty Trash Bin';

  @override
  String get confirmEmptyTrashBin =>
      'All deleted items will be permanently destroyed. Are you sure?';

  @override
  String get restoreAll => 'Restore All';

  @override
  String confirmRestoreAllExpenses(int count) {
    return '$count expenses will be restored. Do you confirm?';
  }

  @override
  String confirmRestoreAllIncomes(int count) {
    return '$count incomes will be restored. Do you confirm?';
  }

  @override
  String confirmRestoreAllAssets(int count) {
    return '$count assets will be restored. Do you confirm?';
  }

  @override
  String get noDeletedIncomes => 'No deleted incomes.';

  @override
  String get noDeletedAssets => 'Trash bin is empty.';

  @override
  String expenseAddedDetailed(String name, String amount) {
    return 'Expense added: $name - $amount ₺';
  }

  @override
  String accountDeleteFailed(String error) {
    return 'Error deleting account: $error';
  }

  @override
  String get profileAccountDeleted =>
      'Your account has been deleted successfully';

  @override
  String get janShort => 'JAN';

  @override
  String get febShort => 'FEB';

  @override
  String get marShort => 'MAR';

  @override
  String get aprShort => 'APR';

  @override
  String get mayShort => 'MAY';

  @override
  String get junShort => 'JUN';

  @override
  String get julShort => 'JUL';

  @override
  String get augShort => 'AUG';

  @override
  String get sepShort => 'SEP';

  @override
  String get octShort => 'OCT';

  @override
  String get novShort => 'NOV';

  @override
  String get decShort => 'DEC';

  @override
  String get transferPageTitle => 'Money Transfer';

  @override
  String get pleaseSelectAccounts => 'Please select accounts';

  @override
  String get cannotTransferToSameAccount =>
      'Cannot transfer to the same account';

  @override
  String get noDebtOnCreditCard =>
      'There is no debt on this credit card. Transfer cannot be made.';

  @override
  String creditCardDebtLimit(String amount) {
    return 'Credit card debt is $amount, you can send at most this much';
  }

  @override
  String scheduledTransferMessage(
    String fromAccount,
    String toAccount,
    String amount,
    String date,
  ) {
    return '$fromAccount ➔ $toAccount\n$amount scheduled to be transferred on $date.';
  }

  @override
  String completedTransferMessage(
    String fromAccount,
    String toAccount,
    String amount,
    String time,
  ) {
    return '$fromAccount ➔ $toAccount\n$amount successfully transferred at $time.';
  }

  @override
  String get sender => 'SENDER';

  @override
  String get receiver => 'RECEIVER';

  @override
  String get amountToSend => 'Amount to Send';

  @override
  String get enterAmountHint => 'Enter amount';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get maximumAmountExceeded => 'Maximum amount exceeded';

  @override
  String payAllDebt(String amount) {
    return 'Pay all debt ($amount)';
  }

  @override
  String scheduledTransferInfo(String date, String time) {
    return 'This transfer will be executed on $date at $time.';
  }

  @override
  String get scheduleTransferButton => 'Schedule Transfer';

  @override
  String get makeTransferButton => 'Make Transfer';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String pendingTransfers(int count) {
    return '⏳ Pending ($count)';
  }

  @override
  String failedTransfers(int count) {
    return '✗ Failed ($count)';
  }

  @override
  String completedTransfersLabel(int count) {
    return '✓ Completed ($count)';
  }

  @override
  String get noTransferHistory => 'No transfer history yet';

  @override
  String get unknownAccount => 'Unknown';

  @override
  String get downloadReportTooltip => 'Download Report';

  @override
  String get noExpenseDataForThisMonth => 'No expense data for this month.';

  @override
  String get highestExpense => 'Highest expense';

  @override
  String get categoryDistribution => 'Category Distribution';

  @override
  String get noIncomeDataForThisMonth => 'No income data for this month.';

  @override
  String get highestIncome => 'Highest income';

  @override
  String get noAssetsAddedYet => 'No assets added yet.';

  @override
  String get mostValuableType => 'Most valuable type';

  @override
  String get assetTypes => 'Asset Types';

  @override
  String get distributionByPaymentMethod => 'Distribution By Payment Method';

  @override
  String get otherStr => 'Other';

  @override
  String get pdfReportTitle => 'PDF Report';

  @override
  String get selectSectionsToInclude => 'Select sections to include';

  @override
  String get reportPeriod => 'Report Period';

  @override
  String get reportOptions => 'Report Options';

  @override
  String get selectAll => 'All';

  @override
  String get includeAllVisualSummaries => 'Include all visual summary options';

  @override
  String get financialSummaryCards => 'Financial Summary Cards';

  @override
  String get expenseIncomeAssetTotals => 'Expense, income and asset totals';

  @override
  String get netStatusCards => 'Net Status Cards';

  @override
  String get monthlyNetStatusAndSavings =>
      'Monthly net status and savings rate';

  @override
  String get pieChartAndDistribution => 'Pie Chart and Distribution';

  @override
  String get expenseIncomeAssetDistribution =>
      'Expense/income/asset distribution graph';

  @override
  String get budgetStatusTitle => 'Budget Status';

  @override
  String get budgetProgressBarAndLimit => 'Budget progress bar and limit info';

  @override
  String get statisticsCards => 'Statistics Cards';

  @override
  String get dailyAverageAndPreviousMonthComparison =>
      'Daily average and previous month comparison';

  @override
  String get top5Expenses => 'Top 5 Expenses';

  @override
  String get top5ExpensesListDescription => 'List of top 5 expenses by amount';

  @override
  String get tablesToIncludeInReport => 'Tables to Include in Report';

  @override
  String get monthlyExpenseDetails => 'Monthly expense details';

  @override
  String get monthlyIncomeDetails => 'Monthly income details';

  @override
  String get assetListAndValues => 'Asset list and values';

  @override
  String get selectAtLeastOneTable => 'You must select at least one table';

  @override
  String get preparing => 'Preparing...';

  @override
  String get createAndSharePdf => 'Create and Share PDF';

  @override
  String get daysText => 'days';

  @override
  String get dailyStreak => 'Daily Streak 🔥';

  @override
  String get freezeUsed => 'Freeze used';

  @override
  String get totalLogins => 'Total Logins';

  @override
  String get streakFreeze => 'Streak Freeze';

  @override
  String get protectsStreakEvenIfSkipped =>
      'Protects your streak even if you skip a day';

  @override
  String get streakFreezeUsedToday => 'Streak freeze used today!';

  @override
  String nextFreezeIn(int days) {
    return 'Next freeze in $days days';
  }

  @override
  String nextBadgeIs(String badgeName) {
    return 'Next Badge: $badgeName';
  }

  @override
  String daysRemainingForBadge(int remaining) {
    return '$remaining days left';
  }

  @override
  String get badges => 'Badges';

  @override
  String get badgeFireStarterName => 'Fire Starter';

  @override
  String get badgeFireStarterDesc => 'You logged in for 3 consecutive days!';

  @override
  String get badgeWeeklyStarName => 'Weekly Star';

  @override
  String get badgeWeeklyStarDesc => 'You logged in for 7 consecutive days!';

  @override
  String get badgeSteadyName => 'Steady';

  @override
  String get badgeSteadyDesc => 'You logged in every day for 2 weeks!';

  @override
  String get badgeMonthlyChampName => 'Monthly Champ';

  @override
  String get badgeMonthlyChampDesc => 'You logged in every day for 1 month!';

  @override
  String get badgeSuperStreakName => 'Super Streak';

  @override
  String get badgeSuperStreakDesc => 'You logged in every day for 2 months!';

  @override
  String get badgeStreakMasterName => 'Streak Master';

  @override
  String get badgeStreakMasterDesc => 'You logged in for 100 consecutive days!';

  @override
  String get badgeLegendName => 'Legend';

  @override
  String get badgeLegendDesc => 'You logged in every day for 1 year!';

  @override
  String get achievements => 'Achievements';

  @override
  String get dShort => 'd';

  @override
  String get earned => '✓ Earned';

  @override
  String requiredStreakDays(int requiredStreak) {
    return '$requiredStreak day streak required';
  }

  @override
  String get streakWhatIsIt => 'What is Streak?';

  @override
  String get streakDescription =>
      'Streak is a counter showing how many consecutive days you opened the app.\n\n• Each day you open the app, your streak increases by 1\n• If you skip a day, your streak resets\n• Multiple logins in a day count as 1 login\n\nThe streak system encourages you to track your financial habits and stay organized.';

  @override
  String get streakFreezeWhatIsIt => 'What is Streak Freeze?';

  @override
  String get streakFreezeDescription =>
      'Streak Freeze is a special feature that protects your streak even if you forget to open the app for a day.\n\n• New users start with 1 streak freeze\n• You earn 1 new freeze for every 7 day streak\n• You can stack maximum 3 freezes\n• Used automatically if you skip 1 day\n• Streak resets if you skip 2 or more days';

  @override
  String get badgesDescription =>
      'You earn badges when you reach specific streak goals:\n\n🔥 Fire Starter - 3 day streak\n⭐ Weekly Star - 7 day streak\n💪 Determined - 14 day streak\n🏅 Monthly Champion - 30 day streak\n💎 Super Streak - 60 day streak\n👑 Streak Master - 100 day streak\n🏆 Legend - 365 day streak\n\nBadges are permanent, they don\'t disappear even if your streak resets!';

  @override
  String get achievementsDescription =>
      'Achievements are special goals you earn while using the app:\n\n✓ First Step - Open the app for the first time\n✓ Streak Starter - Create a 3 day streak\n✓ Streak Freeze - Use a streak freeze\n✓ Regular User - Login for a total of 10 days\n✓ Continuity Master - Create a 30 day streak\n✓ Financial Guru - Login for a total of 100 days\n\nYou\'ll see a green checkmark when you complete achievements.';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsDescription =>
      'You can see the following statistics on the streak page:\n\n📊 Current Streak - Your current consecutive logins\n🏆 Longest Streak - Your highest streak so far\n📅 Total Logins - Total number of days you opened the app\n❄️ Streak Freeze - Number of freezes you have\n\nThese statistics help you track your progress.';

  @override
  String get tipsTitle => 'Tips';

  @override
  String get tipsDescription =>
      'Some tips to protect your streak:\n\n💡 Make it a habit to open the app at the same time every day\n💡 If notifications are on, you can receive daily reminders\n💡 Save your streak freezes for holidays or busy days\n💡 Set goals like 7, 14, 30 days\n💡 Try to break your longest streak record\n\nRegular financial tracking means better money management!';

  @override
  String get streakSystem => 'Streak System';

  @override
  String get streakSystemSubtitle =>
      'Improve your financial habits and\nearn regular tracking rewards!';

  @override
  String get cropPhoto => 'Crop Photo';

  @override
  String get continueText => 'Continue';

  @override
  String get rotateLeft90 => '90° Left';

  @override
  String get rotateRight90 => '90° Right';

  @override
  String get flipHorizontal => 'Horizontal';

  @override
  String get flipVertical => 'Vertical';

  @override
  String get compare => 'Compare';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get resetAll => 'Reset All';

  @override
  String get rotation => 'Rotation';

  @override
  String get grid => 'Grid';

  @override
  String get apply => 'Apply';

  @override
  String get filters => 'Filters';

  @override
  String get adjustments => 'Adjustments';

  @override
  String get transform => 'Transform';

  @override
  String get text => 'Text';

  @override
  String get emoji => 'Emoji';

  @override
  String get frame => 'Frame';

  @override
  String get intensity => 'Intensity';

  @override
  String get brightness => 'Brightness';

  @override
  String get contrast => 'Contrast';

  @override
  String get saturation => 'Saturation';

  @override
  String get temperature => 'Temperature';

  @override
  String get tint => 'Tint';

  @override
  String get shadows => 'Shadows';

  @override
  String get highlights => 'Highlights';

  @override
  String get vignette => 'Vignette';

  @override
  String get selectProfilePhoto => 'Select Profile Photo';

  @override
  String get selectProfilePhotoDesc =>
      'You can change your profile picture by choosing a photo from your gallery or taking a picture with your camera.';

  @override
  String get camera => 'Camera';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get gallery => 'Gallery';

  @override
  String get choosePhoto => 'Choose Photo';

  @override
  String get day => 'day';

  @override
  String get securityPin => 'Security PIN';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get firstStep => 'First Step';

  @override
  String get firstStepDesc => 'Opened the app for the first time';

  @override
  String get streakStarter => 'Streak Starter';

  @override
  String get streakStarterDesc => 'Create a 3 day streak';

  @override
  String get streakFreezeDescAction => 'Use a streak freeze';

  @override
  String get regularUser => 'Regular User';

  @override
  String get regularUserDesc => 'Login for a total of 10 days';

  @override
  String get continuityMaster => 'Continuity Master';

  @override
  String get continuityMasterDesc => 'Create a 30 day streak';

  @override
  String get financialGuru => 'Financial Guru';

  @override
  String get financialGuruDesc => 'Login for a total of 100 days';

  @override
  String get typeText => 'Type text...';

  @override
  String get sizeLabel => 'Size:';

  @override
  String get thickness => 'Thickness';

  @override
  String get rotateLeft => 'Left';

  @override
  String get rotateRight => 'Right';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get vertical => 'Vertical';

  @override
  String get signupSubtitleExpense =>
      'Sign up to start managing your expenses.';

  @override
  String get emailLabel => 'Email';

  @override
  String get pinLabel => 'PIN (4-6 Digits)';

  @override
  String get securityQuestion => 'Security Question';

  @override
  String get securityQuestionAnswer => 'Security Question Answer';

  @override
  String get signupSuccess => 'Registration successful! Welcome! 🎉';

  @override
  String get signupError =>
      'An error occurred during registration. Please try again.';

  @override
  String get loginWithAnotherAccount => 'Login with another account';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get verifyIdentity => 'Verify your identity to log in';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get tapAndSpeak => 'Tap the microphone and speak';

  @override
  String get voiceExampleIncome => 'Example: \"500 dollars salary\"';

  @override
  String get heard => 'Heard: ';

  @override
  String get amountTl => 'Amount (₺)';

  @override
  String get incomeName => 'Income Name';

  @override
  String get orDivider => 'or';

  @override
  String get biometricLoginFailed => 'Biometric login failed';

  @override
  String get enterRegisteredEmail => 'Enter your registered email address';

  @override
  String get userNotFoundWithEmail => 'No user found with this email address';

  @override
  String get noSecurityQuestionDefined =>
      'No security question defined for this account';

  @override
  String get wrongAnswerTryAgain => 'Wrong answer! Please try again.';

  @override
  String get setNewPin => 'Set New PIN';

  @override
  String get enterNewPinDigits => 'Enter your new 4-6 digit PIN code';

  @override
  String get pinUpdatedSuccess => 'PIN updated successfully! ✓';

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get pleaseEnterAnswer => 'Please enter your answer';

  @override
  String get pleaseEnterNewPin => 'Please enter a new PIN';

  @override
  String get pinMinDigits => 'PIN must be at least 4 digits';

  @override
  String get pinOnlyNumbers => 'PIN must contain only numbers';

  @override
  String get pleaseRepeatPin => 'Please repeat the PIN';

  @override
  String get pinRepeatLabel => 'Repeat PIN';

  @override
  String get continueButton => 'Continue';

  @override
  String get verifyButton => 'Verify';

  @override
  String get updatePinButton => 'Update PIN';

  @override
  String expenseDeleted(String name) {
    return '$name deleted';
  }

  @override
  String updateExpenseAmountMsg(String amount) {
    return 'Do you want to update the last expense to $amount ₺?';
  }

  @override
  String get lastWeek => 'Last week';

  @override
  String get users => 'Users';

  @override
  String get noRegisteredUsers => 'No registered users.';

  @override
  String get addNewUser => 'Add New User';
}
