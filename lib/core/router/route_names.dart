/// Route isimleri sabitleri
/// Type-safe navigasyon için kullanılır
abstract class RouteNames {
  // Splash
  static const String splash = 'splash';

  // Auth
  static const String login = 'login';

  // Ana Navigasyon (Bottom Nav)
  static const String tools = 'tools';
  static const String dashboard = 'dashboard';
  static const String profile = 'profile';

  // Features - Ana Sayfalar
  static const String expenses = 'expenses';
  static const String addExpense = 'add-expense';
  static const String incomes = 'incomes';
  static const String addIncome = 'add-income';
  static const String assets = 'assets';
  static const String addAsset = 'add-asset';
  static const String assetDetail = 'asset-detail';
  static const String paymentMethods = 'payment-methods';
  static const String addPaymentMethod = 'add-payment-method';
  static const String paymentMethodDetail = 'payment-method-detail';
  static const String analysis = 'analysis';
  static const String transfer = 'transfer';

  // Settings
  static const String settings = 'settings';
  static const String appearance = 'appearance';
  static const String hapticSettings = 'haptic-settings';
  static const String animationSettings = 'animation-settings';
  static const String voiceAssistant = 'voice-assistant';
  static const String voiceCommands = 'voice-commands';
  static const String profileSettings = 'profile-settings';
  static const String transferSettings = 'transfer-settings';

  // Kategori Yönetimi
  static const String expenseSettings = 'expense-settings';
  static const String incomeSettings = 'income-settings';
  static const String expenseCategories = 'expense-categories';
  static const String incomeCategories = 'income-categories';

  // Tekrarlayan İşlemler
  static const String recurringTransactions = 'recurring-transactions';

  // Çöp Kutusu
  static const String expenseRecycleBin = 'expense-recycle-bin';
  static const String incomeRecycleBin = 'income-recycle-bin';
  static const String assetRecycleBin = 'asset-recycle-bin';
  static const String paymentMethodRecycleBin = 'payment-method-recycle-bin';
}
