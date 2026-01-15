import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';

// Home & Navigation
import '../../features/home/presentation/pages/home_page.dart';

// Route names
import 'route_names.dart';

/// Cashly App Router
/// go_router ile deklaratif navigasyon yönetimi sağlar
class AppRouter {
  final AuthController authController;

  AppRouter({required this.authController});

  /// Ana router yapılandırması
  late final GoRouter router = GoRouter(
    // Auth durumu değiştiğinde router'ı yenile
    refreshListenable: authController,

    // Başlangıç route'u
    initialLocation: '/',

    // Debug modunda navigasyon logları
    debugLogDiagnostics: true,

    // Auth guard - korumalı sayfalara erişim kontrolü
    redirect: _guardRedirect,

    // Hata sayfası
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),

    // Route tanımları
    routes: [
      // ===== AUTH ROUTES =====
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => LoginPage(authController: authController),
      ),

      // ===== ANA SAYFA (Shell Route ile bottom navigation) =====
      // Şimdilik basit bir yapı ile başlıyoruz
      // İleride ShellRoute ile daha karmaşık yapıya geçilebilir
      GoRoute(
        path: '/',
        name: RouteNames.dashboard,
        builder: (context, state) => AnaSayfa(authController: authController),
      ),
    ],
  );

  /// Auth guard redirect fonksiyonu
  /// Kullanıcı giriş yapmamışsa login sayfasına yönlendirir
  String? _guardRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = authController.currentUser != null;
    final isLoading = authController.isLoading;
    final isLoggingIn = state.matchedLocation == '/login';

    // Yükleme sırasında yönlendirme yapma
    if (isLoading) return null;

    // Giriş yapmamış ve login sayfasında değilse -> login'e yönlendir
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    // Giriş yapmış ve login sayfasındaysa -> ana sayfaya yönlendir
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    // Yönlendirme gerekmiyor
    return null;
  }
}

/// go_router extension metodları
/// Kolay navigasyon için yardımcı metodlar
extension GoRouterExtension on BuildContext {
  /// Mevcut route'u değiştir (replace)
  void goNamed(String name, {Map<String, String> pathParameters = const {}}) {
    GoRouter.of(this).goNamed(name, pathParameters: pathParameters);
  }

  /// Yeni route'a git (push)
  void pushNamed(String name, {Map<String, String> pathParameters = const {}}) {
    GoRouter.of(this).pushNamed(name, pathParameters: pathParameters);
  }

  /// Geri git
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}
