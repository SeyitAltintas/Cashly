import 'dart:io';

void main() {
  final targetFiles = [
    'test/unit/expense_business_logic_test.dart',
    'test/unit/expenses_controller_test.dart',
    'test/unit/income_business_logic_test.dart',
    'test/unit/incomes_controller_test.dart',
    'test/unit/payment_method_business_logic_test.dart',
    'test/unit/payment_methods_controller_test.dart',
    'test/widget/transfer_page_edge_cases_test.dart'
  ];

  final dummyBatch = '''
class DummyBatchOperation implements BatchOperation {
  @override
  BatchOperationType get type => BatchOperationType.set;
  @override
  String get collectionPath => '';
  @override
  String get documentId => '';
  @override
  Map<String, dynamic>? get data => null;
}

class MockBatchService implements BatchService {
  @override
  Future<void> commit(List<BatchOperation> operations) async {}
}
''';

  for (final filePath in targetFiles) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();
    bool modified = false;

    if (!content.contains("import 'package:cashly/core/services/batch_service.dart';")) {
      if (content.contains("import 'package:get_it/get_it.dart';")) {
        content = content.replaceFirst("import 'package:get_it/get_it.dart';", "import 'package:get_it/get_it.dart';\nimport 'package:cashly/core/services/batch_service.dart';");
      } else {
        content = content.replaceFirst("import 'package:flutter_test/flutter_test.dart';", "import 'package:flutter_test/flutter_test.dart';\nimport 'package:cashly/core/services/batch_service.dart';");
      }
      modified = true;
    }

    if (!content.contains("class DummyBatchOperation")) {
      if (content.contains("// MOCK REPOSITORIES")) {
        content = content.replaceFirst("// MOCK REPOSITORIES", "\$dummyBatch\n// MOCK REPOSITORIES");
      } else {
        content = content.replaceFirst("void main() {", "\$dummyBatch\nvoid main() {");
      }
      modified = true;
    }

    if (content.contains("class MockExpenseRepository implements ExpenseRepository {") && !content.contains("getAddExpenseOperation")) {
      final ops = '''
  @override
  BatchOperation getAddExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getUpdateExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getDeleteExpenseOperation(String userId, String id) => DummyBatchOperation();
''';
      content = content.replaceFirst("class MockExpenseRepository implements ExpenseRepository {", "class MockExpenseRepository implements ExpenseRepository {\n\$ops");
      modified = true;
    }

    if (content.contains("class MockPaymentMethodRepository implements PaymentMethodRepository {") && !content.contains("getAddPaymentMethodOperation")) {
      final ops = '''
  @override
  BatchOperation getAddPaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getUpdatePaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getDeletePaymentMethodOperation(String userId, String id) => DummyBatchOperation();
  @override
  BatchOperation getAddTransferOperation(String userId, Map<String, dynamic> transfer) => DummyBatchOperation();
''';
      content = content.replaceFirst("class MockPaymentMethodRepository implements PaymentMethodRepository {", "class MockPaymentMethodRepository implements PaymentMethodRepository {\n\$ops");
      modified = true;
    }

    if (content.contains("class MockIncomeRepository implements IncomeRepository {") && !content.contains("getAddIncomeOperation")) {
      final ops = '''
  @override
  BatchOperation getAddIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getUpdateIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getDeleteIncomeOperation(String userId, String id) => DummyBatchOperation();
''';
      content = content.replaceFirst("class MockIncomeRepository implements IncomeRepository {", "class MockIncomeRepository implements IncomeRepository {\n\$ops");
      modified = true;
    }

    if (content.contains("GetIt.instance.registerLazySingleton<CurrencyService>") && !content.contains("GetIt.instance.registerSingleton<BatchService>")) {
      final setupBatch = '''
    if (!GetIt.instance.isRegistered<BatchService>()) {
      GetIt.instance.registerSingleton<BatchService>(MockBatchService());
    }
''';
      content = content.replaceFirst("() => CurrencyService(),\n      );", "() => CurrencyService(),\n      );\n\$setupBatch");
      modified = true;
    }
    
    if (content.contains("GetIt.I.registerLazySingleton<CurrencyService>") && !content.contains("GetIt.I.registerSingleton<BatchService>")) {
      final setupBatch = '''
    if (!GetIt.I.isRegistered<BatchService>()) {
      GetIt.I.registerSingleton<BatchService>(MockBatchService());
    }
''';
      content = content.replaceFirst("() => CurrencyService(),\n    );", "() => CurrencyService(),\n    );\n\$setupBatch");
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print("Updated \${file.path}");
    }
  }
}
