import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network bağlantı durumlarını temsil eden enum
enum NetworkStatus {
  /// İnternet bağlantısı var
  online,

  /// İnternet bağlantısı yok
  offline,

  /// Bağlantı durumu belirleniyor
  unknown,
}

/// Network durumunu izleyen ve yöneten servis
///
/// Kullanım:
/// ```dart
/// final networkService = NetworkService();
/// await networkService.initialize();
///
/// // Anlık durum kontrolü
/// if (networkService.isOnline) {
///   // Online işlemler
/// }
///
/// // Stream ile dinleme
/// networkService.statusStream.listen((status) {
///   print('Network durumu: $status');
/// });
/// ```
class NetworkService extends ChangeNotifier {
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  // Mevcut network durumu
  NetworkStatus _status = NetworkStatus.unknown;
  NetworkStatus get status => _status;

  // Stream controller - network değişikliklerini yayınlamak için
  final _statusController = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  // Subscription referansı - dispose için
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Hızlı erişim getter'ları
  bool get isOnline => _status == NetworkStatus.online;
  bool get isOffline => _status == NetworkStatus.offline;

  // Son bağlantı türleri
  List<ConnectivityResult> _lastResults = [];
  List<ConnectivityResult> get connectionTypes => _lastResults;

  /// Servisi başlatır ve network durumunu dinlemeye başlar
  Future<void> initialize() async {
    try {
      // İlk durum kontrolü
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);

      // Değişiklikleri dinle
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (error) {
          debugPrint('NetworkService: Bağlantı dinleme hatası: $error');
          _setStatus(NetworkStatus.unknown);
        },
      );

      debugPrint('NetworkService: Başlatıldı - Durum: $_status');
    } catch (e) {
      debugPrint('NetworkService: Başlatma hatası: $e');
      _setStatus(NetworkStatus.unknown);
    }
  }

  /// Bağlantı sonuçlarını değerlendirir ve durumu günceller
  void _updateStatus(List<ConnectivityResult> results) {
    _lastResults = results;

    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _setStatus(NetworkStatus.offline);
    } else {
      // WiFi, Mobile, Ethernet, VPN, Bluetooth, Other hepsi online sayılır
      _setStatus(NetworkStatus.online);
    }

    debugPrint(
      'NetworkService: Bağlantı değişti - Durum: $_status, Türler: $results',
    );
  }

  /// Durumu günceller ve dinleyicilere bildirir
  void _setStatus(NetworkStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
      notifyListeners();
    }
  }

  /// Mevcut bağlantı durumunu manuel olarak kontrol eder
  Future<NetworkStatus> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
      return _status;
    } catch (e) {
      debugPrint('NetworkService: Bağlantı kontrolü hatası: $e');
      return NetworkStatus.unknown;
    }
  }

  /// Bağlantı türünü insan okunabilir string'e çevirir
  String getConnectionTypeText() {
    if (_lastResults.isEmpty ||
        _lastResults.contains(ConnectivityResult.none)) {
      return 'Bağlantı yok';
    }

    final types = <String>[];
    for (final result in _lastResults) {
      switch (result) {
        case ConnectivityResult.wifi:
          types.add('Wi-Fi');
          break;
        case ConnectivityResult.mobile:
          types.add('Mobil veri');
          break;
        case ConnectivityResult.ethernet:
          types.add('Ethernet');
          break;
        case ConnectivityResult.vpn:
          types.add('VPN');
          break;
        case ConnectivityResult.bluetooth:
          types.add('Bluetooth');
          break;
        case ConnectivityResult.other:
          types.add('Diğer');
          break;
        case ConnectivityResult.none:
          break;
      }
    }

    return types.isNotEmpty ? types.join(', ') : 'Bilinmiyor';
  }

  /// Servisi temizler
  @override
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
    super.dispose();
  }
}
