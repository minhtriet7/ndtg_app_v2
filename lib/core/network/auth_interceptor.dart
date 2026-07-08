import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;
  static Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.instance.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthRequest =
        err.requestOptions.path == ApiEndpoints.login ||
        err.requestOptions.path == ApiEndpoints.refreshToken;
    final alreadyRetried =
        err.requestOptions.extra['banknoteai_auth_retried'] == true;

    if (!isUnauthorized || isAuthRequest || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await SecureStorage.instance.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await SecureStorage.instance.clearAuthTokens();
      handler.next(err);
      return;
    }

    try {
      _refreshFuture ??= _refreshAccessToken(
        err.requestOptions.baseUrl,
        refreshToken,
      );
      final newAccessToken = await _refreshFuture;
      _refreshFuture = null;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await SecureStorage.instance.clearAuthTokens();
        handler.next(err);
        return;
      }

      final request = err.requestOptions;
      request.extra['banknoteai_auth_retried'] = true;
      request.headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } catch (_) {
      _refreshFuture = null;
      await SecureStorage.instance.clearAuthTokens();
      handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken(
    String baseUrl,
    String refreshToken,
  ) async {
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final response = await refreshDio.post<dynamic>(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    final raw = response.data;
    if (raw is! Map) return null;

    final root = Map<String, dynamic>.from(raw);
    final wrapped = root['data'];
    final data = wrapped is Map ? Map<String, dynamic>.from(wrapped) : root;
    final accessToken = (data['access_token'] ?? data['token'] ?? '')
        .toString()
        .trim();
    final rotatedRefresh = (data['refresh_token'] ?? '').toString().trim();

    if (accessToken.isEmpty) return null;

    await SecureStorage.instance.saveToken(accessToken);
    if (rotatedRefresh.isNotEmpty) {
      await SecureStorage.instance.saveRefreshToken(rotatedRefresh);
    }
    return accessToken;
  }
}
