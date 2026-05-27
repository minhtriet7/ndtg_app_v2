import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/models/auth_response.dart';
import '../data/home_service.dart';
import '../models/home_stats_model.dart';

class HomeController extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _error;
  UserInfo? _userInfo;
  HomeStatsModel _stats = HomeStatsModel.empty();
  List<Map<String, dynamic>> _recentScans = [];

  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get error => _error;
  UserInfo? get userInfo => _userInfo;
  HomeStatsModel get stats => _stats;
  List<Map<String, dynamic>> get recentScans => List.unmodifiable(_recentScans);

  Future<void> fetchDashboardData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait<dynamic>([
        _homeService.getDashboardUser(),
        _homeService.getHomeStats(),
        _homeService.getRecentScans(limit: 5),
      ]);

      _userInfo = results[0] as UserInfo;
      _stats = results[1] as HomeStatsModel;
      _recentScans = (results[2] as List<Map<String, dynamic>>);

      _error = null;
      _hasLoadedOnce = true;
    } catch (error) {
      if (error is ApiException) {
        _error = error.message;
      } else {
        _error = 'Unable to load dashboard data. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchDashboardData(silent: false);

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _hasLoadedOnce = false;
    _error = null;
    _userInfo = null;
    _stats = HomeStatsModel.empty();
    _recentScans = [];
    notifyListeners();
  }
}
