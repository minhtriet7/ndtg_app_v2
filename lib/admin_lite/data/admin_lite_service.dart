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

      if (map.containsKey('data') &&
          map['data'] is Map &&
          !map.containsKey('kpis') &&
          !map.containsKey('items')) {
        return map['data'];
      }
    }

    return payload;
  }

  Map<String, dynamic> _parseMap(dynamic response) {
    final payload = _unwrapApiData(response);
    return ResponseParser.parseMap(payload);
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
    final data = _parseMap(response);

    return AdminDashboardModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getSystemHealth() async {
    final response = await _client.get('/admin/system/health');
    return _parseMap(response);
  }

  Future<Map<String, dynamic>> getAgentPerformance() async {
    final response = await _client.get('/admin/agents/performance');
    return _parseMap(response);
  }

  Future<List<Map<String, dynamic>>> getRecentScans({int limit = 8}) async {
    final response = await _client.get(
      '/admin/recognition/recent',
      queryParameters: {'limit': limit},
    );

    return _parseList(response)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<AdminTransactionModel>> getPendingTransactions() async {
    final response = await _client.get(
      '/admin/transactions',
      queryParameters: {
        'page': 1,
        'limit': 20,
        'status': 'pending',
        'gateway': 'all',
        'search': '',
      },
    );

    return _parseList(response)
        .whereType<Map>()
        .map(
          (item) => AdminTransactionModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<List<AdminFeedbackModel>> getPendingFeedbacks() async {
    // Web admin uses this endpoint for pending feedback on dashboard.
    final response = await _client.get(
      '/admin/feedbacks/pending',
      queryParameters: {'limit': 20},
    );

    final pending = _parseList(response);

    if (pending.isNotEmpty) {
      return pending
          .whereType<Map>()
          .map(
            (item) => AdminFeedbackModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    // Fallback to manager endpoint.
    final fallbackResponse = await _client.get(
      '/admin/feedbacks',
      queryParameters: {
        'page': 1,
        'limit': 20,
        'status': 'pending',
        'type': 'all',
        'priority': 'all',
        'rating': 'all',
        'search': '',
      },
    );

    return _parseList(fallbackResponse)
        .whereType<Map>()
        .map(
          (item) => AdminFeedbackModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
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