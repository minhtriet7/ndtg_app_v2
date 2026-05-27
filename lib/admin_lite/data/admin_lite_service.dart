import '../../core/network/dio_client.dart';
import '../../core/network/response_parser.dart';
import '../models/admin_dashboard_model.dart';
import '../models/admin_feedback_model.dart';
import '../models/admin_transaction_model.dart';

class AdminLiteService {
  final DioClient _client = DioClient();

  Future<AdminDashboardModel> getDashboardSummary() async {
    final response = await _client.get('/admin/dashboard/summary');
    final data = ResponseParser.parseMap(response.data);
    return AdminDashboardModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getSystemHealth() async {
    final response = await _client.get('/admin/system/health');
    return ResponseParser.parseMap(response.data);
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

    final list = ResponseParser.parseList(response.data);
    return list
        .whereType<Map>()
        .map((item) => AdminTransactionModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<AdminFeedbackModel>> getPendingFeedbacks() async {
    final response = await _client.get(
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

    final list = ResponseParser.parseList(response.data);
    return list
        .whereType<Map>()
        .map((item) => AdminFeedbackModel.fromJson(Map<String, dynamic>.from(item)))
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