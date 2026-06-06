import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../../auth/models/auth_response.dart';
import '../models/home_stats_model.dart';

class HomeService {
  final DioClient _client = DioClient();

  Future<UserInfo> getDashboardUser() async {
    final response = await _client.get(ApiEndpoints.userMe);
    final payload = ResponseParser.parseMap(response);
    final data = ResponseParser.parseMap(
      payload['data'] ?? payload['user'] ?? payload,
    );

    return UserInfo.fromJson(data);
  }

  Future<HomeStatsModel> getHomeStats() async {
    try {
      final history = await getRecentScans(limit: 1000);

      final completed = history.where(_isCompletedScan).length;
      final failed = history.where(_isFailedOrReviewScan).length;

      final lastScanAt = history.isNotEmpty
          ? (history.first['created_at'] ??
          history.first['createdAt'] ??
          history.first['timestamp'])
          : null;

      return HomeStatsModel.fromJson({
        'total_scans': history.length,
        'completed': completed,
        'failed': failed,
        'needs_review': failed,
        'last_scan_at': lastScanAt,
      });
    } catch (_) {
      return HomeStatsModel.empty();
    }
  }

  Future<List<Map<String, dynamic>>> getRecentScans({int limit = 5}) async {
    try {
      final response = await _client.get(ApiEndpoints.userHistory);
      final list = ResponseParser.parseList(response)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (limit <= 0 || list.length <= limit) return list;
      return list.take(limit).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  bool _isCompletedScan(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().toLowerCase().trim();

    if (status.contains('failed') ||
        status.contains('error') ||
        status.contains('cancel') ||
        status.contains('review') ||
        status.contains('conflict')) {
      return false;
    }

    if (status.contains('success') ||
        status.contains('completed') ||
        status.contains('complete') ||
        status.contains('high consensus') ||
        status.contains('consensus') ||
        status.contains('partial')) {
      return true;
    }

    final finalResult = item['final_result'];
    if (finalResult is Map && finalResult.isNotEmpty) {
      return true;
    }

    return false;
  }

  bool _isFailedOrReviewScan(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().toLowerCase().trim();

    return status.contains('failed') ||
        status.contains('error') ||
        status.contains('review') ||
        status.contains('conflict') ||
        status.contains('uncertain');
  }
}