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
    // Backend exposes GET /users/me/history without filter query.
    // Do filtering locally to avoid 400 Bad Request.
    final response = await _client.get(ApiEndpoints.userHistory);

    final items = ResponseParser.parseList(response)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final keyword = search.trim().toLowerCase();
    final normalizedStatus = status.toLowerCase();
    final normalizedCurrency = currency.toLowerCase();

    final filtered = items.where((item) {
      final text = item.toString().toLowerCase();

      final itemStatus = (item['status'] ?? '').toString().toLowerCase();

      final finalResult = item['final_result'];
      final resultMap = finalResult is Map ? finalResult : const {};

      final itemCurrency = (item['currency'] ??
          item['loai_tien'] ??
          resultMap['currency'] ??
          resultMap['loai_tien'] ??
          '')
          .toString()
          .toLowerCase();

      final matchSearch = keyword.isEmpty || text.contains(keyword);
      final matchStatus = normalizedStatus == 'all' ||
          itemStatus == normalizedStatus ||
          itemStatus.contains(normalizedStatus);
      final matchCurrency = normalizedCurrency == 'all' ||
          itemCurrency == normalizedCurrency ||
          itemCurrency.contains(normalizedCurrency);

      return matchSearch && matchStatus && matchCurrency;
    }).toList();

    final limited = limit > 0 && filtered.length > limit
        ? filtered.take(limit).toList()
        : filtered;

    return limited
        .map((item) => BanknoteResultModel.fromJson(item))
        .toList();
  }
}
