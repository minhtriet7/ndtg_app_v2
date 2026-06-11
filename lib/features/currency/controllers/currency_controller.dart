import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/currency_service.dart';
import '../models/currency_convert_response.dart';
import '../models/currency_rate_model.dart';

class CurrencyController extends ChangeNotifier {
  final CurrencyService _service = CurrencyService();

  bool _isLoading = false;
  bool _isConverting = false;
  String? _error;

  List<CurrencyRateModel> _rates = [];
  CurrencyRateModel? _fromCurrency;
  CurrencyRateModel? _toCurrency;

  double _amount = 1.0;
  double _convertedAmount = 0.0;
  CurrencyConvertResponse? _lastConversion;
  DateTime? _lastLoadedAt;

  bool get isLoading => _isLoading;
  bool get isConverting => _isConverting;
  String? get error => _error;

  List<CurrencyRateModel> get rates => List.unmodifiable(_rates);

  CurrencyRateModel? get fromCurrency => _fromCurrency;
  CurrencyRateModel? get toCurrency => _toCurrency;

  double get amount => _amount;
  double get convertedAmount => _convertedAmount;
  CurrencyConvertResponse? get lastConversion => _lastConversion;
  DateTime? get lastLoadedAt => _lastLoadedAt;

  bool get hasRates => _rates.isNotEmpty;
  bool get hasStaleRate => _rates.any((item) => item.isStale);

  Future<void> fetchRates() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getPublicRates();

      _rates = response.items
          .where((rate) => rate.isActive && rate.effectiveRateToVnd > 0)
          .toList()
        ..sort(_sortRates);

      if (_rates.isNotEmpty) {
        _fromCurrency = _keepOrFind(_fromCurrency, preferred: 'USD') ??
            _findCurrency('USD') ??
            _findCurrency('THB') ??
            _rates.first;

        _toCurrency = _keepOrFind(_toCurrency, preferred: 'VND') ??
            _findCurrency('VND') ??
            _rates.first;

        if (_fromCurrency?.targetCurrency == _toCurrency?.targetCurrency &&
            _rates.length > 1) {
          _toCurrency = _findCurrency('VND') ??
              _rates.firstWhere(
                    (item) => item.targetCurrency != _fromCurrency!.targetCurrency,
                orElse: () => _rates.first,
              );
        }

        _calculateLocal();
      }

      _lastLoadedAt = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load exchange rates.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _sortRates(CurrencyRateModel a, CurrencyRateModel b) {
    const priority = [
      'VND',
      'USD',
      'THB',
      'MYR',
      'SGD',
      'IDR',
      'PHP',
      'KHR',
      'LAK',
      'MMK',
      'BND',
    ];

    final ai = priority.indexOf(a.targetCurrency);
    final bi = priority.indexOf(b.targetCurrency);

    if (ai != -1 && bi != -1) return ai.compareTo(bi);
    if (ai != -1) return -1;
    if (bi != -1) return 1;

    return a.targetCurrency.compareTo(b.targetCurrency);
  }

  CurrencyRateModel? _keepOrFind(
      CurrencyRateModel? current, {
        required String preferred,
      }) {
    if (current != null) {
      final existing = _findCurrency(current.targetCurrency);
      if (existing != null) return existing;
    }

    return _findCurrency(preferred);
  }

  CurrencyRateModel? _findCurrency(String code) {
    final normalized = code.trim().toUpperCase();

    for (final item in _rates) {
      if (item.targetCurrency == normalized) return item;
    }

    return null;
  }

  void setAmount(String value) {
    final normalized = value
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();

    if (normalized.isEmpty) {
      _amount = 0.0;
    } else {
      _amount = double.tryParse(normalized) ?? _amount;
    }

    _lastConversion = null;
    _calculateLocal();
    notifyListeners();
  }

  void setFromCurrency(CurrencyRateModel currency) {
    _fromCurrency = currency;
    _lastConversion = null;
    _calculateLocal();
    notifyListeners();
  }

  void setToCurrency(CurrencyRateModel currency) {
    _toCurrency = currency;
    _lastConversion = null;
    _calculateLocal();
    notifyListeners();
  }

  void swapCurrencies() {
    if (_fromCurrency == null || _toCurrency == null) return;

    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;

    _lastConversion = null;
    _calculateLocal();
    notifyListeners();
  }

  Future<void> convertWithBackend() async {
    if (_fromCurrency == null || _toCurrency == null) return;
    if (_amount <= 0) {
      _convertedAmount = 0;
      _error = 'Please enter an amount greater than 0.';
      notifyListeners();
      return;
    }

    _isConverting = true;
    _error = null;
    notifyListeners();

    try {
      _lastConversion = await _service.convert(
        amount: _amount,
        fromCurrency: _fromCurrency!.targetCurrency,
        toCurrency: _toCurrency!.targetCurrency,
      );

      if (_lastConversion != null && _lastConversion!.convertedAmount > 0) {
        _convertedAmount = _lastConversion!.convertedAmount;
      } else {
        _calculateLocal();
      }
    } catch (_) {
      _lastConversion = null;
      _calculateLocal();
    } finally {
      _isConverting = false;
      notifyListeners();
    }
  }

  void _calculateLocal() {
    if (_fromCurrency == null || _toCurrency == null) {
      _convertedAmount = 0;
      return;
    }

    if (_amount <= 0) {
      _convertedAmount = 0;
      return;
    }

    final fromRate = _fromCurrency!.effectiveRateToVnd;
    final toRate = _toCurrency!.effectiveRateToVnd;

    if (fromRate <= 0 || toRate <= 0) {
      _convertedAmount = 0;
      return;
    }

    _convertedAmount = (_amount * fromRate) / toRate;
  }

  List<CurrencyRateModel> get quickCurrencies {
    const codes = [
      'USD',
      'THB',
      'MYR',
      'SGD',
      'IDR',
      'PHP',
      'KHR',
      'LAK',
      'MMK',
      'BND',
    ];

    return codes.map(_findCurrency).whereType<CurrencyRateModel>().toList();
  }

  List<CurrencyRateModel> get seaCurrencies {
    return _rates.where((item) => item.isSeaCurrency).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}