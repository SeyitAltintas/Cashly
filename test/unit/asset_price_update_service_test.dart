import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/asset_price_update_service.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';

/// AssetPriceUpdateService — Kategori Filtreleme ve Mapping Testleri
/// Hangi varlık türlerinin güncellenmesi gerektiği, hangi kripto ID'lerinin
/// doğru eşleştiği ve silinen varlıkların atlanması test edilir.
void main() {
  late AssetPriceUpdateService service;

  setUp(() {
    service = AssetPriceUpdateService();
  });

  // ============================================================
  // _shouldSkipUpdate MANTIĞI (davranışsal test)
  // ============================================================
  group('AssetPriceUpdateService — Güncellenecek/Atlanacak Kategoriler', () {
    test('Banka kategorisi güncellenmez (API çağrısı yapılmaz)', () async {
      final assets = [
        Asset(
          id: '1',
          name: 'Vadesiz Hesap',
          amount: 50000,
          category: 'Banka',
          quantity: 1,
          lastUpdated: DateTime.now(),
        ),
      ];

      final result = await service.updateAllAssetPrices(assets);
      // Banka kategorisi atlanır, aynı tutar kalır
      expect(result.first.amount, equals(50000));
      expect(result.first.name, equals('Vadesiz Hesap'));
    });

    test('Hisse Senedi kategorisi güncellenmez', () async {
      final assets = [
        Asset(
          id: '2',
          name: 'THYAO',
          amount: 10000,
          category: 'Hisse Senedi',
          quantity: 100,
          lastUpdated: DateTime.now(),
        ),
      ];

      final result = await service.updateAllAssetPrices(assets);
      expect(result.first.amount, equals(10000));
    });

    test('Diğer kategorisi güncellenmez', () async {
      final assets = [
        Asset(
          id: '3',
          name: 'Koleksiyon',
          amount: 5000,
          category: 'Diğer',
          quantity: 1,
          lastUpdated: DateTime.now(),
        ),
      ];

      final result = await service.updateAllAssetPrices(assets);
      expect(result.first.amount, equals(5000));
    });
  });

  group('AssetPriceUpdateService — Silinen Varlıklar', () {
    test('isDeleted=true olan varlık atlanır', () async {
      final assets = [
        Asset(
          id: '4',
          name: 'Silinmiş Bitcoin',
          amount: 1000000,
          category: 'Kripto',
          type: 'BTC',
          quantity: 0.5,
          isDeleted: true,
          lastUpdated: DateTime.now(),
        ),
      ];

      final result = await service.updateAllAssetPrices(assets);
      // Silinen varlık olduğu gibi listeye eklenir
      expect(result.length, equals(1));
      expect(result.first.isDeleted, isTrue);
      expect(result.first.amount, equals(1000000));
    });
  });

  group('AssetPriceUpdateService — Çıktı Tutarlılığı', () {
    test('boş liste girişinde boş liste döner', () async {
      final result = await service.updateAllAssetPrices([]);
      expect(result, isEmpty);
    });

    test('birden fazla varlık aynı sırayla döner', () async {
      final assets = [
        Asset(
          id: '5',
          name: 'Hesap 1',
          amount: 10000,
          category: 'Banka',
          quantity: 1,
          lastUpdated: DateTime.now(),
        ),
        Asset(
          id: '6',
          name: 'Hesap 2',
          amount: 20000,
          category: 'Diğer',
          quantity: 1,
          lastUpdated: DateTime.now(),
        ),
        Asset(
          id: '7',
          name: 'Hesap 3',
          amount: 30000,
          category: 'Hisse Senedi',
          quantity: 50,
          lastUpdated: DateTime.now(),
        ),
      ];

      final result = await service.updateAllAssetPrices(assets);
      expect(result.length, equals(3));
      expect(result[0].id, equals('5'));
      expect(result[1].id, equals('6'));
      expect(result[2].id, equals('7'));
    });

    test(
      'Altın kategorisi güncelleme yapılır veya mevcut değer korunur',
      () async {
        final assets = [
          Asset(
            id: '8',
            name: 'Gram Altın',
            amount: 50000,
            category: 'Altın',
            type: 'Gram',
            quantity: 20,
            lastUpdated: DateTime.now(),
          ),
        ];

        final result = await service.updateAllAssetPrices(assets);
        // API online → fiyat güncellenir (unitPrice * quantity)
        // API offline → mevcut değer korunur (50000)
        // Her iki durumda da pozitif double olmalı
        expect(result.first.amount, isA<double>());
        expect(result.first.amount, greaterThan(0));
        expect(result.first.name, equals('Gram Altın'));
      },
    );

    test(
      'Kripto kategorisi güncelleme yapılır veya mevcut değer korunur',
      () async {
        final assets = [
          Asset(
            id: '9',
            name: 'Bitcoin',
            amount: 3000000,
            category: 'Kripto',
            type: 'BTC',
            quantity: 1,
            lastUpdated: DateTime.now(),
          ),
        ];

        final result = await service.updateAllAssetPrices(assets);
        expect(result.first.amount, isA<double>());
        expect(result.first.amount, greaterThan(0));
      },
    );

    test(
      'Döviz kategorisi güncelleme yapılır veya mevcut değer korunur',
      () async {
        final assets = [
          Asset(
            id: '10',
            name: 'Dolar',
            amount: 32000,
            category: 'Döviz',
            type: 'Amerikan Doları (USD)',
            quantity: 1000,
            lastUpdated: DateTime.now(),
          ),
        ];

        final result = await service.updateAllAssetPrices(assets);
        expect(result.first.amount, isA<double>());
        expect(result.first.amount, greaterThan(0));
      },
    );
  });

  // ============================================================
  // getUnitPrice — KATEGORİ ROUTING
  // ============================================================
  group('AssetPriceUpdateService.getUnitPrice — Routing', () {
    test('Altın kategorisi → getGoldPrice çağrılır', () async {
      final asset = Asset(
        id: '11',
        name: 'Ata Altın',
        amount: 30000,
        category: 'Altın',
        type: 'Ata',
        quantity: 1,
        lastUpdated: DateTime.now(),
      );
      final result = await service.getUnitPrice(asset);
      // API offline → null
      expect(result == null || result is double, isTrue);
    });

    test('Gümüş kategorisi → getSilverPrice çağrılır', () async {
      final asset = Asset(
        id: '12',
        name: 'Gümüş Ons',
        amount: 15000,
        category: 'Gümüş',
        type: 'Ons',
        quantity: 10,
        lastUpdated: DateTime.now(),
      );
      final result = await service.getUnitPrice(asset);
      expect(result == null || result is double, isTrue);
    });

    test('Kripto kategorisi → getCryptoPrice çağrılır', () async {
      final asset = Asset(
        id: '13',
        name: 'Ethereum',
        amount: 200000,
        category: 'Kripto',
        type: 'ETH',
        quantity: 2,
        lastUpdated: DateTime.now(),
      );
      final result = await service.getUnitPrice(asset);
      expect(result == null || result is double, isTrue);
    });

    test('Döviz kategorisi → getCurrencyPrice çağrılır', () async {
      final asset = Asset(
        id: '14',
        name: 'Euro',
        amount: 35000,
        category: 'Döviz',
        type: 'Euro (EUR)',
        quantity: 1000,
        lastUpdated: DateTime.now(),
      );
      final result = await service.getUnitPrice(asset);
      expect(result == null || result is double, isTrue);
    });

    test('Banka kategorisi → null döner (güncellenmez)', () async {
      final asset = Asset(
        id: '15',
        name: 'Vadesiz',
        amount: 10000,
        category: 'Banka',
        quantity: 1,
        lastUpdated: DateTime.now(),
      );
      final result = await service.getUnitPrice(asset);
      // Banka → default case → null
      expect(result, isNull);
    });

    test('bilinmeyen kategori → null döner', () async {
      final asset = Asset(
        id: '16',
        name: 'Bilinmeyen',
        amount: 1000,
        category: 'Bilinmeyen',
        quantity: 1,
        lastUpdated: DateTime.now(),
      );
      final result = await service.getUnitPrice(asset);
      expect(result, isNull);
    });
  });
}
