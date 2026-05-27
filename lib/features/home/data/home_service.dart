import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../../auth/models/auth_response.dart';
import '../models/home_stats_model.dart';

class HomeService {
  final DioClient _client = DioClient();

  Future<UserInfo> getDashboardUser() async {
    try {
      final response = await _client.get(ApiEndpoints.userMe);
      final data = ResponseParser.parseMap(response);
      return UserInfo.fromJson(data);
    } catch (_) {
      final response = await _client.get(ApiEndpoints.authMe);
      final data = ResponseParser.parseMap(response);
      return UserInfo.fromJson(data);
    }
  }

  Future<HomeStatsModel> getHomeStats() async {
    try {
      final response = await _client.get('/users/me/stats');
      return HomeStatsModel.fromJson(ResponseParser.parseMap(response));
    } catch (_) {
      final user = await getDashboardUser();
      return HomeStatsModel.fromJson(user.toJson());
    }
  }

  Future<List<Map<String, dynamic>>> getRecentScans({int limit = 5}) async {
    final response = await _client.get(
      ApiEndpoints.recognitionHistory,
      queryParameters: {'limit': limit},
    );

    return ResponseParser.parseList(response)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
