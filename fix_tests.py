import os
import glob

def fix_test_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Needs import BatchService
    if "import 'package:cashly/core/services/batch_service.dart';" not in content:
        if "import 'package:get_it/get_it.dart';" in content:
            content = content.replace("import 'package:get_it/get_it.dart';", "import 'package:get_it/get_it.dart';\nimport 'package:cashly/core/services/batch_service.dart';")
        elif "import 'package:cashly/core/di/injection_container.dart';" in content:
            content = content.replace("import 'package:cashly/core/di/injection_container.dart';", "import 'package:cashly/core/di/injection_container.dart';\nimport 'package:cashly/core/services/batch_service.dart';")
        else:
            content = content.replace("import 'package:flutter_test/flutter_test.dart';", "import 'package:flutter_test/flutter_test.dart';\nimport 'package:cashly/core/services/batch_service.dart';")
            
    # DummyBatchOperation
    dummy_op = """
class DummyBatchOperation implements BatchOperation {
  @override
  Map<String, dynamic> toJson() => {};
}
"""
    if "class DummyBatchOperation" not in content:
        if "// MOCK REPOSITORIES" in content:
            content = content.replace("// MOCK REPOSITORIES", dummy_op + "\n// MOCK REPOSITORIES")
        else:
            content = content.replace("void main() {", dummy_op + "\nvoid main() {")
        
    # MockExpenseRepository
    if "class MockExpenseRepository implements ExpenseRepository {" in content and "getAddExpenseOperation" not in content:
        ops = """
  @override
  BatchOperation getAddExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getUpdateExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getDeleteExpenseOperation(String userId, String id) => DummyBatchOperation();
"""
        content = content.replace("class MockExpenseRepository implements ExpenseRepository {", "class MockExpenseRepository implements ExpenseRepository {\n" + ops)
        
    # MockPaymentMethodRepository
    if "class MockPaymentMethodRepository implements PaymentMethodRepository {" in content and "getAddPaymentMethodOperation" not in content:
        ops = """
  @override
  BatchOperation getAddPaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getUpdatePaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getDeletePaymentMethodOperation(String userId, String id) => DummyBatchOperation();
  @override
  BatchOperation getAddTransferOperation(String userId, Map<String, dynamic> transfer) => DummyBatchOperation();
"""
        content = content.replace("class MockPaymentMethodRepository implements PaymentMethodRepository {", "class MockPaymentMethodRepository implements PaymentMethodRepository {\n" + ops)
        
    # MockIncomeRepository
    if "class MockIncomeRepository implements IncomeRepository {" in content and "getAddIncomeOperation" not in content:
        ops = """
  @override
  BatchOperation getAddIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getUpdateIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getDeleteIncomeOperation(String userId, String id) => DummyBatchOperation();
"""
        content = content.replace("class MockIncomeRepository implements IncomeRepository {", "class MockIncomeRepository implements IncomeRepository {\n" + ops)

    # MockBatchService
    mock_batch = """
class MockBatchService implements BatchService {
  @override
  Future<void> commit(List<BatchOperation> operations) async {}
}
"""
    if "class MockBatchService" not in content:
        if "// MOCK REPOSITORIES" in content:
            content = content.replace("// MOCK REPOSITORIES", mock_batch + "\n// MOCK REPOSITORIES")
        else:
            content = content.replace("void main() {", mock_batch + "\nvoid main() {")
        
    # Register MockBatchService
    setup_batch = """
    if (!GetIt.instance.isRegistered<BatchService>()) {
      GetIt.instance.registerSingleton<BatchService>(MockBatchService());
    }
"""
    if "GetIt.instance.registerLazySingleton<CurrencyService>" in content and setup_batch.strip() not in content:
        content = content.replace("() => CurrencyService(),\n      );", "() => CurrencyService(),\n      );\n" + setup_batch)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk('test'):
    for file in files:
        if file.endswith('_test.dart'):
            fix_test_file(os.path.join(root, file))
