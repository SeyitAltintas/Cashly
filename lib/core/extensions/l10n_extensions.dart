import 'package:flutter/material.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

/// BuildContext'ten AppLocalizations'a kolay erişim sağlar.
///
/// Kullanım:
/// ```dart
/// final l10n = context.l10n;
/// Text(l10n.settings);
/// ```
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
