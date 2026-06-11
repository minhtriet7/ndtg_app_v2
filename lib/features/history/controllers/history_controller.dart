import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../recognition/models/banknote_result_model.dart';
import '../data/history_service.dart';

class HistoryController extends ChangeNotifier {
  final HistoryService _service = HistoryService();

  bool _isLoading = false;
  String? _error;

  List<BanknoteResultModel> _allHistory = [];
  List<BanknoteResultModel> _historyList = [];

  String _searchQuery = '';
  String _statusFilter = 'all';
  String _currencyFilter = 'all';

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BanknoteResultModel> get historyList => List.unmodifiable(_historyList);
  List<BanknoteResultModel> get allHistory => List.unmodifiable(_allHistory);

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get currencyFilter => _currencyFilter;

  int get totalScans => _allHistory.length;
  int get filteredScans => _historyList.length;

  bool get hasActiveFilters {
    return _searchQuery.trim().isNotEmpty ||
        _statusFilter != 'all' ||
        _currencyFilter != 'all';
  }

  int get completedCount {
    return _allHistory.where((item) {
      final status = item.status.toLowerCase();
      return status.contains('completed') ||
          status.contains('success') ||
          status.contains('done');
    }).length;
  }

  int get reviewCount {
    return _allHistory.where((item) {
      final status = item.status.toLowerCase();
      return status.contains('review') ||
          status.contains('warning') ||
          status.contains('conflict') ||
          status.contains('uncertain');
    }).length;
  }

  List<String> get availableCurrencies {
    final codes = _allHistory
        .map((item) => item.finalResult.currency.trim().toUpperCase())
        .where((code) =>
    code.isNotEmpty &&
        code != 'UNKNOWN' &&
        code != 'N/A' &&
        code != 'NULL')
        .toSet()
        .toList();

    codes.sort();
    return codes;
  }

  Future<void> fetchHistory() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allHistory = await _service.getFullHistory();
      _applyLocalFilters();
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to load scan history.';
      _historyList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    _searchQuery = value;
    _applyLocalFilters();
    notifyListeners();
  }

  void updateStatusFilter(String value) {
    _statusFilter = value;
    _applyLocalFilters();
    notifyListeners();
  }

  void updateCurrencyFilter(String value) {
    _currencyFilter = value;
    _applyLocalFilters();
    notifyListeners();
  }

  Future<void> applyFilters() async {
    _applyLocalFilters();
    notifyListeners();
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    _statusFilter = 'all';
    _currencyFilter = 'all';
    _applyLocalFilters();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _applyLocalFilters() {
    final keyword = _searchQuery.trim().toLowerCase();
    final normalizedStatus = _statusFilter.toLowerCase();
    final normalizedCurrency = _currencyFilter.toLowerCase();

    _historyList = _allHistory.where((result) {
      final searchBlob = [
        result.id,
        result.status,
        result.message,
        result.finalResult.country,
        result.finalResult.denomination,
        result.finalResult.currency,
        result.finalResult.decisionReason,
        result.rawJson.toString(),
      ].join(' ').toLowerCase();

      final itemStatus = result.status.toLowerCase();
      final itemCurrency = result.finalResult.currency.toLowerCase();

      final matchSearch = keyword.isEmpty || searchBlob.contains(keyword);

      final matchStatus = normalizedStatus == 'all' ||
          itemStatus == normalizedStatus ||
          itemStatus.contains(normalizedStatus);

      final matchCurrency = normalizedCurrency == 'all' ||
          itemCurrency == normalizedCurrency ||
          itemCurrency.contains(normalizedCurrency);

      return matchSearch && matchStatus && matchCurrency;
    }).toList();
  }
}