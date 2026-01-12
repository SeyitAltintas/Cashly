import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/expenses/presentation/controllers/expenses_controller.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';

/// Mock ExpenseRepository - testlerde gerçek veritabanını kullanmadan test yapabilmek için
class MockExpenseRepository implements ExpenseRepository {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _categories = [];
  double _budget = 8000.0;
  List<Map<String, dynamic>> _fixedExpenseTemplates = [];

  @override
  List<Map<String, dynamic>> getExpenses(String userId) => _expenses;

  @override
  Future<void> saveExpenses(
    String userId,
    List<Map<String, dynamic>> expenses,
  ) async {
    _expenses = List.from(expenses);
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
  double getBudget(String userId) => _budget;

  @override
  Future<void> saveBudget(String userId, double limit) async {
    _budget = limit;
  }

  @override
  List<Map<String, dynamic>> getFixedExpenseTemplates(String userId) =>
      _fixedExpenseTemplates;

  @override
  Future<void> saveFixedExpenseTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  ) async {
    _fixedExpenseTemplates = List.from(templates);
  }

  // Test helper metodları
  void setExpenses(List<Map<String, dynamic>> expenses) {
    _expenses = expenses;
  }

  void setCategories(List<Map<String, dynamic>> categories) {
    _categories = categories;
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

  // Test helper metodları
  void setPaymentMethods(List<Map<String, dynamic>> methods) {
    _paymentMethods = methods;
  }
}

void main() {
  group('ExpensesController', () {
    late MockExpenseRepository mockExpenseRepo;
    late MockPaymentMethodRepository mockPaymentMethodRepo;
    late ExpensesController controller;
    const testUserId = 'test_user_123';

    setUp(() {
      mockExpenseRepo = MockExpenseRepository();
      mockPaymentMethodRepo = MockPaymentMethodRepository();
      controller = ExpensesController(
        expenseRepository: mockExpenseRepo,
        paymentMethodRepository: mockPaymentMethodRepo,
        userId: testUserId,
      );
    });

    group('loadData', () {
      test('veri yüklendiğinde isLoading false olur', () async {
        mockExpenseRepo.setExpenses([
          {
            'isim': 'Test Harcama',
            'tutar': 100.0,
            'kategori': 'Yemek',
            'tarih': DateTime.now().toString(),
            'silindi': false,
          },
        ]);
        mockPaymentMethodRepo.setPaymentMethods([
          {
            'id': 'pm1',
            'name': 'Nakit',
            'type': 'nakit',
            'balance': 1000.0,
            'colorIndex': 0,
            'createdAt': DateTime.now().toIso8601String(),
            'isDeleted': false,
          },
        ]);

        await controller.loadData();

        expect(controller.isLoading, isFalse);
        expect(controller.tumHarcamalar.length, equals(1));
        expect(controller.tumOdemeYontemleri.length, equals(1));
      });

      test('kategoriler doğru yüklenir', () async {
        mockExpenseRepo.setCategories([
          {'isim': 'Yemek', 'ikon': 'restaurant'},
          {'isim': 'Ulaşım', 'ikon': 'directions_car'},
        ]);

        await controller.loadData();

        expect(controller.kategoriler.length, equals(2));
      });
    });

    group('filtreleVeGoster', () {
      test('ay filtrelemesi doğru çalışır', () async {
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1, 15);

        mockExpenseRepo.setExpenses([
          {
            'isim': 'Bu Ay',
            'tutar': 100.0,
            'kategori': 'Yemek',
            'tarih': now.toString(),
            'silindi': false,
          },
          {
            'isim': 'Geçen Ay',
            'tutar': 200.0,
            'kategori': 'Yemek',
            'tarih': lastMonth.toString(),
            'silindi': false,
          },
        ]);

        await controller.loadData();
        controller.secilenAy = now;
        controller.filtreleVeGoster();

        expect(controller.gosterilenHarcamalar.length, equals(1));
        expect(controller.gosterilenHarcamalar.first['isim'], equals('Bu Ay'));
      });

      test('arama filtrelemesi doğru çalışır', () async {
        final now = DateTime.now();
        mockExpenseRepo.setExpenses([
          {
            'isim': 'Kahvaltı',
            'tutar': 50.0,
            'kategori': 'Yemek',
            'tarih': now.toString(),
            'silindi': false,
          },
          {
            'isim': 'Taksi',
            'tutar': 100.0,
            'kategori': 'Ulaşım',
            'tarih': now.toString(),
            'silindi': false,
          },
        ]);

        await controller.loadData();
        controller.secilenAy = now;
        controller.filtreleVeGoster(aramaMetni: 'kahv');

        expect(controller.gosterilenHarcamalar.length, equals(1));
        expect(
          controller.gosterilenHarcamalar.first['isim'],
          equals('Kahvaltı'),
        );
      });

      test('silinen harcamalar filtrelenir', () async {
        final now = DateTime.now();
        mockExpenseRepo.setExpenses([
          {
            'isim': 'Aktif',
            'tutar': 100.0,
            'kategori': 'Yemek',
            'tarih': now.toString(),
            'silindi': false,
          },
          {
            'isim': 'Silindi',
            'tutar': 200.0,
            'kategori': 'Yemek',
            'tarih': now.toString(),
            'silindi': true,
          },
        ]);

        await controller.loadData();
        controller.secilenAy = now;
        controller.filtreleVeGoster();

        expect(controller.gosterilenHarcamalar.length, equals(1));
        expect(controller.gosterilenHarcamalar.first['isim'], equals('Aktif'));
      });
    });

    group('harcamaSil', () {
      test('harcama silindi olarak işaretlenir', () async {
        final now = DateTime.now();
        final harcama = {
          'isim': 'Test',
          'tutar': 100.0,
          'kategori': 'Yemek',
          'tarih': now.toString(),
          'silindi': false,
        };
        mockExpenseRepo.setExpenses([harcama]);

        await controller.loadData();
        controller.secilenAy = now;
        await controller.harcamaSil(harcama: harcama);

        expect(harcama['silindi'], isTrue);
      });
    });

    group('ay geçişleri', () {
      test('oncekiAy seçilen ayı azaltır', () {
        final basla = DateTime(2024, 5, 1);
        controller.secilenAy = basla;

        controller.oncekiAy();

        expect(controller.secilenAy.month, equals(4));
        expect(controller.secilenAy.year, equals(2024));
      });

      test('sonrakiAy seçilen ayı artırır', () {
        final basla = DateTime(2024, 5, 1);
        controller.secilenAy = basla;

        controller.sonrakiAy();

        expect(controller.secilenAy.month, equals(6));
        expect(controller.secilenAy.year, equals(2024));
      });
    });

    group('arama modu', () {
      test('toggleAramaModu durumu değiştirir', () {
        expect(controller.aramaModu, isFalse);

        controller.toggleAramaModu();
        expect(controller.aramaModu, isTrue);

        controller.toggleAramaModu();
        expect(controller.aramaModu, isFalse);
      });
    });

    group('state notifications', () {
      test('değişiklikler notifyListeners çağırır', () async {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.aramaModu = true;
        expect(notifyCount, equals(1));

        controller.toggleAramaModu();
        expect(notifyCount, equals(2));
      });
    });
  });
}
