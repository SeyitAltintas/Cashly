import 'base_usecase.dart';
import '../../../features/expenses/domain/repositories/expense_repository.dart';

// ===== EXPENSE USE CASES =====

/// Kullanıcının tüm harcamalarını getir
class GetExpenses
    implements UseCaseSync<List<Map<String, dynamic>>, GetExpensesParams> {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  @override
  List<Map<String, dynamic>> call(GetExpensesParams params) {
    return repository.getExpenses(params.userId);
  }
}

class GetExpensesParams {
  final String userId;
  const GetExpensesParams({required this.userId});
}

/// Harcamaları kaydet
class SaveExpenses implements UseCase<void, SaveExpensesParams> {
  final ExpenseRepository repository;

  SaveExpenses(this.repository);

  @override
  Future<void> call(SaveExpensesParams params) async {
    await repository.saveExpenses(params.userId, params.expenses);
  }
}

class SaveExpensesParams {
  final String userId;
  final List<Map<String, dynamic>> expenses;
  const SaveExpensesParams({required this.userId, required this.expenses});
}

/// Yeni harcama ekle
class AddExpense implements UseCase<void, AddExpenseParams> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<void> call(AddExpenseParams params) async {
    final expenses = repository.getExpenses(params.userId);
    expenses.add(params.expense);
    await repository.saveExpenses(params.userId, expenses);
  }
}

class AddExpenseParams {
  final String userId;
  final Map<String, dynamic> expense;
  const AddExpenseParams({required this.userId, required this.expense});
}

/// Harcama güncelle
class UpdateExpense implements UseCase<void, UpdateExpenseParams> {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  @override
  Future<void> call(UpdateExpenseParams params) async {
    final expenses = repository.getExpenses(params.userId);
    final index = expenses.indexWhere((e) => e['id'] == params.expense['id']);
    if (index != -1) {
      expenses[index] = params.expense;
      await repository.saveExpenses(params.userId, expenses);
    }
  }
}

class UpdateExpenseParams {
  final String userId;
  final Map<String, dynamic> expense;
  const UpdateExpenseParams({required this.userId, required this.expense});
}

/// Harcama sil (soft delete)
class DeleteExpense implements UseCase<void, DeleteExpenseParams> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<void> call(DeleteExpenseParams params) async {
    final expenses = repository.getExpenses(params.userId);
    final index = expenses.indexWhere((e) => e['id'] == params.expenseId);
    if (index != -1) {
      expenses[index]['isDeleted'] = true;
      await repository.saveExpenses(params.userId, expenses);
    }
  }
}

class DeleteExpenseParams {
  final String userId;
  final String expenseId;
  const DeleteExpenseParams({required this.userId, required this.expenseId});
}

/// Bütçe limitini getir
class GetBudget implements UseCaseSync<double, GetBudgetParams> {
  final ExpenseRepository repository;

  GetBudget(this.repository);

  @override
  double call(GetBudgetParams params) {
    return repository.getBudget(params.userId);
  }
}

class GetBudgetParams {
  final String userId;
  const GetBudgetParams({required this.userId});
}

/// Bütçe limitini kaydet
class SaveBudget implements UseCase<void, SaveBudgetParams> {
  final ExpenseRepository repository;

  SaveBudget(this.repository);

  @override
  Future<void> call(SaveBudgetParams params) async {
    await repository.saveBudget(params.userId, params.limit);
  }
}

class SaveBudgetParams {
  final String userId;
  final double limit;
  const SaveBudgetParams({required this.userId, required this.limit});
}

/// Harcama kategorilerini getir
class GetExpenseCategories
    implements
        UseCaseSync<List<Map<String, dynamic>>, GetExpenseCategoriesParams> {
  final ExpenseRepository repository;

  GetExpenseCategories(this.repository);

  @override
  List<Map<String, dynamic>> call(GetExpenseCategoriesParams params) {
    return repository.getCategories(params.userId);
  }
}

class GetExpenseCategoriesParams {
  final String userId;
  const GetExpenseCategoriesParams({required this.userId});
}
