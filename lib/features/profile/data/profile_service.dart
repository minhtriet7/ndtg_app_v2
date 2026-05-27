import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/user_model.dart';

class ProfileService {
  final DioClient _client = DioClient();

  Future<UserModel> getProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.userMe);
      return UserModel.fromJson(ResponseParser.parseMap(response.data));
    } catch (_) {
      final response = await _client.get(ApiEndpoints.authMe);
      return UserModel.fromJson(ResponseParser.parseMap(response.data));
    }
  }

  Future<UserModel> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'full_name': fullName.trim(),
    };

    if (phone != null && phone.trim().isNotEmpty) {
      payload['phone'] = phone.trim();
    }

    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      payload['avatar_url'] = avatarUrl.trim();
    }

    final response = await _client.put(ApiEndpoints.userMe, data: payload);
    return UserModel.fromJson(ResponseParser.parseMap(response.data));
  }
}
