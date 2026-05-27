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

  bool get isLoading => _isLoading;
  bool get isConverting => _isConverting;
  String? get error => _error;
  List<CurrencyRateModel> get rates => _rates;
  CurrencyRateModel? get fromCurrency => _fromCurrency;
  CurrencyRateModel? get toCurrency => _toCurrency;
  double get amount => _amount;
  double get convertedAmount => _convertedAmount;
  CurrencyConvertResponse? get lastConversion => _lastConversion;

  Future<void> fetchRates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getPublicRates();
      _rates = response.items.where((rate) => rate.isActive && rate.effectiveRateToVnd > 0).toList()
        ..sort((a, b) {
          const priority = ['VND', 'USD', 'THB', 'MYR', 'SGD', 'IDR', 'PHP', 'KHR', 'LAK', 'MMK', 'BND'];
          final ai = priority.indexOf(a.targetCurrency);
          final bi = priority.indexOf(b.targetCurrency);
          if (ai != -1 && bi != -1) return ai.compareTo(bi);
          if (ai != -1) return -1;
          if (bi != -1) return 1;
          return a.targetCurrency.compareTo(b.targetCurrency);
        });

      if (_rates.isNotEmpty) {
        _fromCurrency ??= _findCurrency('USD') ?? _rates.first;
        _toCurrency ??= _findCurrency('VND') ?? _rates.first;
        _calculateLocal();
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load exchange rates.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CurrencyRateModel? _findCurrency(String code) {
    for (final item in _rates) {
      if (item.targetCurrency == code) return item;
    }
    return null;
  }

  void setAmount(String value) {
    final normalized = value.replaceAll(',', '').trim();
    _amount = double.tryParse(normalized) ?? 0.0;
    _calculateLocal();
    notifyListeners();
  }

  void setFromCurrency(CurrencyRateModel currency) {
    _fromCurrency = currency;
    _calculateLocal();
    notifyListeners();
  }

  void setToCurrency(CurrencyRateModel currency) {
    _toCurrency = currency;
    _calculateLocal();
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    _calculateLocal();
    notifyListeners();
  }

  Future<void> convertWithBackend() async {
    if (_fromCurrency == null || _toCurrency == null) return;

    _isConverting = true;
    _error = null;
    notifyListeners();

    try {
      _lastConversion = await _service.convert(
        amount: _amount,
        fromCurrency: _fromCurrency!.targetCurrency,
        toCurrency: _toCurrency!.targetCurrency,
      );
      _convertedAmount = _lastConversion!.convertedAmount;
    } catch (_) {
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

    final fromRate = _fromCurrency!.effectiveRateToVnd;
    final toRate = _toCurrency!.effectiveRateToVnd;
    if (fromRate <= 0 || toRate <= 0) {
      _convertedAmount = 0;
      return;
    }

    _convertedAmount = (_amount * fromRate) / toRate;
  }

  List<CurrencyRateModel> get quickCurrencies {
    const codes = ['USD', 'THB', 'MYR', 'SGD', 'IDR', 'PHP'];
    return codes.map(_findCurrency).whereType<CurrencyRateModel>().toList();
  }
}
