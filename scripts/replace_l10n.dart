// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final files = [
    'lib/features/dashboard/presentation/widgets/recent_transactions_card.dart',
    'lib/features/dashboard/presentation/widgets/category_spending_card.dart',
    'lib/features/dashboard/presentation/widgets/balance_card.dart',
    'lib/features/expenses/presentation/widgets/expense_list_item.dart',
    'lib/features/income/presentation/widgets/income_list_item.dart',
    'lib/features/payment_methods/presentation/widgets/payment_method_card.dart',
  ];

  for (var path in files) {
    File f = File(path);
    if (f.existsSync()) {
      var content = f.readAsStringSync();
      var newContent = content
          .replaceAll(
            "Text(expense['isim']",
            "Text(context.translateDbName(expense['isim'])",
          )
          .replaceAll(
            "Text(h['isim']",
            "Text(context.translateDbName(h['isim'])",
          )
          .replaceAll(
            "Text(income.name",
            "Text(context.translateDbName(income.name)",
          )
          .replaceAll("Text(pm.name", "Text(context.translateDbName(pm.name)")
          .replaceAll("\${pm.name}", "\${context.translateDbName(pm.name)}")
          .replaceAll(
            "Text(expense.category",
            "Text(context.translateDbName(expense.category)",
          )
          .replaceAll("entry.key,", "context.translateDbName(entry.key),");

      // Need to add import
      if (newContent != content) {
        if (!newContent.contains("l10n_extensions.dart")) {
          newContent =
              "import 'package:cashly/core/extensions/l10n_extensions.dart';\n$newContent";
        }
        f.writeAsStringSync(newContent);
        print('Updated $path');
      }
    }
  }
}
