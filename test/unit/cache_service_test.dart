import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/cache_service.dart';

/// CacheService testleri
/// In-memory cache: set/get, TTL süresi dolması, invalidation,
/// prefix temizleme ve farklı veri tipleri
void main() {
  setUp(() {
    CacheService.clear();
  });

  group('CacheService — Temel İşlemler', () {
    test('set ve get doğru çalışır (String)', () {
      CacheService.set<String>('test_key', 'test_value');

      final result = CacheService.get<String>('test_key');
      expect(result, equals('test_value'));
    });

    test('set ve get doğru çalışır (int)', () {
      CacheService.set<int>('count', 42);

      final result = CacheService.get<int>('count');
      expect(result, equals(42));
    });

    test('set ve get doğru çalışır (double)', () {
      CacheService.set<double>('price', 99.99);

      final result = CacheService.get<double>('price');
      expect(result, equals(99.99));
    });

    test('set ve get doğru çalışır (Map)', () {
      final data = {'name': 'Test', 'value': 123};
      CacheService.set<Map>('map_key', data);

      final result = CacheService.get<Map>('map_key');
      expect(result?['name'], equals('Test'));
      expect(result?['value'], equals(123));
    });

    test('set ve get doğru çalışır (List)', () {
      CacheService.set<List>('list_key', [1, 2, 3]);

      final result = CacheService.get<List>('list_key');
      expect(result, equals([1, 2, 3]));
    });

    test('olmayan key null döner', () {
      final result = CacheService.get<String>('nonexistent');
      expect(result, isNull);
    });

    test('aynı key üzerine yazılabilir', () {
      CacheService.set<String>('key', 'ilk');
      CacheService.set<String>('key', 'ikinci');

      expect(CacheService.get<String>('key'), equals('ikinci'));
    });
  });

  group('CacheService — Invalidation', () {
    test('invalidate tek anahtarı siler', () {
      CacheService.set<String>('a', 'A');
      CacheService.set<String>('b', 'B');

      CacheService.invalidate('a');

      expect(CacheService.get<String>('a'), isNull);
      expect(CacheService.get<String>('b'), equals('B'));
    });

    test('olmayan key invalidate hata vermez', () {
      expect(() => CacheService.invalidate('ghost'), returnsNormally);
    });

    test('invalidateByPrefix belirtilen prefix ile başlayanları siler', () {
      CacheService.set<String>('expense_1', 'Yemek');
      CacheService.set<String>('expense_2', 'Ulaşım');
      CacheService.set<String>('income_1', 'Maaş');
      CacheService.set<String>('asset_1', 'Altın');

      CacheService.invalidateByPrefix('expense_');

      expect(CacheService.get<String>('expense_1'), isNull);
      expect(CacheService.get<String>('expense_2'), isNull);
      expect(CacheService.get<String>('income_1'), equals('Maaş'));
      expect(CacheService.get<String>('asset_1'), equals('Altın'));
    });

    test('clear tüm cache\'i temizler', () {
      CacheService.set<String>('x', '1');
      CacheService.set<String>('y', '2');
      CacheService.set<String>('z', '3');

      CacheService.clear();

      expect(CacheService.get<String>('x'), isNull);
      expect(CacheService.get<String>('y'), isNull);
      expect(CacheService.get<String>('z'), isNull);
    });
  });

  group('CacheService — TTL (Süre Dolması)', () {
    test('çok kısa TTL ile set edilen veri hemen sona erer', () async {
      CacheService.set<String>(
        'short_lived',
        'value',
        ttl: const Duration(milliseconds: 1),
      );

      // Kısa bir bekleyiş sonrası expire olmalı
      await Future.delayed(const Duration(milliseconds: 50));

      expect(CacheService.get<String>('short_lived'), isNull);
    });

    test('uzun TTL ile set edilen veri hala geçerli', () {
      CacheService.set<String>(
        'long_lived',
        'value',
        ttl: const Duration(hours: 1),
      );

      // Hemen okuyunca hala geçerli olmalı
      expect(CacheService.get<String>('long_lived'), equals('value'));
    });

    test('varsayılan TTL 5 dakikadır', () {
      expect(CacheService.defaultTtl, equals(const Duration(minutes: 5)));
    });
  });

  group('CacheService — Edge Cases', () {
    test('null değer cache\'lenebilir', () {
      CacheService.set<String?>('nullable', null);
      final result = CacheService.get<String?>('nullable');
      expect(result, isNull);
    });

    test('boş string cache\'lenebilir', () {
      CacheService.set<String>('empty', '');
      expect(CacheService.get<String>('empty'), equals(''));
    });

    test('boş prefix invalidation hata vermez', () {
      CacheService.set<String>('test', 'value');
      expect(() => CacheService.invalidateByPrefix(''), returnsNormally);
    });

    test('birden fazla prefix invalidation birbirini etkilemez', () {
      CacheService.set<String>('user_name', 'Ali');
      CacheService.set<String>('user_age', '25');
      CacheService.set<String>('userSettings', 'dark');

      CacheService.invalidateByPrefix('user_');

      expect(CacheService.get<String>('user_name'), isNull);
      expect(CacheService.get<String>('user_age'), isNull);
      expect(CacheService.get<String>('userSettings'), equals('dark'));
    });
  });
}
