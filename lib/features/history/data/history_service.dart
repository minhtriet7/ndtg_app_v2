import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../../recognition/models/banknote_result_model.dart';

class HistoryService {
  final DioClient _client = DioClient();

  dynamic _unwrap(dynamic response) {
    try {
      final data = response.data;
      if (data != null) return data;
    } catch (_) {
      // DioClient may already return raw normalized data.
    }

    return response;
  }

  List<dynamic> _parseList(dynamic response) {
    final payload = _unwrap(response);

    if (payload is List) return payload;

    final direct = ResponseParser.parseList(payload);
    if (direct.isNotEmpty) return direct;

    final map = ResponseParser.parseMap(payload);

    for (final key in [
      'data',
      'items',
      'results',
      'history',
      'recognitions',
      'records',
    ]) {
      final value = map[key];

      if (value is List) return value;

      if (value is Map) {
        for (final nestedKey in [
          'data',
          'items',
          'results',
          'history',
          'recognitions',
          'records',
        ]) {
          final nested = value[nestedKey];
          if (nested is List) return nested;
        }
      }
    }

    return const [];
  }

  Future<List<BanknoteResultModel>> getFullHistory({int limit = 300}) async {
    dynamic response;
    try {
      response = await _client.get(ApiEndpoints.userHistory);
    } catch (e) {
      rethrow;
    }

    final items = _parseList(response)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final results = items.map(BanknoteResultModel.fromJson).toList();

    results.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt);
      final bDate = DateTime.tryParse(b.createdAt);

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    if (limit > 0 && results.length > limit) {
      return results.take(limit).toList();
    }

    return results;
  }
}