import 'base_usecase.dart';
import '../../../features/expenses/domain/repositories/expense_repository.dart';
import '../../../features/income/domain/repositories/income_repository.dart';
import '../../../features/payment_methods/domain/repositories/payment_method_repository.dart';

// ===== DASHBOARD USE CASES =====

/// Toplam bakiye hesapla
/// Tüm ödeme yöntemlerinin bakiyelerini toplar (kredi kartı hariç)
class CalculateTotalBalance
    implements UseCaseSync<double, CalculateTotalBalanceParams> {
  final PaymentMethodRepository repository;

  CalculateTotalBalance(this.repository);

  @override
  double call(CalculateTotalBalanceParams params) {
    final paymentMethods = repository.getPaymentMethods(params.userId);

    double total = 0.0;
    for (final pm in paymentMethods) {
      // Silinen ve kredi kartlarını atla
      if (pm['isDeleted'] == true) continue;
      if (pm['type'] == 'kredi') continue;

      final balance = pm['balance'];
      if (balance is num) {
        total += balance.toDouble();
      }
    }

    return total;
  }
}

class CalculateTotalBalanceParams {
  final String userId;
  const CalculateTotalBalanceParams({required this.userId});
}

/// Toplam kredi kartı borcunu hesapla
class CalculateTotalDebt
    implements UseCaseSync<double, CalculateTotalDebtParams> {
  final PaymentMethodRepository repository;

  CalculateTotalDebt(this.repository);

  @override
  double call(CalculateTotalDebtParams params) {
    final paymentMethods = repository.getPaymentMethods(params.userId);

    double total = 0.0;
    for (final pm in paymentMethods) {
      if (pm['isDeleted'] == true) continue;
      if (pm['type'] != 'kredi') continue;

      final balance = pm['balance'];
      if (balance is num) {
        total += balance.toDouble();
      }
    }

    return total;
  }
}

class CalculateTotalDebtParams {
  final String userId;
  const CalculateTotalDebtParams({required this.userId});
}

/// Aylık harcama hesapla
class GetMonthlyExpense
    implements UseCaseSync<double, GetMonthlyExpenseParams> {
  final ExpenseRepository repository;

  GetMonthlyExpense(this.repository);

  @override
  double call(GetMonthlyExpenseParams params) {
    final expenses = repository.getExpenses(params.userId);

    double total = 0.0;
    for (final expense in expenses) {
      if (expense['isDeleted'] == true) continue;

      final dateStr = expense['tarih']?.toString();
      if (dateStr == null) continue;

      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      // Belirtilen ay ve yıl kontrolü
      if (date.year == params.year && date.month == params.month) {
        final amount = expense['tutar'];
        if (amount is num) {
          total += amount.toDouble();
        }
      }
    }

    return total;
  }
}

class GetMonthlyExpenseParams {
  final String userId;
  final int year;
  final int month;
  const GetMonthlyExpenseParams({
    required this.userId,
    required this.year,
    required this.month,
  });
}

/// Aylık gelir hesapla
class GetMonthlyIncome implements UseCaseSync<double, GetMonthlyIncomeParams> {
  final IncomeRepository repository;

  GetMonthlyIncome(this.repository);

  @override
  double call(GetMonthlyIncomeParams params) {
    final incomes = repository.getIncomes(params.userId);

    double total = 0.0;
    for (final income in incomes) {
      if (income['isDeleted'] == true) continue;

      final dateStr = income['tarih']?.toString();
      if (dateStr == null) continue;

      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      // Belirtilen ay ve yıl kontrolü
      if (date.year == params.year && date.month == params.month) {
        final amount = income['tutar'];
        if (amount is num) {
          total += amount.toDouble();
        }
      }
    }

    return total;
  }
}

class GetMonthlyIncomeParams {
  final String userId;
  final int year;
  final int month;
  const GetMonthlyIncomeParams({
    required this.userId,
    required this.year,
    required this.month,
  });
}

/// Finansal özet getir (Dashboard için)
class GetFinancialSummary
    implements UseCaseSync<FinancialSummary, GetFinancialSummaryParams> {
  final ExpenseRepository expenseRepository;
  final IncomeRepository incomeRepository;
  final PaymentMethodRepository paymentMethodRepository;

  GetFinancialSummary({
    required this.expenseRepository,
    required this.incomeRepository,
    required this.paymentMethodRepository,
  });

  @override
  FinancialSummary call(GetFinancialSummaryParams params) {
    // Toplam bakiye
    final paymentMethods = paymentMethodRepository.getPaymentMethods(
      params.userId,
    );
    double totalBalance = 0.0;
    double totalDebt = 0.0;

    for (final pm in paymentMethods) {
      if (pm['isDeleted'] == true) continue;
      final balance = pm['balance'] as num? ?? 0;
      if (pm['type'] == 'kredi') {
        totalDebt += balance.toDouble();
      } else {
        totalBalance += balance.toDouble();
      }
    }

    // Aylık harcama ve gelir
    final expenses = expenseRepository.getExpenses(params.userId);
    final incomes = incomeRepository.getIncomes(params.userId);

    double monthlyExpense = 0.0;
    double monthlyIncome = 0.0;

    final now = DateTime.now();

    for (final expense in expenses) {
      if (expense['isDeleted'] == true) continue;
      final dateStr = expense['tarih']?.toString();
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date != null && date.year == now.year && date.month == now.month) {
        monthlyExpense += (expense['tutar'] as num?)?.toDouble() ?? 0;
      }
    }

    for (final income in incomes) {
      if (income['isDeleted'] == true) continue;
      final dateStr = income['tarih']?.toString();
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date != null && date.year == now.year && date.month == now.month) {
        monthlyIncome += (income['tutar'] as num?)?.toDouble() ?? 0;
      }
    }

    return FinancialSummary(
      totalBalance: totalBalance,
      totalDebt: totalDebt,
      monthlyExpense: monthlyExpense,
      monthlyIncome: monthlyIncome,
      netDiff: monthlyIncome - monthlyExpense,
      paymentMethodsCount: paymentMethods
          .where((pm) => pm['isDeleted'] != true)
          .length,
    );
  }
}

class GetFinancialSummaryParams {
  final String userId;
  const GetFinancialSummaryParams({required this.userId});
}

/// Finansal özet veri sınıfı
class FinancialSummary {
  final double totalBalance;
  final double totalDebt;
  final double monthlyExpense;
  final double monthlyIncome;
  final double netDiff;
  final int paymentMethodsCount;

  const FinancialSummary({
    required this.totalBalance,
    required this.totalDebt,
    required this.monthlyExpense,
    required this.monthlyIncome,
    required this.netDiff,
    required this.paymentMethodsCount,
  });
}

/// Aktif ödeme yöntemlerini getir
class GetActivePaymentMethods
    implements
        UseCaseSync<List<Map<String, dynamic>>, GetActivePaymentMethodsParams> {
  final PaymentMethodRepository repository;

  GetActivePaymentMethods(this.repository);

  @override
  List<Map<String, dynamic>> call(GetActivePaymentMethodsParams params) {
    final methods = repository.getPaymentMethods(params.userId);
    return methods.where((pm) => pm['isDeleted'] != true).toList();
  }
}

class GetActivePaymentMethodsParams {
  final String userId;
  const GetActivePaymentMethodsParams({required this.userId});
}
