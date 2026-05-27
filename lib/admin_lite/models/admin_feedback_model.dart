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
      id: JsonHelper.safeString(JsonHelper.getValue(json, ['id', '_id'])),
      userEmail: JsonHelper.safeString(
        JsonHelper.getValue(json, ['user.email', 'email', 'user_email']),
        defaultValue: 'Unknown user',
      ),
      type: JsonHelper.safeString(
        JsonHelper.getValue(json, ['type', 'feedback_type']),
        defaultValue: 'general',
      ),
      message: JsonHelper.safeString(
        JsonHelper.getValue(json, ['message', 'content', 'description']),
      ),
      rating: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['rating', 'stars']),
        defaultValue: 5,
      ),
      status: JsonHelper.safeString(
        JsonHelper.getValue(json, ['status']),
        defaultValue: 'pending',
      ),
      priority: JsonHelper.safeString(
        JsonHelper.getValue(json, ['priority']),
        defaultValue: 'normal',
      ),
      createdAt: JsonHelper.safeString(
        JsonHelper.getValue(json, ['created_at', 'createdAt']),
      ),
    );
  }
}