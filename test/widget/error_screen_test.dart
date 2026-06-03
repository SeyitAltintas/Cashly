import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/error_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

void main() {
  group('ErrorScreen Testleri', () {
    Future<void> pumpErrorScreen(
      WidgetTester tester, {
      FlutterErrorDetails? errorDetails,
      String? errorMessage,
      VoidCallback? onRetry,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: ErrorScreen(
            errorDetails: errorDetails,
            errorMessage: errorMessage,
            onRetry: onRetry,
          ),
        ),
      );
      // flutter_animate animasyonlarının pending timer bırakmaması için settle et
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets('Temel error screen render edilmeli', (tester) async {
      await pumpErrorScreen(tester);

      // Widget'ta Icons.emergency_outlined kullanılıyor
      expect(find.byIcon(Icons.emergency_outlined), findsOneWidget);

      // Başlık görünmeli
      expect(find.text('Bir Hata Oluştu'), findsOneWidget);

      // Varsayılan mesaj görünmeli (Kısmi metin arama)
      expect(
        find.textContaining('Beklenmedik bir hata meydana geldi'),
        findsOneWidget,
      );
    });

    testWidgets('Özel hata mesajı gösterilmeli', (tester) async {
      await pumpErrorScreen(tester, errorMessage: 'Özel hata mesajı burada');

      expect(find.text('Özel hata mesajı burada'), findsOneWidget);
    });

    testWidgets('Tekrar dene butonu gösterilmeli ve çalışmalı', (tester) async {
      int retryCount = 0;

      await pumpErrorScreen(tester, onRetry: () => retryCount++);

      // Tekrar dene butonu görünmeli
      expect(find.text('Tekrar Dene'), findsOneWidget);
      // Widget'ta Icons.refresh_rounded kullanılıyor
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      // Butona tıkla
      await tester.tap(find.text('Tekrar Dene'));
      expect(retryCount, 1);
    });

    testWidgets('onRetry null ise buton gösterilmemeli', (tester) async {
      await pumpErrorScreen(tester);

      // Tekrar dene butonu görünmemeli
      expect(find.text('Tekrar Dene'), findsNothing);
    });

    testWidgets('FlutterErrorDetails ile teknik detaylar gösterilebilmeli', (
      tester,
    ) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test hatası'),
        library: 'test library',
        context: ErrorDescription('test context'),
      );

      await pumpErrorScreen(tester, errorDetails: errorDetails);

      // Teknik Detaylar butonu görünmeli
      expect(find.text('Teknik Detaylar'), findsOneWidget);

      // Expansion tile'ı aç
      await tester.tap(find.text('Teknik Detaylar'));
      // Animasyon timer'larını tüket
      await tester.pump(const Duration(seconds: 2));

      // Hata detayı görünmeli
      expect(find.textContaining('Test hatası'), findsOneWidget);

      // Kalan timer'ları temizle
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Scaffold doğru background color ile render edilmeli', (
      tester,
    ) async {
      await pumpErrorScreen(tester);

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      // Widget'ta 0xFF0F1115 kullanılıyor, Colors.black değil
      expect(scaffold.backgroundColor, const Color(0xFF0F1115));
    });
  });
}
