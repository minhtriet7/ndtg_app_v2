import 'package:dio/dio.dart';

class ResponseParser {
  ResponseParser._();

  static dynamic unwrap(dynamic response) {
    if (response is Response) return response.data;
    return response;
  }

  static List<dynamic> parseList(dynamic response) {
    final target = unwrap(response);

    if (target == null) return [];
    if (target is List) return target;

    if (target is Map) {
      if (target['items'] is List) return target['items'] as List;
      if (target['results'] is List) return target['results'] as List;
      if (target['data'] is List) return target['data'] as List;

      final data = target['data'];
      if (data is Map) {
        if (data['items'] is List) return data['items'] as List;
        if (data['results'] is List) return data['results'] as List;
        if (data['data'] is List) return data['data'] as List;
      }
    }

    return [];
  }

  static Map<String, dynamic> parseMap(dynamic response) {
    final target = unwrap(response);

    if (target is Map) {
      final map = Map<String, dynamic>.from(target);
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      return map;
    }

    return {};
  }

  static dynamic getValue(
      Map<String, dynamic> json,
      List<String> keys, {
        dynamic defaultValue,
      }) {
    for (final key in keys) {
      final value = _readPath(json, key);
      if (value != null) return value;
    }

    return defaultValue;
  }

  static dynamic _readPath(Map<String, dynamic> json, String key) {
    if (!key.contains('.')) return json[key];

    dynamic current = json;
    for (final part in key.split('.')) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }
}
