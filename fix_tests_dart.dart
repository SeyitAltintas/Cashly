import 'dart:io';

void main() {
  final targetFiles = [
    'test/unit/expense_business_logic_test.dart',
    'test/unit/expenses_controller_test.dart',
    'test/unit/income_business_logic_test.dart',
    'test/unit/incomes_controller_test.dart',
    'test/unit/payment_method_business_logic_test.dart',
    'test/unit/payment_methods_controller_test.dart',
    'test/widget/transfer_page_edge_cases_test.dart',
    'test/unit/asset_business_logic_test.dart',
    'test/unit/assets_controller_test.dart'
  ];

  final opsExpense = '''
  @override
  BatchOperation getAddExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getUpdateExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getDeleteExpenseOperation(String userId, String id) => DummyBatchOperation();
''';

  final opsPayment = '''
  @override
  BatchOperation getAddPaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getUpdatePaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getDeletePaymentMethodOperation(String userId, String id) => DummyBatchOperation();
  @override
  BatchOperation getAddTransferOperation(String userId, Map<String, dynamic> transfer) => DummyBatchOperation();
''';

  final opsIncome = '''
  @override
  BatchOperation getAddIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getUpdateIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getDeleteIncomeOperation(String userId, String id) => DummyBatchOperation();
''';

  final opsAsset = '''
  @override
  BatchOperation getAddAssetOperation(String userId, Map<String, dynamic> asset) => DummyBatchOperation();
  @override
  BatchOperation getUpdateAssetOperation(String userId, Map<String, dynamic> asset) => DummyBatchOperation();
  @override
  BatchOperation getDeleteAssetOperation(String userId, String id) => DummyBatchOperation();
  @override
  Future<void> saveDeletedAssets(String userId, List<Map<String, dynamic>> assets) async {}
''';

  for (final filePath in targetFiles) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();
    bool changed = false;

    // 1. Fix DummyBatchOperation literal
    if (content.contains("\$dummyBatch")) {
       content = content.replaceAll("\$dummyBatch", '''
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
}''');
       changed = true;
    }

    // 2. Fix $ops with EXACT match for the enclosing class
    if (content.contains("\$ops")) {
        content = content.replaceAll("class MockExpenseRepository implements ExpenseRepository {\n\$ops", "class MockExpenseRepository implements ExpenseRepository {\n" + opsExpense);
        content = content.replaceAll("class MockPaymentMethodRepository implements PaymentMethodRepository {\n\$ops", "class MockPaymentMethodRepository implements PaymentMethodRepository {\n" + opsPayment);
        content = content.replaceAll("class MockIncomeRepository implements IncomeRepository {\n\$ops", "class MockIncomeRepository implements IncomeRepository {\n" + opsIncome);
        content = content.replaceAll("class MockAssetRepository implements AssetRepository {\n\$ops", "class MockAssetRepository implements AssetRepository {\n" + opsAsset);
        changed = true;
    }
    
    // 3. For Asset tests, they didn't have $ops in the latest commit, because the initial script missed them or didn't add it! 
    // They have DummyBatchOperation() usage but no DummyBatchOperation class! Wait, if they have DummyBatchOperation() usage they must be fixed.
    if (content.contains("class MockAssetRepository implements AssetRepository {") && !content.contains("getAddAssetOperation")) {
        content = content.replaceFirst("class MockAssetRepository implements AssetRepository {", "class MockAssetRepository implements AssetRepository {\n" + opsAsset);
        changed = true;
    }

    if (changed) {
        file.writeAsStringSync(content);
        print("Fixed " + file.path);
    }
  }
}
