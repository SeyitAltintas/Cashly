import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/assets/presentation/controllers/assets_controller.dart';
import 'package:cashly/features/assets/domain/repositories/asset_repository.dart';
import 'package:cashly/features/assets/data/models/asset_model.dart';

/// Mock AssetRepository
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

void main() {
  group('AssetsController', () {
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

    group('loadData', () {
      test('veri yüklendiğinde isLoading false olur', () async {
        mockRepo.setAssets([
          Asset(
            id: '1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.isLoading, isFalse);
        expect(controller.assets.length, equals(1));
      });

      test('silinen varlıklar yüklenir', () async {
        mockRepo.setDeletedAssets([
          Asset(
            id: '2',
            name: 'Silinen',
            amount: 5000.0,
            quantity: 5,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.deletedAssets.length, equals(1));
      });
    });

    group('filtrele', () {
      test('arama filtrelemesi çalışır', () async {
        mockRepo.setAssets([
          Asset(
            id: '1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ).toMap(),
          Asset(
            id: '2',
            name: 'Dolar',
            amount: 5000.0,
            quantity: 100,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();
        controller.aramaModu = true;
        controller.filtrele('alt');

        expect(controller.filtrelenmisVarliklar.length, equals(1));
        expect(controller.filtrelenmisVarliklar.first.name, equals('Altın'));
      });

      test('silinen varlıklar filtreden çıkarılır', () async {
        mockRepo.setAssets([
          Asset(
            id: '1',
            name: 'Aktif',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: false,
          ).toMap(),
          Asset(
            id: '2',
            name: 'Silindi',
            amount: 5000.0,
            quantity: 5,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.filtrelenmisVarliklar.length, equals(1));
      });
    });

    group('addAsset', () {
      test('varlık listeye eklenir', () async {
        await controller.loadData();

        final yeniVarlik = Asset(
          id: 'new_1',
          name: 'Yeni Altın',
          amount: 15000.0,
          quantity: 15,
          category: 'Altın',
          lastUpdated: DateTime.now(),
        );

        await controller.addAsset(yeniVarlik);

        expect(controller.assets.length, equals(1));
      });
    });

    group('deleteAsset', () {
      test('varlık çöp kutusuna taşınır', () async {
        final varlik = Asset(
          id: '1',
          name: 'Test',
          amount: 10000.0,
          quantity: 10,
          category: 'Altın',
          lastUpdated: DateTime.now(),
        );
        mockRepo.setAssets([varlik.toMap()]);

        await controller.loadData();
        await controller.deleteAsset(controller.assets.first);

        expect(controller.assets.length, equals(0));
        expect(controller.deletedAssets.length, equals(1));
      });
    });

    group('restoreAsset', () {
      test('varlık çöp kutusundan geri yüklenir', () async {
        final varlik = Asset(
          id: '1',
          name: 'Test',
          amount: 10000.0,
          quantity: 10,
          category: 'Altın',
          lastUpdated: DateTime.now(),
          isDeleted: true,
        );
        mockRepo.setDeletedAssets([varlik.toMap()]);

        await controller.loadData();
        await controller.restoreAsset(controller.deletedAssets.first);

        expect(controller.assets.length, equals(1));
        expect(controller.deletedAssets.length, equals(0));
      });
    });

    group('emptyBin', () {
      test('çöp kutusu temizlenir', () async {
        mockRepo.setDeletedAssets([
          Asset(
            id: '1',
            name: 'Test1',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
          Asset(
            id: '2',
            name: 'Test2',
            amount: 5000.0,
            quantity: 5,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
            isDeleted: true,
          ).toMap(),
        ]);

        await controller.loadData();
        await controller.emptyBin();

        expect(controller.deletedAssets.length, equals(0));
      });
    });

    group('toplamDeger', () {
      test('aktif varlıkların toplam değerini hesaplar', () async {
        mockRepo.setAssets([
          Asset(
            id: '1',
            name: 'Altın',
            amount: 10000.0,
            quantity: 10,
            category: 'Altın',
            lastUpdated: DateTime.now(),
          ).toMap(),
          Asset(
            id: '2',
            name: 'Dolar',
            amount: 5000.0,
            quantity: 100,
            category: 'Döviz',
            lastUpdated: DateTime.now(),
          ).toMap(),
        ]);

        await controller.loadData();

        expect(controller.toplamDeger, equals(15000.0));
      });
    });
  });
}
