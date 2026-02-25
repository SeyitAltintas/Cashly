import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/income/data/models/income_model.dart';

/// Income Model — Kapsamlı Unit Testleri
void main() {
  final testDate = DateTime(2024, 6, 15, 10, 30);

  group('Income — Constructor', () {
    test('tüm alanlar doğru set edilir', () {
      final income = Income(
        id: 'i-1',
        name: 'Maaş',
        amount: 25000,
        category: 'Maaş',
        date: testDate,
      );
      expect(income.id, 'i-1');
      expect(income.name, 'Maaş');
      expect(income.amount, 25000.0);
      expect(income.category, 'Maaş');
      expect(income.date, testDate);
      expect(income.paymentMethodId, isNull);
      expect(income.paraBirimi, 'TRY');
      expect(income.isDeleted, isFalse);
    });

    test('opsiyonel alanlar doğru çalışır', () {
      final income = Income(
        id: 'i-2',
        name: 'Freelance',
        amount: 5000,
        category: 'Serbest',
        date: testDate,
        paymentMethodId: 'pm-1',
        paraBirimi: 'USD',
        isDeleted: true,
      );
      expect(income.paymentMethodId, 'pm-1');
      expect(income.paraBirimi, 'USD');
      expect(income.isDeleted, isTrue);
    });
  });

  group('Income — toMap / fromMap', () {
    test('round-trip tutarlı', () {
      final original = Income(
        id: 'i-3',
        name: 'Kira Geliri',
        amount: 8000,
        category: 'Yatırım',
        date: testDate,
        paymentMethodId: 'pm-2',
      );
      final map = original.toMap();
      final restored = Income.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.paymentMethodId, original.paymentMethodId);
      expect(restored.paraBirimi, original.paraBirimi);
      expect(restored.isDeleted, original.isDeleted);
    });

    test('toMap tüm anahtarları içerir', () {
      final income = Income(
        id: 'i-4',
        name: 'Test',
        amount: 100,
        category: 'Test',
        date: testDate,
      );
      final map = income.toMap();
      expect(map.containsKey('id'), isTrue);
      expect(map.containsKey('name'), isTrue);
      expect(map.containsKey('amount'), isTrue);
      expect(map.containsKey('category'), isTrue);
      expect(map.containsKey('date'), isTrue);
      expect(map.containsKey('paymentMethodId'), isTrue);
      expect(map.containsKey('paraBirimi'), isTrue);
      expect(map.containsKey('isDeleted'), isTrue);
    });

    test('fromMap eksik alanlar için varsayılan değerler', () {
      final income = Income.fromMap({'amount': 100});
      expect(income.name, '');
      expect(income.category, 'Diğer');
      expect(income.paraBirimi, 'TRY');
      expect(income.isDeleted, isFalse);
    });
  });

  group('Income — copyWith', () {
    test('tek alan güncellenir, diğerleri korunur', () {
      final original = Income(
        id: 'i-5',
        name: 'Maaş',
        amount: 20000,
        category: 'Maaş',
        date: testDate,
      );
      final updated = original.copyWith(amount: 25000);
      expect(updated.amount, 25000.0);
      expect(updated.name, 'Maaş');
      expect(updated.id, 'i-5');
    });

    test('birden fazla alan güncellenir', () {
      final original = Income(
        id: 'i-6',
        name: 'Eski',
        amount: 1000,
        category: 'Eski',
        date: testDate,
      );
      final updated = original.copyWith(
        name: 'Yeni',
        amount: 5000,
        isDeleted: true,
      );
      expect(updated.name, 'Yeni');
      expect(updated.amount, 5000.0);
      expect(updated.isDeleted, isTrue);
      expect(updated.category, 'Eski');
    });
  });
}
