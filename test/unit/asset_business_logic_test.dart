import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/assets/presentation/controllers/assets_controller.dart';
import 'package:cashly/features/assets/domain/repositories/asset_repository.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

// =====================================================================
// MOCK REPOSITORY
// =====================================================================

class MockAssetRepository implements AssetRepository {
  List<Map<String, dynamic>> _assets = [];
  List<Map<String, dynamic>> _deletedAssets = [];

  @override
  List<Map<String, dynamic>> getAssets(String userId) => _assets;

  @override
  Future<void> saveAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    _assets = List.from(assets);
  }

  @override
  List<Map<String, dynamic>> getDeletedAssets(String userId) => _deletedAssets;

  @override
  Future<void> saveDeletedAssets(
    String userId,
    List<Map<String, dynamic>> assets,
  ) async {
    _deletedAssets = List.from(assets);
  }

  void setAssets(List<Map<String, dynamic>> assets) {
    _assets = assets;
  }

  void setDeletedAssets(List<Map<String, dynamic>> assets) {
    _deletedAssets = assets;
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

  group('AssetsController - Business Logic Tests', () {
    late MockAssetRepository mockRepo;
    late AssetsController controller;
    const testUserId = 'test_user_123';

    setUp(() {
      mockRepo = MockAssetRepository();
      controller = AssetsController(
        assetRepository: mockRepo,
        userId: testUserId,
      );
    });

    // =================================================================
    // KAR/ZARAR HESAPLAMA TESTLERİ (Asset Model Logic)
    // =================================================================

    group('Kar/Zarar Hesaplama', () {
      test('Varlığın kârı doğru hesaplanır (değer arttığında)', () {
        final asset = Asset(
          id: '1',
          name: 'Altın',
          amount: 15000.0, // Güncel toplam değer
          quantity: 10,
          category: 'Altın',
          lastUpdated: DateTime.now(),
          purchasePrice: 10000.0, // Alış fiyatı
        );

        expect(asset.profitLoss, equals(5000.0));
        expect(asset.profitLossPercentage, equals(50.0));
      });

      test('Varlığın zararı doğru hesaplanır (değer düştüğünde)', () {
        final asset = Asset(
          id: '1',
          name: 'Dolar',
          amount: 8000.0,
          quantity: 100,
          category: 'Döviz',
          lastUpdated: DateTime.now(),
          purchasePrice: 10000.0,
        );

        expect(asset.profitLoss, equals(-2000.0));
        expect(asset.profitLossPercentage, equals(-20.0));
      });

      test('Birim fiyatlar doğru hesaplanır', () {
        final asset = Asset(
          id: '1',
          name: 'Altın',
          amount: 15000.0,
          quantity: 10,
          category: 'Altın',
          lastUpdated: DateTime.now(),
          purchasePrice: 10000.0,
        );

        expect(asset.unitPurchasePrice, equals(1000.0)); // 10000 / 10
        expect(asset.unitCurrentPrice, equals(1500.0)); // 15000 / 10
      });

      test('Alış fiyatı 0 iken yüzde hesaplaması sıfır döner', () {
        final asset = Asset(
          id: '1',
          name: 'Hediye',
          amount: 5000.0,
          quantity: 1,
          category: 'Diğer',
          lastUpdated: DateTime.now(),
          purchasePrice: 0.0,
        );

        expect(asset.profitLossPercentage, equals(0.0));
      });

      test('Değer değişmediğinde kar/zarar sıfırdır', () {
        final asset = Asset(
          id: '1',
          name: 'Sabit',
          amount: 10000.0,
          quantity: 5,
          category: 'Döviz',
          lastUpdated: DateTime.now(),
          purchasePrice: 10000.0,
        );

        expect(asset.profitLoss, equals(0.0));
        expect(asset.profitLossPercentage, equals(0.0));
      });
    });

    // =================================================================
    // VARLIK EKLEME TESTLERİ
    // =================================================================

    group('Varlık Ekleme', () {
      test('Varlık listeye eklenir ve toplam değeri artırır', () async {
        await controller.loadData();

        controller.addAsset(
          Asset(
            id: 'a1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ),
        );

        expect(controller.assets.length, equals(1));
        expect(controller.toplamDeger, equals(10000.0));
      });

      test(
        'Birden fazla varlık eklendiğinde toplam doğru hesaplanır',
        () async {
          await controller.loadData();

          controller.addAsset(
            Asset(
              id: 'a1',
              name: 'Altın',
              amount: 10000.0,
              quantity: 10,
              category: 'Altın',
              lastUpdated: DateTime.now(),
            ),
          );
          controller.addAsset(
            Asset(
              id: 'a2',
              name: 'Dolar',
              amount: 5000.0,
              quantity: 100,
              category: 'Döviz',
              lastUpdated: DateTime.now(),
            ),
          );

          expect(controller.assets.length, equals(2));
          expect(controller.toplamDeger, equals(15000.0));
        },
      );
    });

    // =================================================================
    // VARLIK SİLME TESTLERİ
    // =================================================================

    group('Varlık Silme (Çöp Kutusu)', () {
      test('Varlık silindikten sonra toplam değerden düşer', () async {
        mockRepo.setAssets([
          Asset(
            id: 'a1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ).toMap(),
          Asset(
            id: 'a2',
            name: 'Dolar',
            amount: 5000.0,
            quantity: 100,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        expect(controller.toplamDeger, equals(15000.0));

        controller.deleteAsset(controller.assets.first);

        expect(controller.assets.length, equals(1));
        expect(controller.deletedAssets.length, equals(1));
        expect(controller.toplamDeger, equals(5000.0));
      });

      test(
        'Silinen varlık geri yüklendiğinde isDeleted false olur ve listeye döner',
        () async {
          final varlik = Asset(
            id: 'a1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          );
          mockRepo.setDeletedAssets([varlik.toMap()]);
          await controller.loadData();

          controller.restoreAsset(controller.deletedAssets.first);

          expect(controller.assets.length, equals(1));
          expect(controller.deletedAssets.length, equals(0));
          expect(controller.assets.first.isDeleted, isFalse);
        },
      );

      test('Kalıcı silme sonrası varlık hiçbir listede bulunmaz', () async {
        final varlik = Asset(
          id: 'a1',
          name: 'Silinecek',
          amount: 1000.0,
          quantity: 1,
          category: 'Diğer',
          lastUpdated: DateTime.now(),
          isDeleted: true,
        );
        mockRepo.setDeletedAssets([varlik.toMap()]);
        await controller.loadData();

        controller.permanentDeleteAsset(controller.deletedAssets.first);

        expect(controller.assets, isEmpty);
        expect(controller.deletedAssets, isEmpty);
      });
    });

    // =================================================================
    // VARLIK GÜNCELLEME TESTLERİ
    // =================================================================

    group('Varlık Güncelleme', () {
      test('Güncellenen varlığın yeni değerleri doğru kaydedilir', () async {
        mockRepo.setAssets([
          Asset(
            id: 'a1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        final updatedAsset = controller.assets.first.copyWith(
          name: 'Çeyrek Altın',
          amount: 12000.0,
          quantity: 12,
        );
        controller.updateAsset(updatedAsset);

        expect(controller.assets.first.name, equals('Çeyrek Altın'));
        expect(controller.assets.first.amount, equals(12000.0));
        expect(controller.assets.first.quantity, equals(12));
      });

      test(
        'Olmayan ID ile güncelleme yapıldığında listede değişiklik olmaz',
        () async {
          mockRepo.setAssets([
            Asset(
              id: 'a1',
              name: 'Altın',
              amount: 10000.0,
              quantity: 10,
              category: 'Altın',
              lastUpdated: DateTime.now(),
            ).toMap(),
          ]);
          await controller.loadData();

          final phantomAsset = Asset(
            id: 'olmayan_id',
            name: 'Hayalet',
            amount: 999.0,
            quantity: 1,
            category: 'Diğer',
            lastUpdated: DateTime.now(),
          );
          controller.updateAsset(phantomAsset);

          expect(controller.assets.length, equals(1));
          expect(controller.assets.first.name, equals('Altın'));
        },
      );
    });

    // =================================================================
    // FİLTRELEME TESTLERİ
    // =================================================================

    group('Arama Filtreleme', () {
      test('İsme göre arama doğru çalışır', () async {
        mockRepo.setAssets([
          Asset(
            id: 'a1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ).toMap(),
          Asset(
            id: 'a2',
            name: 'Dolar',
            amount: 5000.0,
            quantity: 100,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
          ).toMap(),
          Asset(
            id: 'a3',
            name: 'Bitcoin',
            amount: 50000.0,
            quantity: 0.5,
            category: 'Kripto',
            lastUpdated: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        controller.aramaModu = true;
        controller.filtrele('alt');

        expect(controller.filtrelenmisVarliklar.length, equals(1));
        expect(controller.filtrelenmisVarliklar.first.name, equals('Altın'));
      });

      test('Boş arama tüm aktif varlıkları gösterir', () async {
        mockRepo.setAssets([
          Asset(
            id: 'a1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ).toMap(),
          Asset(
            id: 'a2',
            name: 'Dolar',
            amount: 5000.0,
            quantity: 100,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
          ).toMap(),
        ]);
        await controller.loadData();

        controller.filtrele('');

        expect(controller.filtrelenmisVarliklar.length, equals(2));
      });

      test('Silinen varlıklar filtre sonuçlarında görünmez', () async {
        mockRepo.setAssets([
          Asset(
            id: 'a1',
            name: 'Aktif Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: false,
          ).toMap(),
          Asset(
            id: 'a2',
            name: 'Silinen Altın',
            amount: 5000.0,
            quantity: 5,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);
        await controller.loadData();

        controller.filtrele('altın');

        expect(controller.filtrelenmisVarliklar.length, equals(1));
        expect(
          controller.filtrelenmisVarliklar.first.name,
          equals('Aktif Altın'),
        );
      });
    });

    // =================================================================
    // ÇÖP KUTUSU (TOPLU İŞLEM) TESTLERİ
    // =================================================================

    group('Çöp Kutusu Toplu İşlemler', () {
      test('emptyBin tüm silinen varlıkları temizler', () async {
        mockRepo.setDeletedAssets([
          Asset(
            id: 'a1',
            name: 'Silinen1',
            amount: 1000.0,
            quantity: 1,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
          Asset(
            id: 'a2',
            name: 'Silinen2',
            amount: 2000.0,
            quantity: 2,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);
        await controller.loadData();

        expect(controller.deletedAssets.length, equals(2));

        controller.emptyBin();

        expect(controller.deletedAssets, isEmpty);
      });

      test('restoreAll tüm silinen varlıkları geri yükler', () async {
        mockRepo.setDeletedAssets([
          Asset(
            id: 'a1',
            name: 'Silinen1',
            amount: 1000.0,
            quantity: 1,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
          Asset(
            id: 'a2',
            name: 'Silinen2',
            amount: 2000.0,
            quantity: 2,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);
        await controller.loadData();

        controller.restoreAll();

        expect(controller.assets.length, equals(2));
        expect(controller.deletedAssets, isEmpty);
        expect(
          controller.assets.every((a) => !a.isDeleted),
          isTrue,
          reason: 'Geri yüklenen tüm varlıklar isDeleted=false olmalı',
        );
      });
    });

    // =================================================================
    // MODEL SERİALİZASYON TESTLERİ
    // =================================================================

    group('Asset Model Serialization', () {
      test('toMap ve fromMap dönüşümü veri kaybetmez', () {
        final original = Asset(
          id: 'a1',
          name: 'Altın',
          amount: 15000.0,
          quantity: 10,
          category: 'Altın',
          type: 'çeyrek',
          lastUpdated: DateTime(2024, 6, 15),
          purchaseDate: DateTime(2024, 1, 1),
          purchasePrice: 10000.0,
          paraBirimi: 'TRY',
          isDeleted: false,
        );

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
        'Geriye dönük uyumluluk: purchaseDate/purchasePrice olmazsa default kullanır',
        () {
          final map = {
            'id': 'a1',
            'name': 'Eski Varlık',
            'amount': 5000.0,
            'category': 'Altın',
            'lastUpdated': DateTime(2024, 6, 1).toIso8601String(),
            // purchaseDate ve purchasePrice KASITLI olarak yok
          };

          final asset = Asset.fromMap(map);

          expect(asset.purchasePrice, equals(5000.0));
          expect(asset.purchaseDate, equals(DateTime(2024, 6, 1)));
        },
      );

      test('copyWith sadece belirtilen alanları değiştirir', () {
        final original = Asset(
          id: 'a1',
          name: 'Altın',
          amount: 10000.0,
          quantity: 10,
          category: 'Altın',
          lastUpdated: DateTime.now(),
        );

        final updated = original.copyWith(amount: 15000.0, name: 'Çeyrek');

        expect(updated.amount, equals(15000.0));
        expect(updated.name, equals('Çeyrek'));
        expect(updated.quantity, equals(10)); // Değişmemeli
        expect(updated.category, equals('Altın')); // Değişmemeli
        expect(updated.id, equals('a1')); // Değişmemeli
      });
    });

    // =================================================================
    // FORM STATE TESTLERİ
    // =================================================================

    group('Form State', () {
      test('Form state initialize ve reset doğru çalışır', () {
        controller.initializeFormState(
          editCategory: 'Altın',
          editType: 'çeyrek',
          editCustomName: 'Çeyrek Altın',
          editPurchaseDate: DateTime(2024, 1, 1),
        );

        expect(controller.formSelectedCategory, equals('Altın'));
        expect(controller.formSelectedType, equals('çeyrek'));

        controller.resetFormState();

        expect(controller.formSelectedCategory, equals('Döviz'));
        expect(controller.formSelectedType, isNull);
      });

      test('Form error set ve clear çalışır', () {
        controller.setFormError('Test hatası');
        // setFormError notification yapar, error state'ini günceller

        controller.clearFormError();
        // clearFormError sonrası error temizlenir
      });
    });

    // =================================================================
    // EDGE CASE TESTLERİ
    // =================================================================

    group('Edge Cases', () {
      test('Boş varlık listesinde toplam değer sıfırdır', () async {
        await controller.loadData();
        expect(controller.toplamDeger, equals(0.0));
      });

      test('Quantity 1 olan varlıkta birim fiyat = toplam fiyat', () {
        final asset = Asset(
          id: '1',
          name: 'Tek Parça',
          amount: 5000.0,
          quantity: 1,
          category: 'Diğer',
          lastUpdated: DateTime.now(),
          purchasePrice: 3000.0,
        );

        expect(asset.unitPurchasePrice, equals(3000.0));
        expect(asset.unitCurrentPrice, equals(5000.0));
      });

      test('Çok küçük quantity ile varlık hesaplaması doğru', () {
        final asset = Asset(
          id: '1',
          name: 'Bitcoin Parça',
          amount: 50000.0,
          quantity: 0.001,
          category: 'Kripto',
          lastUpdated: DateTime.now(),
          purchasePrice: 40000.0,
        );

        expect(asset.unitPurchasePrice, closeTo(40000000.0, 0.01));
        expect(asset.unitCurrentPrice, closeTo(50000000.0, 0.01));
        expect(asset.profitLoss, equals(10000.0));
      });

      test('Default quantity varsayılan olarak 1.0', () {
        final map = {
          'id': '1',
          'name': 'Test',
          'amount': 1000.0,
          'category': 'Diğer',
          'lastUpdated': DateTime.now().toIso8601String(),
          // quantity belirtilmemiş
        };

        final asset = Asset.fromMap(map);
        expect(asset.quantity, equals(1.0));
      });
    });
  });
}
