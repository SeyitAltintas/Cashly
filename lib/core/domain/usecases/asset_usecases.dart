import 'base_usecase.dart';
import '../../../features/assets/domain/repositories/asset_repository.dart';

// ===== ASSET USE CASES =====

/// Kullanıcının tüm varlıklarını getir
class GetAssets
    implements UseCaseSync<List<Map<String, dynamic>>, GetAssetsParams> {
  final AssetRepository repository;

  GetAssets(this.repository);

  @override
  List<Map<String, dynamic>> call(GetAssetsParams params) {
    return repository.getAssets(params.userId);
  }
}

class GetAssetsParams {
  final String userId;
  const GetAssetsParams({required this.userId});
}

/// Varlıkları kaydet
class SaveAssets implements UseCase<void, SaveAssetsParams> {
  final AssetRepository repository;

  SaveAssets(this.repository);

  @override
  Future<void> call(SaveAssetsParams params) async {
    await repository.saveAssets(params.userId, params.assets);
  }
}

class SaveAssetsParams {
  final String userId;
  final List<Map<String, dynamic>> assets;
  const SaveAssetsParams({required this.userId, required this.assets});
}

/// Yeni varlık ekle
class AddAsset implements UseCase<void, AddAssetParams> {
  final AssetRepository repository;

  AddAsset(this.repository);

  @override
  Future<void> call(AddAssetParams params) async {
    final assets = repository.getAssets(params.userId);
    assets.add(params.asset);
    await repository.saveAssets(params.userId, assets);
  }
}

class AddAssetParams {
  final String userId;
  final Map<String, dynamic> asset;
  const AddAssetParams({required this.userId, required this.asset});
}

/// Varlık güncelle
class UpdateAsset implements UseCase<void, UpdateAssetParams> {
  final AssetRepository repository;

  UpdateAsset(this.repository);

  @override
  Future<void> call(UpdateAssetParams params) async {
    final assets = repository.getAssets(params.userId);
    final index = assets.indexWhere((a) => a['id'] == params.asset['id']);
    if (index != -1) {
      assets[index] = params.asset;
      await repository.saveAssets(params.userId, assets);
    }
  }
}

class UpdateAssetParams {
  final String userId;
  final Map<String, dynamic> asset;
  const UpdateAssetParams({required this.userId, required this.asset});
}

/// Varlık sil (soft delete)
class DeleteAsset implements UseCase<void, DeleteAssetParams> {
  final AssetRepository repository;

  DeleteAsset(this.repository);

  @override
  Future<void> call(DeleteAssetParams params) async {
    final assets = repository.getAssets(params.userId);
    final index = assets.indexWhere((a) => a['id'] == params.assetId);
    if (index != -1) {
      assets[index]['isDeleted'] = true;
      await repository.saveAssets(params.userId, assets);
    }
  }
}

class DeleteAssetParams {
  final String userId;
  final String assetId;
  const DeleteAssetParams({required this.userId, required this.assetId});
}

/// Varlığı kalıcı olarak sil
class PermanentDeleteAsset
    implements UseCase<void, PermanentDeleteAssetParams> {
  final AssetRepository repository;

  PermanentDeleteAsset(this.repository);

  @override
  Future<void> call(PermanentDeleteAssetParams params) async {
    final assets = repository.getAssets(params.userId);
    assets.removeWhere((a) => a['id'] == params.assetId);
    await repository.saveAssets(params.userId, assets);
  }
}

class PermanentDeleteAssetParams {
  final String userId;
  final String assetId;
  const PermanentDeleteAssetParams({
    required this.userId,
    required this.assetId,
  });
}

/// Varlığı geri yükle
class RestoreAsset implements UseCase<void, RestoreAssetParams> {
  final AssetRepository repository;

  RestoreAsset(this.repository);

  @override
  Future<void> call(RestoreAssetParams params) async {
    final assets = repository.getAssets(params.userId);
    final index = assets.indexWhere((a) => a['id'] == params.assetId);
    if (index != -1) {
      assets[index]['isDeleted'] = false;
      await repository.saveAssets(params.userId, assets);
    }
  }
}

class RestoreAssetParams {
  final String userId;
  final String assetId;
  const RestoreAssetParams({required this.userId, required this.assetId});
}
