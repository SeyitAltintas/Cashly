import os
import re

target_files = [
    'test/unit/expense_business_logic_test.dart',
    'test/unit/expenses_controller_test.dart',
    'test/unit/income_business_logic_test.dart',
    'test/unit/incomes_controller_test.dart',
    'test/unit/payment_method_business_logic_test.dart',
    'test/unit/payment_methods_controller_test.dart',
    'test/widget/transfer_page_edge_cases_test.dart',
    'test/unit/asset_business_logic_test.dart',
    'test/unit/assets_controller_test.dart'
]

ops_expense = '''
  @override
  BatchOperation getAddExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getUpdateExpenseOperation(String userId, Map<String, dynamic> expense) => DummyBatchOperation();
  @override
  BatchOperation getDeleteExpenseOperation(String userId, String id) => DummyBatchOperation();
'''

ops_payment = '''
  @override
  BatchOperation getAddPaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getUpdatePaymentMethodOperation(String userId, Map<String, dynamic> method) => DummyBatchOperation();
  @override
  BatchOperation getDeletePaymentMethodOperation(String userId, String id) => DummyBatchOperation();
  @override
  BatchOperation getAddTransferOperation(String userId, Map<String, dynamic> transfer) => DummyBatchOperation();
'''

ops_income = '''
  @override
  BatchOperation getAddIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getUpdateIncomeOperation(String userId, Map<String, dynamic> income) => DummyBatchOperation();
  @override
  BatchOperation getDeleteIncomeOperation(String userId, String id) => DummyBatchOperation();
'''

ops_asset = '''
  @override
  BatchOperation getAddAssetOperation(String userId, Map<String, dynamic> asset) => DummyBatchOperation();
  @override
  BatchOperation getUpdateAssetOperation(String userId, Map<String, dynamic> asset) => DummyBatchOperation();
  @override
  BatchOperation getDeleteAssetOperation(String userId, String id) => DummyBatchOperation();
  @override
  Future<void> saveDeletedAssets(String userId, List<Map<String, dynamic>> assets) async {}
'''

def replace_ops(match):
    repo_name = match.group(1)
    replacement = ""
    if repo_name == "Expense":
        replacement = ops_expense
    elif repo_name == "PaymentMethod":
        replacement = ops_payment
    elif repo_name == "Income":
        replacement = ops_income
    elif repo_name == "Asset":
        replacement = ops_asset
    
    return f"class Mock{repo_name}Repository implements {repo_name}Repository {{{replacement}"

for filepath in target_files:
    if not os.path.exists(filepath):
        continue
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changed = False
    if "$ops" in content:
        # Regex to match class Mock...Repository implements ...Repository { and any whitespace then $ops
        pattern = r"class\s+Mock(\w+)Repository\s+implements\s+\1Repository\s*\{\s*\$ops"
        new_content = re.sub(pattern, replace_ops, content)
        if new_content != content:
            content = new_content
            changed = True
            
    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")
