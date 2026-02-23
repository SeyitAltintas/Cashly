import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/form/category_selector.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

void main() {
  // Test için örnek kategori ikonları
  final testCategoryIcons = <String, IconData>{
    'Yiyecek': Icons.restaurant,
    'Ulaşım': Icons.directions_car,
    'Alışveriş': Icons.shopping_cart,
    'Eğlence': Icons.movie,
    'Sağlık': Icons.local_hospital,
  };

  group('CategorySelector Widget Testleri', () {
    testWidgets('Temel CategorySelector oluşturulabilir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: null,
              categoryIcons: testCategoryIcons,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(CategorySelector), findsOneWidget);

      // Kategori ikonu görünür mü
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('CategorySelector.expense factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: CategorySelector.expense(
              selectedCategory: 'Yiyecek',
              categoryIcons: testCategoryIcons,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(CategorySelector), findsOneWidget);

      // Seçili kategori görünür mü
      expect(find.text('Yiyecek'), findsOneWidget);
    });

    testWidgets('CategorySelector.income factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: CategorySelector.income(
              selectedCategory: 'Ulaşım',
              categoryIcons: testCategoryIcons,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(CategorySelector), findsOneWidget);

      // Seçili kategori görünür mü
      expect(find.text('Ulaşım'), findsOneWidget);
    });

    testWidgets('CategorySelector null değerle çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: null,
              categoryIcons: testCategoryIcons,
              onChanged: (_) {},
              labelText: 'Kategori seçin',
            ),
          ),
        ),
      );

      // Hint text görünür mü
      expect(find.text('Kategori seçin'), findsOneWidget);
    });

    testWidgets('CategorySelector dropdown açılır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: 'Yiyecek',
              categoryIcons: testCategoryIcons,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Dropdown butona tıkla
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Tüm kategorilerin menüde görünür olduğunu kontrol et
      // Not: Dropdown açıldığında seçili olan + menüdeki = 2 kez görünebilir
      expect(find.text('Ulaşım'), findsWidgets);
      expect(find.text('Alışveriş'), findsWidgets);
      expect(find.text('Eğlence'), findsWidgets);
    });

    testWidgets('CategorySelector seçim callback tetikler', (
      WidgetTester tester,
    ) async {
      String? selectedCategory = 'Yiyecek';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CategorySelector(
                  selectedCategory: selectedCategory,
                  categoryIcons: testCategoryIcons,
                  onChanged: (value) {
                    setState(() => selectedCategory = value);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Dropdown aç
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Farklı kategori seç
      await tester.tap(find.text('Ulaşım').last);
      await tester.pumpAndSettle();

      // Seçimin değiştiğini kontrol et
      expect(selectedCategory, equals('Ulaşım'));
    });

    testWidgets('CategorySelector kategori ikonlarını gösterir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: 'Yiyecek',
              categoryIcons: testCategoryIcons,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Dropdown aç
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Kategori ikonlarının görünür olduğunu kontrol et
      expect(find.byIcon(Icons.restaurant), findsWidgets);
      expect(find.byIcon(Icons.directions_car), findsWidgets);
    });
  });
}
