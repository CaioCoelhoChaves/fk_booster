import 'package:example/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';

export 'package:example/l10n/arb/app_localizations.dart';

/// Extension for ergonomic l10n access via `context.l10n`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
