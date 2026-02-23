import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/payment_methods/presentation/controllers/payment_methods_controller.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

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

  void setDeletedPaymentMethods(List<Map<String, dynamic>> methods) {
    _deletedPaymentMethods = methods;
  }
}

void main() {
  setUpAll(() {
    if (!GetIt.instance.isRegistered<CurrencyService>()) {
      GetIt.instance.registerLazySingleton<CurrencyService>(
        () => CurrencyService(),
      );
    }
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('PaymentMethodsController', () {
    late MockPaymentMethodRepository mockRepo;
    late PaymentMethodsController controller;
    const testUserId = 'test_user_123';

    setUp(() {
      mockRepo = MockPaymentMethodRepository();
      controller = PaymentMethodsController(
        paymentMethodRepository: mockRepo,
        userId: testUserId,
      );
    });

    group('loadData', () {
      test('veri yüklendiğinde isLoading false olur', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: '1',
            name: 'Nakit',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.isLoading, isFalse);
        expect(controller.paymentMethods.length, equals(1));
      });
    });

    group('totalBalance', () {
      test('nakit ve banka bakiyelerini toplar', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: '1',
            name: 'Nakit',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: '2',
            name: 'Banka',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.totalBalance, equals(6000.0));
      });

      test('kredi kartları toplam bakiyeye eklenmez', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: '1',
            name: 'Nakit',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: '2',
            name: 'Kredi',
            type: 'kredi',
            balance: 500.0,
            limit: 5000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.totalBalance, equals(1000.0));
      });
    });

    group('totalDebt', () {
      test('kredi kartı borçlarını toplar', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: '1',
            name: 'Kredi1',
            type: 'kredi',
            balance: 500.0,
            limit: 5000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: '2',
            name: 'Kredi2',
            type: 'kredi',
            balance: 1500.0,
            limit: 10000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.totalDebt, equals(2000.0));
      });
    });

    group('addMethod', () {
      test('ödeme yöntemi eklenir', () async {
        await controller.loadData();

        final yeniPm = PaymentMethod(
          id: 'new_1',
          name: 'Yeni Nakit',
          type: 'nakit',
          balance: 2000.0,
          colorIndex: 0,
          createdAt: DateTime.now(),
        );

        await controller.addMethod(yeniPm);

        expect(controller.paymentMethods.length, equals(1));
      });
    });

    group('moveToBin', () {
      test('ödeme yöntemi çöp kutusuna taşınır', () async {
        final pm = PaymentMethod(
          id: '1',
          name: 'Test',
          type: 'nakit',
          balance: 1000.0,
          colorIndex: 0,
          createdAt: DateTime.now(),
        );
        mockRepo.setPaymentMethods([pm.toMap()]);

        await controller.loadData();
        await controller.moveToBin(controller.paymentMethods.first);

        expect(controller.paymentMethods.length, equals(0));
        expect(controller.deletedPaymentMethods.length, equals(1));
      });
    });

    group('restoreMethod', () {
      test('ödeme yöntemi geri yüklenir', () async {
        final pm = PaymentMethod(
          id: '1',
          name: 'Test',
          type: 'nakit',
          balance: 1000.0,
          colorIndex: 0,
          createdAt: DateTime.now(),
          isDeleted: true,
        );
        mockRepo.setDeletedPaymentMethods([pm.toMap()]);

        await controller.loadData();
        await controller.restoreMethod(controller.deletedPaymentMethods.first);

        expect(controller.paymentMethods.length, equals(1));
        expect(controller.deletedPaymentMethods.length, equals(0));
      });
    });

    group('updateBalance', () {
      test('bakiye güncellenir', () async {
        final pm = PaymentMethod(
          id: '1',
          name: 'Nakit',
          type: 'nakit',
          balance: 1000.0,
          colorIndex: 0,
          createdAt: DateTime.now(),
        );
        mockRepo.setPaymentMethods([pm.toMap()]);

        await controller.loadData();
        await controller.updateBalance('1', 500.0);

        expect(controller.paymentMethods.first.balance, equals(1500.0));
      });
    });

    group('arama modu', () {
      test('arama metni filtreleme yapar', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: '1',
            name: 'Nakit Cüzdan',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: '2',
            name: 'Banka Kartı',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();
        controller.aramaModu = true;
        controller.aramaMetni = 'nakit';

        expect(controller.filteredMethods.length, equals(1));
        expect(controller.filteredMethods.first.name, equals('Nakit Cüzdan'));
      });
    });
  });
}
