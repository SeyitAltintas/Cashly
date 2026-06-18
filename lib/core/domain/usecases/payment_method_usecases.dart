import 'base_usecase.dart';
import '../../../features/payment_methods/domain/repositories/payment_method_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/batch_service.dart';

// ===== PAYMENT METHOD USE CASES =====

/// Kullanıcının tüm ödeme yöntemlerini getir
class GetPaymentMethods
    implements
        UseCaseSync<List<Map<String, dynamic>>, GetPaymentMethodsParams> {
  final PaymentMethodRepository repository;

  GetPaymentMethods(this.repository);

  @override
  List<Map<String, dynamic>> call(GetPaymentMethodsParams params) {
    return repository.getPaymentMethods(params.userId);
  }
}

class GetPaymentMethodsParams {
  final String userId;
  const GetPaymentMethodsParams({required this.userId});
}

/// Ödeme yöntemlerini kaydet
class SavePaymentMethods implements UseCase<void, SavePaymentMethodsParams> {
  final PaymentMethodRepository repository;

  SavePaymentMethods(this.repository);

  @override
  Future<void> call(SavePaymentMethodsParams params) async {
    // Deprecated: Batch save is no longer supported.
    // This is left here to not break DI.
  }
}

class SavePaymentMethodsParams {
  final String userId;
  final List<Map<String, dynamic>> paymentMethods;
  const SavePaymentMethodsParams({
    required this.userId,
    required this.paymentMethods,
  });
}

/// Yeni ödeme yöntemi ekle
class AddPaymentMethod implements UseCase<void, AddPaymentMethodParams> {
  final PaymentMethodRepository repository;

  AddPaymentMethod(this.repository);

  @override
  Future<void> call(AddPaymentMethodParams params) async {
    await repository.addPaymentMethod(params.userId, params.paymentMethod);
  }
}

class AddPaymentMethodParams {
  final String userId;
  final Map<String, dynamic> paymentMethod;
  const AddPaymentMethodParams({
    required this.userId,
    required this.paymentMethod,
  });
}

/// Ödeme yöntemini güncelle
class UpdatePaymentMethod implements UseCase<void, UpdatePaymentMethodParams> {
  final PaymentMethodRepository repository;

  UpdatePaymentMethod(this.repository);

  @override
  Future<void> call(UpdatePaymentMethodParams params) async {
    await repository.updatePaymentMethod(params.userId, params.paymentMethod);
  }
}

class UpdatePaymentMethodParams {
  final String userId;
  final Map<String, dynamic> paymentMethod;
  const UpdatePaymentMethodParams({
    required this.userId,
    required this.paymentMethod,
  });
}

/// Ödeme yöntemini sil (soft delete)
class DeletePaymentMethod implements UseCase<void, DeletePaymentMethodParams> {
  final PaymentMethodRepository repository;

  DeletePaymentMethod(this.repository);

  @override
  Future<void> call(DeletePaymentMethodParams params) async {
    await repository.deletePaymentMethod(params.userId, params.paymentMethodId);
  }
}

class DeletePaymentMethodParams {
  final String userId;
  final String paymentMethodId;
  const DeletePaymentMethodParams({
    required this.userId,
    required this.paymentMethodId,
  });
}

/// Bakiye güncelle
class UpdateBalance implements UseCase<void, UpdateBalanceParams> {
  final PaymentMethodRepository repository;

  UpdateBalance(this.repository);

  @override
  Future<void> call(UpdateBalanceParams params) async {
    final paymentMethods = repository.getPaymentMethods(params.userId);
    final index = paymentMethods.indexWhere(
      (pm) => pm['id'] == params.paymentMethodId,
    );
    if (index != -1) {
      final oldBalance = (paymentMethods[index]['balance'] as num?)?.toDouble() ?? 0.0;
      final delta = params.newBalance - oldBalance;
      
      final operations = <BatchOperation>[
        repository.getIncrementBalanceOperation(params.userId, params.paymentMethodId, delta)
      ];
      await getIt<BatchService>().commit(operations);
    }
  }
}

class UpdateBalanceParams {
  final String userId;
  final String paymentMethodId;
  final double newBalance;
  const UpdateBalanceParams({
    required this.userId,
    required this.paymentMethodId,
    required this.newBalance,
  });
}

// ===== TRANSFER USE CASES =====

/// Transferleri getir
class GetTransfers
    implements UseCaseSync<List<Map<String, dynamic>>, GetTransfersParams> {
  final PaymentMethodRepository repository;

  GetTransfers(this.repository);

  @override
  List<Map<String, dynamic>> call(GetTransfersParams params) {
    return repository.getTransfers(params.userId);
  }
}

class GetTransfersParams {
  final String userId;
  const GetTransfersParams({required this.userId});
}

/// Transferleri kaydet
class SaveTransfers implements UseCase<void, SaveTransfersParams> {
  final PaymentMethodRepository repository;

  SaveTransfers(this.repository);

  @override
  Future<void> call(SaveTransfersParams params) async {
    // Deprecated
  }
}

class SaveTransfersParams {
  final String userId;
  final List<Map<String, dynamic>> transfers;
  const SaveTransfersParams({required this.userId, required this.transfers});
}

/// Yeni transfer ekle
class AddTransfer implements UseCase<void, AddTransferParams> {
  final PaymentMethodRepository repository;

  AddTransfer(this.repository);

  @override
  Future<void> call(AddTransferParams params) async {
    await repository.addTransfer(params.userId, params.transfer);
  }
}

class AddTransferParams {
  final String userId;
  final Map<String, dynamic> transfer;
  const AddTransferParams({required this.userId, required this.transfer});
}
