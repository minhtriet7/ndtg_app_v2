import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class SecureStorage {
  SecureStorage._internal();

  static final SecureStorage instance = SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getToken() {
    return _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> clearToken() {
    return _storage.delete(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> clearAuthTokens() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  Future<void> writeString(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> readString(String key) {
    return _storage.read(key: key);
  }

  Future<void> deleteKey(String key) {
    return _storage.delete(key: key);
  }

  Future<void> clearAll() {
    return _storage.deleteAll();
  }
}
