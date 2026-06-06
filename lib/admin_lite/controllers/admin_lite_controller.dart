import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../data/admin_lite_service.dart';
import '../models/admin_dashboard_model.dart';
import '../models/admin_feedback_model.dart';
import '../models/admin_transaction_model.dart';

class AdminLiteController extends ChangeNotifier {
  final AdminLiteService _service = AdminLiteService();

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  AdminDashboardModel _dashboard = AdminDashboardModel.empty();
  Map<String, dynamic> _systemHealth = {};
  List<AdminTransactionModel> _pendingTransactions = [];
  List<AdminFeedbackModel> _pendingFeedbacks = [];

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  AdminDashboardModel get dashboard => _dashboard;
  Map<String, dynamic> get systemHealth => _systemHealth;
  List<AdminTransactionModel> get pendingTransactions => _pendingTransactions;
  List<AdminFeedbackModel> get pendingFeedbacks => _pendingFeedbacks;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getDashboardSummary(),
        _service.getSystemHealth(),
        _service.getPendingTransactions(),
        _service.getPendingFeedbacks(),
      ]);

      _dashboard = results[0] as AdminDashboardModel;
      _systemHealth = results[1] as Map<String, dynamic>;
      _pendingTransactions = results[2] as List<AdminTransactionModel>;
      _pendingFeedbacks = results[3] as List<AdminFeedbackModel>;

      // Some backend dashboard summaries may omit pending counters while
      // the pending-list endpoints return real data. Use the loaded lists as
      // a safe UI fallback without changing backend behavior.
      if ((_dashboard.pendingTransactions == 0 && _pendingTransactions.isNotEmpty) ||
          (_dashboard.pendingFeedbacks == 0 && _pendingFeedbacks.isNotEmpty)) {
        _dashboard = _dashboard.copyWith(
          pendingTransactions: _dashboard.pendingTransactions == 0
              ? _pendingTransactions.length
              : _dashboard.pendingTransactions,
          pendingFeedbacks: _dashboard.pendingFeedbacks == 0
              ? _pendingFeedbacks.length
              : _dashboard.pendingFeedbacks,
        );
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load admin dashboard.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingTransactions = await _service.getPendingTransactions();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load pending transactions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingFeedbacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingFeedbacks = await _service.getPendingFeedbacks();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load pending feedback.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markTransactionPaid(String transactionId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.markTransactionPaid(transactionId);
      await loadPendingTransactions();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to mark transaction as paid.';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelTransaction(String transactionId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.cancelTransaction(transactionId);
      await loadPendingTransactions();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to cancel transaction.';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resolveFeedback(String feedbackId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateFeedbackStatus(feedbackId, 'resolved');
      await loadPendingFeedbacks();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to resolve feedback.';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFeedbackPriority(String feedbackId, String priority) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateFeedbackPriority(feedbackId, priority);
      await loadPendingFeedbacks();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to update feedback priority.';
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}