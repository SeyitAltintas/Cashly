import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/image_compression_service.dart';

/// ImageCompressionService — _formatBytes ve Size model testleri
/// Donanım bağımsız pure logic testleri
void main() {
  group('ImageCompressionService — Sabitler', () {
    test('varsayılan boyut değerleri', () {
      expect(ImageCompressionService.defaultMaxWidth, equals(800));
      expect(ImageCompressionService.defaultMaxHeight, equals(800));
      expect(ImageCompressionService.defaultQuality, equals(85));
      expect(ImageCompressionService.thumbnailSize, equals(150));
    });

    test('singleton pattern çalışır', () {
      final instance1 = ImageCompressionService();
      final instance2 = ImageCompressionService();
      expect(identical(instance1, instance2), isTrue);
    });
  });

}
