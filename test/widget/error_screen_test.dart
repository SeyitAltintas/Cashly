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
    }

    testWidgets('Temel error screen render edilmeli', (tester) async {
      await pumpErrorScreen(tester);

      // Hata ikonu görünmeli
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

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
      expect(find.byIcon(Icons.refresh), findsOneWidget);

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

      // Teknik Detaylar expansion tile görünmeli
      expect(find.text('Teknik Detaylar'), findsOneWidget);

      // Expansion tile'ı aç
      await tester.tap(find.text('Teknik Detaylar'));
      await tester.pumpAndSettle();

      // Hata detayı görünmeli
      expect(find.textContaining('Test hatası'), findsOneWidget);
    });

    testWidgets('Scaffold doğru background color ile render edilmeli', (
      tester,
    ) async {
      await pumpErrorScreen(tester);

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.backgroundColor, Colors.black);
    });
  });
}
