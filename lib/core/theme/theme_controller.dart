import 'package:flutter/material.dart';
import '../storage/local_storage.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = LocalStorage.instance.getBool('is_dark_mode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  bool isDarkMode(BuildContext context) {
    return _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    if (mode != ThemeMode.system) {
      await LocalStorage.instance.saveBool('is_dark_mode', mode == ThemeMode.dark);
    }
    notifyListeners();
  }

  Future<void> toggleTheme(BuildContext context) async {
    final newMode = isDarkMode(context) ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
