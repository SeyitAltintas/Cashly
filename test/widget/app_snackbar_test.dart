// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';

void main() {
  group('AppSnackBar Widget Testleri', () {
    testWidgets('success SnackBar doğru şekilde görüntülenir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AppSnackBar.success(context, 'Başarılı işlem!');
                  },
                  child: const Text('Göster'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Göster'));
      await tester.pumpAndSettle();

      expect(find.text('Başarılı işlem!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('error SnackBar doğru şekilde görüntülenir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AppSnackBar.error(context, 'Hata oluştu!');
                  },
                  child: const Text('Göster'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Göster'));
      await tester.pumpAndSettle();

      expect(find.text('Hata oluştu!'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('warning SnackBar doğru şekilde görüntülenir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AppSnackBar.warning(context, 'Dikkat!');
                  },
                  child: const Text('Göster'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Göster'));
      await tester.pumpAndSettle();

      expect(find.text('Dikkat!'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('info SnackBar doğru şekilde görüntülenir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AppSnackBar.info(context, 'Bilgi mesajı');
                  },
                  child: const Text('Göster'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Göster'));
      await tester.pumpAndSettle();

      expect(find.text('Bilgi mesajı'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    // Timer kullanan asenkron deleted testi
    // fake_async ile timer'lar kontrol altına alınıyor
    testWidgets('deleted SnackBar görüntülenir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AppSnackBar.deleted(context, 'Öğe silindi');
                  },
                  child: const Text('Sil'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Sil'));
      // SnackBar'ın görünmesi için kısa bekle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Öğe silindi'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Timer'ı temizle - 1500ms sonra kapanacak
      await tester.pump(const Duration(milliseconds: 1600));
    });

    testWidgets('hide mevcut SnackBar\'ı gizler', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        AppSnackBar.success(context, 'Test mesajı');
                      },
                      child: const Text('Göster'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AppSnackBar.hide(context);
                      },
                      child: const Text('Gizle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // SnackBar göster
      await tester.tap(find.text('Göster'));
      await tester.pumpAndSettle();
      expect(find.text('Test mesajı'), findsOneWidget);

      // SnackBar gizle
      await tester.tap(find.text('Gizle'));
      await tester.pumpAndSettle();
      expect(find.text('Test mesajı'), findsNothing);
    });

    testWidgets('custom SnackBar özel parametrelerle görüntülenir', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AppSnackBar.custom(
                      context,
                      message: 'Özel mesaj',
                      backgroundColor: Colors.purple,
                      icon: Icons.star,
                    );
                  },
                  child: const Text('Göster'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Göster'));
      await tester.pumpAndSettle();

      expect(find.text('Özel mesaj'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
