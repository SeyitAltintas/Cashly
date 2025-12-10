import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Cashly Uygulama Testleri', () {
    testWidgets('MaterialApp başarıyla oluşturulabilir', (
      WidgetTester tester,
    ) async {
      // Basit bir MaterialApp test edilir
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Cashly Test'))),
        ),
      );

      // Widget'ın varlığını doğrula
      expect(find.text('Cashly Test'), findsOneWidget);
    });

    testWidgets('CircularProgressIndicator render edilebilir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
