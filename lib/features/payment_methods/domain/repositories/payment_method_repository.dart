/// Ödeme yöntemi repository interface (Domain Layer)
/// Bu interface, ödeme yöntemi verilerine erişim için soyut bir kontrat tanımlar.
abstract class PaymentMethodRepository {
  /// Kullanıcının tüm ödeme yöntemlerini getirir
  List<Map<String, dynamic>> getPaymentMethods(String userId);

  /// Yeni bir ödeme yöntemi ekler
  Future<void> addPaymentMethod(String userId, Map<String, dynamic> method);

  /// Mevcut bir ödeme yöntemini günceller
  Future<void> updatePaymentMethod(String userId, Map<String, dynamic> method);

  /// Bir ödeme yöntemini siler
  Future<void> deletePaymentMethod(String userId, String methodId);

  /// Silinen ödeme yöntemlerini getirir
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId);

  /// Geri dönüşüm kutusuna ödeme yöntemi ekler
  Future<void> addDeletedPaymentMethod(String userId, Map<String, dynamic> method);

  /// Geri dönüşüm kutusundan ödeme yöntemini tamamen siler
  Future<void> removeDeletedPaymentMethod(String userId, String methodId);

  /// Varsayılan ödeme yöntemini getirir
  String? getDefaultPaymentMethod(String userId);

  /// Varsayılan ödeme yöntemini kaydeder
  Future<void> saveDefaultPaymentMethod(String userId, String? methodId);

  /// Kullanıcının transferlerini getirir
  List<Map<String, dynamic>> getTransfers(String userId);

  /// Yeni bir transfer ekler
  Future<void> addTransfer(String userId, Map<String, dynamic> transfer);

  /// Mevcut bir transferi günceller
  Future<void> updateTransfer(String userId, Map<String, dynamic> transfer);

  /// Bir transferi siler
  Future<void> deleteTransfer(String userId, String transferId);
}
