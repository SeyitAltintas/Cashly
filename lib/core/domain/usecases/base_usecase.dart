// Base Use Case sınıfları
// Clean Architecture prensiplerinde domain katmanının temel yapı taşları

/// Parametre alan use case'ler için base sınıf
/// [Output] - Use case'in döndüreceği tip
/// [Params] - Use case'e geçilecek parametreler
abstract class UseCase<Output, Params> {
  /// Use case'i çalıştır
  /// [params] - Gerekli parametreler
  Future<Output> call(Params params);
}

/// Senkron use case'ler için base sınıf
/// Veritabanı gibi senkron işlemler için kullanılır
abstract class UseCaseSync<Output, Params> {
  /// Use case'i senkron olarak çalıştır
  Output call(Params params);
}

/// Parametre gerektirmeyen use case'ler için marker sınıf
class NoParams {
  const NoParams();
}

/// Use case sonucu - başarı veya hata durumu
/// Either pattern'in basit bir implementasyonu
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  /// Başarılı sonuç oluştur
  factory Result.success(T data) => Result._(data: data, isSuccess: true);

  /// Hatalı sonuç oluştur
  factory Result.failure(String error) =>
      Result._(error: error, isSuccess: false);

  /// Sonucu işle
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onFailure,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }
    return onFailure(error ?? 'Bilinmeyen hata');
  }
}
