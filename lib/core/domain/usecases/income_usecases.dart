import 'base_usecase.dart';
import '../../../features/income/domain/repositories/income_repository.dart';

// ===== INCOME USE CASES =====

/// Kullanıcının tüm gelirlerini getir
class GetIncomes
    implements UseCaseSync<List<Map<String, dynamic>>, GetIncomesParams> {
  final IncomeRepository repository;

  GetIncomes(this.repository);

  @override
  List<Map<String, dynamic>> call(GetIncomesParams params) {
    return repository.getIncomes(params.userId);
  }
}

class GetIncomesParams {
  final String userId;
  const GetIncomesParams({required this.userId});
}

/// Gelirleri kaydet
class SaveIncomes implements UseCase<void, SaveIncomesParams> {
  final IncomeRepository repository;

  SaveIncomes(this.repository);

  @override
  Future<void> call(SaveIncomesParams params) async {
    throw UnimplementedError('saveIncomes is deprecated. Use add/update/delete Income instead.');
  }
}

class SaveIncomesParams {
  final String userId;
  final List<Map<String, dynamic>> incomes;
  const SaveIncomesParams({required this.userId, required this.incomes});
}

/// Yeni gelir ekle
class AddIncome implements UseCase<void, AddIncomeParams> {
  final IncomeRepository repository;

  AddIncome(this.repository);

  @override
  Future<void> call(AddIncomeParams params) async {
    await repository.addIncome(params.userId, params.income);
  }
}

class AddIncomeParams {
  final String userId;
  final Map<String, dynamic> income;
  const AddIncomeParams({required this.userId, required this.income});
}

/// Gelir güncelle
class UpdateIncome implements UseCase<void, UpdateIncomeParams> {
  final IncomeRepository repository;

  UpdateIncome(this.repository);

  @override
  Future<void> call(UpdateIncomeParams params) async {
    await repository.updateIncome(params.userId, params.income);
  }
}

class UpdateIncomeParams {
  final String userId;
  final Map<String, dynamic> income;
  const UpdateIncomeParams({required this.userId, required this.income});
}

/// Gelir sil (soft delete)
class DeleteIncome implements UseCase<void, DeleteIncomeParams> {
  final IncomeRepository repository;

  DeleteIncome(this.repository);

  @override
  Future<void> call(DeleteIncomeParams params) async {
    await repository.deleteIncome(params.userId, params.incomeId);
  }
}

class DeleteIncomeParams {
  final String userId;
  final String incomeId;
  const DeleteIncomeParams({required this.userId, required this.incomeId});
}

/// Gelir kategorilerini getir
class GetIncomeCategories
    implements
        UseCaseSync<List<Map<String, dynamic>>, GetIncomeCategoriesParams> {
  final IncomeRepository repository;

  GetIncomeCategories(this.repository);

  @override
  List<Map<String, dynamic>> call(GetIncomeCategoriesParams params) {
    return repository.getCategories(params.userId);
  }
}

class GetIncomeCategoriesParams {
  final String userId;
  const GetIncomeCategoriesParams({required this.userId});
}
