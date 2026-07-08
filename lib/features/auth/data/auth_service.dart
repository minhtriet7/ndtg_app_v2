import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
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

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      return AuthResponse.fromJson(ResponseParser.parseMap(_unwrap(response)));
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 400 || statusCode == 415 || statusCode == 422) {
        final formResponse = await _client.post(
          ApiEndpoints.login,
          data: FormData.fromMap(request.toFormJson()),
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );

        return AuthResponse.fromJson(
          ResponseParser.parseMap(_unwrap(formResponse)),
        );
      }

      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(ResponseParser.parseMap(_unwrap(response)));
  }

  Future<void> forgotPassword(String email) async {
    await _client.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim()},
    );
  }

  Future<UserInfo> getMe() async {
    dynamic response;

    try {
      response = await _client.get(ApiEndpoints.userMe);
    } catch (_) {
      response = await _client.get(ApiEndpoints.authMe);
    }

    final payload = ResponseParser.parseMap(_unwrap(response));
    final data = ResponseParser.parseMap(
      payload['data'] ??
          payload['user'] ??
          payload['profile'] ??
          payload['account'] ??
          payload,
    );

    if (data.isEmpty) {
      throw ApiException(message: 'Unable to read current user profile.');
    }

    return UserInfo.fromJson(data);
  }

  String getGoogleLoginUrl() {
    final root = AppConfig.baseUrl.endsWith('/api/v1')
        ? AppConfig.baseUrl.substring(
            0,
            AppConfig.baseUrl.length - '/api/v1'.length,
          )
        : AppConfig.baseUrl;

    return '$root/api/v1/auth/google/login?platform=mobile';
  }

  Future<AuthResponse> authenticateWithGoogle() async {
    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: getGoogleLoginUrl(),
      callbackUrlScheme: 'banknoteai',
    );

    final uri = Uri.parse(callbackUrl);
    final token = uri.queryParameters['token'];
    final refreshToken = uri.queryParameters['refresh_token'] ?? '';

    if (token == null || token.isEmpty) {
      final error = uri.queryParameters['error'] ?? 'Google login failed.';
      throw ApiException(message: error);
    }

    return AuthResponse.fromJson({
      'access_token': token,
      'refresh_token': refreshToken,
      'token_type': 'bearer',
    });
  }
}
