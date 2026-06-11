import '../../core/network/dio_client.dart';
import '../../core/network/response_parser.dart';
import '../models/admin_dashboard_model.dart';
import '../models/admin_feedback_model.dart';
import '../models/admin_transaction_model.dart';

class AdminLiteService {
  final DioClient _client = DioClient();

  dynamic _unwrapResponse(dynamic response) {
    try {
      final data = response.data;
      if (data != null) return data;
    } catch (_) {
      // DioClient may already return normalized response data.
    }

    return response;
  }

  dynamic _unwrapApiData(dynamic response) {
    final payload = _unwrapResponse(response);

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);

      if (map.containsKey('success') && map.containsKey('data')) {
        return map['data'];
      }

      if (map.containsKey('data')) {
        final data = map['data'];

        if (data is List) return data;

        if (data is Map) {
          final dataMap = Map<String, dynamic>.from(data);

          final hasDashboardKeys = dataMap.containsKey('kpis') ||
              dataMap.containsKey('summary') ||
              dataMap.containsKey('payments') ||
              dataMap.containsKey('payment_overview') ||
              dataMap.containsKey('system_status') ||
              dataMap.containsKey('health');

          if (hasDashboardKeys) return dataMap;

          for (final key in [
            'items',
            'results',
            'transactions',
            'feedbacks',
            'records',
            'rows',
          ]) {
            if (dataMap[key] is List) return dataMap[key];
          }

          return dataMap;
        }
      }
    }

    return payload;
  }

  Map<String, dynamic> _parseMap(dynamic response) {
    return ResponseParser.parseMap(_unwrapApiData(response));
  }

  List<dynamic> _parseList(dynamic response) {
    final payload = _unwrapApiData(response);

    if (payload is List) return payload;

    final directList = ResponseParser.parseList(payload);
    if (directList.isNotEmpty) return directList;

    final map = ResponseParser.parseMap(payload);

    for (final key in [
      'items',
      'data',
      'results',
      'transactions',
      'feedbacks',
      'records',
      'rows',
    ]) {
      final value = map[key];

      if (value is List) return value;

      if (value is Map) {
        for (final nestedKey in [
          'items',
          'data',
          'results',
          'transactions',
          'feedbacks',
          'records',
          'rows',
        ]) {
          final nestedValue = value[nestedKey];
          if (nestedValue is List) return nestedValue;
        }
      }
    }

    return const [];
  }

  Future<AdminDashboardModel> getDashboardSummary() async {
    final response = await _client.get('/admin/dashboard/summary');
    return AdminDashboardModel.fromJson(_parseMap(response));
  }

  Future<Map<String, dynamic>> getSystemHealth() async {
    final response = await _client.get('/admin/system/health');
    return _parseMap(response);
  }

  Future<List<AdminTransactionModel>> getPendingTransactions({
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/admin/transactions',
      queryParameters: {
        'page': 1,
        'limit': limit,
        'status': 'pending',
        'gateway': 'all',
        'search': '',
      },
    );

    final items = _parseList(response)
        .whereType<Map>()
        .map((item) => AdminTransactionModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.isPending)
        .toList();

    return items;
  }

  Future<List<AdminFeedbackModel>> getPendingFeedbacks({
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/admin/feedbacks/pending',
      queryParameters: {'limit': limit},
    );

    final primary = _parseList(response)
        .whereType<Map>()
        .map((item) => AdminFeedbackModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.isPending)
        .toList();

    if (primary.isNotEmpty) return primary;

    final fallbackResponse = await _client.get(
      '/admin/feedbacks',
      queryParameters: {
        'page': 1,
        'limit': limit,
        'status': 'pending',
        'type': 'all',
        'priority': 'all',
        'rating': 'all',
        'search': '',
      },
    );

    return _parseList(fallbackResponse)
        .whereType<Map>()
        .map((item) => AdminFeedbackModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.isPending)
        .toList();
  }

  Future<void> markTransactionPaid(String transactionId) async {
    await _client.put('/admin/transactions/$transactionId/mark-paid');
  }

  Future<void> cancelTransaction(String transactionId) async {
    await _client.put('/admin/transactions/$transactionId/cancel');
  }

  Future<void> updateFeedbackStatus(String feedbackId, String status) async {
    await _client.put(
      '/admin/feedbacks/$feedbackId/status',
      data: {'status': status},
    );
  }

  Future<void> updateFeedbackPriority(String feedbackId, String priority) async {
    await _client.put(
      '/admin/feedbacks/$feedbackId/priority',
      data: {'priority': priority},
    );
  }
}