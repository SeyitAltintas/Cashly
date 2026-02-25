import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';

/// PaymentMethod Model — Kapsamlı Unit Testleri
void main() {
  final now = DateTime(2024, 6, 15);

  group('PaymentMethod — Constructor', () {
    test('tüm zorunlu alanlar doğru set edilir', () {
      final pm = PaymentMethod(
        id: 'pm-1',
        name: 'Ziraat Bankası',
        type: 'banka',
        balance: 50000,
        createdAt: now,
      );
      expect(pm.id, 'pm-1');
      expect(pm.name, 'Ziraat Bankası');
      expect(pm.type, 'banka');
      expect(pm.balance, 50000.0);
      expect(pm.lastFourDigits, isNull);
      expect(pm.limit, isNull);
      expect(pm.colorIndex, 0);
      expect(pm.paraBirimi, 'TRY');
      expect(pm.isDeleted, isFalse);
    });

    test('kredi kartı opsiyonel alanları', () {
      final pm = PaymentMethod(
        id: 'pm-2',
        name: 'Yapı Kredi',
        type: 'kredi',
        balance: 3000,
        limit: 20000,
        lastFourDigits: '4567',
        colorIndex: 3,
        createdAt: now,
      );
      expect(pm.lastFourDigits, '4567');
      expect(pm.limit, 20000.0);
      expect(pm.colorIndex, 3);
    });
  });

  group('PaymentMethod — typeDisplayName', () {
    test('banka → "Banka Kartı"', () {
      final pm = PaymentMethod(
        id: '1',
        name: 'T',
        type: 'banka',
        balance: 0,
        createdAt: now,
      );
      expect(pm.typeDisplayName, 'Banka Kartı');
    });

    test('kredi → "Kredi Kartı"', () {
      final pm = PaymentMethod(
        id: '2',
        name: 'T',
        type: 'kredi',
        balance: 0,
        createdAt: now,
      );
      expect(pm.typeDisplayName, 'Kredi Kartı');
    });

    test('nakit → "Nakit"', () {
      final pm = PaymentMethod(
        id: '3',
        name: 'T',
        type: 'nakit',
        balance: 0,
        createdAt: now,
      );
      expect(pm.typeDisplayName, 'Nakit');
    });

    test('bilinmeyen tip → tip adı döner', () {
      final pm = PaymentMethod(
        id: '4',
        name: 'T',
        type: 'dijital_cüzdan',
        balance: 0,
        createdAt: now,
      );
      expect(pm.typeDisplayName, 'dijital_cüzdan');
    });
  });

  group('PaymentMethod — remainingLimit', () {
    test('kredi kartı: kalan limit = limit - balance', () {
      final pm = PaymentMethod(
        id: '5',
        name: 'Kart',
        type: 'kredi',
        balance: 5000,
        limit: 20000,
        createdAt: now,
      );
      expect(pm.remainingLimit, 15000.0);
    });

    test('kredi kartı: limit tamamen kullanılmış', () {
      final pm = PaymentMethod(
        id: '6',
        name: 'Kart',
        type: 'kredi',
        balance: 20000,
        limit: 20000,
        createdAt: now,
      );
      expect(pm.remainingLimit, 0.0);
    });

    test('kredi kartı: limit aşılmış (negatif kalan)', () {
      final pm = PaymentMethod(
        id: '7',
        name: 'Kart',
        type: 'kredi',
        balance: 25000,
        limit: 20000,
        createdAt: now,
      );
      expect(pm.remainingLimit, -5000.0);
    });

    test('banka kartı: remainingLimit null', () {
      final pm = PaymentMethod(
        id: '8',
        name: 'Banka',
        type: 'banka',
        balance: 50000,
        createdAt: now,
      );
      expect(pm.remainingLimit, isNull);
    });

    test('nakit: remainingLimit null', () {
      final pm = PaymentMethod(
        id: '9',
        name: 'Nakit',
        type: 'nakit',
        balance: 1000,
        createdAt: now,
      );
      expect(pm.remainingLimit, isNull);
    });

    test('kredi ama limit null → null', () {
      final pm = PaymentMethod(
        id: '10',
        name: 'Kart',
        type: 'kredi',
        balance: 5000,
        createdAt: now,
      );
      expect(pm.remainingLimit, isNull);
    });
  });

  group('PaymentMethod — toMap / fromMap', () {
    test('round-trip tutarlı', () {
      final original = PaymentMethod(
        id: 'pm-10',
        name: 'İş Bankası',
        type: 'banka',
        balance: 75000,
        lastFourDigits: '1234',
        colorIndex: 2,
        createdAt: now,
        paraBirimi: 'EUR',
      );
      final map = original.toMap();
      final restored = PaymentMethod.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.balance, original.balance);
      expect(restored.lastFourDigits, original.lastFourDigits);
      expect(restored.colorIndex, original.colorIndex);
      expect(restored.paraBirimi, original.paraBirimi);
    });

    test('fromMap geriye dönük uyumluluk', () {
      final map = {
        'id': 'old-1',
        'name': 'Eski',
        'type': 'nakit',
        'balance': 1000,
      };
      final pm = PaymentMethod.fromMap(map);
      expect(pm.colorIndex, 0);
      expect(pm.paraBirimi, 'TRY');
      expect(pm.isDeleted, isFalse);
    });
  });

  group('PaymentMethod — copyWith', () {
    test('bakiye güncellenir', () {
      final original = PaymentMethod(
        id: 'pm-11',
        name: 'Test',
        type: 'banka',
        balance: 10000,
        createdAt: now,
      );
      final updated = original.copyWith(balance: 15000);
      expect(updated.balance, 15000.0);
      expect(updated.name, 'Test');
    });

    test('isDeleted güncellenir', () {
      final original = PaymentMethod(
        id: 'pm-12',
        name: 'Test',
        type: 'banka',
        balance: 5000,
        createdAt: now,
      );
      final updated = original.copyWith(isDeleted: true);
      expect(updated.isDeleted, isTrue);
    });
  });
}
