import '../../../core/utils/json_helper.dart';

class CurrencyConvertResponse {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double convertedAmount;
  final double exchangeRate;
  final String source;
  final String provider;
  final bool isStale;
  final DateTime? lastUpdated;

  const CurrencyConvertResponse({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.source,
    required this.provider,
    required this.isStale,
    this.lastUpdated,
  });

  factory CurrencyConvertResponse.fromJson(Map<String, dynamic> json) {
    final data = JsonHelper.getValue(json, ['data', 'result']);
    final map = data is Map<String, dynamic> ? data : json;

    return CurrencyConvertResponse(
      amount: JsonHelper.safeDouble(
        JsonHelper.getValue(map, ['amount', 'original_amount', 'from_amount']),
      ),
      fromCurrency: JsonHelper.safeString(
        JsonHelper.getValue(map, ['from_currency', 'from', 'source_currency']),
        fallback: 'UNK',
      ).toUpperCase(),
      toCurrency: JsonHelper.safeString(
        JsonHelper.getValue(map, ['to_currency', 'to', 'target_currency']),
        fallback: 'UNK',
      ).toUpperCase(),
      convertedAmount: JsonHelper.safeDouble(
        JsonHelper.getValue(
          map,
          ['converted_amount', 'result', 'to_amount', 'converted'],
        ),
      ),
      exchangeRate: JsonHelper.safeDouble(
        JsonHelper.getValue(map, ['exchange_rate', 'rate']),
      ),
      source: JsonHelper.safeString(
        JsonHelper.getValue(map, ['source']),
        fallback: 'database',
      ),
      provider: JsonHelper.safeString(
        JsonHelper.getValue(map, ['provider']),
        fallback: 'system',
      ),
      isStale: JsonHelper.safeBool(
        JsonHelper.getValue(map, ['is_stale', 'stale']),
        fallback: false,
      ),
      lastUpdated: JsonHelper.safeDateTime(
        JsonHelper.getValue(map, ['last_updated', 'updated_at']),
      ),
    );
  }

  bool get isValid {
    return convertedAmount > 0 && fromCurrency != 'UNK' && toCurrency != 'UNK';
  }
}