import 'package:flutter/foundation.dart';

import '../constants/storage_keys.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import 'environment.dart';

class AppConfig {
  static const String appName = 'BanknoteAI';
  static const String appVersion = '1.0.0';
  static bool get isDebug => kDebugMode;

  static const String defaultDevelopmentBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String defaultStagingBaseUrl =
      'https://staging-api.banknoteai.com/api/v1';
  static const String defaultProductionBaseUrl =
      'https://api.banknoteai.com/api/v1';
  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get defaultBaseUrl {
    final definedUrl = normalizeApiBaseUrl(_definedBaseUrl);
    if (definedUrl != null) return definedUrl;

    // A release build never reads the mutable developer override.
    if (kReleaseMode) return defaultProductionBaseUrl;

    return switch (Environment.current) {
      EnvironmentType.production => defaultProductionBaseUrl,
      EnvironmentType.staging => defaultStagingBaseUrl,
      EnvironmentType.development => defaultDevelopmentBaseUrl,
    };
  }

  static String get baseUrl {
    if (kDebugMode) {
      try {
        final savedUrl = LocalStorage.instance.getString(
          StorageKeys.devApiBaseUrl,
        );
        final normalized = normalizeApiBaseUrl(savedUrl ?? '');
        if (normalized != null) {
          return normalized;
        }
      } catch (_) {
        // LocalStorage may not be ready during an early config read.
      }
    }

    return defaultBaseUrl;
  }

  static bool get hasSavedDevelopmentOverride {
    if (!kDebugMode) return false;
    try {
      final savedUrl = LocalStorage.instance.getString(
        StorageKeys.devApiBaseUrl,
      );
      return normalizeApiBaseUrl(savedUrl ?? '') != null;
    } catch (_) {
      return false;
    }
  }

  static String? normalizeApiBaseUrl(String input) {
    final value = input.trim();
    if (value.isEmpty || RegExp(r'\s').hasMatch(value)) return null;

    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return null;
    }

    var path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    if (!path.endsWith('/api/v1')) {
      path = '${path.isEmpty ? '' : path}/api/v1';
    }

    return uri.replace(path: path).toString();
  }

  static Future<String> saveCustomUrl(String url) async {
    if (!kDebugMode) {
      throw UnsupportedError('Runtime API override is debug-only.');
    }

    final normalized = normalizeApiBaseUrl(url);
    if (normalized == null) {
      throw const FormatException('Invalid API base URL.');
    }

    await LocalStorage.instance.setString(
      StorageKeys.devApiBaseUrl,
      normalized,
    );
    DioClient().updateBaseUrl(normalized);
    return normalized;
  }

  static Future<void> clearCustomUrl() async {
    if (!kDebugMode) return;
    await LocalStorage.instance.remove(StorageKeys.devApiBaseUrl);
    DioClient().updateBaseUrl(defaultBaseUrl);
  }

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 300000; // Tăng lên 5 phút (300,000 ms)
  static const int sendTimeoutMs =
      60000; // Tăng lên 1 phút (60,000 ms) để tải ảnh

  static const int maxImageSizeMb = 5;
  static const int pollingIntervalMs = 2500;
  static const int paymentPollingIntervalMs = 5000;
}
