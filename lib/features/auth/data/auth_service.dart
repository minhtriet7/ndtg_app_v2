import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
  final DioClient _client = DioClient();

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      // Some FastAPI auth endpoints use OAuth2PasswordRequestForm.
      // Retry with form data only when the JSON shape is rejected, not on invalid credentials.
      if (statusCode == 400 || statusCode == 415 || statusCode == 422) {
        final formResponse = await _client.post(
          ApiEndpoints.login,
          data: FormData.fromMap(request.toFormJson()),
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
        return AuthResponse.fromJson(formResponse.data);
      }
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<UserInfo> getMe() async {
    Response response;
    try {
      response = await _client.get(ApiEndpoints.authMe);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        response = await _client.get(ApiEndpoints.userMe);
      } else {
        rethrow;
      }
    }

    final payload = ResponseParser.parseMap(response);
    final data = ResponseParser.parseMap(payload['data'] ?? payload['user'] ?? payload);
    if (data.isEmpty) {
      throw ApiException(message: 'Unable to read current user profile.');
    }
    return UserInfo.fromJson(data);
  }
}
