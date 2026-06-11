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
      JsonHelper.getValue(
        json,
        [
          'target_currency',
          'currency_code',
          'currency',
          'code',
          'targetCurrency',
        ],
      ),
      fallback: 'UNK',
    ).toUpperCase();

    final marketRateValue = JsonHelper.getValue(
      json,
      ['market_rate_to_vnd', 'marketRateToVnd', 'market_rate'],
    );

    final manualRateValue = JsonHelper.getValue(
      json,
      ['manual_rate_to_vnd', 'manualRateToVnd', 'manual_rate'],
    );

    return CurrencyRateModel(
      id: JsonHelper.safeString(
        JsonHelper.getValue(json, ['id', '_id']),
        fallback: code,
      ),
      targetCurrency: code,
      currencyName: JsonHelper.safeString(
        JsonHelper.getValue(
          json,
          ['currency_name', 'name', 'currencyName', 'display_name'],
        ),
        fallback: _fallbackName(code),
      ),
      rateToVnd: JsonHelper.safeDouble(
        JsonHelper.getValue(
          json,
          ['rate_to_vnd', 'rateToVnd', 'rate', 'value'],
        ),
        fallback: code == 'VND' ? 1 : 0,
      ),
      marketRateToVnd: marketRateValue == null
          ? null
          : JsonHelper.safeDouble(marketRateValue),
      manualRateToVnd: manualRateValue == null
          ? null
          : JsonHelper.safeDouble(manualRateValue),
      manualOverride: JsonHelper.safeBool(
        JsonHelper.getValue(json, ['manual_override', 'manualOverride']),
        fallback: false,
      ),
      source: JsonHelper.safeString(
        JsonHelper.getValue(json, ['source']),
        fallback: code == 'VND' ? 'base' : 'market',
      ),
      provider: JsonHelper.safeString(
        JsonHelper.getValue(json, ['provider']),
        fallback: 'system',
      ),
      isActive: JsonHelper.safeBool(
        JsonHelper.getValue(json, ['is_active', 'active', 'enabled']),
        fallback: true,
      ),
      isStale: JsonHelper.safeBool(
        JsonHelper.getValue(json, ['is_stale', 'stale']),
        fallback: false,
      ),
      lastUpdated: JsonHelper.safeDateTime(
        JsonHelper.getValue(
          json,
          ['last_updated', 'updated_at', 'created_at', 'lastUpdated'],
        ),
      ),
    );
  }

  bool get isVnd => targetCurrency == 'VND';

  bool get isSeaCurrency {
    const sea = {
      'VND',
      'THB',
      'IDR',
      'MYR',
      'SGD',
      'PHP',
      'KHR',
      'LAK',
      'MMK',
      'BND',
    };

    return sea.contains(targetCurrency);
  }

  double get effectiveRateToVnd {
    if (manualOverride && manualRateToVnd != null && manualRateToVnd! > 0) {
      return manualRateToVnd!;
    }

    if (marketRateToVnd != null && marketRateToVnd! > 0) {
      return marketRateToVnd!;
    }

    return rateToVnd;
  }

  String get displayName => '$targetCurrency • $currencyName';

  String get shortLabel {
    final name = currencyName.trim();
    if (name.isEmpty || name.toUpperCase() == targetCurrency) {
      return targetCurrency;
    }

    return '$targetCurrency · $name';
  }

  static String _fallbackName(String code) {
    const names = {
      'VND': 'Vietnamese Dong',
      'USD': 'US Dollar',
      'THB': 'Thai Baht',
      'IDR': 'Indonesian Rupiah',
      'MYR': 'Malaysian Ringgit',
      'SGD': 'Singapore Dollar',
      'PHP': 'Philippine Peso',
      'KHR': 'Cambodian Riel',
      'LAK': 'Lao Kip',
      'MMK': 'Myanmar Kyat',
      'BND': 'Brunei Dollar',
    };

    return names[code] ?? code;
  }
}