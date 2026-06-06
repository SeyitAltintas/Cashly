import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/income/presentation/controllers/incomes_controller.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';
import 'package:cashly/core/services/batch_service.dart';

/// Mock IncomeRepository
class MockIncomeRepository implements IncomeRepository {
  @override
  BatchOperation getAddIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getUpdateIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getDeleteIncomeOperation(String userId, String id) => DummyBatchOperation();

  List<Map<String, dynamic>> _incomes = [];
  final List<Map<String, dynamic>> _categories = [];
  final List<Map<String, dynamic>> _recurringIncomes = [];

  @override
  List<Map<String, dynamic>> getIncomes(String userId) => _incomes;

  @override
  Stream<List<Map<String, dynamic>>> watchIncomesByMonth(String userId, DateTime month) {
    return Stream.value(_incomes);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchIncomesForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    return _incomes.where((i) {
      if (i['isDeleted'] == true || i['silindi'] == true) return false;
      final tarih = DateTime.tryParse(i['date']?.toString() ?? i['tarih']?.toString() ?? '');
      if (tarih == null) return false;
      return tarih.isAfter(start.subtract(const Duration(seconds: 1))) &&
          tarih.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  @override
  Future<void> addIncome(String userId, Map<String, dynamic> income) async {}
  @override
  Future<void> updateIncome(String userId, Map<String, dynamic> income) async {}
  @override
  Future<void> deleteIncome(String userId, String incomeId) async {}

  @override
  List<Map<String, dynamic>> getCategories(String userId) => _categories;

  @override
  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {}

  @override
  List<Map<String, dynamic>> getRecurringIncomes(String userId) =>
      _recurringIncomes;

  @override
  Future<void> saveRecurringIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {}

  @override
  double getIncomeTarget(String userId) => 0.0;

  @override
  Future<void> saveIncomeTarget(String userId, double target) async {}

  @override
  List<Map<String, dynamic>> getRecurringIncomeTemplates(String userId) => [];

  @override
  Future<void> saveRecurringIncomeTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  ) async {}
  // Test helper
  void setIncomes(List<Map<String, dynamic>> incomes) {
    _incomes = incomes;
  }
}

/// Mock PaymentMethodRepository
class MockPaymentMethodRepository implements PaymentMethodRepository {
  @override
  BatchOperation getAddPaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getUpdatePaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getDeletePaymentMethodOperation(String userId, String id) => DummyBatchOperation();
  @override
  BatchOperation getAddTransferOperation(String userId, Map<String, dynamic> transfer) => DummyBatchOperation();

  List<Map<String, dynamic>> _paymentMethods = [];
  final List<Map<String, dynamic>> _deletedPaymentMethods = [];
  String? _defaultPaymentMethodId;
  final List<Map<String, dynamic>> _transfers = [];

  @override
  List<Map<String, dynamic>> getPaymentMethods(String userId) =>
      _paymentMethods;

  @override
  Future<void> addPaymentMethod(String userId, Map<String, dynamic> method) async {}
  @override
  Future<void> updatePaymentMethod(String userId, Map<String, dynamic> method) async {}
  @override
  Future<void> deletePaymentMethod(String userId, String id) async {}
  @override
  Future<void> addDeletedPaymentMethod(String userId, Map<String, dynamic> method) async {}
  @override
  Future<void> removeDeletedPaymentMethod(String userId, String id) async {}
  @override
  Future<void> addTransfer(String userId, Map<String, dynamic> transfer) async {}
  @override
  Future<void> updateTransfer(String userId, Map<String, dynamic> transfer) async {}
  @override
  Future<void> deleteTransfer(String userId, String transferId) async {}

  @override
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId) =>
      _deletedPaymentMethods;



  @override
  String? getDefaultPaymentMethod(String userId) => _defaultPaymentMethodId;

  @override
  Future<void> saveDefaultPaymentMethod(String userId, String? id) async {
    _defaultPaymentMethodId = id;
  }

  @override
  List<Map<String, dynamic>> getTransfers(String userId) => _transfers;



  void setPaymentMethods(List<Map<String, dynamic>> methods) {
    _paymentMethods = methods;
  }
}

class DummyBatchOperation implements BatchOperation {
  @override
  BatchOperationType get type => BatchOperationType.set;
  @override
  String get collectionPath => '';
  @override
  String get documentId => '';
  @override
  Map<String, dynamic>? get data => null;
  @override
  bool get merge => false;
}

class MockBatchService implements BatchService {
  @override
  Future<void> commit(List<BatchOperation> operations) async {}
}
void main() {
  setUpAll(() {
    if (!GetIt.instance.isRegistered<BatchService>()) { GetIt.instance.registerLazySingleton<BatchService>(() => MockBatchService()); }

    if (!GetIt.instance.isRegistered<CurrencyService>()) {
      GetIt.instance.registerLazySingleton<CurrencyService>(
        () => CurrencyService(),
      );
    }
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

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
        await controller.filtreleVeGoster();

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
        await controller.filtreleVeGoster();

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
        await controller.filtreleVeGoster();

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
