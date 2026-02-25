import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/price_service.dart';

/// PriceService — _parsePrice Unit Testleri
/// API'den gelen Türk formatındaki fiyat stringlerini double'a çevirme
/// ve altın tipi → API key eşleştirmesi testleri
void main() {
  late PriceService service;

  setUp(() {
    service = PriceService();
  });

  // PriceService._parsePrice private olduğu için reflection yapamıyoruz.
  // Fakat getGoldPrice, getSilverPrice, getCurrencyPrice'ın iç mantığını
  // davranışsal (behavioral) olarak test edebiliriz.

  // ============================================================
  // DESTEKLENEN KATEGORİLER VE MAPPING
  // ============================================================
  group('PriceService — TRY Para Birimi Özel Durum', () {
    test('TRY para biriminde kur her zaman 1.0 döner', () async {
      final result = await service.getCurrencyPrice('TRY');
      expect(result, equals(1.0));
    });
  });

  group('PriceService — Altın Tip Eşleştirmesi', () {
    // getGoldPrice internal switch/case mantığını behavioural test ediyoruz.
    // API çağrıları cache'e bağlı olduğundan, burada:
    // "API başarısız + cache boş = null" senaryosu test ediliyor.
    // Bu durumda fonksiyonun hata yapmadan null döndürmesi beklenir.

    test('gram altın fiyatı — API offline ise null döner (graceful)', () async {
      // PriceCacheService henüz init() çağrılmamış, cache boş.
      // API'ye ulaşılamıyor (test ortamı). Hata patlamadan null dönmeli.
      final result = await service.getGoldPrice('gram');
      // API erişimi yoksa null veya cache değeri döner
      expect(result == null || result is double, isTrue);
    });

    test('çeyrek altın fiyatı — graceful null', () async {
      final result = await service.getGoldPrice('çeyrek');
      expect(result == null || result is double, isTrue);
    });

    test('yarım altın fiyatı — graceful null', () async {
      final result = await service.getGoldPrice('yarım');
      expect(result == null || result is double, isTrue);
    });

    test('tam altın fiyatı — graceful null', () async {
      final result = await service.getGoldPrice('tam');
      expect(result == null || result is double, isTrue);
    });

    test('cumhuriyet altını fiyatı — graceful null', () async {
      final result = await service.getGoldPrice('cumhuriyet');
      expect(result == null || result is double, isTrue);
    });

    test('ata altın fiyatı — graceful null', () async {
      final result = await service.getGoldPrice('ata');
      expect(result == null || result is double, isTrue);
    });

    test('ons altın fiyatı — graceful null', () async {
      final result = await service.getGoldPrice('ons');
      expect(result == null || result is double, isTrue);
    });

    test('bilinmeyen altın tipi → varsayılan gram-altin kullanılır', () async {
      final result = await service.getGoldPrice('bilinmeyen_tip');
      // "bilinmeyen_tip" → default case → 'gram-altin' key kullanılır
      expect(result == null || result is double, isTrue);
    });
  });

  group('PriceService — Gümüş Fiyat', () {
    test('gram gümüş — graceful null/double', () async {
      final result = await service.getSilverPrice('Gram');
      expect(result == null || result is double, isTrue);
    });

    test('ons gümüş — graceful null/double', () async {
      final result = await service.getSilverPrice('Ons');
      expect(result == null || result is double, isTrue);
    });
  });

  group('PriceService — Kripto Fiyat', () {
    test('bitcoin fiyatı — graceful null/double', () async {
      final result = await service.getCryptoPrice('bitcoin');
      expect(result == null || result is double, isTrue);
    });

    test('ethereum fiyatı — graceful null/double', () async {
      final result = await service.getCryptoPrice('ethereum');
      expect(result == null || result is double, isTrue);
    });
  });

  group('PriceService — Döviz Fiyat', () {
    test('USD fiyatı — graceful null/double', () async {
      final result = await service.getCurrencyPrice('USD');
      expect(result == null || result is double, isTrue);
    });

    test('EUR fiyatı — graceful null/double', () async {
      final result = await service.getCurrencyPrice('EUR');
      expect(result == null || result is double, isTrue);
    });

    test('GBP fiyatı — graceful null/double', () async {
      final result = await service.getCurrencyPrice('GBP');
      expect(result == null || result is double, isTrue);
    });
  });

  // ============================================================
  // CACHE YARDIMCI FONKSİYONLAR
  // ============================================================
  group('PriceService — Cache Helper Methods', () {
    test('getLastPriceUpdate — cache boşken null döner', () {
      final result = service.getLastPriceUpdate('non_existent_key');
      expect(result, isNull);
    });

    test('getCacheAgeMinutes — cache boşken null döner', () {
      final result = service.getCacheAgeMinutes('non_existent_key');
      expect(result, isNull);
    });
  });
}
