import '../../core/utils/json_helper.dart';

class AdminDashboardModel {
  final int totalUsers;
  final int activeUsers;
  final int totalScans;
  final int totalTransactions;
  final int pendingTransactions;
  final int pendingFeedbacks;
  final int completedScans;
  final int needsReview;
  final int tokensSold;
  final double totalRevenue;
  final String systemStatus;
  final String lastUpdated;

  const AdminDashboardModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalScans,
    required this.totalTransactions,
    required this.pendingTransactions,
    required this.pendingFeedbacks,
    required this.completedScans,
    required this.needsReview,
    required this.tokensSold,
    required this.totalRevenue,
    required this.systemStatus,
    required this.lastUpdated,
  });

  factory AdminDashboardModel.empty() {
    return const AdminDashboardModel(
      totalUsers: 0,
      activeUsers: 0,
      totalScans: 0,
      totalTransactions: 0,
      pendingTransactions: 0,
      pendingFeedbacks: 0,
      completedScans: 0,
      needsReview: 0,
      tokensSold: 0,
      totalRevenue: 0,
      systemStatus: 'unknown',
      lastUpdated: '',
    );
  }

  static dynamic _get(Map<String, dynamic> json, List<String> paths) {
    for (final path in paths) {
      final parts = path.split('.');
      dynamic current = json;

      for (final part in parts) {
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          current = null;
          break;
        }
      }

      if (current != null) return current;
    }

    return null;
  }

  static int _intValue(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static double _doubleValue(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? fallback;
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalUsers: _intValue(
        _get(json, [
          'kpis.total_users',
          'summary.total_users',
          'total_users',
          'users_breakdown.total_users',
          'users.total',
          'users_count',
        ]),
      ),
      activeUsers: _intValue(
        _get(json, [
          'kpis.active_users',
          'summary.active_users',
          'active_users',
          'users_breakdown.active_users',
          'active_users_count',
        ]),
      ),
      totalScans: _intValue(
        _get(json, [
          'kpis.total_scans',
          'summary.total_scans',
          'total_scans',
          'recognitions.total',
          'recognition_count',
          'scans_count',
        ]),
      ),
      completedScans: _intValue(
        _get(json, [
          'kpis.completed_scans',
          'summary.completed_scans',
          'completed_scans',
          'success_scans',
          'recognitions.completed',
        ]),
      ),
      totalTransactions: _intValue(
        _get(json, [
          'payments.total_transactions',
          'payment_overview.total_transactions',
          'total_transactions',
          'transactions_count',
        ]),
      ),
      pendingTransactions: _intValue(
        _get(json, [
          'payments.pending_transactions',
          'payment_overview.pending_transactions',
          'pending_transactions',
          'pending_payments',
        ]),
      ),
      pendingFeedbacks: _intValue(
        _get(json, [
          'kpis.pending_feedback',
          'kpis.pending_feedback_count',
          'summary.pending_feedback',
          'pending_feedback',
          'pending_feedbacks',
          'feedbacks.pending',
        ]),
      ),
      needsReview: _intValue(
        _get(json, [
          'kpis.needs_review',
          'summary.needs_review',
          'needs_review',
          'recognitions.needs_review',
        ]),
      ),
      tokensSold: _intValue(
        _get(json, [
          'kpis.tokens_sold',
          'summary.tokens_sold',
          'tokens_sold',
          'payments.tokens_sold',
        ]),
      ),
      totalRevenue: _doubleValue(
        _get(json, [
          'kpis.total_revenue_vnd',
          'kpis.revenue_vnd',
          'kpis.revenue',
          'summary.total_revenue_vnd',
          'payments.revenue_vnd',
          'payment_overview.revenue_vnd',
          'total_revenue_vnd',
          'total_revenue',
          'revenue',
        ]),
      ),
      systemStatus: _stringValue(
        _get(json, [
          'system_status',
          'health.status',
          'status',
        ]),
        fallback: 'unknown',
      ),
      lastUpdated: _stringValue(
        _get(json, [
          'last_updated',
          'updated_at',
          'checked_at',
        ]),
      ),
    );
  }

  AdminDashboardModel copyWith({
    int? totalUsers,
    int? activeUsers,
    int? totalScans,
    int? totalTransactions,
    int? pendingTransactions,
    int? pendingFeedbacks,
    int? completedScans,
    int? needsReview,
    int? tokensSold,
    double? totalRevenue,
    String? systemStatus,
    String? lastUpdated,
  }) {
    return AdminDashboardModel(
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      totalScans: totalScans ?? this.totalScans,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      pendingTransactions: pendingTransactions ?? this.pendingTransactions,
      pendingFeedbacks: pendingFeedbacks ?? this.pendingFeedbacks,
      completedScans: completedScans ?? this.completedScans,
      needsReview: needsReview ?? this.needsReview,
      tokensSold: tokensSold ?? this.tokensSold,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      systemStatus: systemStatus ?? this.systemStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'total_scans': totalScans,
      'total_transactions': totalTransactions,
      'pending_transactions': pendingTransactions,
      'pending_feedbacks': pendingFeedbacks,
      'completed_scans': completedScans,
      'needs_review': needsReview,
      'tokens_sold': tokensSold,
      'total_revenue': totalRevenue,
      'system_status': systemStatus,
      'last_updated': lastUpdated,
    };
  }
}