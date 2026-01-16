import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/animated_card.dart';

void main() {
  group('AnimatedCard Widget Tests', () {
    testWidgets('renders child widget correctly', (tester) async {
      // Arrange
      const testText = 'Test Content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedCard(delay: 0, child: Text(testText))),
        ),
      );

      // Act & Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('applies animation with delay', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(delay: 100, child: Text('Delayed Content')),
          ),
        ),
      );

      // Animasyon başlangıcı - opacity 0 olmalı
      await tester.pump();

      // Animasyon tamamlanana kadar bekle
      await tester.pumpAndSettle();

      // İçerik görünür olmalı
      expect(find.text('Delayed Content'), findsOneWidget);
    });

    testWidgets('child widget is tappable', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              delay: 0,
              child: GestureDetector(
                onTap: () => tapped = true,
                child: const Text('Tappable Content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Tappable Content'));

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('works with different child widgets', (tester) async {
      // Arrange - Container ile test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              delay: 50,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Center(child: Icon(Icons.star)),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('handles zero delay', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(delay: 0, child: Text('Zero Delay')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Zero Delay'), findsOneWidget);
    });

    testWidgets('handles large delay value', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(delay: 500, child: Text('Large Delay')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Large Delay'), findsOneWidget);
    });

    testWidgets('multiple AnimatedCards work together', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedCard(delay: 0, child: Text('Card 1')),
                AnimatedCard(delay: 100, child: Text('Card 2')),
                AnimatedCard(delay: 200, child: Text('Card 3')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.text('Card 3'), findsOneWidget);
    });
  });
}
