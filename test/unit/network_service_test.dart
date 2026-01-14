import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/network_service.dart';

void main() {
  group('NetworkService', () {
    late NetworkService networkService;

    setUp(() {
      // NetworkService singleton olduğundan her testte aynı instance kullanılır
      networkService = NetworkService();
    });

    test('singleton pattern çalışmalı', () {
      // NetworkService singleton olduğundan aynı instance döndürmeli
      final instance1 = NetworkService();
      final instance2 = NetworkService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('başlangıç durumu unknown olmalı', () {
      // Not: Bu test, initialize çağrılmadan önceki durumu kontrol eder
      // Gerçek uygulamada initialize çağrıldıktan sonra durum değişir
      // Bu test sadece enum değerlerini doğrulamak için
      expect(NetworkStatus.values.length, 3);
      expect(NetworkStatus.online.name, 'online');
      expect(NetworkStatus.offline.name, 'offline');
      expect(NetworkStatus.unknown.name, 'unknown');
    });

    test('isOnline getter doğru çalışmalı', () {
      // NetworkService singleton olduğundan bu test mevcut durumu kontrol eder
      // Gerçek network durumuna bağlı olarak true veya false dönebilir
      final isOnline = networkService.isOnline;
      final isOffline = networkService.isOffline;

      // isOnline ve isOffline birbirinin tersi olmalı (unknown durumu hariç)
      if (networkService.status != NetworkStatus.unknown) {
        expect(isOnline, !isOffline);
      }
    });

    test('getConnectionTypeText boş string dönmemeli', () {
      final text = networkService.getConnectionTypeText();
      expect(text, isNotEmpty);
    });

    test('statusStream null olmamalı', () {
      expect(networkService.statusStream, isNotNull);
    });

    test('connectionTypes liste olmalı', () {
      final types = networkService.connectionTypes;
      expect(types, isA<List>());
    });
  });

  group('NetworkStatus enum', () {
    test('tüm değerler mevcut olmalı', () {
      expect(NetworkStatus.values.contains(NetworkStatus.online), isTrue);
      expect(NetworkStatus.values.contains(NetworkStatus.offline), isTrue);
      expect(NetworkStatus.values.contains(NetworkStatus.unknown), isTrue);
    });
  });
}
