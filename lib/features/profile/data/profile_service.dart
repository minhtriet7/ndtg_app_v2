import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/user_model.dart';

class ProfileService {
  final DioClient _client = DioClient();

  dynamic _unwrap(dynamic response) {
    try {
      final data = response.data;
      if (data != null) return data;
    } catch (_) {
      // DioClient may already return normalized raw data.
    }

    return response;
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.userMe);
      return UserModel.fromJson(ResponseParser.parseMap(_unwrap(response)));
    } catch (_) {
      final response = await _client.get(ApiEndpoints.authMe);
      return UserModel.fromJson(ResponseParser.parseMap(_unwrap(response)));
    }
  }

  Future<UserModel> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'full_name': fullName.trim(),
      'fullName': fullName.trim(),
    };

    if (phone != null) {
      payload['phone'] = phone.trim();
    }

    if (avatarUrl != null) {
      payload['avatar_url'] = avatarUrl.trim();
      payload['avatarUrl'] = avatarUrl.trim();
    }

    final response = await _client.put(
      ApiEndpoints.userMe,
      data: payload,
    );

    return UserModel.fromJson(ResponseParser.parseMap(_unwrap(response)));
  }
}