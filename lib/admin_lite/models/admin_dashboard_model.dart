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

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalUsers: _intValue(_get(json, [
        'kpis.total_users',
        'kpis.users',
        'summary.total_users',
        'total_users',
        'users_breakdown.total_users',
        'users.total',
        'users_count',
        'totalUsers',
      ])),
      activeUsers: _intValue(_get(json, [
        'kpis.active_users',
        'summary.active_users',
        'active_users',
        'users_breakdown.active_users',
        'users.active',
        'active_users_count',
        'activeUsers',
      ])),
      totalScans: _intValue(_get(json, [
        'kpis.total_scans',
        'summary.total_scans',
        'total_scans',
        'recognitions.total',
        'recognition.total',
        'recognition_count',
        'scans_count',
        'totalScans',
      ])),
      completedScans: _intValue(_get(json, [
        'kpis.completed_scans',
        'summary.completed_scans',
        'completed_scans',
        'success_scans',
        'recognitions.completed',
        'recognition.completed',
        'completedScans',
      ])),
      totalTransactions: _intValue(_get(json, [
        'payments.total_transactions',
        'payment_overview.total_transactions',
        'total_transactions',
        'transactions.total',
        'transactions_count',
        'totalTransactions',
      ])),
      pendingTransactions: _intValue(_get(json, [
        'payments.pending_transactions',
        'payment_overview.pending_transactions',
        'pending_transactions',
        'transactions.pending',
        'pending_payments',
        'pendingTransactions',
      ])),
      pendingFeedbacks: _intValue(_get(json, [
        'kpis.pending_feedback',
        'kpis.pending_feedback_count',
        'summary.pending_feedback',
        'pending_feedback',
        'pending_feedbacks',
        'feedbacks.pending',
        'feedback.pending',
        'pendingFeedbacks',
      ])),
      needsReview: _intValue(_get(json, [
        'kpis.needs_review',
        'summary.needs_review',
        'needs_review',
        'recognitions.needs_review',
        'recognition.needs_review',
        'needsReview',
      ])),
      tokensSold: _intValue(_get(json, [
        'kpis.tokens_sold',
        'summary.tokens_sold',
        'tokens_sold',
        'payments.tokens_sold',
        'payment_overview.tokens_sold',
        'tokensSold',
      ])),
      totalRevenue: _doubleValue(_get(json, [
        'kpis.total_revenue_vnd',
        'kpis.revenue_vnd',
        'kpis.revenue',
        'summary.total_revenue_vnd',
        'payments.revenue_vnd',
        'payments.total_revenue',
        'payment_overview.revenue_vnd',
        'total_revenue_vnd',
        'total_revenue',
        'revenue',
        'totalRevenue',
      ])),
      systemStatus: _stringValue(_get(json, [
        'system_status',
        'health.status',
        'status',
        'systemStatus',
      ]), fallback: 'unknown'),
      lastUpdated: _stringValue(_get(json, [
        'last_updated',
        'updated_at',
        'checked_at',
        'lastUpdated',
      ])),
    );
  }

  double get completionRate {
    if (totalScans <= 0) return 0;
    return (completedScans / totalScans).clamp(0, 1).toDouble();
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

    final text = value.toString().replaceAll(',', '').trim();
    return int.tryParse(text) ?? fallback;
  }

  static double _doubleValue(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value.toDouble();
    if (value is double) return value;

    final text = value.toString().replaceAll(',', '').trim();
    return double.tryParse(text) ?? fallback;
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}