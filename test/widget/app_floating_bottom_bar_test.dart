import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/app_floating_bottom_bar.dart';

void main() {
  group('BottomBarItem Testleri', () {
    test('BottomBarItem doğru şekilde oluşturulmalı', () {
      bool tapped = false;
      final item = BottomBarItem(
        icon: Icons.home,
        label: 'Ana Sayfa',
        onTap: () => tapped = true,
      );

      expect(item.icon, Icons.home);
      expect(item.label, 'Ana Sayfa');

      item.onTap();
      expect(tapped, isTrue);
    });
  });

  group('AppFloatingBottomBar Testleri', () {
    testWidgets('Bottom bar doğru render edilmeli', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppFloatingBottomBar(
              items: [
                BottomBarItem(
                  icon: Icons.list,
                  label: 'Liste',
                  onTap: () => tapCount++,
                ),
                BottomBarItem(
                  icon: Icons.settings,
                  label: 'Ayarlar',
                  onTap: () => tapCount++,
                ),
              ],
            ),
          ),
        ),
      );

      // Widget'ların render edildiğini kontrol et
      expect(find.text('Liste'), findsOneWidget);
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Bottom bar item tıklaması çalışmalı', (tester) async {
      int listeTapCount = 0;
      int ayarlarTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppFloatingBottomBar(
              items: [
                BottomBarItem(
                  icon: Icons.list,
                  label: 'Liste',
                  onTap: () => listeTapCount++,
                ),
                BottomBarItem(
                  icon: Icons.settings,
                  label: 'Ayarlar',
                  onTap: () => ayarlarTapCount++,
                ),
              ],
            ),
          ),
        ),
      );

      // Liste'ye tıkla
      await tester.tap(find.text('Liste'));
      expect(listeTapCount, 1);

      // Ayarlar'a tıkla
      await tester.tap(find.text('Ayarlar'));
      expect(ayarlarTapCount, 1);
    });

    testWidgets('Center button (yuvarlak) gösterilmeli', (tester) async {
      int centerTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppFloatingBottomBar(
              items: [
                BottomBarItem(icon: Icons.list, label: 'Liste', onTap: () {}),
                BottomBarItem(
                  icon: Icons.settings,
                  label: 'Ayarlar',
                  onTap: () {},
                ),
              ],
              onCenterButtonTap: () => centerTapCount++,
              centerButtonIcon: Icons.add,
            ),
          ),
        ),
      );

      // Center button ikonunu bul ve tıkla
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      expect(centerTapCount, 1);
    });

    testWidgets('Center button with label gösterilmeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppFloatingBottomBar(
              items: [
                BottomBarItem(icon: Icons.list, label: 'Liste', onTap: () {}),
              ],
              onCenterButtonTap: () {},
              centerButtonIcon: Icons.add,
              centerButtonLabel: 'Ekle',
              centerButtonColor: Colors.blue,
            ),
          ),
        ),
      );

      // Etiketli center button görünmeli
      expect(find.text('Ekle'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Custom center widget kullanılabilmeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppFloatingBottomBar(
              items: [
                BottomBarItem(icon: Icons.list, label: 'Liste', onTap: () {}),
              ],
              centerButton: Container(
                key: const Key('customCenter'),
                width: 60,
                height: 60,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      // Custom center widget görünmeli
      expect(find.byKey(const Key('customCenter')), findsOneWidget);
    });
  });
}
