import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';

/// Asset Model — Kapsamlı Unit Testleri
/// Constructor, toMap/fromMap serialization, copyWith, Kar/Zarar hesaplama,
/// birim fiyat hesaplamaları ve edge case'ler
void main() {
  final now = DateTime(2024, 6, 15, 10, 30);

  Asset createTestAsset({
    String id = 'test-1',
    String name = 'Test Varlık',
    double amount = 100000,
    double quantity = 10,
    String category = 'Altın',
    String? type = 'Gram',
    double? purchasePrice,
    String paraBirimi = 'TRY',
    bool isDeleted = false,
  }) {
    return Asset(
      id: id,
      name: name,
      amount: amount,
      quantity: quantity,
      category: category,
      type: type,
      lastUpdated: now,
      purchaseDate: now,
      purchasePrice: purchasePrice,
      paraBirimi: paraBirimi,
      isDeleted: isDeleted,
    );
  }

  // ============================================================
  // CONSTRUCTOR
  // ============================================================
  group('Asset — Constructor', () {
    test('tüm alanlar doğru set edilir', () {
      final asset = createTestAsset();
      expect(asset.id, equals('test-1'));
      expect(asset.name, equals('Test Varlık'));
      expect(asset.amount, equals(100000));
      expect(asset.quantity, equals(10));
      expect(asset.category, equals('Altın'));
      expect(asset.type, equals('Gram'));
      expect(asset.paraBirimi, equals('TRY'));
      expect(asset.isDeleted, isFalse);
    });

    test('purchasePrice null ise amount kullanılır', () {
      final asset = createTestAsset(amount: 50000, purchasePrice: null);
      expect(asset.purchasePrice, equals(50000));
    });

    test('purchaseDate null ise lastUpdated kullanılır', () {
      final asset = Asset(
        id: '1',
        name: 'Test',
        amount: 1000,
        category: 'Banka',
        lastUpdated: now,
      );
      expect(asset.purchaseDate, equals(now));
    });

    test('varsayılan quantity 1.0', () {
      final asset = Asset(
        id: '1',
        name: 'Test',
        amount: 1000,
        category: 'Banka',
        lastUpdated: now,
      );
      expect(asset.quantity, equals(1.0));
    });

    test('varsayılan paraBirimi TRY', () {
      final asset = Asset(
        id: '1',
        name: 'Test',
        amount: 1000,
        category: 'Banka',
        lastUpdated: now,
      );
      expect(asset.paraBirimi, equals('TRY'));
    });
  });

  // ============================================================
  // KAR/ZARAR HESAPLAMA
  // ============================================================
  group('Asset — Kar/Zarar Hesaplamaları', () {
    test('kârda: amount > purchasePrice', () {
      final asset = createTestAsset(amount: 150000, purchasePrice: 100000);
      expect(asset.profitLoss, equals(50000));
      expect(asset.profitLossPercentage, equals(50.0));
    });

    test('zararda: amount < purchasePrice', () {
      final asset = createTestAsset(amount: 80000, purchasePrice: 100000);
      expect(asset.profitLoss, equals(-20000));
      expect(asset.profitLossPercentage, equals(-20.0));
    });

    test('başa baş: amount == purchasePrice', () {
      final asset = createTestAsset(amount: 100000, purchasePrice: 100000);
      expect(asset.profitLoss, equals(0));
      expect(asset.profitLossPercentage, equals(0.0));
    });

    test('purchasePrice 0 ise yüzde 0 döner (sıfıra bölme koruması)', () {
      final asset = createTestAsset(amount: 50000, purchasePrice: 0);
      expect(asset.profitLoss, equals(50000));
      expect(asset.profitLossPercentage, equals(0)); // sıfıra bölme yok
    });
  });

  // ============================================================
  // BİRİM FİYAT HESAPLAMA
  // ============================================================
  group('Asset — Birim Fiyat', () {
    test('unitPurchasePrice doğru hesaplanır', () {
      final asset = createTestAsset(quantity: 10, purchasePrice: 100000);
      expect(asset.unitPurchasePrice, equals(10000)); // 100000 / 10
    });

    test('unitCurrentPrice doğru hesaplanır', () {
      final asset = createTestAsset(amount: 150000, quantity: 10);
      expect(asset.unitCurrentPrice, equals(15000)); // 150000 / 10
    });

    test('quantity 1 ise birim fiyat = toplam fiyat', () {
      final asset = createTestAsset(
        amount: 50000,
        quantity: 1,
        purchasePrice: 40000,
      );
      expect(asset.unitCurrentPrice, equals(50000));
      expect(asset.unitPurchasePrice, equals(40000));
    });

    test('küçük quantity (0.5 Bitcoin gibi)', () {
      final asset = createTestAsset(
        amount: 1500000,
        quantity: 0.5,
        purchasePrice: 1000000,
      );
      expect(asset.unitCurrentPrice, equals(3000000)); // 1.5M / 0.5
      expect(asset.unitPurchasePrice, equals(2000000)); // 1M / 0.5
    });
  });

  // ============================================================
  // SERIALIZATION: toMap / fromMap
  // ============================================================
  group('Asset — toMap / fromMap Round-trip', () {
    test('toMap doğru key-value döndürür', () {
      final asset = createTestAsset();
      final map = asset.toMap();

      expect(map['id'], equals('test-1'));
      expect(map['name'], equals('Test Varlık'));
      expect(map['amount'], equals(100000));
      expect(map['quantity'], equals(10));
      expect(map['category'], equals('Altın'));
      expect(map['type'], equals('Gram'));
      expect(map['paraBirimi'], equals('TRY'));
      expect(map['isDeleted'], isFalse);
      expect(map['purchasePrice'], equals(100000));
      expect(map['lastUpdated'], isA<String>());
      expect(map['purchaseDate'], isA<String>());
    });

    test('fromMap → toMap round-trip tutarlı', () {
      final original = createTestAsset(amount: 75000, purchasePrice: 60000);
      final map = original.toMap();
      final restored = Asset.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.amount, equals(original.amount));
      expect(restored.quantity, equals(original.quantity));
      expect(restored.category, equals(original.category));
      expect(restored.type, equals(original.type));
      expect(restored.purchasePrice, equals(original.purchasePrice));
      expect(restored.paraBirimi, equals(original.paraBirimi));
      expect(restored.isDeleted, equals(original.isDeleted));
    });

    test(
      'fromMap geriye dönük uyumluluk: purchasePrice yok → amount kullanılır',
      () {
        final map = {
          'id': 'legacy-1',
          'name': 'Eski Varlık',
          'amount': 25000.0,
          'category': 'Banka',
          'lastUpdated': now.toIso8601String(),
        };
        final asset = Asset.fromMap(map);
        expect(asset.purchasePrice, equals(25000.0));
        expect(asset.quantity, equals(1.0));
        expect(asset.paraBirimi, equals('TRY'));
        expect(asset.isDeleted, isFalse);
      },
    );
  });

  // ============================================================
  // COPYWITH
  // ============================================================
  group('Asset — copyWith', () {
    test('amount güncellenir, diğerleri korunur', () {
      final original = createTestAsset(amount: 100000);
      final updated = original.copyWith(amount: 120000);

      expect(updated.amount, equals(120000));
      expect(updated.name, equals(original.name));
      expect(updated.id, equals(original.id));
      expect(updated.quantity, equals(original.quantity));
    });

    test('birden fazla alan güncellenir', () {
      final original = createTestAsset();
      final updated = original.copyWith(
        name: 'Yeni İsim',
        amount: 200000,
        isDeleted: true,
      );

      expect(updated.name, equals('Yeni İsim'));
      expect(updated.amount, equals(200000));
      expect(updated.isDeleted, isTrue);
      expect(updated.category, equals(original.category)); // korunur
    });

    test('lastUpdated güncellenir', () {
      final original = createTestAsset();
      final newDate = DateTime(2025, 1, 1);
      final updated = original.copyWith(lastUpdated: newDate);

      expect(updated.lastUpdated, equals(newDate));
    });
  });
}
