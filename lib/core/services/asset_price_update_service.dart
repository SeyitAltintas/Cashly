import 'package:flutter/foundation.dart';
import '../../../../features/assets/data/models/asset_model.dart';
import 'price_service.dart';

/// Varlık fiyat güncelleme servisi
/// Uygulama açılışında tüm varlıkların güncel fiyatlarını çeker
class AssetPriceUpdateService {
  final PriceService _priceService = PriceService();

  /// Tüm varlıkların güncel fiyatlarını günceller
  /// Banka, Hisse Senedi ve Diğer kategorileri güncellenmez (sabit değerler)
  Future<List<Asset>> updateAllAssetPrices(List<Asset> assets) async {
    final updatedAssets = <Asset>[];

    for (final asset in assets) {
      if (asset.isDeleted) {
        updatedAssets.add(asset);
        continue;
      }

      // Banka, Hisse Senedi, Diğer kategorileri güncellenmez
      if (_shouldSkipUpdate(asset.category)) {
        updatedAssets.add(asset);
        continue;
      }

      try {
        final unitPrice = await getUnitPrice(asset);
        if (unitPrice != null) {
          // Güncel toplam değeri hesapla
          final newAmount = unitPrice * asset.quantity;
          // Alış bilgileri korunarak sadece amount güncellenir
          final updatedAsset = asset.copyWith(
            amount: newAmount,
            lastUpdated: DateTime.now(),
          );
          updatedAssets.add(updatedAsset);
          debugPrint(
            'Varlık güncellendi: ${asset.name} - Eski: ${asset.amount.toStringAsFixed(2)} TL -> Yeni: ${newAmount.toStringAsFixed(2)} TL',
          );
        } else {
          // Fiyat alınamadıysa mevcut değeri koru
          updatedAssets.add(asset);
          debugPrint('Fiyat alınamadı: ${asset.name}, mevcut değer korunuyor');
        }
      } catch (e) {
        // Hata durumunda mevcut değeri koru
        updatedAssets.add(asset);
        debugPrint('Fiyat güncelleme hatası (${asset.name}): $e');
      }
    }

    return updatedAssets;
  }

  /// Tek varlığın birim fiyatını çeker
  Future<double?> getUnitPrice(Asset asset) async {
    final category = asset.category;
    final type = asset.type;

    switch (category) {
      case 'Altın':
        return await _priceService.getGoldPrice(type ?? 'Gram');

      case 'Gümüş':
        return await _priceService.getSilverPrice(type ?? 'Gram');

      case 'Döviz':
        String currencyCode = 'USD';
        if (type != null && type.contains('(')) {
          currencyCode = type.split('(').last.replaceAll(')', '');
        }
        return await _priceService.getCurrencyPrice(currencyCode);

      case 'Kripto':
        final cryptoId = _getCryptoId(type);
        return await _priceService.getCryptoPrice(cryptoId);

      default:
        return null;
    }
  }

  /// Güncellenmemesi gereken kategorileri kontrol eder
  bool _shouldSkipUpdate(String category) {
    const skipCategories = ['Banka', 'Hisse Senedi', 'Diğer'];
    return skipCategories.contains(category);
  }

  /// Kripto sembolünü CoinGecko ID'sine çevirir
  String _getCryptoId(String? type) {
    switch (type) {
      case 'BTC':
        return 'bitcoin';
      case 'ETH':
        return 'ethereum';
      case 'SOL':
        return 'solana';
      case 'AVAX':
        return 'avalanche-2';
      case 'XRP':
        return 'ripple';
      case 'USDT':
        return 'tether';
      default:
        return 'bitcoin';
    }
  }
}
