import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'language_controller.dart';
import 'translations.dart';

class AppLocalizations {
  AppLocalizations(this.context);

  final BuildContext context;

  static AppLocalizations of(BuildContext context) => AppLocalizations(context);

  String translate(String key) {
    final locale = context.read<LanguageController>().currentLocale;
    return Translations.keys[locale]?[key] ?? Translations.keys['en']?[key] ?? key;
  }

  String t(String key) => translate(key);

  static String text(BuildContext context, String key) {
    return AppLocalizations.of(context).t(key);
  }
}

extension AppLocalizationsExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).t(key);
}
