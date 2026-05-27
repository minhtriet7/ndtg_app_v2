import 'package:flutter/material.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

class LanguageController extends ChangeNotifier {
  String _currentLocale = 'vi';

  String get currentLocale => _currentLocale;
  bool get isVietnamese => _currentLocale == 'vi';

  LanguageController() {
    loadLocale();
  }

  void loadLocale() {
    final savedLocale = LocalStorage.instance.getString(StorageKeys.languageCode);
    if (savedLocale == 'vi' || savedLocale == 'en') {
      _currentLocale = savedLocale!;
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != 'vi' && languageCode != 'en') return;

    _currentLocale = languageCode;
    await LocalStorage.instance.saveString(StorageKeys.languageCode, languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    await changeLanguage(_currentLocale == 'vi' ? 'en' : 'vi');
  }
}
