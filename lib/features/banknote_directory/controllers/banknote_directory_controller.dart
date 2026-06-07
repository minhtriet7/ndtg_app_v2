import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/banknote_directory_service.dart';
import '../models/banknote_directory_model.dart';
import '../models/supported_country_model.dart';

class BanknoteDirectoryController extends ChangeNotifier {
  final BanknoteDirectoryService _service = BanknoteDirectoryService();

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  List<BanknoteDirectoryModel> _banknotes = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  List<BanknoteDirectoryModel> get banknotes => List.unmodifiable(_banknotes);

  List<BanknoteDirectoryModel> get filteredBanknotes {
    return _banknotes.where((item) => item.matches(_searchQuery)).toList();
  }

  List<SupportedCountryModel> get countries {
    return SupportedCountryModel.fromBanknotes(filteredBanknotes);
  }

  int get totalCountries {
    return SupportedCountryModel.fromBanknotes(_banknotes).length;
  }

  int get totalNotes => _banknotes.length;

  Future<void> loadBanknotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _banknotes = await _service.getBanknotes();
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to load banknote directory.';
      _banknotes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadBanknotes();

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }
}