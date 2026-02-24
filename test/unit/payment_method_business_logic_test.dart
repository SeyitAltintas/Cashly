import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/payment_methods/presentation/controllers/payment_methods_controller.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

// =====================================================================
// MOCK REPOSITORY
// =====================================================================

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

  group('PaymentMethodsController - Business Logic Tests', () {
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

    // =================================================================
    // TOPLAM BAKİYE HESAPLAMA TESTLERİ
    // =================================================================

    group('Toplam Bakiye Hesaplama', () {
      test('totalBalance sadece nakit ve banka bakiyelerini toplar', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Nakit',
            type: 'nakit',
            balance: 2000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Banka',
            type: 'banka',
            balance: 8000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm3',
            name: 'Kredi',
            type: 'kredi',
            balance: 5000.0,
            limit: 10000.0,
            colorIndex: 2,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        // Nakit (2000) + Banka (8000) = 10000 (Kredi hariç)
        expect(controller.totalBalance, equals(10000.0));
      });

      test('totalDebt sadece kredi kartı borçlarını toplar', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Nakit',
            type: 'nakit',
            balance: 2000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Kredi1',
            type: 'kredi',
            balance: 3000.0,
            limit: 10000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm3',
            name: 'Kredi2',
            type: 'kredi',
            balance: 7000.0,
            limit: 20000.0,
            colorIndex: 2,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        // Kredi1 (3000) + Kredi2 (7000) = 10000
        expect(controller.totalDebt, equals(10000.0));
      });

      test('Hiç ödeme yöntemi yoksa bakiye ve borç sıfırdır', () async {
        await controller.loadData();

        expect(controller.totalBalance, equals(0.0));
        expect(controller.totalDebt, equals(0.0));
      });

      test('Sadece kredi kartları varsa toplam bakiye sıfırdır', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Kredi',
            type: 'kredi',
            balance: 5000.0,
            limit: 10000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        expect(controller.totalBalance, equals(0.0));
        expect(controller.totalDebt, equals(5000.0));
      });
    });

    // =================================================================
    // BAKİYE GÜNCELLEME TESTLERİ
    // =================================================================

    group('Bakiye Güncelleme', () {
      test('Pozitif tutar ekleme bakiyeyi artırır', () async {
        mockRepo.setPaymentMethods([
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

        await controller.updateBalance('pm1', 500.0);

        expect(controller.paymentMethods.first.balance, equals(1500.0));
      });

      test('Negatif tutar ekleme bakiyeyi azaltır', () async {
        mockRepo.setPaymentMethods([
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

        await controller.updateBalance('pm1', -300.0);

        expect(controller.paymentMethods.first.balance, equals(700.0));
      });

      test('Olmayan PM ID ye bakiye güncelleme sessiz kalır', () async {
        mockRepo.setPaymentMethods([
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

        await controller.updateBalance('olmayan_id', 500.0);

        expect(controller.paymentMethods.first.balance, equals(1000.0));
      });

      test('Bakiye eksiye düşebilir (iş kuralı: engelleme yok)', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Nakit',
            type: 'nakit',
            balance: 100.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.updateBalance('pm1', -500.0);

        expect(controller.paymentMethods.first.balance, equals(-400.0));
      });
    });

    // =================================================================
    // ÇÖP KUTUSU TESTLERİ
    // =================================================================

    group('Çöp Kutusu İşlemleri', () {
      test('moveToBin: PM aktif listeden silinir ve çöpe eklenir', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Nakit',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Banka',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.moveToBin(controller.paymentMethods.first);

        expect(controller.paymentMethods.length, equals(1));
        expect(controller.deletedPaymentMethods.length, equals(1));
        expect(controller.deletedPaymentMethods.first.isDeleted, isTrue);
      });

      test('restoreMethod: PM çöpten aktif listeye döner', () async {
        mockRepo.setDeletedPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Silinen',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.restoreMethod(controller.deletedPaymentMethods.first);

        expect(controller.paymentMethods.length, equals(1));
        expect(controller.deletedPaymentMethods, isEmpty);
        expect(controller.paymentMethods.first.isDeleted, isFalse);
      });

      test(
        'permanentDelete: kalıcı silme sonrası PM tamamen kaldırılır',
        () async {
          mockRepo.setDeletedPaymentMethods([
            PaymentMethod(
              id: 'pm1',
              name: 'Silinecek',
              type: 'nakit',
              balance: 0.0,
              colorIndex: 0,
              createdAt: DateTime.now(),
              isDeleted: true,
            ).toMap(),
          ]);
          await controller.loadData();

          await controller.permanentDelete(
            controller.deletedPaymentMethods.first,
          );

          expect(controller.paymentMethods, isEmpty);
          expect(controller.deletedPaymentMethods, isEmpty);
        },
      );

      test('emptyBin: tüm çöp kutusu temizlenir', () async {
        mockRepo.setDeletedPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Silinen1',
            type: 'nakit',
            balance: 0.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
            isDeleted: true,
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Silinen2',
            type: 'banka',
            balance: 0.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.emptyBin();

        expect(controller.deletedPaymentMethods, isEmpty);
      });

      test('restoreAll: tüm silinen PM ler geri yüklenir', () async {
        mockRepo.setDeletedPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Silinen1',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
            isDeleted: true,
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Silinen2',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);
        await controller.loadData();

        await controller.restoreAll();

        expect(controller.paymentMethods.length, equals(2));
        expect(controller.deletedPaymentMethods, isEmpty);
        expect(controller.paymentMethods.every((p) => !p.isDeleted), isTrue);
      });
    });

    // =================================================================
    // ARAMA FİLTRELEME TESTLERİ
    // =================================================================

    group('Arama Filtreleme', () {
      test('İsme göre arama çalışır', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Nakit Cüzdan',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Ziraat Bankası',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm3',
            name: 'Garanti Kredi',
            type: 'kredi',
            balance: 2000.0,
            limit: 10000.0,
            colorIndex: 2,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        controller.aramaModu = true;
        controller.aramaMetni = 'ziraat';

        expect(controller.filteredMethods.length, equals(1));
        expect(controller.filteredMethods.first.name, equals('Ziraat Bankası'));
      });

      test('Tür adına göre arama çalışır', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Cüzdan',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Ziraat',
            type: 'banka',
            balance: 5000.0,
            colorIndex: 1,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        controller.aramaModu = true;
        controller.aramaMetni = 'Banka Kartı';

        expect(controller.filteredMethods.length, equals(1));
        expect(controller.filteredMethods.first.name, equals('Ziraat'));
      });

      test('Arama modu kapatıldığında tüm PM ler gösterilir', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Nakit',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
          PaymentMethod(
            id: 'pm2',
            name: 'Banka',
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

        controller.aramaModu = false;
        expect(controller.filteredMethods.length, equals(2));
      });
    });

    // =================================================================
    // PM GÜNCELLEME TESTLERİ
    // =================================================================

    group('PM Güncelleme', () {
      test('updateMethod var olan PM yi günceller', () async {
        mockRepo.setPaymentMethods([
          PaymentMethod(
            id: 'pm1',
            name: 'Eski İsim',
            type: 'nakit',
            balance: 1000.0,
            colorIndex: 0,
            createdAt: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        final updated = controller.paymentMethods.first.copyWith(
          name: 'Yeni İsim',
          balance: 2000.0,
        );
        await controller.updateMethod(updated);

        expect(controller.paymentMethods.first.name, equals('Yeni İsim'));
        expect(controller.paymentMethods.first.balance, equals(2000.0));
      });

      test('updatePaymentMethodBalance bakiyeyi doğrudan günceller', () async {
        mockRepo.setPaymentMethods([
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

        controller.updatePaymentMethodBalance('pm1', 5000.0);

        expect(controller.paymentMethods.first.balance, equals(5000.0));
      });
    });

    // =================================================================
    // TRANSFER STATE TESTLERİ
    // =================================================================

    group('Transfer State', () {
      test('Transfer formu sıfırlanır', () {
        controller.setTransferFromAccount('pm1');
        controller.setTransferToAccount('pm2');
        controller.setTransferDate(DateTime(2024, 6, 15));

        controller.resetTransferForm();

        expect(controller.transferFromAccountId, isNull);
        expect(controller.transferToAccountId, isNull);
      });

      test('Transfer başarı mesajı set ve clear edilir', () {
        controller.setTransferSuccessMessage('Transfer başarılı!');
        expect(controller.transferSuccessMessage, equals('Transfer başarılı!'));

        controller.clearTransferSuccessMessage();
        expect(controller.transferSuccessMessage, isNull);
      });
    });

    // =================================================================
    // FORM STATE TESTLERİ
    // =================================================================

    group('Form State', () {
      test('Form state initialize ve reset doğru çalışır', () {
        controller.initializeFormState(editType: 'banka', editColorIndex: 3);

        expect(controller.formSelectedType, equals('banka'));
        expect(controller.formSelectedColorIndex, equals(3));

        controller.resetFormState();

        expect(controller.formSelectedType, equals('nakit'));
        expect(controller.formSelectedColorIndex, equals(0));
      });
    });

    // =================================================================
    // MODEL TESTLERİ
    // =================================================================

    group('PaymentMethod Model', () {
      test('typeDisplayName doğru çalışır', () {
        expect(
          PaymentMethod(
            id: '1',
            name: 'Test',
            type: 'banka',
            balance: 0,
            createdAt: DateTime.now(),
          ).typeDisplayName,
          equals('Banka Kartı'),
        );
        expect(
          PaymentMethod(
            id: '2',
            name: 'Test',
            type: 'kredi',
            balance: 0,
            createdAt: DateTime.now(),
          ).typeDisplayName,
          equals('Kredi Kartı'),
        );
        expect(
          PaymentMethod(
            id: '3',
            name: 'Test',
            type: 'nakit',
            balance: 0,
            createdAt: DateTime.now(),
          ).typeDisplayName,
          equals('Nakit'),
        );
        expect(
          PaymentMethod(
            id: '4',
            name: 'Test',
            type: 'bilinmeyen',
            balance: 0,
            createdAt: DateTime.now(),
          ).typeDisplayName,
          equals('bilinmeyen'),
        );
      });

      test('remainingLimit sadece kredi kartı için hesaplanır', () {
        final kredi = PaymentMethod(
          id: '1',
          name: 'Kredi',
          type: 'kredi',
          balance: 3000.0,
          limit: 10000.0,
          createdAt: DateTime.now(),
        );
        expect(kredi.remainingLimit, equals(7000.0));

        final nakit = PaymentMethod(
          id: '2',
          name: 'Nakit',
          type: 'nakit',
          balance: 1000.0,
          createdAt: DateTime.now(),
        );
        expect(nakit.remainingLimit, isNull);

        final banka = PaymentMethod(
          id: '3',
          name: 'Banka',
          type: 'banka',
          balance: 5000.0,
          createdAt: DateTime.now(),
        );
        expect(banka.remainingLimit, isNull);
      });

      test('toMap ve fromMap dönüşümü veri kaybetmez', () {
        final original = PaymentMethod(
          id: 'pm1',
          name: 'Test PM',
          type: 'banka',
          lastFourDigits: '1234',
          balance: 5000.0,
          limit: 10000.0,
          colorIndex: 3,
          createdAt: DateTime(2024, 6, 15),
          paraBirimi: 'USD',
          isDeleted: false,
        );

        final map = original.toMap();
        final restored = PaymentMethod.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.type, equals(original.type));
        expect(restored.lastFourDigits, equals(original.lastFourDigits));
        expect(restored.balance, equals(original.balance));
        expect(restored.limit, equals(original.limit));
        expect(restored.colorIndex, equals(original.colorIndex));
        expect(restored.paraBirimi, equals(original.paraBirimi));
        expect(restored.isDeleted, equals(original.isDeleted));
      });

      test('copyWith sadece belirtilen alanları değiştirir', () {
        final original = PaymentMethod(
          id: 'pm1',
          name: 'Nakit',
          type: 'nakit',
          balance: 1000.0,
          colorIndex: 0,
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          name: 'Nakit Cüzdan',
          balance: 2000.0,
        );

        expect(updated.name, equals('Nakit Cüzdan'));
        expect(updated.balance, equals(2000.0));
        expect(updated.type, equals('nakit')); // Değişmemeli
        expect(updated.id, equals('pm1')); // Değişmemeli
      });
    });

    // =================================================================
    // DETAIL PAGE STATE TESTLERİ
    // =================================================================

    group('Detail Page State', () {
      test('Ay seçimi güncellenir', () {
        controller.selectDetailMonth(3, 2024);

        expect(controller.detailSecilenAy, equals(3));
        expect(controller.detailSecilenYil, equals(2024));
      });

      test('Detail ay sıfırlama şu aya döner', () {
        controller.selectDetailMonth(3, 2020);
        controller.resetDetailMonth();

        final now = DateTime.now();
        expect(controller.detailSecilenAy, equals(now.month));
        expect(controller.detailSecilenYil, equals(now.year));
      });
    });
  });
}
