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
    return Translations.keys[locale]?[key] ??
        Translations.keys['en']?[key] ??
        key;
  }

  String t(String key) => translate(key);

  String format(String key, Map<String, Object?> values) {
    var value = translate(key);
    for (final entry in values.entries) {
      value = value.replaceAll('{${entry.key}}', '${entry.value ?? ''}');
    }
    return value;
  }

  String status(String rawStatus) {
    final normalized = rawStatus.trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
    final key = 'status_$normalized';
    final translated = translate(key);
    if (translated != key) return translated;
    if (normalized.isEmpty) return translate('status_unknown');

    return normalized
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String text(BuildContext context, String key) {
    return AppLocalizations.of(context).t(key);
  }
}

extension AppLocalizationsExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).t(key);
  String trArgs(String key, Map<String, Object?> values) =>
      AppLocalizations.of(this).format(key, values);
  String trStatus(String status) => AppLocalizations.of(this).status(status);
}
