import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (err.response?.statusCode == 401) {
      await SecureStorage.instance.clearToken();
    }

    final normalized = ApiException.fromDioException(err);

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: normalized,
        message: normalized.message,
        stackTrace: err.stackTrace,
      ),
    );
  }
}
