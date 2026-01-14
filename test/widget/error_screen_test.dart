import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/error_screen.dart';

void main() {
  group('ErrorScreen Testleri', () {
    testWidgets('Temel error screen render edilmeli', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ErrorScreen()));

      // Hata ikonu görünmeli
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Başlık görünmeli
      expect(find.text('Bir Hata Oluştu'), findsOneWidget);

      // Varsayılan mesaj görünmeli
      expect(
        find.textContaining('Beklenmedik bir hata meydana geldi'),
        findsOneWidget,
      );
    });

    testWidgets('Özel hata mesajı gösterilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorScreen(errorMessage: 'Özel hata mesajı burada'),
        ),
      );

      expect(find.text('Özel hata mesajı burada'), findsOneWidget);
    });

    testWidgets('Tekrar dene butonu gösterilmeli ve çalışmalı', (tester) async {
      int retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(home: ErrorScreen(onRetry: () => retryCount++)),
      );

      // Tekrar dene butonu görünmeli
      expect(find.text('Tekrar Dene'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Butona tıkla
      await tester.tap(find.text('Tekrar Dene'));
      expect(retryCount, 1);
    });

    testWidgets('onRetry null ise buton gösterilmemeli', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ErrorScreen()));

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

      await tester.pumpWidget(
        MaterialApp(home: ErrorScreen(errorDetails: errorDetails)),
      );

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
      await tester.pumpWidget(const MaterialApp(home: ErrorScreen()));

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.backgroundColor, Colors.black);
    });
  });
}
