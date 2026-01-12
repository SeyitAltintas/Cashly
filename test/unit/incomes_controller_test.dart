import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/income/presentation/controllers/incomes_controller.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';

/// Mock IncomeRepository
class MockIncomeRepository implements IncomeRepository {
  List<Map<String, dynamic>> _incomes = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _recurringIncomes = [];

  @override
  List<Map<String, dynamic>> getIncomes(String userId) => _incomes;

  @override
  Future<void> saveIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {
    _incomes = List.from(incomes);
  }

  @override
  List<Map<String, dynamic>> getCategories(String userId) => _categories;

  @override
  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    _categories = List.from(categories);
  }

  @override
  List<Map<String, dynamic>> getRecurringIncomes(String userId) =>
      _recurringIncomes;

  @override
  Future<void> saveRecurringIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {
    _recurringIncomes = List.from(incomes);
  }

  // Test helper
  void setIncomes(List<Map<String, dynamic>> incomes) {
    _incomes = incomes;
  }
}

/// Mock PaymentMethodRepository
class MockPaymentMethodRepository implements PaymentMethodRepository {
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _deletedPaymentMethods = [];
  String? _defaultPaymentMethodId;
  List<Map<String, dynamic>> _transfers = [];

  @override
  List<Map<String, dynamic>> getPaymentMethods(String userId) =>
      _paymentMethods;

  @override
  Future<void> savePaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  ) async {
    _paymentMethods = List.from(methods);
  }

  @override
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId) =>
      _deletedPaymentMethods;

  @override
  Future<void> saveDeletedPaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  ) async {
    _deletedPaymentMethods = List.from(methods);
  }

  @override
  String? getDefaultPaymentMethod(String userId) => _defaultPaymentMethodId;

  @override
  Future<void> saveDefaultPaymentMethod(String userId, String? id) async {
    _defaultPaymentMethodId = id;
  }

  @override
  List<Map<String, dynamic>> getTransfers(String userId) => _transfers;

  @override
  Future<void> saveTransfers(
    String userId,
    List<Map<String, dynamic>> transfers,
  ) async {
    _transfers = List.from(transfers);
  }

  void setPaymentMethods(List<Map<String, dynamic>> methods) {
    _paymentMethods = methods;
  }
}

void main() {
  group('IncomesController', () {
    late MockIncomeRepository mockIncomeRepo;
    late MockPaymentMethodRepository mockPaymentMethodRepo;
    late IncomesController controller;
    const testUserId = 'test_user_123';

    setUp(() {
      mockIncomeRepo = MockIncomeRepository();
      mockPaymentMethodRepo = MockPaymentMethodRepository();
      controller = IncomesController(
        incomeRepository: mockIncomeRepo,
        paymentMethodRepository: mockPaymentMethodRepo,
        userId: testUserId,
      );
    });

    group('loadData', () {
      test('veri yüklendiğinde isLoading false olur', () async {
        mockIncomeRepo.setIncomes([
          Income(
            id: '1',
            name: 'Maaş',
            amount: 5000.0,
            category: 'Maaş',
            date: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.isLoading, isFalse);
        expect(controller.tumGelirler.length, equals(1));
      });
    });

    group('filteredGelirler', () {
      test('silinen gelirler filtrelenir', () async {
        final now = DateTime.now();
        mockIncomeRepo.setIncomes([
          Income(
            id: '1',
            name: 'Aktif',
            amount: 1000.0,
            category: 'Maaş',
            date: now,
            isDeleted: false,
          ).toMap(),
          Income(
            id: '2',
            name: 'Silindi',
            amount: 2000.0,
            category: 'Maaş',
            date: now,
            isDeleted: true,
          ).toMap(),
        ]);

        await controller.loadData();
        controller.secilenAy = now;

        expect(controller.filteredGelirler.length, equals(1));
        expect(controller.filteredGelirler.first.name, equals('Aktif'));
      });

      test('ay filtrelemesi çalışır', () async {
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1, 15);
        mockIncomeRepo.setIncomes([
          Income(
            id: '1',
            name: 'Bu Ay',
            amount: 1000.0,
            category: 'Maaş',
            date: now,
          ).toMap(),
          Income(
            id: '2',
            name: 'Geçen Ay',
            amount: 2000.0,
            category: 'Maaş',
            date: lastMonth,
          ).toMap(),
        ]);

        await controller.loadData();
        controller.secilenAy = now;

        expect(controller.filteredGelirler.length, equals(1));
        expect(controller.filteredGelirler.first.name, equals('Bu Ay'));
      });
    });

    group('toplamTutar', () {
      test('filtrelenmiş gelirlerin toplamını hesaplar', () async {
        final now = DateTime.now();
        mockIncomeRepo.setIncomes([
          Income(
            id: '1',
            name: 'Maaş',
            amount: 5000.0,
            category: 'Maaş',
            date: now,
          ).toMap(),
          Income(
            id: '2',
            name: 'Ek Gelir',
            amount: 1000.0,
            category: 'Diğer',
            date: now,
          ).toMap(),
        ]);

        await controller.loadData();
        controller.secilenAy = now;

        expect(controller.toplamTutar, equals(6000.0));
      });
    });

    group('addIncome', () {
      test('gelir listeye eklenir', () async {
        await controller.loadData();

        final yeniGelir = Income(
          id: 'new_1',
          name: 'Test Gelir',
          amount: 1500.0,
          category: 'Maaş',
          date: DateTime.now(),
        );

        await controller.addIncome(yeniGelir);

        expect(controller.tumGelirler.length, equals(1));
        expect(controller.tumGelirler.first.name, equals('Test Gelir'));
      });
    });

    group('deleteIncome', () {
      test('gelir silindi olarak işaretlenir', () async {
        final gelir = Income(
          id: '1',
          name: 'Test',
          amount: 1000.0,
          category: 'Maaş',
          date: DateTime.now(),
        );
        mockIncomeRepo.setIncomes([gelir.toMap()]);

        await controller.loadData();
        await controller.deleteIncome(controller.tumGelirler.first);

        expect(controller.tumGelirler.first.isDeleted, isTrue);
      });
    });

    group('ay geçişleri', () {
      test('oncekiAy çalışır', () {
        controller.secilenAy = DateTime(2024, 6, 1);
        controller.oncekiAy();
        expect(controller.secilenAy.month, equals(5));
      });

      test('sonrakiAy çalışır', () {
        controller.secilenAy = DateTime(2024, 6, 1);
        controller.sonrakiAy();
        expect(controller.secilenAy.month, equals(7));
      });
    });

    group('arama modu', () {
      test('toggleAramaModu durumu değiştirir', () {
        expect(controller.aramaModu, isFalse);
        controller.toggleAramaModu();
        expect(controller.aramaModu, isTrue);
      });
    });
  });
}
