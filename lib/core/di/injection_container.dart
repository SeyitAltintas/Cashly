import 'package:get_it/get_it.dart';

// Repository Interfaces (Domain)
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/income/domain/repositories/income_repository.dart';
import '../../features/assets/domain/repositories/asset_repository.dart';
import '../../features/payment_methods/domain/repositories/payment_method_repository.dart';
import '../../features/streak/domain/repositories/streak_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

// Repository Implementations (Data)
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/income/data/repositories/income_repository_impl.dart';
import '../../features/assets/data/repositories/asset_repository_impl.dart';
import '../../features/payment_methods/data/repositories/payment_method_repository_impl.dart';
import '../../features/streak/data/repositories/streak_repository_impl.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';

// Controllers
import '../../features/auth/presentation/controllers/auth_controller.dart';

/// GetIt service locator instance
final getIt = GetIt.instance;

/// Tüm bağımlılıkları kaydeder
/// Bu fonksiyon uygulama başlatılırken main.dart'ta çağrılır
Future<void> initializeDependencies() async {
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

  // ===== CONTROLLERS =====

  // Auth Controller - her seferinde yeni instance oluştur
  getIt.registerFactory<AuthController>(
    () => AuthController(getIt<AuthRepository>()),
  );
}
