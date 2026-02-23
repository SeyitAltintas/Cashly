import 'package:get_it/get_it.dart';

// Repository Interfaces (Domain)
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/income/domain/repositories/income_repository.dart';
import '../../features/assets/domain/repositories/asset_repository.dart';
import '../../features/payment_methods/domain/repositories/payment_method_repository.dart';
import '../../features/streak/domain/repositories/streak_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/recurring_repository.dart';

// Repository Implementations (Data)
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/income/data/repositories/income_repository_impl.dart';
import '../../features/assets/data/repositories/asset_repository_impl.dart';
import '../../features/payment_methods/data/repositories/payment_method_repository_impl.dart';
import '../../features/streak/data/repositories/streak_repository_impl.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/recurring_repository_impl.dart';

// Notification Services
import '../services/notification_service.dart';
import '../services/notification_scheduler.dart';
import '../repositories/notification_settings_repository.dart';

// Currency Service
import '../services/currency_service.dart';

// Use Cases
import '../domain/usecases/expense_usecases.dart';
import '../domain/usecases/income_usecases.dart';
import '../domain/usecases/asset_usecases.dart';
import '../domain/usecases/payment_method_usecases.dart';
import '../domain/usecases/streak_usecases.dart';
import '../domain/usecases/dashboard_usecases.dart';

// Controllers
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/expenses/presentation/controllers/expenses_controller.dart';
import '../../features/income/presentation/controllers/incomes_controller.dart';
import '../../features/assets/presentation/controllers/assets_controller.dart';
import '../../features/payment_methods/presentation/controllers/payment_methods_controller.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/analysis/presentation/controllers/analysis_controller.dart';
import '../../features/streak/presentation/controllers/streak_controller.dart';
import '../../features/tools/presentation/controllers/tools_controller.dart';

/// GetIt service locator instance
final getIt = GetIt.instance;

/// Bağımlılıkların zaten kayıtlı olup olmadığını kontrol eder
bool _dependenciesInitialized = false;

