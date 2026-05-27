import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  final int? statusCode;
  final String message;
  final dynamic data;

  factory ApiException.fromDioException(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;

    String message;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Kết nối tới máy chủ quá hạn. Vui lòng kiểm tra mạng.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Gửi dữ liệu quá hạn. Vui lòng thử lại.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Máy chủ phản hồi quá lâu. Vui lòng thử lại.';
        break;
      case DioExceptionType.badResponse:
        message = _parseErrorMessage(statusCode, data);
        break;
      case DioExceptionType.cancel:
        message = 'Yêu cầu đã bị hủy.';
        break;
      case DioExceptionType.connectionError:
        message = 'Không thể kết nối máy chủ. Kiểm tra Internet hoặc backend.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Chứng chỉ kết nối không hợp lệ.';
        break;
      case DioExceptionType.unknown:
        message = dioException.message?.contains('SocketException') == true
            ? 'Không có kết nối mạng ổn định.'
            : 'Đã xảy ra lỗi không xác định.';
        break;
    }

    return ApiException(statusCode: statusCode, message: message, data: data);
  }

  static String _parseErrorMessage(int? statusCode, dynamic data) {
    final backendMessage = _backendMessage(data);
    if (backendMessage != null && backendMessage.isNotEmpty) {
      return backendMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ. Vui lòng kiểm tra thông tin.';
      case 401:
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền thực hiện tác vụ này.';
      case 404:
        return 'Không tìm thấy tài nguyên yêu cầu.';
      case 422:
        return 'Dữ liệu không hợp lệ hoặc thiếu trường bắt buộc.';
      case 500:
        return 'Lỗi hệ thống backend. Vui lòng thử lại sau.';
      default:
        return 'Máy chủ phản hồi lỗi${statusCode == null ? '' : ' $statusCode'}.';
    }
  }

  static String? _backendMessage(dynamic data) {
    if (data is Map) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) return first['msg'].toString();
        return first.toString();
      }
      if (detail != null) return detail.toString();
    }

    if (data is String && data.trim().isNotEmpty) return data;
    return null;
  }

  @override
  String toString() => message;
}
