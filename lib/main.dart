import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/database_helper.dart';
import 'core/services/haptic_service.dart';
import 'features/streak/data/services/streak_service.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/data/initialize_default_user.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_manager.dart';
import 'core/widgets/error_screen.dart';
import 'core/di/injection_container.dart';
import 'core/services/price_cache_service.dart';

void main() async {
  // Global error handling - tüm beklenmedik hataları yakala
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Flutter framework hatalarını yakala
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('❌ FLUTTER ERROR');
        debugPrint('Exception: ${details.exceptionAsString()}');
        debugPrint('Stack: ${details.stack}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      };

      // Widget render hatalarında ErrorScreen göster
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return ErrorScreen(
          errorDetails: details,
          errorMessage: 'Widget oluşturulurken bir hata oluştu.',
        );
      };

      try {
        await Hive.initFlutter();
        // DI container'ı başlat
        await initializeDependencies();
        runApp(
          ChangeNotifierProvider(
            create: (_) => ThemeManager(),
            child: const CashlyApp(),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('HATA: Uygulama başlatılırken bir sorun oluştu: $e');
        debugPrint('Stack Trace: $stackTrace');
        runApp(
          MaterialApp(
            home: ErrorScreen(errorMessage: 'Uygulama başlatılamadı:\n$e'),
          ),
        );
      }
    },
    (error, stackTrace) {
      // Zone dışı hatalar (async hatalar)
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ UNCAUGHT ERROR');
      debugPrint('Error: $error');
      debugPrint('Stack Trace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    },
  );
}

class CashlyApp extends StatefulWidget {
  const CashlyApp({super.key});

  @override
  State<CashlyApp> createState() => _CashlyAppState();
}

class _CashlyAppState extends State<CashlyApp> {
  AuthController? _authController;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // UI'ın çizilmesi için bekle (büyük asset yükleme süresini kapsasın)
      await Future.delayed(const Duration(milliseconds: 300));

      // Veritabanını başlat
      await DatabaseHelper.baslat();

      // Haptic service ayarlarını başlat
      await HapticService.init();

      // Streak service'ı başlat
      await StreakService.initialize();

      // Fiyat cache service'ı başlat (offline fallback için)
      await PriceCacheService().init();

      // Varsayılan test kullanıcısını oluştur (geçici)
      await initializeDefaultUser();

      // Auth controller'ı DI container'dan al
      final authController = getIt<AuthController>();

      // Auth durumunu kontrol et
      await authController.checkAuth();

      if (mounted) {
        setState(() {
          _authController = authController;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Başlatma hatası: $e");
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitialized =
              true; // Hata olsa bile initialized sayalım ki hata ekranını gösterebilelim
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        // Henüz başlatılmadıysa veya başlatılıyor ise Loading ekranı göster
        if (!_isInitialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/image/seffaflogo.png', height: 70),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        }

        // Başlatma sırasında hata olduysa
        if (_initError != null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Uygulama başlatılamadı",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _initError!,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isInitialized = false;
                            _initError = null;
                          });
                          _initializeApp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              themeManager.currentTheme.colorScheme.primary,
                        ),
                        child: const Text(
                          "Tekrar Dene",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Başarılı başlatma
        return MaterialApp(
          title: 'Cashly',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr', 'TR')],
          theme: themeManager.currentTheme,
          home: AuthWrapper(authController: _authController!),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthController authController;

  const AuthWrapper({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, child) {
        if (authController.isLoading) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return authController.currentUser != null
            ? AnaSayfa(authController: authController)
            : LoginPage(authController: authController);
      },
    );
  }
}
