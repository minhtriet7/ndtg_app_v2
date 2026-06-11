import 'environment.dart';

class AppConfig {
  static const String appName = 'BanknoteAI';
  static const String appVersion = '1.0.0';
  static const bool isDebug = true;

  // Android Emulator: dùng 10.0.2.2 (http://10.0.2.2:8000/api/v1)
  // Điện thoại thật: dùng IP Wi-Fi của máy tính (http://192.168.1.160:8000/api/v1)
  // Production: dùng HTTPS domain thật.
  static String get baseUrl {
    switch (Environment.current) {
      case EnvironmentType.production:
        return 'https://api.banknoteai.com/api/v1';
      case EnvironmentType.staging:
        return 'https://staging-api.banknoteai.com/api/v1';
      case EnvironmentType.development:
        // return 'http://10.0.2.2:8000/api/v1';
        // return 'http://192.168.1.160:8000/api/v1';
        return 'https://nonpropitiable-dentately-lee.ngrok-free.dev/api/v1';
    }
  }

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 300000; // Tăng lên 5 phút (300,000 ms)
  static const int sendTimeoutMs = 60000;     // Tăng lên 1 phút (60,000 ms) để tải ảnh

  static const int maxImageSizeMb = 5;
  static const int pollingIntervalMs = 2500;
  static const int paymentPollingIntervalMs = 5000;
}