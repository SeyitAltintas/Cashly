import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/image_cache_service.dart';
import 'dart:typed_data';

void main() {
  group('ImageCacheService Tests', () {
    late ImageCacheService cacheService;

    setUp(() {
      cacheService = ImageCacheService();
    });

    test('singleton instance olmalı', () {
      final instance1 = ImageCacheService();
      final instance2 = ImageCacheService();

      expect(identical(instance1, instance2), true);
    });

    test('cache key URL\'den üretilmeli', () async {
      // Private metod dolaylı olarak test edilir
      // Memory cache'e veri ekle ve oku
      const testUrl = 'https://example.com/image.png';
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      await cacheService.put(testUrl, testBytes);
      final result = await cacheService.get(testUrl);

      expect(result, isNotNull);
      expect(result!.length, 5);
    });

    test('olmayan URL null dönmeli', () async {
      final result = await cacheService.get(
        'https://nonexistent.com/image.png',
      );
      expect(result, isNull);
    });

    test('clear() tüm cache\'i temizlemeli', () async {
      const testUrl = 'https://example.com/image2.png';
      final testBytes = Uint8List.fromList([1, 2, 3]);

      await cacheService.put(testUrl, testBytes);
      await cacheService.clear();

      final result = await cacheService.get(testUrl);
      expect(result, isNull);
    });

    test('remove() belirli görseli silmeli', () async {
      const testUrl1 = 'https://example.com/img1.png';
      const testUrl2 = 'https://example.com/img2.png';
      final testBytes = Uint8List.fromList([1, 2, 3]);

      await cacheService.put(testUrl1, testBytes);
      await cacheService.put(testUrl2, testBytes);

      await cacheService.remove(testUrl1);

      final result1 = await cacheService.get(testUrl1);
      final result2 = await cacheService.get(testUrl2);

      expect(result1, isNull);
      expect(result2, isNotNull);
    });
  });
}
