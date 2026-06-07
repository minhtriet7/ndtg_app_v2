import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/banknote_directory_model.dart';

class BanknoteDirectoryService {
  final DioClient _client = DioClient();

  dynamic _unwrap(dynamic response) {
    try {
      final data = response.data;
      if (data != null) return data;
    } catch (_) {
      // DioClient may already return normalized response data.
    }
    return response;
  }

  List<dynamic> _parseList(dynamic response) {
    final payload = _unwrap(response);

    if (payload is List) return payload;

    final direct = ResponseParser.parseList(payload);
    if (direct.isNotEmpty) return direct;

    final map = ResponseParser.parseMap(payload);

    for (final key in ['data', 'items', 'results', 'banknotes']) {
      final value = map[key];
      if (value is List) return value;

      if (value is Map) {
        for (final nestedKey in ['data', 'items', 'results', 'banknotes']) {
          final nested = value[nestedKey];
          if (nested is List) return nested;
        }
      }
    }

    return const [];
  }

  Map<String, dynamic> _parseMap(dynamic response) {
    final payload = _unwrap(response);
    final map = ResponseParser.parseMap(payload);

    if (map.containsKey('data') && map['data'] is Map) {
      return Map<String, dynamic>.from(map['data']);
    }

    return map;
  }

  Future<List<BanknoteDirectoryModel>> getBanknotes() async {
    final response = await _client.get(ApiEndpoints.banknotes);
    final list = _parseList(response);

    return list
        .whereType<Map>()
        .map((item) => BanknoteDirectoryModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.isActive)
        .toList();
  }

  Future<BanknoteDirectoryModel> getBanknoteDetail(String id) async {
    final response = await _client.get(ApiEndpoints.banknoteDetail(id));
    final data = _parseMap(response);
    return BanknoteDirectoryModel.fromJson(data);
  }
}