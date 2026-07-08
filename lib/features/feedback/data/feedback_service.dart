import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final DioClient _client = DioClient();

  Future<List<FeedbackModel>> getMyFeedbacks() async {
    final response = await _client.get(ApiEndpoints.myFeedback);
    final listData = ResponseParser.parseList(response);
    return listData.map((e) => FeedbackModel.fromJson(e)).toList();
  }

  Future<FeedbackModel> createFeedback({
    required String message,
    required int rating,
    String feedbackType = 'general',
    String? relatedResultId,
  }) async {
    final payload = <String, dynamic>{
      'message': message,
      'rating': rating,
      'feedback_type': feedbackType,
    };

    if (relatedResultId != null && relatedResultId.isNotEmpty) {
      payload['related_result_id'] = relatedResultId;
    }

    final response = await _client.post(ApiEndpoints.feedback, data: payload);
    return FeedbackModel.fromJson(ResponseParser.parseMap(response));
  }
}
