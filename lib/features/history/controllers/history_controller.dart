import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../recognition/models/banknote_result_model.dart';
import '../data/history_service.dart';

class HistoryController extends ChangeNotifier {
  final HistoryService _service = HistoryService();

  bool _isLoading = false;
  String? _error;
  List<BanknoteResultModel> _historyList = [];

  String _searchQuery = '';
  String _statusFilter = 'all';
  String _currencyFilter = 'all';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BanknoteResultModel> get historyList => _historyList;

  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get currencyFilter => _currencyFilter;

  List<String> get availableCurrencies {
    final codes = _historyList
        .map((item) => item.finalResult.currency)
        .where((code) => code.trim().isNotEmpty && code.toLowerCase() != 'unknown')
        .toSet()
        .toList();
    codes.sort();
    return codes;
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _historyList = await _service.getFullHistory(
        search: _searchQuery,
        status: _statusFilter,
        currency: _currencyFilter,
      );
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to load scan history.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  void updateCurrencyFilter(String value) {
    _currencyFilter = value;
    notifyListeners();
  }

  Future<void> applyFilters() async {
    await fetchHistory();
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    _statusFilter = 'all';
    _currencyFilter = 'all';
    await fetchHistory();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
