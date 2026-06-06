import '../../../../core/services/batch_service.dart';

/// Ödeme yöntemi repository interface (Domain Layer)
/// Bu interface, ödeme yöntemi verilerine erişim için soyut bir kontrat tanımlar.
abstract class PaymentMethodRepository {
  /// Kullanıcının tüm ödeme yöntemlerini getirir
  List<Map<String, dynamic>> getPaymentMethods(String userId);

  /// Kullanıcının ödeme yöntemlerini dinler
  Stream<List<Map<String, dynamic>>> watchPaymentMethods(String userId);

  /// Yeni bir ödeme yöntemi ekler
  Future<void> addPaymentMethod(String userId, Map<String, dynamic> method);

  /// Mevcut bir ödeme yöntemini günceller
  Future<void> updatePaymentMethod(String userId, Map<String, dynamic> method);

  /// Bir ödeme yöntemini silmek için batch operasyonu döndürür
  BatchOperation getDeletePaymentMethodOperation(
    String userId,
    String methodId,
  );

  /// Bir ödeme yöntemini siler
  Future<void> deletePaymentMethod(String userId, String methodId);

  /// Bir ödeme yöntemini eklemek için batch operasyonu döndürür
  BatchOperation getAddPaymentMethodOperation(
    String userId,
    Map<String, dynamic> method,
  );

  /// Bir ödeme yöntemini güncellemek için batch operasyonu döndürür
  BatchOperation getUpdatePaymentMethodOperation(
    String userId,
    Map<String, dynamic> method,
  );

  /// Çevrimdışı senkronizasyonda veri kaybını (race condition) önlemek için 
  /// mutlak bakiye yerine delta (artış/azalış) miktarını kullanan batch operasyonu döndürür
  BatchOperation getIncrementBalanceOperation(
    String userId,
    String methodId,
    double amountDelta,
  );

  /// Silinen ödeme yöntemlerini getirir
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId);

  /// Geri dönüşüm kutusuna ödeme yöntemi ekler
  Future<void> addDeletedPaymentMethod(
    String userId,
    Map<String, dynamic> method,
  );

  /// Geri dönüşüm kutusundan ödeme yöntemini tamamen siler
  Future<void> removeDeletedPaymentMethod(String userId, String methodId);

  /// Varsayılan ödeme yöntemini getirir
  String? getDefaultPaymentMethod(String userId);

  /// Varsayılan ödeme yöntemini kaydeder
  Future<void> saveDefaultPaymentMethod(String userId, String? methodId);

  /// Kullanıcının tüm transferlerini getirir
  List<Map<String, dynamic>> getTransfers(String userId);

  /// Kullanıcının tüm transferlerini dinler
  Stream<List<Map<String, dynamic>>> watchTransfers(String userId);

  /// Yeni bir transfer ekler
  Future<void> addTransfer(String userId, Map<String, dynamic> transfer);

  /// Yeni bir transfer eklemek için batch operasyonu döndürür
  BatchOperation getAddTransferOperation(String userId, Map<String, dynamic> transfer);

  /// Mevcut bir transferi günceller
  Future<void> updateTransfer(String userId, Map<String, dynamic> transfer);

  /// Bir transferi siler
  Future<void> deleteTransfer(String userId, String transferId);
}
