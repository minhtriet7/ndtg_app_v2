import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/currency_convert_response.dart';
import '../models/currency_rate_model.dart';
import '../models/currency_rates_response.dart';

class CurrencyService {
  final DioClient _client = DioClient();

  dynamic _unwrap(dynamic response) {
    try {
      final data = response.data;
      if (data != null) return data;
    } catch (_) {
      // DioClient may already return normalized raw data.
    }

    return response;
  }

  Map<String, dynamic> _parseMap(dynamic response) {
    final payload = _unwrap(response);
    final map = ResponseParser.parseMap(payload);

    final nested = ResponseParser.parseMap(
      map['data'] ?? map['result'] ?? map,
    );

    return nested.isNotEmpty ? nested : map;
  }

  Future<CurrencyRatesResponse> getPublicRates() async {
    final response = await _client.get(ApiEndpoints.currencyRates);
    final payload = _unwrap(response);
    return CurrencyRatesResponse.fromJson(payload);
  }

  Future<CurrencyConvertResponse> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final from = fromCurrency.trim().toUpperCase();
    final to = toCurrency.trim().toUpperCase();

    final response = await _client.post(
      ApiEndpoints.currencyConvert,
      data: {
        'amount': amount,
        'from_currency': from,
        'to_currency': to,
      },
    );

    return CurrencyConvertResponse.fromJson(_parseMap(response));
  }

  Future<double?> convertToVnd({
    required double amount,
    required String fromCurrency,
  }) async {
    final code = fromCurrency.trim().toUpperCase();

    if (code.isEmpty || amount <= 0) return null;
    if (code == 'VND') return amount;

    try {
      final response = await convert(
        amount: amount,
        fromCurrency: code,
        toCurrency: 'VND',
      );

      if (response.convertedAmount > 0) {
        return response.convertedAmount;
      }
    } catch (_) {
      // Fallback to local rates below.
    }

    try {
      final rates = await getPublicRates();

      CurrencyRateModel? rate;
      for (final item in rates.items) {
        if (item.targetCurrency.toUpperCase() == code) {
          rate = item;
          break;
        }
      }

      if (rate == null || rate.effectiveRateToVnd <= 0) return null;

      return amount * rate.effectiveRateToVnd;
    } catch (_) {
      return null;
    }
  }

  Future<double?> convertLocal({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final from = fromCurrency.trim().toUpperCase();
    final to = toCurrency.trim().toUpperCase();

    if (amount <= 0 || from.isEmpty || to.isEmpty) return null;
    if (from == to) return amount;

    final rates = await getPublicRates();

    CurrencyRateModel? fromRate;
    CurrencyRateModel? toRate;

    for (final item in rates.items) {
      if (item.targetCurrency == from) fromRate = item;
      if (item.targetCurrency == to) toRate = item;
    }

    if (fromRate == null || toRate == null) return null;
    if (fromRate.effectiveRateToVnd <= 0 || toRate.effectiveRateToVnd <= 0) {
      return null;
    }

    return (amount * fromRate.effectiveRateToVnd) / toRate.effectiveRateToVnd;
  }
}