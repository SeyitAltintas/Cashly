import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/lazy_load_list_view.dart';

void main() {
  group('LazyLoadListView Widget Testleri', () {
    testWidgets('Temel LazyLoadListView oluşturulabilir', (
      WidgetTester tester,
    ) async {
      final items = List.generate(10, (i) => 'Item $i');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadListView<String>(
              items: items,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(LazyLoadListView<String>), findsOneWidget);

      // İlk item'ların görünür olduğunu kontrol et
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('Boş liste için emptyWidget gösterir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadListView<String>(
              items: const [],
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
              emptyWidget: const Center(child: Text('Liste boş')),
            ),
          ),
        ),
      );

      // Empty widget'ın görünür olduğunu kontrol et
      expect(find.text('Liste boş'), findsOneWidget);
    });

    testWidgets('hasMore true olduğunda loading indicator gösterir', (
      WidgetTester tester,
    ) async {
      final items = List.generate(5, (i) => 'Item $i');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadListView<String>(
              items: items,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
              hasMore: true,
              onLoadMore: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
            ),
          ),
        ),
      );

      // Listenin sonuna scroll et
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      // Loading indicator görünür mü (varsayılan CircularProgressIndicator)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Özel loadingWidget kullanılabilir', (
      WidgetTester tester,
    ) async {
      final items = List.generate(3, (i) => 'Item $i');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadListView<String>(
              items: items,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
              hasMore: true,
              loadingWidget: const Text('Yükleniyor...'),
            ),
          ),
        ),
      );

      // Scroll et
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      // Özel loading widget görünür mü
      expect(find.text('Yükleniyor...'), findsOneWidget);
    });

    testWidgets('Padding doğru uygulanır', (WidgetTester tester) async {
      final items = ['Test Item'];
      const testPadding = EdgeInsets.all(20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyLoadListView<String>(
              items: items,
              itemBuilder: (context, item, index) => Text(item),
              padding: testPadding,
            ),
          ),
        ),
      );

      // ListView'i bul ve padding'i kontrol et
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, equals(testPadding));
    });
  });

  group('PaginationController Testleri', () {
    test('PaginationController başlangıç değerleri doğru', () {
      final controller = PaginationController<String>(
        pageSize: 20,
        fetchPage: (page, pageSize) async => [],
      );

      expect(controller.items, isEmpty);
      expect(controller.hasMore, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.currentPage, equals(0));

      controller.dispose();
    });

    test('PaginationController refresh çalışır', () async {
      int fetchCount = 0;
      final controller = PaginationController<String>(
        pageSize: 10,
        fetchPage: (page, pageSize) async {
          fetchCount++;
          return List.generate(10, (i) => 'Item ${page * 10 + i}');
        },
      );

      await controller.refresh();

      expect(fetchCount, equals(1));
      expect(controller.items.length, equals(10));
      expect(controller.currentPage, equals(1));

      controller.dispose();
    });

    test('PaginationController loadMore ek veri yükler', () async {
      final controller = PaginationController<String>(
        pageSize: 10,
        fetchPage: (page, pageSize) async {
          return List.generate(10, (i) => 'Item ${page * 10 + i}');
        },
      );

      // İlk sayfa
      await controller.refresh();
      expect(controller.items.length, equals(10));

      // İkinci sayfa
      await controller.loadMore();
      expect(controller.items.length, equals(20));

      controller.dispose();
    });

    test('PaginationController hasMore false olur', () async {
      final controller = PaginationController<String>(
        pageSize: 10,
        fetchPage: (page, pageSize) async {
          // Sadece 5 item döndür (pageSize'dan az)
          return List.generate(5, (i) => 'Item $i');
        },
      );

      await controller.refresh();

      expect(controller.hasMore, isFalse);

      controller.dispose();
    });

    test('PaginationController updateItem çalışır', () async {
      final controller = PaginationController<String>(
        pageSize: 10,
        fetchPage: (page, pageSize) async {
          return List.generate(10, (i) => 'Item $i');
        },
      );

      await controller.refresh();

      controller.updateItem(5, 'Updated Item');
      expect(controller.items[5], equals('Updated Item'));

      controller.dispose();
    });

    test('PaginationController removeItem çalışır', () async {
      final controller = PaginationController<String>(
        pageSize: 10,
        fetchPage: (page, pageSize) async {
          return List.generate(10, (i) => 'Item $i');
        },
      );

      await controller.refresh();
      final initialLength = controller.items.length;

      controller.removeItem(5);
      expect(controller.items.length, equals(initialLength - 1));

      controller.dispose();
    });

    test('PaginationController insertAtStart çalışır', () async {
      final controller = PaginationController<String>(
        pageSize: 10,
        fetchPage: (page, pageSize) async {
          return List.generate(10, (i) => 'Item $i');
        },
      );

      await controller.refresh();

      controller.insertAtStart('New Item');
      expect(controller.items.first, equals('New Item'));

      controller.dispose();
    });
  });
}
