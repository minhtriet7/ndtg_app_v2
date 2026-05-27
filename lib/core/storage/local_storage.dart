import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static final LocalStorage instance = LocalStorage._();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final current = _prefs;
    if (current == null) {
      throw StateError('LocalStorage has not been initialized. Call initialize() first.');
    }
    return current;
  }

  Future<bool> setString(String key, String value) async {
    return prefs.setString(key, value);
  }

  Future<bool> saveString(String key, String value) async {
    return setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return prefs.setBool(key, value);
  }

  Future<bool> saveBool(String key, bool value) async {
    return setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return prefs.setInt(key, value);
  }

  Future<bool> saveInt(String key, int value) async {
    return setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<bool> remove(String key) async {
    return prefs.remove(key);
  }

  Future<bool> deleteKey(String key) async {
    return remove(key);
  }

  Future<bool> clear() async {
    return prefs.clear();
  }
}