/// Tüm bağımlılıkları kaydeder
/// Bu fonksiyon uygulama başlatılırken main.dart'ta çağrılır
Future<void> initializeDependencies() async {
  // Zaten kayıtlıysa tekrar kaydetme (integration testler için)
  if (_dependenciesInitialized) {
    return;
  }
  _dependenciesInitialized = true;

  // ===== NOTIFICATION SERVICES =====

  // Notification Settings Repository
  getIt.registerLazySingleton<NotificationSettingsRepository>(
    () => NotificationSettingsRepository(),
  );

  // Notification Service (singleton)
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Notification Scheduler
  getIt.registerLazySingleton<NotificationScheduler>(
    () => NotificationScheduler(),
  );

  // Currency Service
  getIt.registerLazySingleton<CurrencyService>(() => CurrencyService());

  // ===== REPOSITORIES =====

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // Expense Repository
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl());

  // Income Repository
  getIt.registerLazySingleton<IncomeRepository>(() => IncomeRepositoryImpl());

  // Asset Repository
  getIt.registerLazySingleton<AssetRepository>(() => AssetRepositoryImpl());

  // Payment Method Repository
  getIt.registerLazySingleton<PaymentMethodRepository>(
    () => PaymentMethodRepositoryImpl(),
  );

  // Streak Repository
  getIt.registerLazySingleton<StreakRepository>(() => StreakRepositoryImpl());

  // Settings Repository
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(),
  );

  // Category Repository (Merkezi kategori yönetimi)
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(),
  );

  // Recurring Repository (Tekrarlayan işlemler)
  getIt.registerLazySingleton<RecurringRepository>(
    () => RecurringRepositoryImpl(),
  );

  // ===== USE CASES =====

  // Expense Use Cases
  getIt.registerLazySingleton<GetExpenses>(
    () => GetExpenses(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<SaveExpenses>(
    () => SaveExpenses(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<AddExpense>(
    () => AddExpense(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<UpdateExpense>(
    () => UpdateExpense(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<DeleteExpense>(
    () => DeleteExpense(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<GetBudget>(
    () => GetBudget(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<SaveBudget>(
    () => SaveBudget(getIt<ExpenseRepository>()),
  );

  // Income Use Cases
  getIt.registerLazySingleton<GetIncomes>(
    () => GetIncomes(getIt<IncomeRepository>()),
  );
  getIt.registerLazySingleton<SaveIncomes>(
    () => SaveIncomes(getIt<IncomeRepository>()),
  );
  getIt.registerLazySingleton<AddIncome>(
    () => AddIncome(getIt<IncomeRepository>()),
  );
  getIt.registerLazySingleton<UpdateIncome>(
    () => UpdateIncome(getIt<IncomeRepository>()),
  );
  getIt.registerLazySingleton<DeleteIncome>(
    () => DeleteIncome(getIt<IncomeRepository>()),
  );

  // Asset Use Cases
  getIt.registerLazySingleton<GetAssets>(
    () => GetAssets(getIt<AssetRepository>()),
  );
  getIt.registerLazySingleton<SaveAssets>(
    () => SaveAssets(getIt<AssetRepository>()),
  );
  getIt.registerLazySingleton<AddAsset>(
    () => AddAsset(getIt<AssetRepository>()),
  );
  getIt.registerLazySingleton<UpdateAsset>(
    () => UpdateAsset(getIt<AssetRepository>()),
  );
  getIt.registerLazySingleton<DeleteAsset>(
    () => DeleteAsset(getIt<AssetRepository>()),
  );

  // Payment Method Use Cases
  getIt.registerLazySingleton<GetPaymentMethods>(
    () => GetPaymentMethods(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<SavePaymentMethods>(
    () => SavePaymentMethods(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<AddPaymentMethod>(
    () => AddPaymentMethod(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<UpdatePaymentMethod>(
    () => UpdatePaymentMethod(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<DeletePaymentMethod>(
    () => DeletePaymentMethod(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<UpdateBalance>(
    () => UpdateBalance(getIt<PaymentMethodRepository>()),
  );

  // Transfer Use Cases
  getIt.registerLazySingleton<GetTransfers>(
    () => GetTransfers(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<SaveTransfers>(
    () => SaveTransfers(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<AddTransfer>(
    () => AddTransfer(getIt<PaymentMethodRepository>()),
  );

  // Streak Use Cases
  getIt.registerLazySingleton<GetStreakData>(
    () => GetStreakData(getIt<StreakRepository>()),
  );
  getIt.registerLazySingleton<CheckAndUpdateStreak>(
    () => CheckAndUpdateStreak(),
  );
  getIt.registerLazySingleton<SaveStreakData>(() => SaveStreakData());
  getIt.registerLazySingleton<UseFreeze>(
    () => UseFreeze(getIt<StreakRepository>()),
  );

  // Dashboard Use Cases
  getIt.registerLazySingleton<CalculateTotalBalance>(
    () => CalculateTotalBalance(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<CalculateTotalDebt>(
    () => CalculateTotalDebt(getIt<PaymentMethodRepository>()),
  );
  getIt.registerLazySingleton<GetMonthlyExpense>(
    () => GetMonthlyExpense(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<GetMonthlyIncome>(
    () => GetMonthlyIncome(getIt<IncomeRepository>()),
  );
  getIt.registerLazySingleton<GetFinancialSummary>(
    () => GetFinancialSummary(
      expenseRepository: getIt<ExpenseRepository>(),
      incomeRepository: getIt<IncomeRepository>(),
      paymentMethodRepository: getIt<PaymentMethodRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetActivePaymentMethods>(
    () => GetActivePaymentMethods(getIt<PaymentMethodRepository>()),
  );

  // ===== CONTROLLERS =====

  // Auth Controller - her seferinde yeni instance oluştur
  getIt.registerFactory<AuthController>(
    () => AuthController(getIt<AuthRepository>()),
  );

  // Expenses Controller - userId parametresi ile factory
  getIt.registerFactoryParam<ExpensesController, String, void>(
    (userId, _) => ExpensesController(
      expenseRepository: getIt<ExpenseRepository>(),
      paymentMethodRepository: getIt<PaymentMethodRepository>(),
      userId: userId,
    ),
  );

  // Incomes Controller - userId parametresi ile factory
  getIt.registerFactoryParam<IncomesController, String, void>(
    (userId, _) => IncomesController(
      incomeRepository: getIt<IncomeRepository>(),
      paymentMethodRepository: getIt<PaymentMethodRepository>(),
      userId: userId,
    ),
  );

  // Assets Controller - userId parametresi ile factory
  getIt.registerFactoryParam<AssetsController, String, void>(
    (userId, _) => AssetsController(
      assetRepository: getIt<AssetRepository>(),
      userId: userId,
    ),
  );

  // Payment Methods Controller - userId parametresi ile factory
  getIt.registerFactoryParam<PaymentMethodsController, String, void>(
    (userId, _) => PaymentMethodsController(
      paymentMethodRepository: getIt<PaymentMethodRepository>(),
      userId: userId,
    ),
  );

  // Dashboard Controller - singleton (tüm veriler dışarıdan set edilir)
  getIt.registerLazySingleton<DashboardController>(() => DashboardController());

  // Analysis Controller - singleton (tüm veriler dışarıdan set edilir)
  getIt.registerLazySingleton<AnalysisController>(() => AnalysisController());

  // Streak Controller - singleton (tüm veriler dışarıdan set edilir)
  getIt.registerLazySingleton<StreakController>(() => StreakController());

  // Tools Controller - singleton
  getIt.registerLazySingleton<ToolsController>(() => ToolsController());
}
