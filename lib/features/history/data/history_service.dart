import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../../recognition/models/banknote_result_model.dart';

class HistoryService {
  final DioClient _client = DioClient();

  Future<List<BanknoteResultModel>> getFullHistory({
    String search = '',
    String status = 'all',
    String currency = 'all',
    int limit = 100,
  }) async {
    final response = await _client.get(
      ApiEndpoints.recognitionHistory,
      queryParameters: {
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (status != 'all') 'status': status,
        if (currency != 'all') 'currency': currency,
      },
    );

    final items = ResponseParser.parseList(response);
    return items
        .whereType<Map>()
        .map((item) => BanknoteResultModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
