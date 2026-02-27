// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final files = [
    'lib/features/payment_methods/presentation/pages/payment_method_detail_page.dart',
  ];

  for (var path in files) {
    File f = File(path);
    if (f.existsSync()) {
      var content = f.readAsStringSync();
      var newContent = content
          .replaceAll("Text(pm.name)", "Text(context.translateDbName(pm.name))")
          .replaceAll(
            "Text(pm.name",
            "Text(context.translateDbName(pm.name)",
          ) // for max lines etc.
          .replaceAll("g.name", "context.translateDbName(g.name)")
          .replaceAll(
            "fromAccount.name",
            "context.translateDbName(fromAccount.name)",
          )
          .replaceAll(
            "toAccount.name",
            "context.translateDbName(toAccount.name)",
          );

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
