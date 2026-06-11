import '../../core/utils/json_helper.dart';

class AdminFeedbackModel {
  final String id;
  final String userEmail;
  final String type;
  final String message;
  final int rating;
  final String status;
  final String priority;
  final String createdAt;

  const AdminFeedbackModel({
    required this.id,
    required this.userEmail,
    required this.type,
    required this.message,
    required this.rating,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  factory AdminFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AdminFeedbackModel(
      id: JsonHelper.safeString(
        JsonHelper.getValue(json, ['id', '_id', 'feedback_id']),
      ),
      userEmail: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'user.email',
          'user_email',
          'email',
          'userEmail',
          'author.email',
        ]),
        defaultValue: 'Unknown user',
      ),
      type: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'type',
          'feedback_type',
          'category',
          'topic',
        ]),
        defaultValue: 'general',
      ),
      message: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'message',
          'content',
          'description',
          'text',
          'body',
        ]),
      ),
      rating: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['rating', 'stars', 'score']),
        defaultValue: 5,
      ).clamp(0, 5),
      status: JsonHelper.safeString(
        JsonHelper.getValue(json, ['status']),
        defaultValue: 'pending',
      ),
      priority: JsonHelper.safeString(
        JsonHelper.getValue(json, ['priority', 'severity']),
        defaultValue: 'normal',
      ),
      createdAt: JsonHelper.safeString(
        JsonHelper.getValue(json, ['created_at', 'createdAt', 'created']),
      ),
    );
  }

  bool get isPending {
    final value = status.toLowerCase();
    return value.contains('pending') ||
        value.contains('open') ||
        value.contains('new') ||
        value.contains('unresolved');
  }
}