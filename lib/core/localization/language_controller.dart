import 'package:flutter/material.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

class LanguageController extends ChangeNotifier {
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;
  bool get isVietnamese => _currentLocale == 'vi';
  bool get isEnglish => _currentLocale == 'en';

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
    final normalized = languageCode.trim().toLowerCase();
    if (normalized != 'vi' && normalized != 'en') return;
    if (_currentLocale == normalized) return;

    _currentLocale = normalized;
    await LocalStorage.instance.saveString(StorageKeys.languageCode, normalized);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    await changeLanguage(_currentLocale == 'vi' ? 'en' : 'vi');
  }
}
