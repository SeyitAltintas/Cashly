import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/expenses/presentation/controllers/expenses_controller.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';

/// Mock ExpenseRepository - testlerde gerçek veritabanını kullanmadan test yapabilmek için
class MockExpenseRepository implements ExpenseRepository {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _categories = [];
  double _budget = 8000.0;
  final List<Map<String, dynamic>> _fixedExpenseTemplates = [];
  final Map<String, double> _categoryBudgets = {};

  @override
  List<Map<String, dynamic>> getExpenses(String userId) => _expenses;

  @override
  Future<void> addExpense(String userId, Map<String, dynamic> expense) async {}
  @override
  Future<void> updateExpense(String userId, Map<String, dynamic> expense) async {}
  @override
  Future<void> deleteExpense(String userId, String expenseId) async {}

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
  ) async {}

  @override
  Map<String, double> getCategoryBudgets(String userId) => _categoryBudgets;

  @override
  Future<void> saveCategoryBudgets(
    String userId,
    Map<String, double> budgets,
  ) async {}
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

    group('harcamaEkleVeyaDuzenleLegacy (Edit Bug Fix)', () {
      test('eski ödeme yöntemine iade yapıp yeni yöntemi günceller', () async {
        final now = DateTime.now();
        final harcama = {
          'isim': 'Market',
          'tutar': 500.0,
          'kategori': 'Yemek',
          'tarih': now.toString(),
          'silindi': false,
          'odemeYontemiId': 'pm1',
          'paraBirimi': 'TRY',
        };
        
        final pm1 = {
          'id': 'pm1',
          'name': 'Banka A',
          'type': 'banka',
          'balance': 4500.0,
          'colorIndex': 0,
          'createdAt': now.toIso8601String(),
          'isDeleted': false,
          'paraBirimi': 'TRY',
        };

        final pm2 = {
          'id': 'pm2',
          'name': 'Banka B',
          'type': 'banka',
          'balance': 3000.0,
          'colorIndex': 1,
          'createdAt': now.toIso8601String(),
          'isDeleted': false,
          'paraBirimi': 'TRY',
        };

        final List<Map<String, dynamic>> mockHarcamalar = [harcama];
        final List<dynamic> mockPaymentMethods = [pm1, pm2];

        // pm1 -> pm2 olarak güncelleniyor ve tutar 500 -> 800 oluyor.
        await controller.harcamaEkleVeyaDuzenleLegacy(
          tumHarcamalar: mockHarcamalar,
          tumOdemeYontemleri: mockPaymentMethods,
          name: 'Market Güncel',
          amount: 800.0,
          category: 'Yemek',
          date: now,
          paymentMethodId: 'pm2',
          duzenlenecekHarcama: harcama,
          eskiOdemeYontemiId: 'pm1',
          eskiTutar: 500.0,
        );

        // Beklenen: pm1'e eski harcama (500) iade edilecek -> 4500 + 500 = 5000
        expect(
          controller.tumOdemeYontemleri.firstWhere((pm) => pm.id == 'pm1').balance,
          equals(5000.0),
        );

        // Beklenen: pm2'den yeni harcama (800) düşülecek -> 3000 - 800 = 2200
        expect(
          controller.tumOdemeYontemleri.firstWhere((pm) => pm.id == 'pm2').balance,
          equals(2200.0),
        );

        // Harcamalar listesi güncellenmeli
        expect(controller.tumHarcamalar.first['isim'], equals('Market Güncel'));
        expect(controller.tumHarcamalar.first['tutar'], equals(800.0));
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
