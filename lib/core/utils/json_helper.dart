class JsonHelper {
  const JsonHelper._();

  static dynamic getValue(
      Map<String, dynamic>? json,
      List<String> keys, {
        dynamic fallback,
        dynamic defaultValue,
      }) {
    if (json == null) return fallback ?? defaultValue;

    for (final key in keys) {
      final value = _readPath(json, key);
      if (value != null) return value;
    }

    return fallback ?? defaultValue;
  }

  static dynamic _readPath(Map<String, dynamic> json, String path) {
    dynamic current = json;

    for (final part in path.split('.')) {
      if (current is Map) {
        if (current.containsKey(part)) {
          current = current[part];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    return current;
  }

  static String safeString(
      dynamic value, {
        String fallback = '',
        String defaultValue = '',
      }) {
    final fb = fallback.isNotEmpty ? fallback : defaultValue;
    if (value == null) return fb;
    final text = value.toString();
    return text.isEmpty ? fb : text;
  }

  static String? safeStringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int safeInt(
      dynamic value, {
        int fallback = 0,
        int defaultValue = 0,
      }) {
    final fb = fallback != 0 ? fallback : defaultValue;
    if (value == null) return fb;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? fb;
  }

  static double safeDouble(
      dynamic value, {
        double fallback = 0,
        double defaultValue = 0,
      }) {
    final fb = fallback != 0 ? fallback : defaultValue;
    if (value == null) return fb;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fb;
  }

  static bool safeBool(
      dynamic value, {
        bool fallback = false,
        bool defaultValue = false,
      }) {
    final fb = fallback || defaultValue;
    if (value == null) return fb;
    if (value is bool) return value;
    final text = value.toString().toLowerCase().trim();
    if (['true', '1', 'yes', 'active', 'enabled'].contains(text)) return true;
    if (['false', '0', 'no', 'inactive', 'disabled'].contains(text)) return false;
    return fb;
  }

  static DateTime? safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static Map<String, dynamic> safeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<dynamic> safeList(dynamic value) {
    if (value is List) return value;
    return <dynamic>[];
  }
}