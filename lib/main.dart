import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'core/services/database_helper.dart';
import 'core/services/error_logger_service.dart';
import 'core/services/haptic_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/locale_manager.dart';
import 'features/streak/data/services/streak_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_manager.dart';
import 'core/widgets/error_screen.dart';
import 'core/di/injection_container.dart';
import 'core/services/price_cache_service.dart';
import 'core/services/currency_service.dart';
import 'core/services/network_service.dart';
import 'core/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/services/secure_storage_service.dart';

import 'core/widgets/fallback_error_widget.dart';
import 'core/widgets/offline_sensor.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ====== BAŞLATMA SIRALAMASI ======
      // Önce Hive'ı başlatıyoruz, çünkü erken fırlatılan bir hatada 
      // ErrorLoggerService loglamak için Hive'ı kullanacaktır.
      await Hive.initFlutter();
      await SecureStorageService.openSecureBox('settings');

      // ====== FIREBASE BAŞLATMA ======
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        if (e is FirebaseException && e.code == 'duplicate-app') {
          debugPrint('Firebase [DEFAULT] zaten arka planda başlatılmış, devam ediliyor...');
        } else {
          rethrow;
        }
      }

      // Crashlytics'i etkinleştir
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Firestore offline persistence (internetsiz çalışma desteği)
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Google Fonts: İnternetten font indirmeyi kapat
      GoogleFonts.config.allowRuntimeFetching = false;

      // Flutter framework hatalarını yakala → Crashlytics + ErrorLogger
      FlutterError.onError = (FlutterErrorDetails details) {
        // Crashlytics'e gönder (fatal Flutter error)
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        
        FlutterError.presentError(details);
        
        ErrorLoggerService.logError(
          'FlutterError: ${details.exceptionAsString()}',
          stackTrace: details.stack?.toString(),
        );

        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('❌ FLUTTER ERROR');
        debugPrint('Exception: ${details.exceptionAsString()}');
        debugPrint('Stack: ${details.stack}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      };

      // Platform hataları (Dart async, isolate vb.) → Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Widget render hatalarında FallbackErrorWidget göster
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return FallbackErrorWidget(details: details);
      };

      try {
        
        await initializeDependencies();
        await ImageCacheService().initialize();
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeManager()),
              ChangeNotifierProvider(create: (_) => LocaleManager()),
              ChangeNotifierProvider.value(value: getIt<CurrencyService>()),
            ],
            child: const CashlyApp(),
          ),
        );
      } catch (e, stackTrace) {
        await ErrorLoggerService.logError('Main Initialization Error: $e', stackTrace: stackTrace.toString());
        
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
      // Crashlytics'e gönder (runZonedGuarded yakaladı)
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      
      ErrorLoggerService.logError('Uncaught RunZonedGuarded Error: $error', stackTrace: stackTrace.toString());
      
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

class _CashlyAppState extends State<CashlyApp> with WidgetsBindingObserver {
  AppRouter? _appRouter;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notificationService = getIt<NotificationService>();
    notificationService.setAppInForeground(state == AppLifecycleState.resumed);
  }

  Future<void> _initializeApp() async {
    try {
      await DatabaseHelper.baslat();
      await HapticService.init();
      await StreakService.initialize();
      await PriceCacheService().init();

      final currencyService = getIt<CurrencyService>();
      await currencyService.init();

      await NetworkService().initialize();

      final notificationService = getIt<NotificationService>();
      await notificationService.initialize();
      await notificationService.requestPermission();

      NotificationService.onNotificationNavigate =
          _handleNotificationNavigation;

      final authController = getIt<AuthController>();
      await authController.checkAuth();

      if (mounted) {
        setState(() {
          _appRouter = AppRouter(authController: authController);
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Başlatma hatası: $e");
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitialized = true;
        });
      }
    }
  }

  void _handleNotificationNavigation(String payload) {
    debugPrint('Handling notification navigation: $payload');

    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigator context bulunamadı');
      return;
    }

    if (payload == 'monthly_summary') {
      debugPrint('Monthly summary notification - navigating to home');
    } else if (payload.startsWith('recurring_')) {
      final transactionId = payload.replaceFirst('recurring_', '');
      debugPrint('Recurring transaction notification: $transactionId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeManager, LocaleManager>(
      builder: (context, themeManager, localeManager, child) {
        if (!_isInitialized) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF0D0D0D),
              body: SizedBox.shrink(),
            ),
          );
        }

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

        return MaterialApp.router(
          title: 'Cashly',
          debugShowCheckedModeBanner: false,
          locale: localeManager.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleManager.supportedLocales,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (final locale in supportedLocales) {
              if (locale.languageCode == deviceLocale?.languageCode) {
                return locale;
              }
            }
            return supportedLocales.first;
          },
          theme: themeManager.currentTheme,
          routerConfig: _appRouter!.router,
          builder: (context, child) {
            return OfflineSensor(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
