import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/income/presentation/controllers/incomes_controller.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

// =====================================================================
// MOCK REPOSITORIES
// =====================================================================

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

  void setIncomes(List<Map<String, dynamic>> incomes) {
    _incomes = incomes;
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

  group('IncomesController - Business Logic Tests', () {
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

    // =================================================================
    // BAKIYE GÜNCELLEME TESTLERİ
    // =================================================================

    group('Bakiye Güncelleme - Gelir Ekleme', () {
      test('Banka hesabına gelir eklendiğinde bakiye ARTAR', () async {
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Ziraat',
            type: 'banka',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        final gelir = Income(
          id: 'inc1',
          name: 'Maaş',
          amount: 5000.0,
          category: 'Maaş',
          date: DateTime.now(),
          paymentMethodId: 'pm1',
        );
        await controller.addIncome(gelir);

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(6000.0),
          reason: 'Banka bakiyesi 1000 + 5000 = 6000 olmalı',
        );
      });

      test('Nakit hesaba gelir eklendiğinde bakiye ARTAR', () async {
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm_nakit',
            name: 'Nakit',
            type: 'nakit',
            balance: 500.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        final gelir = Income(
          id: 'inc1',
          name: 'Freelance',
          amount: 2000.0,
          category: 'Ek Gelir',
          date: DateTime.now(),
          paymentMethodId: 'pm_nakit',
        );
        await controller.addIncome(gelir);

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(2500.0),
          reason: 'Nakit bakiye 500 + 2000 = 2500 olmalı',
        );
      });

      test(
        'Kredi kartına gelir eklendiğinde borç AZALIR (ters mantık)',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm_kredi',
              name: 'Kredi Kartı',
              type: 'kredi',
              balance: 3000.0,
              limit: 10000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          await controller.loadData();

          final gelir = Income(
            id: 'inc1',
            name: 'Kredi Kartı Ödemesi',
            amount: 1000.0,
            category: 'Diğer',
            date: DateTime.now(),
            paymentMethodId: 'pm_kredi',
          );
          await controller.addIncome(gelir);

          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(2000.0),
            reason: 'Kredi kartı borcu 3000 - 1000 = 2000 olmalı',
          );
        },
      );

      test('Ödeme yöntemi belirtilmeyen gelir bakiyeleri etkilemez', () async {
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

        final gelir = Income(
          id: 'inc1',
          name: 'Bahşiş',
          amount: 100.0,
          category: 'Diğer',
          date: DateTime.now(),
          // paymentMethodId = null
        );
        await controller.addIncome(gelir);

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(1000.0),
          reason: 'Ödeme yöntemi olmayan gelir bakiyeyi değiştirmemeli',
        );
      });

      test(
        'Var olmayan ödeme yöntemine gelir eklendiğinde hata fırlatmaz',
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

          final gelir = Income(
            id: 'inc1',
            name: 'Bilinmeyen PM',
            amount: 500.0,
            category: 'Diğer',
            date: DateTime.now(),
            paymentMethodId: 'olmayan_pm_id',
          );

          // Hata fırlatmamalı, sessizce devam etmeli
          await expectLater(controller.addIncome(gelir), completes);

          // Mevcut ödeme yönteminin bakiyesi değişmemeli
          expect(controller.tumOdemeYontemleri.first.balance, equals(1000.0));
        },
      );
    });

    // =================================================================
    // SİLME VE BAKİYE GERİ ALMA TESTLERİ
    // =================================================================

    group('Bakiye Güncelleme - Gelir Silme', () {
      test('Banka hesabından gelir silindiğinde bakiye AZALIR', () async {
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Ziraat',
            type: 'banka',
            balance: 6000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        mockIncomeRepo.setIncomes([
          Income(
            id: 'inc1',
            name: 'Maaş',
            amount: 5000.0,
            category: 'Maaş',
            date: DateTime.now(),
            paymentMethodId: 'pm1',
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.deleteIncome(controller.tumGelirler.first);

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(1000.0),
          reason: 'Bakiye 6000 - 5000 = 1000 olmalı (gelir silindi)',
        );
        expect(controller.tumGelirler.first.isDeleted, isTrue);
      });

      test(
        'Kredi kartından gelir silindiğinde borç GERİ ARTAR (ters mantık)',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm_kredi',
              name: 'Kredi',
              type: 'kredi',
              balance: 2000.0,
              limit: 10000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          mockIncomeRepo.setIncomes([
            Income(
              id: 'inc1',
              name: 'KK Ödeme',
              amount: 1000.0,
              category: 'Diğer',
              date: DateTime.now(),
              paymentMethodId: 'pm_kredi',
            ).toMap(),
          ]);
          await controller.loadData();

          await controller.deleteIncome(controller.tumGelirler.first);

          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(3000.0),
            reason: 'Kredi borcu 2000 + 1000 = 3000 olmalı (gelir silindi)',
          );
        },
      );
    });

    // =================================================================
    // UNDO (GERİ ALMA) TESTLERİ
    // =================================================================

    group('Undo Delete (Silme Geri Alma)', () {
      test(
        'Silme geri alındığında gelir aktif olur ve bakiye eski haline döner',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Banka',
              type: 'banka',
              balance: 6000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          mockIncomeRepo.setIncomes([
            Income(
              id: 'inc1',
              name: 'Maaş',
              amount: 5000.0,
              category: 'Maaş',
              date: DateTime.now(),
              paymentMethodId: 'pm1',
            ).toMap(),
          ]);
          await controller.loadData();

          final originalBalance =
              controller.tumOdemeYontemleri.first.balance; // 6000

          // Sil
          await controller.deleteIncome(controller.tumGelirler.first);
          expect(controller.tumOdemeYontemleri.first.balance, equals(1000.0));

          // Geri Al
          await controller.undoDelete(
            controller.tumGelirler.first,
            wasDeleted: false,
            oldBalance: originalBalance,
            pmIndex: 0,
          );

          expect(controller.tumGelirler.first.isDeleted, isFalse);
          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(originalBalance),
            reason: 'Bakiye silme öncesi haline dönmeli',
          );
        },
      );
    });

    // =================================================================
    // GÜNCELLEME TESTLERİ
    // =================================================================

    group('Gelir Güncelleme', () {
      test(
        'Aynı ödeme yöntemiyle tutar değiştiğinde bakiye doğru güncellenir',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Banka',
              type: 'banka',
              balance: 6000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          mockIncomeRepo.setIncomes([
            Income(
              id: 'inc1',
              name: 'Maaş',
              amount: 5000.0,
              category: 'Maaş',
              date: DateTime.now(),
              paymentMethodId: 'pm1',
            ).toMap(),
          ]);
          await controller.loadData();

          // 5000 -> 7000 olarak güncelle
          await controller.updateIncome(
            income: controller.tumGelirler.first,
            name: 'Maaş (Güncel)',
            amount: 7000.0,
            category: 'Maaş',
            date: DateTime.now(),
            paymentMethodId: 'pm1',
          );

          // Eski tutar çıkarılır (6000 - 5000 = 1000), yeni tutar eklenir (1000 + 7000 = 8000)
          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(8000.0),
            reason: 'Bakiye: 6000 - 5000(eski) + 7000(yeni) = 8000 olmalı',
          );
          expect(controller.tumGelirler.first.name, equals('Maaş (Güncel)'));
          expect(controller.tumGelirler.first.amount, equals(7000.0));
        },
      );

      test(
        'Ödeme yöntemi değiştiğinde eski PM bakiyesi azalır yeni PM artar',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Banka A',
              type: 'banka',
              balance: 6000.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
            PaymentMethod(
              id: 'pm2',
              name: 'Banka B',
              type: 'banka',
              balance: 2000.0,
              colorIndex: 1,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          mockIncomeRepo.setIncomes([
            Income(
              id: 'inc1',
              name: 'Maaş',
              amount: 5000.0,
              category: 'Maaş',
              date: DateTime.now(),
              paymentMethodId: 'pm1',
            ).toMap(),
          ]);
          await controller.loadData();

          // pm1'den pm2'ye taşı
          await controller.updateIncome(
            income: controller.tumGelirler.first,
            name: 'Maaş',
            amount: 5000.0,
            category: 'Maaş',
            date: DateTime.now(),
            paymentMethodId: 'pm2',
          );

          // pm1: 6000 - 5000 = 1000
          expect(
            controller.tumOdemeYontemleri
                .firstWhere((p) => p.id == 'pm1')
                .balance,
            equals(1000.0),
          );
          // pm2: 2000 + 5000 = 7000
          expect(
            controller.tumOdemeYontemleri
                .firstWhere((p) => p.id == 'pm2')
                .balance,
            equals(7000.0),
          );
        },
      );
    });

    // =================================================================
    // ÇÖP KUTUSU (RECYCLE BIN) TESTLERİ
    // =================================================================

    group('Çöp Kutusu İşlemleri', () {
      test(
        'binRestoreGelir: silinen gelir geri yüklendiğinde isDeleted false olur',
        () async {
          final gelir = Income(
            id: 'inc1',
            name: 'Maaş',
            amount: 5000.0,
            category: 'Maaş',
            date: DateTime.now(),
            isDeleted: true,
          );
          mockIncomeRepo.setIncomes([gelir.toMap()]);
          await controller.loadData();

          controller.setBinSilinenGelirler([controller.tumGelirler.first]);
          controller.binRestoreGelir(controller.tumGelirler.first);

          expect(controller.tumGelirler.first.isDeleted, isFalse);
          expect(controller.binSilinenGelirler, isEmpty);
        },
      );

      test(
        'binPermanentDeleteGelir: kalıcı silme sonrası listelerden tamamen kaldırılır',
        () async {
          final gelir = Income(
            id: 'inc1',
            name: 'Silinecek',
            amount: 1000.0,
            category: 'Diğer',
            date: DateTime.now(),
            isDeleted: true,
          );
          mockIncomeRepo.setIncomes([gelir.toMap()]);
          await controller.loadData();

          controller.setBinSilinenGelirler([controller.tumGelirler.first]);
          controller.binPermanentDeleteGelir(controller.tumGelirler.first);

          expect(controller.tumGelirler, isEmpty);
          expect(controller.binSilinenGelirler, isEmpty);
        },
      );

      test('binEmptyBin: tüm silinen gelirler temizlenir', () async {
        final now = DateTime.now();
        mockIncomeRepo.setIncomes([
          Income(
            id: 'inc1',
            name: 'Aktif',
            amount: 1000.0,
            category: 'Maaş',
            date: now,
            isDeleted: false,
          ).toMap(),
          Income(
            id: 'inc2',
            name: 'Silinen1',
            amount: 2000.0,
            category: 'Maaş',
            date: now,
            isDeleted: true,
          ).toMap(),
          Income(
            id: 'inc3',
            name: 'Silinen2',
            amount: 3000.0,
            category: 'Diğer',
            date: now,
            isDeleted: true,
          ).toMap(),
        ]);
        await controller.loadData();

        controller.binEmptyBin();

        // Sadece aktif gelir kalmalı
        expect(controller.tumGelirler.length, equals(1));
        expect(controller.tumGelirler.first.name, equals('Aktif'));
        expect(controller.binSilinenGelirler, isEmpty);
      });

      test('binRestoreAll: tüm silinen gelirler geri yüklenir', () async {
        final now = DateTime.now();
        final gelir1 = Income(
          id: 'inc1',
          name: 'Silinen1',
          amount: 1000.0,
          category: 'Maaş',
          date: now,
          isDeleted: true,
        );
        final gelir2 = Income(
          id: 'inc2',
          name: 'Silinen2',
          amount: 2000.0,
          category: 'Diğer',
          date: now,
          isDeleted: true,
        );
        mockIncomeRepo.setIncomes([gelir1.toMap(), gelir2.toMap()]);
        await controller.loadData();

        controller.setBinSilinenGelirler(List.from(controller.tumGelirler));
        controller.binRestoreAll();

        expect(controller.tumGelirler.every((g) => !g.isDeleted), isTrue);
        expect(controller.binSilinenGelirler, isEmpty);
      });
    });

    // =================================================================
    // EDGE CASE TESTLERİ
    // =================================================================

    group('Edge Cases', () {
      test('Sıfır tutarlı gelir eklenebilir ve bakiye değişmez', () async {
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

        final gelir = Income(
          id: 'inc1',
          name: 'Sıfır Gelir',
          amount: 0.0,
          category: 'Diğer',
          date: DateTime.now(),
          paymentMethodId: 'pm1',
        );
        await controller.addIncome(gelir);

        expect(controller.tumGelirler.length, equals(1));
        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(1000.0),
          reason: 'Sıfır tutar bakiyeyi değiştirmemeli',
        );
      });

      test('Büyük tutarlı gelir eklenebilir', () async {
        mockPaymentMethodRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Banka',
            type: 'banka',
            balance: 0.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        final gelir = Income(
          id: 'inc1',
          name: 'Jackpot',
          amount: 999999999.99,
          category: 'Diğer',
          date: DateTime.now(),
          paymentMethodId: 'pm1',
        );
        await controller.addIncome(gelir);

        expect(
          controller.tumOdemeYontemleri.first.balance,
          equals(999999999.99),
        );
      });

      test(
        'Aynı anda birden fazla gelir eklendiğinde bakiye doğru toplanır',
        () async {
          mockPaymentMethodRepo.setPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Banka',
              type: 'banka',
              balance: 0.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
            ).toMap(),
          ]);
          await controller.loadData();

          for (int i = 1; i <= 5; i++) {
            await controller.addIncome(
              Income(
                id: 'inc_$i',
                name: 'Gelir $i',
                amount: 1000.0,
                category: 'Maaş',
                date: DateTime.now(),
                paymentMethodId: 'pm1',
              ),
            );
          }

          expect(controller.tumGelirler.length, equals(5));
          expect(
            controller.tumOdemeYontemleri.first.balance,
            equals(5000.0),
            reason: '5 x 1000 = 5000',
          );
        },
      );

      test('Boş liste üzerinde filtreleme hata vermez', () async {
        await controller.loadData();
        controller.secilenAy = DateTime.now();

        expect(controller.filteredGelirler, isEmpty);
        expect(controller.toplamTutar, equals(0.0));
      });
    });

    // =================================================================
    // FİLTRELEME TESTLERİ
    // =================================================================

    group('Gelişmiş Filtreleme', () {
      test('Farklı yıllardaki gelirler doğru filtrelenir', () async {
        mockIncomeRepo.setIncomes([
          Income(
            id: 'inc1',
            name: 'Bu yıl',
            amount: 1000.0,
            category: 'Maaş',
            date: DateTime(2024, 6, 15),
          ).toMap(),
          Income(
            id: 'inc2',
            name: 'Geçen yıl',
            amount: 2000.0,
            category: 'Maaş',
            date: DateTime(2023, 6, 15),
          ).toMap(),
        ]);
        await controller.loadData();
        controller.secilenAy = DateTime(2024, 6, 1);

        expect(controller.filteredGelirler.length, equals(1));
        expect(controller.filteredGelirler.first.name, equals('Bu yıl'));
      });

      test('Gelirler tarihe göre azalan sırada listelenir', () async {
        mockIncomeRepo.setIncomes([
          Income(
            id: 'inc1',
            name: 'Erken',
            amount: 100.0,
            category: 'Maaş',
            date: DateTime(2024, 6, 1),
          ).toMap(),
          Income(
            id: 'inc2',
            name: 'Geç',
            amount: 200.0,
            category: 'Maaş',
            date: DateTime(2024, 6, 25),
          ).toMap(),
          Income(
            id: 'inc3',
            name: 'Orta',
            amount: 300.0,
            category: 'Maaş',
            date: DateTime(2024, 6, 15),
          ).toMap(),
        ]);
        await controller.loadData();
        controller.secilenAy = DateTime(2024, 6, 1);

        final filtered = controller.filteredGelirler;
        expect(filtered[0].name, equals('Geç'));
        expect(filtered[1].name, equals('Orta'));
        expect(filtered[2].name, equals('Erken'));
      });
    });

    // =================================================================
    // TEKRARLAYAN GELİR TESTLERİ
    // =================================================================

    group('Tekrarlayan Gelirler', () {
      test('Tekrarlayan gelir eklenir', () {
        controller.setTekrarlayanGelirler([]);
        controller.addTekrarlayanGelir({
          'isim': 'Aylık Maaş',
          'tutar': 10000.0,
          'periyot': 'aylik',
        });

        expect(controller.tekrarlayanGelirler.length, equals(1));
        expect(
          controller.tekrarlayanGelirler.first['isim'],
          equals('Aylık Maaş'),
        );
      });

      test('Tekrarlayan gelir güncellenir', () {
        controller.setTekrarlayanGelirler([
          {'isim': 'Maaş', 'tutar': 10000.0, 'periyot': 'aylik'},
        ]);

        controller.updateTekrarlayanGelir(0, {
          'isim': 'Maaş',
          'tutar': 12000.0,
          'periyot': 'aylik',
        });

        expect(controller.tekrarlayanGelirler.first['tutar'], equals(12000.0));
      });

      test('Tekrarlayan gelir silinir', () {
        controller.setTekrarlayanGelirler([
          {'isim': 'Maaş', 'tutar': 10000.0, 'periyot': 'aylik'},
          {'isim': 'Kira', 'tutar': 3000.0, 'periyot': 'aylik'},
        ]);

        controller.removeTekrarlayanGelirAt(0);

        expect(controller.tekrarlayanGelirler.length, equals(1));
        expect(controller.tekrarlayanGelirler.first['isim'], equals('Kira'));
      });

      test('Geçersiz index ile güncelleme sessizce atlanır', () {
        controller.setTekrarlayanGelirler([
          {'isim': 'Maaş', 'tutar': 10000.0},
        ]);

        // Negatif index
        controller.updateTekrarlayanGelir(-1, {'isim': 'Hata'});
        expect(controller.tekrarlayanGelirler.first['isim'], equals('Maaş'));

        // Out of bounds index
        controller.updateTekrarlayanGelir(99, {'isim': 'Hata'});
        expect(controller.tekrarlayanGelirler.first['isim'], equals('Maaş'));
      });

      test('Geçersiz index ile silme sessizce atlanır', () {
        controller.setTekrarlayanGelirler([
          {'isim': 'Maaş', 'tutar': 10000.0},
        ]);

        controller.removeTekrarlayanGelirAt(-1);
        expect(controller.tekrarlayanGelirler.length, equals(1));

        controller.removeTekrarlayanGelirAt(99);
        expect(controller.tekrarlayanGelirler.length, equals(1));
      });
    });

    // =================================================================
    // KATEGORİ YÖNETİMİ TESTLERİ
    // =================================================================

    group('Kategori Yönetimi', () {
      test('Kategori eklenir', () {
        controller.setCatMgmtKategoriler([]);
        controller.addCatMgmtKategori('Maaş', 'attach_money');

        expect(controller.catMgmtKategoriler.length, equals(1));
        expect(controller.catMgmtKategoriler.first['isim'], equals('Maaş'));
      });

      test('Kategori silinir', () {
        controller.setCatMgmtKategoriler([
          {'isim': 'Maaş', 'ikon': 'attach_money'},
          {'isim': 'Kira', 'ikon': 'home'},
        ]);

        controller.removeCatMgmtKategoriAt(0);

        expect(controller.catMgmtKategoriler.length, equals(1));
        expect(controller.catMgmtKategoriler.first['isim'], equals('Kira'));
      });

      test('Kategoriler yeniden sıralanır', () {
        controller.setCatMgmtKategoriler([
          {'isim': 'A', 'ikon': 'a'},
          {'isim': 'B', 'ikon': 'b'},
          {'isim': 'C', 'ikon': 'c'},
        ]);

        // A'yı 3. sıraya taşı (index 0 -> 2)
        controller.reorderCatMgmtKategoriler(0, 3);

        expect(controller.catMgmtKategoriler[0]['isim'], equals('B'));
        expect(controller.catMgmtKategoriler[1]['isim'], equals('C'));
        expect(controller.catMgmtKategoriler[2]['isim'], equals('A'));
      });
    });

    // =================================================================
    // FORM STATE TESTLERİ
    // =================================================================

    group('Form State', () {
      test('Form state initialize edilir', () {
        controller.initializeFormState(
          defaultCategory: 'Maaş',
          defaultPaymentMethodId: 'pm1',
        );

        expect(controller.formSelectedCategory, equals('Maaş'));
        expect(controller.formSelectedPaymentMethodId, equals('pm1'));
      });

      test('Form state sıfırlanır', () {
        controller.initializeFormState(
          defaultCategory: 'Maaş',
          defaultPaymentMethodId: 'pm1',
        );
        controller.resetFormState();

        expect(controller.formSelectedCategory, equals(''));
        expect(controller.formSelectedPaymentMethodId, isNull);
      });

      test('Edit modunda form doğru doldurulur', () {
        final editDate = DateTime(2024, 3, 15);
        controller.initializeFormState(
          defaultCategory: 'Maaş',
          editDate: editDate,
          editCategory: 'Ek Gelir',
          editPaymentMethodId: 'pm2',
        );

        expect(controller.formSelectedCategory, equals('Ek Gelir'));
        expect(controller.formSelectedPaymentMethodId, equals('pm2'));
        expect(controller.formSelectedDate, equals(editDate));
      });
    });

    // =================================================================
    // NOTIFY LISTENERS TESTLERİ
    // =================================================================

    group('State Notifications', () {
      test('Gelir eklendiğinde listener tetiklenir', () async {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);
        await controller.loadData();

        final beforeCount = notifyCount;
        await controller.addIncome(
          Income(
            id: 'inc1',
            name: 'Test',
            amount: 100.0,
            category: 'Maaş',
            date: DateTime.now(),
          ),
        );

        expect(notifyCount, greaterThan(beforeCount));
      });

      test('Ay geçişinde listener tetiklenir', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.oncekiAy();
        expect(notifyCount, equals(1));

        controller.sonrakiAy();
        expect(notifyCount, equals(2));
      });
    });
  });
}
