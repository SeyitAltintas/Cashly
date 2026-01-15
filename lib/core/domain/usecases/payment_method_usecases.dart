import 'base_usecase.dart';
import '../../../features/payment_methods/domain/repositories/payment_method_repository.dart';

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
    await repository.savePaymentMethods(params.userId, params.paymentMethods);
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
    final paymentMethods = repository.getPaymentMethods(params.userId);
    paymentMethods.add(params.paymentMethod);
    await repository.savePaymentMethods(params.userId, paymentMethods);
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
    final paymentMethods = repository.getPaymentMethods(params.userId);
    final index = paymentMethods.indexWhere(
      (pm) => pm['id'] == params.paymentMethod['id'],
    );
    if (index != -1) {
      paymentMethods[index] = params.paymentMethod;
      await repository.savePaymentMethods(params.userId, paymentMethods);
    }
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
    final paymentMethods = repository.getPaymentMethods(params.userId);
    final index = paymentMethods.indexWhere(
      (pm) => pm['id'] == params.paymentMethodId,
    );
    if (index != -1) {
      paymentMethods[index]['isDeleted'] = true;
      await repository.savePaymentMethods(params.userId, paymentMethods);
    }
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
      paymentMethods[index]['balance'] = params.newBalance;
      await repository.savePaymentMethods(params.userId, paymentMethods);
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
    await repository.saveTransfers(params.userId, params.transfers);
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
    final transfers = repository.getTransfers(params.userId);
    transfers.insert(0, params.transfer); // En yeni transfer başa
    await repository.saveTransfers(params.userId, transfers);
  }
}

class AddTransferParams {
  final String userId;
  final Map<String, dynamic> transfer;
  const AddTransferParams({required this.userId, required this.transfer});
}
