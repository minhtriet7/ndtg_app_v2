import 'package:flutter/material.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = LocalStorage.instance.getString(StorageKeys.themeMode);
    if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedMode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedMode == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      final legacyDark = LocalStorage.instance.getBool('is_dark_mode');
      if (legacyDark != null) {
        _themeMode = legacyDark ? ThemeMode.dark : ThemeMode.light;
      }
    }
  }

  bool isDarkMode(BuildContext context) {
    return _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await LocalStorage.instance.saveString(
      StorageKeys.themeMode,
      switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      },
    );
    notifyListeners();
  }

  Future<void> toggleTheme(BuildContext context) async {
    final newMode = isDarkMode(context) ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
