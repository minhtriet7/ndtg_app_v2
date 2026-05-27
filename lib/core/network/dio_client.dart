import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConfig.sendTimeoutMs),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());

    if (AppConfig.isDebug) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (object) {
            final log = object.toString();
            if (!log.toLowerCase().contains('authorization')) {
              debugPrint('🌐 [Dio] $log');
            }
          },
        ),
      );
    }
  }

  static final DioClient _singleton = DioClient._internal();

  factory DioClient() => _singleton;

  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<dynamic>> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<dynamic>> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<dynamic>> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<dynamic>> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) {
    return _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<dynamic>> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) {
    return _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }
}
