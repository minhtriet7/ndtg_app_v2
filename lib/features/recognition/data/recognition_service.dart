import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/banknote_result_model.dart';
import '../models/recognition_task_model.dart';

class RecognitionStartResponse {
  final RecognitionTaskModel? task;
  final BanknoteResultModel? result;

  const RecognitionStartResponse({this.task, this.result});

  bool get isAsync => task != null;
  bool get isDirectResult => result != null;
}

class RecognitionService {
  final DioClient _client = DioClient();

  Future<RecognitionStartResponse> startRecognition(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    Response response;

    try {
      response = await _client.post(
        ApiEndpoints.recognitionAnalyze,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          // Ép buộc kết nối chờ tối đa 5 phút cho luồng AI
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 1),
        ),
      );
    } catch (error) {
      final apiError = _unwrapApiException(error);

      if (apiError?.statusCode != 404) {
        rethrow;
      }

      response = await _client.post(
        ApiEndpoints.recognitionStart,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          // Ép buộc kết nối chờ tối đa 5 phút cho luồng fallback
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 1),
        ),
      );
    }

    final map = _payloadMap(response);
    final taskMap = _nestedMap(map, 'task') ?? map;
    final taskId = ResponseParser.getValue(taskMap, [
      'task_id',
      'id',
      'job_id',
    ]);
    if (taskId != null && taskId.toString().isNotEmpty) {
      return RecognitionStartResponse(
        task: RecognitionTaskModel.fromJson(taskMap),
      );
    }

    return RecognitionStartResponse(
      result: BanknoteResultModel.fromJson(_nestedMap(map, 'result') ?? map),
    );
  }

  Future<RecognitionTaskModel> getTaskStatus(String taskId) async {
    final response = await _client.get(
      ApiEndpoints.recognitionTaskStatus(taskId),
    );
    final map = _payloadMap(response);
    return RecognitionTaskModel.fromJson(_nestedMap(map, 'task') ?? map);
  }

  Future<BanknoteResultModel> getResultDetail(String id) async {
    final response = await _client.get(ApiEndpoints.recognitionDetail(id));
    return BanknoteResultModel.fromJson(response);
  }

  Future<List<BanknoteResultModel>> getHistory({
    int limit = 20,
    int page = 1,
  }) async {
    final response = await _client.get(
      ApiEndpoints.recognitionHistory,
      queryParameters: {'limit': limit, 'page': page},
    );

    return ResponseParser.parseList(
      response,
    ).map((item) => BanknoteResultModel.fromJson(item)).toList();
  }

  Map<String, dynamic> _payloadMap(dynamic response) {
    final raw = ResponseParser.unwrap(response);
    if (raw is! Map) return const {};

    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return map;
  }

  Map<String, dynamic>? _nestedMap(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  ApiException? _unwrapApiException(dynamic error) {
    if (error is DioException && error.error is ApiException) {
      return error.error as ApiException;
    }

    if (error is ApiException) return error;
    return null;
  }
}
