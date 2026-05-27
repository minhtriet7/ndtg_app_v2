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
    return CurrencyConvertResponse(
      amount: JsonHelper.safeDouble(JsonHelper.getValue(json, ['amount', 'original_amount'])),
      fromCurrency: JsonHelper.safeString(JsonHelper.getValue(json, ['from_currency']), fallback: 'UNK'),
      toCurrency: JsonHelper.safeString(JsonHelper.getValue(json, ['to_currency']), fallback: 'UNK'),
      convertedAmount: JsonHelper.safeDouble(JsonHelper.getValue(json, ['converted_amount', 'result'])),
      exchangeRate: JsonHelper.safeDouble(JsonHelper.getValue(json, ['exchange_rate', 'rate'])),
      source: JsonHelper.safeString(JsonHelper.getValue(json, ['source']), fallback: 'database'),
      provider: JsonHelper.safeString(JsonHelper.getValue(json, ['provider']), fallback: 'system'),
      isStale: JsonHelper.safeBool(JsonHelper.getValue(json, ['is_stale']), fallback: false),
      lastUpdated: JsonHelper.safeDateTime(JsonHelper.getValue(json, ['last_updated'])),
    );
  }
}
