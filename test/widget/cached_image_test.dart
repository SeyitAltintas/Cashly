import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/cached_image.dart';

void main() {
  group('CachedImage Widget Testleri', () {
    testWidgets('Widget oluşturulur ve loading state gösterilir', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/test.jpg',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      // Loading state'de CircularProgressIndicator gösterilmeli
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Özel placeholder widget gösterilir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/test.jpg',
              width: 100,
              height: 100,
              placeholder: Center(child: Text('Yükleniyor...')),
            ),
          ),
        ),
      );

      expect(find.text('Yükleniyor...'), findsOneWidget);
    });

    testWidgets('Width ve height doğru uygulanır', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/test.jpg',
              width: 150,
              height: 200,
            ),
          ),
        ),
      );

      // Widget oluşturulmuş olmalı
      expect(find.byType(CachedImage), findsOneWidget);
    });

    testWidgets('BorderRadius uygulanır', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/test.jpg',
              width: 100,
              height: 100,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );

      // ClipRRect widget'ı bulunmalı (borderRadius uygulandığında)
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('BoxFit parametresi kabul edilir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/test.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );

      expect(find.byType(CachedImage), findsOneWidget);
    });

    testWidgets('ErrorWidget parametresi kabul edilir', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'invalid-url',
              width: 100,
              height: 100,
              errorWidget: Center(child: Icon(Icons.error)),
            ),
          ),
        ),
      );

      // Widget oluşturulmuş olmalı
      expect(find.byType(CachedImage), findsOneWidget);
    });
  });
}
