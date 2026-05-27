import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

class FeedbackModel {
  final String id;
  final String message;
  final int rating;
  final String type;
  final String status;
  final String priority;
  final String adminReply;
  final String createdAt;
  final Map<String, dynamic> raw;

  const FeedbackModel({
    required this.id,
    required this.message,
    required this.rating,
    required this.type,
    required this.status,
    required this.priority,
    required this.adminReply,
    required this.createdAt,
    required this.raw,
  });

  factory FeedbackModel.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    return FeedbackModel(
      id: JsonHelper.safeString(ResponseParser.getValue(json, ['id', '_id', 'feedback_id'])),
      message: JsonHelper.safeString(ResponseParser.getValue(json, ['message', 'content', 'description'])),
      rating: JsonHelper.safeInt(ResponseParser.getValue(json, ['rating', 'stars']), fallback: 5).clamp(1, 5),
      type: JsonHelper.safeString(ResponseParser.getValue(json, ['type', 'feedback_type']), fallback: 'general'),
      status: JsonHelper.safeString(ResponseParser.getValue(json, ['status']), fallback: 'pending').toLowerCase(),
      priority: JsonHelper.safeString(ResponseParser.getValue(json, ['priority']), fallback: 'normal'),
      adminReply: JsonHelper.safeString(ResponseParser.getValue(json, ['admin_reply', 'reply'])),
      createdAt: JsonHelper.safeString(ResponseParser.getValue(json, ['created_at', 'createdAt'])),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
