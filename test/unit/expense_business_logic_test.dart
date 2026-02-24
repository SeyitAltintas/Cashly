import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/expenses/presentation/controllers/expenses_controller.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

// =====================================================================
// MOCK REPOSITORIES
// =====================================================================

class MockExpenseRepository implements ExpenseRepository {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _categories = [];
  double _budget = 8000.0;
  List<Map<String, dynamic>> _fixedExpenseTemplates = [];
  Map<String, double> _categoryBudgets = {};

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

  @override
  Map<String, double> getCategoryBudgets(String userId) => _categoryBudgets;

  @override
  Future<void> saveCategoryBudgets(
    String userId,
    Map<String, double> budgets,
  ) async {
    _categoryBudgets = Map.from(budgets);
  }

  void setExpenses(List<Map<String, dynamic>> expenses) {
    _expenses = expenses;
  }

  void setCategories(List<Map<String, dynamic>> categories) {
    _categories = categories;
  }
}

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

// =====================================================================
// TEST SUITE
// =====================================================================

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

  group('ExpensesController - Business Logic Tests', () {
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

    // =================================================================
    // HARCAMA EKLEME - BAKİYE GÜNCELLEME TESTLERİ
    // =================================================================

    group('Bakiye Güncelleme - Harcama Ekleme', () {
      test('Banka hesabından harcama yapıldığında bakiye AZALIR', () async {
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Ziraat',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.harcamaEkleVeyaDuzenle(
          name: 'Market',
          amount: 500.0,
          category: 'Yemek',
          date: DateTime.now(),
          paymentMethodId: 'pm1',
        );

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(4500.0),
          reason: 'Banka bakiyesi 5000 - 500 = 4500 olmalı',
        );
      });

      test('Nakit hesaptan harcama yapıldığında bakiye AZALIR', () async {
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm_nakit',
            name: 'Nakit',
            type: 'nakit',
            balance: 2000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.harcamaEkleVeyaDuzenle(
          name: 'Taksi',
          amount: 150.0,
          category: 'Ulaşım',
          date: DateTime.now(),
          paymentMethodId: 'pm_nakit',
        );

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(1850.0),
          reason: 'Nakit bakiye 2000 - 150 = 1850 olmalı',
        );
      });

      test(
        'Kredi kartından harcama yapıldığında borç ARTAR (ters mantık)',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm_kredi',
              name: 'Kredi',
              type: 'kredi',
              balance: 1000.0,
              limit: 10000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          await controller.loadData();

          await controller.harcamaEkleVeyaDuzenle(
            name: 'Elektronik',
            amount: 2000.0,
            category: 'Alışveriş',
            date: DateTime.now(),
            paymentMethodId: 'pm_kredi',
          );

          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(3000.0),
            reason: 'Kredi borcu 1000 + 2000 = 3000 olmalı',
          );
        },
      );

      test(
        'Ödeme yöntemi olmadan harcama eklendiğinde bakiye değişmez',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Nakit',
              type: 'nakit',
              balance: 1000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          await controller.loadData();

          await controller.harcamaEkleVeyaDuzenle(
            name: 'Bahşiş',
            amount: 50.0,
            category: 'Diğer',
            date: DateTime.now(),
            // paymentMethodId yok
          );

          expect(controller.tumOdemeYontemleri.first.balance, equals(1000.0));
          expect(controller.tumHarcamalar.length, equals(1));
        },
      );
    });

    // =================================================================
    // HARCAMA SİLME - BAKİYE GERİ ALMA TESTLERİ
    // =================================================================

    group('Bakiye Güncelleme - Harcama Silme', () {
      test('Banka hesabından harcama silindiğinde bakiye GERİ ARTAR', () async {
        final now = DateTime.now();
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Ziraat',
            type: 'banka',
            balance: 4500.0,
            colorIndex: 0,
            createdAt: now,
          ).toMap(),
        ]);
        mockExpenseRepo.setExpenses([
          {
            'isim': 'Market',
            'tutar': 500.0,
            'kategori': 'Yemek',
            'tarih': now.toString(),
            'silindi': false,
            'odemeYontemiId': 'pm1',
          },
        ]);
        await controller.loadData();

        await controller.harcamaSil(harcama: controller.tumHarcamalar.first);

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(5000.0),
          reason:
              'Bakiye 4500 + 500 = 5000 olmalı (harcama silindi, bakiye geri geldi)',
        );
        expect(controller.tumHarcamalar.first['silindi'], isTrue);
      });

      test(
        'Kredi kartından harcama silindiğinde borç AZALIR (ters mantık)',
        () async {
          final now = DateTime.now();
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm_kredi',
              name: 'Kredi',
              type: 'kredi',
              balance: 3000.0,
              limit: 10000.0,
              colorIndex: 0,
              createdAt: now,
            ).toMap(),
          ]);
          mockExpenseRepo.setExpenses([
            {
              'isim': 'Elektronik',
              'tutar': 2000.0,
              'kategori': 'Alışveriş',
              'tarih': now.toString(),
              'silindi': false,
              'odemeYontemiId': 'pm_kredi',
            },
          ]);
          await controller.loadData();

          await controller.harcamaSil(harcama: controller.tumHarcamalar.first);

          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(1000.0),
            reason: 'Kredi borcu 3000 - 2000 = 1000 olmalı',
          );
        },
      );
    });

    // =================================================================
    // SİLME GERİ ALMA (UNDO) TESTLERİ
    // =================================================================

    group('Silme Geri Alma (Undo)', () {
      test('Harcama silme geri alındığında bakiye eski haline döner', () async {
        final now = DateTime.now();
        final harcama = {
          'isim': 'Market',
          'tutar': 500.0,
          'kategori': 'Yemek',
          'tarih': now.toString(),
          'silindi': false,
          'odemeYontemiId': 'pm1',
        };
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Banka',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 0,
            createdAt: now,
          ).toMap(),
        ]);
        mockExpenseRepo.setExpenses([harcama]);
        await controller.loadData();

        final originalBalance = controller.tumOdemeYontemleri.first.balance;

        // Sil
        await controller.harcamaSil(harcama: harcama);
        expect(controller.tumOdemeYontemleri.first.balance, equals(5500.0));

        // Geri Al
        await controller.harcamaSilmeGeriAl(
          harcama: harcama,
          eskiSilindi: false,
          eskiBakiye: originalBalance,
          pmIndex: 0,
        );

        expect(harcama['silindi'], isFalse);
        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(originalBalance),
          reason: 'Bakiye silme öncesine dönmeli',
        );
      });
    });

    // =================================================================
    // HARCAMA GÜNCELLEME TESTLERİ
    // =================================================================

    group('Harcama Güncelleme', () {
      test('Aynı PM ile tutar değiştiğinde bakiye doğru güncellenir', () async {
        final now = DateTime.now();
        final harcama = {
          'isim': 'Market',
          'tutar': 500.0,
          'kategori': 'Yemek',
          'tarih': now.toString(),
          'silindi': false,
          'odemeYontemiId': 'pm1',
        };
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Banka',
            type: 'banka',
            balance: 4500.0,
            colorIndex: 0,
            createdAt: now,
          ).toMap(),
        ]);
        mockExpenseRepo.setExpenses([harcama]);
        await controller.loadData();

        // 500 -> 800 olarak güncelle
        await controller.harcamaEkleVeyaDuzenle(
          name: 'Market (Büyük)',
          amount: 800.0,
          category: 'Yemek',
          date: now,
          paymentMethodId: 'pm1',
          duzenlenecekHarcama: harcama,
          eskiOdemeYontemiId: 'pm1',
          eskiTutar: 500.0,
        );

        // Eski eklenir geri: 4500 + 500 = 5000, yeni çıkar: 5000 - 800 = 4200
        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(4200.0),
          reason: 'Bakiye: 4500 + 500(eski geri) - 800(yeni) = 4200',
        );
      });

      test('PM değiştiğinde eski PM bakiyesi artar yeni PM azalır', () async {
        final now = DateTime.now();
        final harcama = {
          'isim': 'Market',
          'tutar': 500.0,
          'kategori': 'Yemek',
          'tarih': now.toString(),
          'silindi': false,
          'odemeYontemiId': 'pm1',
        };
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Banka A',
            type: 'banka',
            balance: 4500.0,
            colorIndex: 0,
            createdAt: now,
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Banka B',
            type: 'banka',
            balance: 3000.0,
            colorIndex: 1,
            createdAt: now,
          ).toMap(),
        ]);
        mockExpenseRepo.setExpenses([harcama]);
        await controller.loadData();

        // pm1 -> pm2 olarak güncelle
        await controller.harcamaEkleVeyaDuzenle(
          name: 'Market',
          amount: 500.0,
          category: 'Yemek',
          date: now,
          paymentMethodId: 'pm2',
          duzenlenecekHarcama: harcama,
          eskiOdemeYontemiId: 'pm1',
          eskiTutar: 500.0,
        );

        // pm1: 4500 + 500 = 5000 (eski harcama geri eklendi)
        expect(
          controller.tumOdemeYontemleri
              .firstWhere((p) => p.id == 'pm1')
              .balance,
          equals(5000.0),
        );
        // pm2: 3000 - 500 = 2500 (yeni PM'den düşüldü)
        expect(
          controller.tumOdemeYontemleri
              .firstWhere((p) => p.id == 'pm2')
              .balance,
          equals(2500.0),
        );
      });
    });

    // =================================================================
    // ÇÖP KUTUSU TESTLERİ
    // =================================================================

    group('Çöp Kutusu İşlemleri', () {
      test(
        'binRestoreHarcama: banka hesabı harcaması restore edildiğinde bakiye AZALIR',
        () async {
          final now = DateTime.now();
          final harcama = {
            'isim': 'Market',
            'tutar': 500.0,
            'kategori': 'Yemek',
            'tarih': now.toString(),
            'silindi': true,
            'odemeYontemiId': 'pm1',
          };
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Banka',
              type: 'banka',
              balance: 5000.0,
              colorIndex: 0,
              createdAt: now,
            ).toMap(),
          ]);
          mockExpenseRepo.setExpenses([harcama]);
          await controller.loadData();

          controller.setBinSilinenHarcamalar([harcama]);
          controller.binRestoreHarcama(harcama);

          expect(harcama['silindi'], isFalse);
          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(4500.0),
            reason: 'Harcama geri yüklenince bakiye düşmeli: 5000 - 500 = 4500',
          );
          expect(controller.binSilinenHarcamalar, isEmpty);
        },
      );

      test(
        'binRestoreHarcama: kredi kartı harcaması restore edildiğinde borç ARTAR',
        () async {
          final now = DateTime.now();
          final harcama = {
            'isim': 'Elektronik',
            'tutar': 2000.0,
            'kategori': 'Alışveriş',
            'tarih': now.toString(),
            'silindi': true,
            'odemeYontemiId': 'pm_kredi',
          };
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm_kredi',
              name: 'Kredi',
              type: 'kredi',
              balance: 1000.0,
              limit: 10000.0,
              colorIndex: 0,
              createdAt: now,
            ).toMap(),
          ]);
          mockExpenseRepo.setExpenses([harcama]);
          await controller.loadData();

          controller.setBinSilinenHarcamalar([harcama]);
          controller.binRestoreHarcama(harcama);

          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(3000.0),
            reason: 'Kredi borcu: 1000 + 2000 = 3000',
          );
        },
      );

      test(
        'binEmptyBin: tüm silinen harcamalar kalıcı olarak temizlenir',
        () async {
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
              'isim': 'Silinen1',
              'tutar': 200.0,
              'kategori': 'Yemek',
              'tarih': now.toString(),
              'silindi': true,
            },
            {
              'isim': 'Silinen2',
              'tutar': 300.0,
              'kategori': 'Ulaşım',
              'tarih': now.toString(),
              'silindi': true,
            },
          ]);
          await controller.loadData();

          controller.binEmptyBin();

          expect(controller.tumHarcamalar.length, equals(1));
          expect(controller.tumHarcamalar.first['isim'], equals('Aktif'));
          expect(controller.binSilinenHarcamalar, isEmpty);
        },
      );

      test(
        'binRestoreAll: tüm silinen harcamalar geri yüklendiğinde bakiyeler güncellenir',
        () async {
          final now = DateTime.now();
          final harcama1 = {
            'isim': 'Market',
            'tutar': 500.0,
            'kategori': 'Yemek',
            'tarih': now.toString(),
            'silindi': true,
            'odemeYontemiId': 'pm1',
          };
          final harcama2 = {
            'isim': 'Taksi',
            'tutar': 300.0,
            'kategori': 'Ulaşım',
            'tarih': now.toString(),
            'silindi': true,
            'odemeYontemiId': 'pm1',
          };
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Banka',
              type: 'banka',
              balance: 5000.0,
              colorIndex: 0,
              createdAt: now,
            ).toMap(),
          ]);
          mockExpenseRepo.setExpenses([harcama1, harcama2]);
          await controller.loadData();

          controller.setBinSilinenHarcamalar([harcama1, harcama2]);
          controller.binRestoreAll();

          // Her iki harcama geri yüklenince: 5000 - 500 - 300 = 4200
          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(4200.0),
            reason: 'Bakiye: 5000 - 500 - 300 = 4200',
          );
          expect(harcama1['silindi'], isFalse);
          expect(harcama2['silindi'], isFalse);
          expect(controller.binSilinenHarcamalar, isEmpty);
        },
      );

      test(
        'binPermanentDeleteHarcama: kalıcı silme listelerden kaldırır',
        () async {
          final now = DateTime.now();
          final harcama = {
            'isim': 'Silinecek',
            'tutar': 100.0,
            'kategori': 'Diğer',
            'tarih': now.toString(),
            'silindi': true,
          };
          mockExpenseRepo.setExpenses([harcama]);
          await controller.loadData();

          controller.setBinSilinenHarcamalar([harcama]);
          controller.binPermanentDeleteHarcama(harcama);

          expect(controller.tumHarcamalar, isEmpty);
          expect(controller.binSilinenHarcamalar, isEmpty);
        },
      );
    });

    // =================================================================
    // FİLTRELEME TESTLERİ
    // =================================================================

    group('Gelişmiş Filtreleme', () {
      test('Silinen harcamalar filtrelenmişlerde gösterilmez', () async {
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
            'isim': 'Silinen',
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

      test('Farklı ay/yıl harcamaları doğru filtrelenir', () async {
        mockExpenseRepo.setExpenses([
          {
            'isim': 'Ocak 2024',
            'tutar': 100.0,
            'kategori': 'Yemek',
            'tarih': DateTime(2024, 1, 15).toString(),
            'silindi': false,
          },
          {
            'isim': 'Şubat 2024',
            'tutar': 200.0,
            'kategori': 'Yemek',
            'tarih': DateTime(2024, 2, 15).toString(),
            'silindi': false,
          },
          {
            'isim': 'Ocak 2023',
            'tutar': 300.0,
            'kategori': 'Yemek',
            'tarih': DateTime(2023, 1, 15).toString(),
            'silindi': false,
          },
        ]);
        await controller.loadData();
        controller.secilenAy = DateTime(2024, 1, 1);
        controller.filtreleVeGoster();

        expect(controller.gosterilenHarcamalar.length, equals(1));
        expect(
          controller.gosterilenHarcamalar.first['isim'],
          equals('Ocak 2024'),
        );
      });

      test(
        'Arama filtrelemesi hem isim hem kategori üzerinde çalışır',
        () async {
          final now = DateTime.now();
          mockExpenseRepo.setExpenses([
            {
              'isim': 'Kebap',
              'tutar': 100.0,
              'kategori': 'Yemek',
              'tarih': now.toString(),
              'silindi': false,
            },
            {
              'isim': 'Taksi',
              'tutar': 150.0,
              'kategori': 'Ulaşım',
              'tarih': now.toString(),
              'silindi': false,
            },
            {
              'isim': 'Yemek Siparişi',
              'tutar': 200.0,
              'kategori': 'Online',
              'tarih': now.toString(),
              'silindi': false,
            },
          ]);
          await controller.loadData();
          controller.secilenAy = now;

          // "yemek" hem isimde hem kategoride bulunmalı
          controller.filtreleVeGoster(aramaMetni: 'yemek');

          expect(controller.gosterilenHarcamalar.length, equals(2));
        },
      );

      test('Harcamalar tarihe göre azalan sırada listelenir', () async {
        mockExpenseRepo.setExpenses([
          {
            'isim': 'Erken',
            'tutar': 100.0,
            'kategori': 'Yemek',
            'tarih': DateTime(2024, 6, 1).toString(),
            'silindi': false,
          },
          {
            'isim': 'Geç',
            'tutar': 200.0,
            'kategori': 'Yemek',
            'tarih': DateTime(2024, 6, 25).toString(),
            'silindi': false,
          },
          {
            'isim': 'Orta',
            'tutar': 300.0,
            'kategori': 'Yemek',
            'tarih': DateTime(2024, 6, 15).toString(),
            'silindi': false,
          },
        ]);
        await controller.loadData();
        controller.secilenAy = DateTime(2024, 6, 1);
        controller.filtreleVeGoster();

        final list = controller.gosterilenHarcamalar;
        expect(list[0]['isim'], equals('Geç'));
        expect(list[1]['isim'], equals('Orta'));
        expect(list[2]['isim'], equals('Erken'));
      });
    });

    // =================================================================
    // KATEGORİ YÖNETİMİ TESTLERİ
    // =================================================================

    group('Kategori Yönetimi', () {
      test('Kategori ekle', () {
        controller.setCatMgmtKategoriler([]);
        controller.addCatMgmtKategori('Yemek', 'restaurant');

        expect(controller.catMgmtKategoriler.length, equals(1));
        expect(controller.catMgmtKategoriler.first['isim'], equals('Yemek'));
      });

      test('Kategori sil', () {
        controller.setCatMgmtKategoriler([
          {'isim': 'Yemek', 'ikon': 'restaurant'},
          {'isim': 'Ulaşım', 'ikon': 'directions_car'},
        ]);

        controller.removeCatMgmtKategoriAt(0);

        expect(controller.catMgmtKategoriler.length, equals(1));
        expect(controller.catMgmtKategoriler.first['isim'], equals('Ulaşım'));
      });

      test('Kategorileri yeniden sırala', () {
        controller.setCatMgmtKategoriler([
          {'isim': 'A', 'ikon': 'a'},
          {'isim': 'B', 'ikon': 'b'},
          {'isim': 'C', 'ikon': 'c'},
        ]);

        controller.reorderCatMgmtKategoriler(0, 3);

        expect(controller.catMgmtKategoriler[0]['isim'], equals('B'));
        expect(controller.catMgmtKategoriler[2]['isim'], equals('A'));
      });

      test('Kategorileri varsayılana sıfırla', () {
        controller.setCatMgmtKategoriler([
          {'isim': 'Özel1', 'ikon': 'custom1'},
        ]);

        final defaults = [
          {'isim': 'Yemek', 'ikon': 'restaurant'},
          {'isim': 'Ulaşım', 'ikon': 'directions_car'},
        ];
        controller.resetCatMgmtToDefault(defaults);

        expect(controller.catMgmtKategoriler.length, equals(2));
        expect(controller.catMgmtKategoriler.first['isim'], equals('Yemek'));
      });

      test('Geçersiz index ile silme sessiz kalır', () {
        controller.setCatMgmtKategoriler([
          {'isim': 'Yemek', 'ikon': 'restaurant'},
        ]);

        controller.removeCatMgmtKategoriAt(-1);
        expect(controller.catMgmtKategoriler.length, equals(1));

        controller.removeCatMgmtKategoriAt(99);
        expect(controller.catMgmtKategoriler.length, equals(1));
      });
    });

    // =================================================================
    // EDGE CASE TESTLERİ
    // =================================================================

    group('Edge Cases', () {
      test('Boş listeyle filtreleme hata vermez', () async {
        await controller.loadData();
        controller.secilenAy = DateTime.now();
        controller.filtreleVeGoster();

        expect(controller.gosterilenHarcamalar, isEmpty);
        expect(controller.toplamTutar, equals(0.0));
      });

      test(
        'Aynı anda aynı PM ye birden fazla harcama eklendiğinde bakiye doğru kalır',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Banka',
              type: 'banka',
              balance: 10000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          await controller.loadData();

          for (int i = 1; i <= 5; i++) {
            await controller.harcamaEkleVeyaDuzenle(
              name: 'Harcama $i',
              amount: 1000.0,
              category: 'Yemek',
              date: DateTime.now(),
              paymentMethodId: 'pm1',
            );
          }

          expect(controller.tumHarcamalar.length, equals(5));
          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(5000.0),
            reason: '10000 - (5 x 1000) = 5000',
          );
        },
      );

      test('Sıfır tutarlı harcama eklenebilir', () async {
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Nakit',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.harcamaEkleVeyaDuzenle(
          name: 'Ücretsiz',
          amount: 0.0,
          category: 'Diğer',
          date: DateTime.now(),
          paymentMethodId: 'pm1',
        );

        expect(controller.tumOdemeYontemleri.first.balance, equals(1000.0));
      });
    });

    // =================================================================
    // FORM STATE TESTLERİ
    // =================================================================

    group('Form State', () {
      test('Form initialize ve reset doğru çalışır', () {
        controller.initializeFormState(
          defaultCategory: 'Yemek',
          defaultPaymentMethodId: 'pm1',
        );

        expect(controller.formSelectedCategory, equals('Yemek'));
        expect(controller.formSelectedPaymentMethodId, equals('pm1'));

        controller.resetFormState();

        expect(controller.formSelectedCategory, equals(''));
        expect(controller.formSelectedPaymentMethodId, isNull);
      });
    });

    // =================================================================
    // VOICE STATE TESTLERİ
    // =================================================================

    group('Voice Input State', () {
      test('Voice initialize başarı durumu', () {
        controller.setVoiceInitialized(success: true);

        expect(controller.voiceIsInitializing, isFalse);
        expect(controller.voiceHasError, isFalse);
      });

      test('Voice initialize hata durumu', () {
        controller.setVoiceInitialized(
          success: false,
          error: 'Mikrofon erişilemedi',
        );

        expect(controller.voiceIsInitializing, isFalse);
        expect(controller.voiceHasError, isTrue);
        expect(controller.voiceErrorMessage, equals('Mikrofon erişilemedi'));
      });

      test('Voice listening başlat ve durdur', () {
        controller.startVoiceListening();

        expect(controller.voiceIsListening, isTrue);
        expect(controller.voiceRecognizedText, isEmpty);
        expect(controller.voiceHasError, isFalse);

        controller.stopVoiceListening();
        expect(controller.voiceIsListening, isFalse);
      });

      test('Voice form sıfırlama', () {
        controller.updateVoiceRecognizedText('test metin');
        controller.resetVoiceForm();

        expect(controller.voiceRecognizedText, isEmpty);
        expect(controller.voiceParseResult, isNull);
      });
    });
  });
}
