import '../../core/utils/json_helper.dart';

class AdminDashboardModel {
  final int totalUsers;
  final int totalScans;
  final int totalTransactions;
  final int pendingTransactions;
  final int pendingFeedbacks;
  final int completedScans;
  final int needsReview;
  final double totalRevenue;
  final String systemStatus;

  const AdminDashboardModel({
    required this.totalUsers,
    required this.totalScans,
    required this.totalTransactions,
    required this.pendingTransactions,
    required this.pendingFeedbacks,
    required this.completedScans,
    required this.needsReview,
    required this.totalRevenue,
    required this.systemStatus,
  });

  factory AdminDashboardModel.empty() {
    return const AdminDashboardModel(
      totalUsers: 0,
      totalScans: 0,
      totalTransactions: 0,
      pendingTransactions: 0,
      pendingFeedbacks: 0,
      completedScans: 0,
      needsReview: 0,
      totalRevenue: 0,
      systemStatus: 'unknown',
    );
  }

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalUsers: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['total_users', 'users.total', 'users_count']),
      ),
      totalScans: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['total_scans', 'recognitions.total', 'scans_count']),
      ),
      totalTransactions: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['total_transactions', 'payments.total', 'transactions_count']),
      ),
      pendingTransactions: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['pending_transactions', 'payments.pending', 'pending_payments']),
      ),
      pendingFeedbacks: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['pending_feedbacks', 'feedbacks.pending']),
      ),
      completedScans: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['completed_scans', 'recognitions.completed']),
      ),
      needsReview: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['needs_review', 'recognitions.needs_review']),
      ),
      totalRevenue: JsonHelper.safeDouble(
        JsonHelper.getValue(json, ['total_revenue', 'payments.revenue', 'revenue']),
      ),
      systemStatus: JsonHelper.safeString(
        JsonHelper.getValue(json, ['system_status', 'health.status', 'status']),
        defaultValue: 'unknown',
      ),
    );
  }
}