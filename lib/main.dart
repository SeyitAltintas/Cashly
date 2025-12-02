import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/database_helper.dart';
import 'home_page.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_manager.dart';

void main() async {
  // Hata yakalama bloğu
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
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
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'Uygulama başlatılamadı:\n$e',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
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
      await Future.delayed(const Duration(milliseconds: 500));

      // Veritabanını başlat
      await DatabaseHelper.baslat();

      // Auth repository ve controller'ı oluştur
      final authRepository = AuthRepositoryImpl();
      final authController = AuthController(authRepository);

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
                    Image.asset('assets/image/seffaflogo.png', height: 100),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: themeManager.currentTheme.colorScheme.primary,
                    ),
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
        return AnimatedBuilder(
          animation: _authController!,
          builder: (context, child) {
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
              home: _authController!.isLoading
                  ? Scaffold(
                      backgroundColor: Colors.black,
                      body: Center(
                        child: CircularProgressIndicator(
                          color: themeManager.currentTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : _authController!.currentUser != null
                  ? AnaSayfa(authController: _authController!)
                  : LoginPage(authController: _authController!),
            );
          },
        );
      },
    );
  }
}
