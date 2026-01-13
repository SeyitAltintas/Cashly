import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/utils/debouncer.dart';

void main() {
  group('Debouncer Tests', () {
    test('run() callback sonunda çalışmalı', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      var callCount = 0;

      debouncer.run(() => callCount++);

      // Henüz çalışmamış olmalı
      expect(callCount, 0);
      expect(debouncer.isActive, true);

      // Bekleme süresini geç
      await Future.delayed(const Duration(milliseconds: 150));

      expect(callCount, 1);
      expect(debouncer.isActive, false);

      debouncer.dispose();
    });

    test('ardışık çağrılarda sadece son callback çalışmalı', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      var lastValue = 0;

      // 3 ardışık çağrı
      debouncer.run(() => lastValue = 1);
      debouncer.run(() => lastValue = 2);
      debouncer.run(() => lastValue = 3);

      // Sadece son değer atanmalı
      await Future.delayed(const Duration(milliseconds: 150));

      expect(lastValue, 3);

      debouncer.dispose();
    });

    test('cancel() timer\'ı iptal etmeli', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      var callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 150));

      expect(callCount, 0);

      debouncer.dispose();
    });
  });

  group('Throttler Tests', () {
    test('run() ilk çağrıda hemen çalışmalı', () async {
      final throttler = Throttler(delay: const Duration(milliseconds: 100));
      var callCount = 0;

      throttler.run(() => callCount++);

      // Hemen çalışmış olmalı
      expect(callCount, 1);

      throttler.dispose();
    });

    test('ardışık çağrılarda sadece ilk callback çalışmalı', () async {
      final throttler = Throttler(delay: const Duration(milliseconds: 100));
      var lastValue = 0;

      // 3 ardışık çağrı
      throttler.run(() => lastValue = 1);
      throttler.run(() => lastValue = 2);
      throttler.run(() => lastValue = 3);

      // Sadece ilk değer atanmalı
      expect(lastValue, 1);

      throttler.dispose();
    });

    test('bekleme süresinden sonra tekrar çalışmalı', () async {
      final throttler = Throttler(delay: const Duration(milliseconds: 50));
      var callCount = 0;

      throttler.run(() => callCount++);
      expect(callCount, 1);

      throttler.run(() => callCount++);
      expect(callCount, 1); // Henüz throttle aktif

      await Future.delayed(const Duration(milliseconds: 60));

      throttler.run(() => callCount++);
      expect(callCount, 2); // Şimdi çalışmalı

      throttler.dispose();
    });
  });
}
