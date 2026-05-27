enum EnvironmentType {
  development,
  staging,
  production,
}

class Environment {
  Environment._();

  static EnvironmentType _currentEnv = EnvironmentType.development;

  static EnvironmentType get current => _currentEnv;

  static void setEnvironment(EnvironmentType type) {
    _currentEnv = type;
  }

  static bool get isDevelopment => _currentEnv == EnvironmentType.development;
  static bool get isStaging => _currentEnv == EnvironmentType.staging;
  static bool get isProduction => _currentEnv == EnvironmentType.production;

  static String get name => _currentEnv.name;
}
