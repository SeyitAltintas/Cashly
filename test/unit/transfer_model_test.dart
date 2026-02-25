import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/payment_methods/data/models/transfer_model.dart';

/// Transfer Model — Kapsamlı Unit Testleri
void main() {
  group('Transfer — Constructor', () {
    test('tüm alanlar doğru set edilir', () {
      final transfer = Transfer(
        id: 't-1',
        fromAccountId: 'a-1',
        toAccountId: 'a-2',
        amount: 1000,
        date: DateTime(2024, 6, 15),
      );
      expect(transfer.id, 't-1');
      expect(transfer.fromAccountId, 'a-1');
      expect(transfer.toAccountId, 'a-2');
      expect(transfer.amount, 1000.0);
      expect(transfer.description, isNull);
      expect(transfer.paraBirimi, 'TRY');
      expect(transfer.isScheduled, isFalse);
      expect(transfer.isExecuted, isFalse);
      expect(transfer.isFailed, isFalse);
      expect(transfer.failureReason, isNull);
    });
  });

  group('Transfer — isDue', () {
    test('geçmiş tarih → isDue = true', () {
      final transfer = Transfer(
        id: 't-2',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 500,
        date: DateTime(2020, 1, 1),
      );
      expect(transfer.isDue, isTrue);
    });

    test('bugünkü tarih → isDue = true', () {
      final now = DateTime.now();
      final transfer = Transfer(
        id: 't-3',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 500,
        date: DateTime(now.year, now.month, now.day),
      );
      expect(transfer.isDue, isTrue);
    });

    test('gelecek tarih → isDue = false', () {
      final transfer = Transfer(
        id: 't-4',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 500,
        date: DateTime(2099, 12, 31),
      );
      expect(transfer.isDue, isFalse);
    });
  });

  group('Transfer — isPending', () {
    test('zamanlanmış + tarihi gelmiş + uygulanmamış = pending', () {
      final transfer = Transfer(
        id: 't-5',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 1000,
        date: DateTime(2020, 1, 1),
        isScheduled: true,
      );
      expect(transfer.isPending, isTrue);
    });

    test('zamanlanmış + uygulanmış = NOT pending', () {
      final transfer = Transfer(
        id: 't-6',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 1000,
        date: DateTime(2020, 1, 1),
        isScheduled: true,
        isExecuted: true,
      );
      expect(transfer.isPending, isFalse);
    });

    test('zamanlanmış + başarısız = NOT pending', () {
      final transfer = Transfer(
        id: 't-7',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 1000,
        date: DateTime(2020, 1, 1),
        isScheduled: true,
        isFailed: true,
        failureReason: 'Yetersiz bakiye',
      );
      expect(transfer.isPending, isFalse);
    });

    test('zamanlanmamış → NOT pending', () {
      final transfer = Transfer(
        id: 't-8',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 1000,
        date: DateTime(2020, 1, 1),
      );
      expect(transfer.isPending, isFalse);
    });

    test('zamanlanmış + tarihi gelmemiş = NOT pending', () {
      final transfer = Transfer(
        id: 't-9',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 1000,
        date: DateTime(2099, 12, 31),
        isScheduled: true,
      );
      expect(transfer.isPending, isFalse);
    });
  });

  group('Transfer — toMap / fromMap', () {
    test('round-trip tutarlı', () {
      final original = Transfer(
        id: 't-10',
        fromAccountId: 'from-1',
        toAccountId: 'to-1',
        amount: 5000,
        date: DateTime(2024, 3, 15),
        description: 'Kira ödemesi',
        paraBirimi: 'USD',
        isScheduled: true,
        isExecuted: true,
      );
      final map = original.toMap();
      final restored = Transfer.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.fromAccountId, original.fromAccountId);
      expect(restored.toAccountId, original.toAccountId);
      expect(restored.amount, original.amount);
      expect(restored.description, original.description);
      expect(restored.paraBirimi, original.paraBirimi);
      expect(restored.isScheduled, original.isScheduled);
      expect(restored.isExecuted, original.isExecuted);
    });

    test('fromMap varsayılan değerler', () {
      final transfer = Transfer.fromMap({});
      expect(transfer.amount, 0.0);
      expect(transfer.fromAccountId, '');
      expect(transfer.paraBirimi, 'TRY');
      expect(transfer.isScheduled, isFalse);
      expect(transfer.isFailed, isFalse);
    });
  });

  group('Transfer — copyWith', () {
    test('isExecuted güncellenir', () {
      final original = Transfer(
        id: 't-11',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 1000,
        date: DateTime.now(),
        isScheduled: true,
      );
      final executed = original.copyWith(isExecuted: true);
      expect(executed.isExecuted, isTrue);
      expect(executed.isScheduled, isTrue);
      expect(executed.amount, 1000.0);
    });

    test('failureReason eklenir', () {
      final original = Transfer(
        id: 't-12',
        fromAccountId: 'a',
        toAccountId: 'b',
        amount: 1000,
        date: DateTime.now(),
      );
      final failed = original.copyWith(
        isFailed: true,
        failureReason: 'Hesap silinmiş',
      );
      expect(failed.isFailed, isTrue);
      expect(failed.failureReason, 'Hesap silinmiş');
    });
  });
}
