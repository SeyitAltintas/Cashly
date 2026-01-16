import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/money_animation.dart';

void main() {
  group('MoneyRainAnimation Widget Tests', () {
    testWidgets('renders without errors', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: MoneyRainAnimation(),
            ),
          ),
        ),
      );

      // Act - Animasyonu başlat
      await tester.pump();

      // Assert - Widget render edilmeli
      expect(find.byType(MoneyRainAnimation), findsOneWidget);
    });

    testWidgets('calls onComplete callback when animation finishes', (
      tester,
    ) async {
      // Arrange
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: MoneyRainAnimation(
                duration: const Duration(milliseconds: 100),
                onComplete: () => completed = true,
              ),
            ),
          ),
        ),
      );

      // Act - Animasyonu tamamla
      await tester.pumpAndSettle();

      // Assert
      expect(completed, isTrue);
    });

    testWidgets('respects custom duration', (tester) async {
      // Arrange
      bool completed = false;
      const customDuration = Duration(milliseconds: 200);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: MoneyRainAnimation(
                duration: customDuration,
                onComplete: () => completed = true,
              ),
            ),
          ),
        ),
      );

      // Act - Yarı süre sonra tamamlanmamış olmalı
      await tester.pump(const Duration(milliseconds: 100));
      expect(completed, isFalse);

      // Animasyonu tamamla
      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });

    testWidgets('respects custom coin count', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: MoneyRainAnimation(
                coinCount: 5,
                duration: Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert - Widget render edilmeli
      expect(find.byType(MoneyRainAnimation), findsOneWidget);
    });

    testWidgets('is wrapped with IgnorePointer', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: MoneyRainAnimation(duration: Duration(milliseconds: 100)),
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert - MoneyRainAnimation'ın build metodunda IgnorePointer var
      // Widget ağacında IgnorePointer olduğunu doğrula
      final ignorePointerFinder = find.descendant(
        of: find.byType(MoneyRainAnimation),
        matching: find.byType(IgnorePointer),
      );
      expect(ignorePointerFinder, findsOneWidget);
    });

    testWidgets('disposes animation controller properly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: MoneyRainAnimation(duration: Duration(milliseconds: 100)),
            ),
          ),
        ),
      );

      await tester.pump();

      // Act - Widget'ı kaldır
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      // Assert - Hata olmamalı
      expect(find.byType(MoneyRainAnimation), findsNothing);
    });
  });

  group('MoneyAnimationOverlay Tests', () {
    testWidgets('show creates overlay entry', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => MoneyAnimationOverlay.show(context),
                  child: const Text('Show Animation'),
                ),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Animation'));
      await tester.pump();

      // Assert - Overlay oluşturulmuş olmalı
      expect(find.byType(MoneyRainAnimation), findsOneWidget);
    });

    testWidgets('hide removes overlay entry', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => MoneyAnimationOverlay.show(context),
                      child: const Text('Show'),
                    ),
                    ElevatedButton(
                      onPressed: () => MoneyAnimationOverlay.hide(),
                      child: const Text('Hide'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Act - Göster
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.byType(MoneyRainAnimation), findsOneWidget);

      // Gizle
      await tester.tap(find.text('Hide'));
      await tester.pump();

      // Assert
      expect(find.byType(MoneyRainAnimation), findsNothing);
    });

    testWidgets('calling show twice replaces previous overlay', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => MoneyAnimationOverlay.show(context),
                  child: const Text('Show'),
                ),
              );
            },
          ),
        ),
      );

      // Act - İki kez göster
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.tap(find.text('Show'));
      await tester.pump();

      // Assert - Sadece bir tane olmalı
      expect(find.byType(MoneyRainAnimation), findsOneWidget);
    });
  });
}
