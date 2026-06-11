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

  DateTime? _lastLoadedAt;

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  AdminDashboardModel get dashboard => _dashboard;
  Map<String, dynamic> get systemHealth => Map.unmodifiable(_systemHealth);

  List<AdminTransactionModel> get pendingTransactions =>
      List.unmodifiable(_pendingTransactions);

  List<AdminFeedbackModel> get pendingFeedbacks =>
      List.unmodifiable(_pendingFeedbacks);

  DateTime? get lastLoadedAt => _lastLoadedAt;

  Future<void> loadDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    String? firstError;

    try {
      try {
        _dashboard = await _service.getDashboardSummary();
      } catch (e) {
        firstError ??= _errorMessage(e, 'Failed to load admin summary.');
      }

      try {
        _pendingTransactions = await _service.getPendingTransactions();

        _dashboard = _dashboard.copyWith(
          pendingTransactions: _pendingTransactions.isNotEmpty
              ? _pendingTransactions.length
              : _dashboard.pendingTransactions,
        );
      } catch (e) {
        firstError ??= _errorMessage(e, 'Failed to load pending transactions.');
      }

      try {
        _pendingFeedbacks = await _service.getPendingFeedbacks();

        _dashboard = _dashboard.copyWith(
          pendingFeedbacks: _pendingFeedbacks.isNotEmpty
              ? _pendingFeedbacks.length
              : _dashboard.pendingFeedbacks,
        );
      } catch (e) {
        firstError ??= _errorMessage(e, 'Failed to load pending feedback.');
      }

      try {
        _systemHealth = await _service.getSystemHealth();

        final healthStatus = _statusFromHealth(_systemHealth);
        if (_dashboard.systemStatus == 'unknown' && healthStatus != 'unknown') {
          _dashboard = _dashboard.copyWith(systemStatus: healthStatus);
        }
      } catch (_) {
        _systemHealth = {
          'status': 'unknown',
          'message': 'System health endpoint is unavailable.',
        };

        if (_dashboard.systemStatus == 'unknown') {
          _dashboard = _dashboard.copyWith(systemStatus: 'unknown');
        }
      }

      _lastLoadedAt = DateTime.now();

      final hasAnyRealData = _dashboard.totalUsers > 0 ||
          _dashboard.totalScans > 0 ||
          _dashboard.totalRevenue > 0 ||
          _pendingTransactions.isNotEmpty ||
          _pendingFeedbacks.isNotEmpty;

      _error = hasAnyRealData ? null : firstError;
    } catch (e) {
      _error = _errorMessage(e, 'Failed to load admin dashboard.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingTransactions() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingTransactions = await _service.getPendingTransactions();

      _dashboard = _dashboard.copyWith(
        pendingTransactions: _pendingTransactions.length,
      );

      _lastLoadedAt = DateTime.now();
    } catch (e) {
      _error = _errorMessage(e, 'Failed to load pending transactions.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingFeedbacks() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingFeedbacks = await _service.getPendingFeedbacks();

      _dashboard = _dashboard.copyWith(
        pendingFeedbacks: _pendingFeedbacks.length,
      );

      _lastLoadedAt = DateTime.now();
    } catch (e) {
      _error = _errorMessage(e, 'Failed to load pending feedback.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markTransactionPaid(String transactionId) async {
    if (transactionId.trim().isEmpty) {
      _error = 'Missing transaction id.';
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.markTransactionPaid(transactionId);
      await loadPendingTransactions();
      return true;
    } catch (e) {
      _error = _errorMessage(e, 'Failed to mark transaction as paid.');
      notifyListeners();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelTransaction(String transactionId) async {
    if (transactionId.trim().isEmpty) {
      _error = 'Missing transaction id.';
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.cancelTransaction(transactionId);
      await loadPendingTransactions();
      return true;
    } catch (e) {
      _error = _errorMessage(e, 'Failed to cancel transaction.');
      notifyListeners();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resolveFeedback(String feedbackId) async {
    if (feedbackId.trim().isEmpty) {
      _error = 'Missing feedback id.';
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateFeedbackStatus(feedbackId, 'resolved');
      await loadPendingFeedbacks();
      return true;
    } catch (e) {
      _error = _errorMessage(e, 'Failed to resolve feedback.');
      notifyListeners();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFeedbackPriority(String feedbackId, String priority) async {
    if (feedbackId.trim().isEmpty) {
      _error = 'Missing feedback id.';
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateFeedbackPriority(feedbackId, priority);
      await loadPendingFeedbacks();
      return true;
    } catch (e) {
      _error = _errorMessage(e, 'Failed to update feedback priority.');
      notifyListeners();
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

  String _statusFromHealth(Map<String, dynamic> health) {
    final value = health['status'] ??
        health['system_status'] ??
        health['api'] ??
        health['backend'];

    final text = value?.toString().trim();

    if (text == null || text.isEmpty) return 'unknown';

    return text;
  }

  String _errorMessage(dynamic error, String fallback) {
    if (error is ApiException) return error.message;
    return fallback;
  }
}