import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';
import 'package:cashly/core/services/error_logger_service.dart';

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
class NetworkService extends ChangeNotifier with SafeNotifierMixin {
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
    // Prevent multiple initializations (Memory Leak / Edge Case Fix)
    if (_subscription != null) return;

    // Değişiklikleri dinle (İlk durum kontrolünden önce başlatılır ki timeout olsa bile dinlemeye devam etsin)
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateStatus,
      onError: (error) {
        _setStatus(NetworkStatus.unknown);
      },
    );

    try {
      // İlk durum kontrolü (App Launch Hang Edge Case Fix: Timeout eklendi)
      final results = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 5),
      );
      _updateStatus(results);
    } catch (e) {
      _setStatus(NetworkStatus.unknown);
      // Hata olsa bile dinleyici yukarıda başlatıldığı için bağlantı gelince yakalanacak.
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
  }

  /// Durumu günceller ve dinleyicilere bildirir
  void _setStatus(NetworkStatus newStatus) {
    if (isDisposedSafe) return; // Edge Case: Servis kapatılmışsa işlem yapma

    if (_status != newStatus) {
      _status = newStatus;

      if (!_statusController.isClosed) {
        _statusController.add(
          _status,
        ); // Edge Case: Kapalı stream'e veri eklemeyi önle
      }

      if (_status == NetworkStatus.online) {
        ErrorLoggerService.flushLogsToCloud();
      }

      notifyListeners();
    }
  }

  /// Mevcut bağlantı durumunu manuel olarak kontrol eder
  Future<NetworkStatus> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 5),
      );
      _updateStatus(results);
      return _status;
    } catch (e) {
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
    _subscription = null; // Fix memory leak & allow re-initialization
    if (!_statusController.isClosed) {
      _statusController.close();
    }
    super.dispose();
  }
}
