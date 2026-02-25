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

  group('Size Model', () {
    test('width ve height doğru set edilir', () {
      const size = Size(1920, 1080);
      expect(size.width, equals(1920));
      expect(size.height, equals(1080));
    });

    test('sıfır boyut', () {
      const size = Size(0, 0);
      expect(size.width, equals(0));
      expect(size.height, equals(0));
    });

    test('ondalıklı boyut', () {
      const size = Size(100.5, 200.75);
      expect(size.width, equals(100.5));
      expect(size.height, equals(200.75));
    });

    test('toString doğru format', () {
      const size = Size(800.0, 600.0);
      expect(size.toString(), equals('Size(800.0, 600.0)'));
    });
  });
}
