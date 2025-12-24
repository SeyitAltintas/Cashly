/// Ödeme yöntemi repository interface (Domain Layer)
/// Bu interface, ödeme yöntemi verilerine erişim için soyut bir kontrat tanımlar.
abstract class PaymentMethodRepository {
  /// Kullanıcının tüm ödeme yöntemlerini getirir
  List<Map<String, dynamic>> getPaymentMethods(String userId);

  /// Kullanıcının ödeme yöntemlerini kaydeder
  Future<void> savePaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  );

  /// Silinen ödeme yöntemlerini getirir
  List<Map<String, dynamic>> getDeletedPaymentMethods(String userId);

  /// Silinen ödeme yöntemlerini kaydeder
  Future<void> saveDeletedPaymentMethods(
    String userId,
    List<Map<String, dynamic>> methods,
  );

  /// Varsayılan ödeme yöntemini getirir
  String? getDefaultPaymentMethod(String userId);

  /// Varsayılan ödeme yöntemini kaydeder
  Future<void> saveDefaultPaymentMethod(String userId, String? methodId);

  /// Kullanıcının transferlerini getirir
  List<Map<String, dynamic>> getTransfers(String userId);

  /// Kullanıcının transferlerini kaydeder
  Future<void> saveTransfers(
    String userId,
    List<Map<String, dynamic>> transfers,
  );
}
