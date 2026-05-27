import '../../../core/utils/json_helper.dart';

class CurrencyRateModel {
  final String id;
  final String targetCurrency;
  final String currencyName;
  final double rateToVnd;
  final double? marketRateToVnd;
  final double? manualRateToVnd;
  final bool manualOverride;
  final String source;
  final String provider;
  final bool isActive;
  final bool isStale;
  final DateTime? lastUpdated;

  const CurrencyRateModel({
    required this.id,
    required this.targetCurrency,
    required this.currencyName,
    required this.rateToVnd,
    this.marketRateToVnd,
    this.manualRateToVnd,
    required this.manualOverride,
    required this.source,
    required this.provider,
    required this.isActive,
    required this.isStale,
    this.lastUpdated,
  });

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final code = JsonHelper.safeString(
      JsonHelper.getValue(json, ['target_currency', 'currency_code', 'currency']),
      fallback: 'UNK',
    ).toUpperCase();

    return CurrencyRateModel(
      id: JsonHelper.safeString(JsonHelper.getValue(json, ['id', '_id']), fallback: code),
      targetCurrency: code,
      currencyName: JsonHelper.safeString(JsonHelper.getValue(json, ['currency_name', 'name']), fallback: code),
      rateToVnd: JsonHelper.safeDouble(JsonHelper.getValue(json, ['rate_to_vnd', 'rate', 'value']), fallback: code == 'VND' ? 1 : 0),
      marketRateToVnd: JsonHelper.getValue(json, ['market_rate_to_vnd']) == null ? null : JsonHelper.safeDouble(JsonHelper.getValue(json, ['market_rate_to_vnd'])),
      manualRateToVnd: JsonHelper.getValue(json, ['manual_rate_to_vnd']) == null ? null : JsonHelper.safeDouble(JsonHelper.getValue(json, ['manual_rate_to_vnd'])),
      manualOverride: JsonHelper.safeBool(JsonHelper.getValue(json, ['manual_override']), fallback: false),
      source: JsonHelper.safeString(JsonHelper.getValue(json, ['source']), fallback: code == 'VND' ? 'base' : 'market'),
      provider: JsonHelper.safeString(JsonHelper.getValue(json, ['provider']), fallback: 'system'),
      isActive: JsonHelper.safeBool(JsonHelper.getValue(json, ['is_active', 'active']), fallback: true),
      isStale: JsonHelper.safeBool(JsonHelper.getValue(json, ['is_stale', 'stale']), fallback: false),
      lastUpdated: JsonHelper.safeDateTime(JsonHelper.getValue(json, ['last_updated', 'updated_at', 'created_at'])),
    );
  }

  bool get isVnd => targetCurrency == 'VND';

  double get effectiveRateToVnd {
    if (manualOverride && manualRateToVnd != null && manualRateToVnd! > 0) return manualRateToVnd!;
    if (marketRateToVnd != null && marketRateToVnd! > 0) return marketRateToVnd!;
    return rateToVnd;
  }

  String get displayName => '$targetCurrency • $currencyName';
}
