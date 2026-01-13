import 'dart:async';

/// Debounce utility - arama ve filtreleme işlemlerinde gereksiz çağrıları önler
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Verilen callback'i belirtilen süre sonra çalıştırır.
  /// Eğer bu süre içinde tekrar çağrılırsa, önceki timer iptal edilir.
  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Mevcut timer'ı iptal eder
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Bekleyen bir işlem var mı?
  bool get isActive => _timer?.isActive ?? false;

  /// Timer'ı temizle
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttle utility - belirli bir süre içinde sadece bir kez çalışmasını sağlar
class Throttler {
  final Duration delay;
  Timer? _timer;

  Throttler({this.delay = const Duration(milliseconds: 300)});

  /// Verilen callback'i throttle eder.
  /// Eğer timer aktifse çağrıyı yoksayar.
  void run(void Function() callback) {
    if (_timer?.isActive ?? false) return;

    callback();
    _timer = Timer(delay, () {});
  }

  /// Timer'ı iptal eder
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Timer'ı temizle
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
