import '../../../core/network/response_parser.dart';
import 'currency_rate_model.dart';

class CurrencyRatesResponse {
  final String base;
  final String source;
  final String provider;
  final bool isStale;
  final DateTime? lastUpdated;
  final List<CurrencyRateModel> items;

  const CurrencyRatesResponse({
    required this.base,
    required this.source,
    required this.provider,
    required this.isStale,
    required this.items,
    this.lastUpdated,
  });

  factory CurrencyRatesResponse.fromJson(dynamic response) {
    final map = ResponseParser.parseMap(response);

    final nested = ResponseParser.parseMap(
      map['data'] ?? map['result'] ?? map,
    );

    final rawItems = _extractItems(nested.isNotEmpty ? nested : response);

    final items = rawItems
        .whereType<Map>()
        .map((item) => CurrencyRateModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.isActive && item.effectiveRateToVnd > 0)
        .toList();

    final hasVnd = items.any((item) => item.targetCurrency == 'VND');
    if (!hasVnd) {
      items.insert(
        0,
        CurrencyRateModel.fromJson({
          'target_currency': 'VND',
          'currency_name': 'Vietnamese Dong',
          'rate_to_vnd': 1,
          'source': 'base',
          'provider': 'system',
          'is_active': true,
          'is_stale': false,
          'last_updated': nested['last_updated'],
        }),
      );
    }

    return CurrencyRatesResponse(
      base: (nested['base'] ?? map['base'] ?? 'VND').toString(),
      source: (nested['source'] ?? map['source'] ?? 'database').toString(),
      provider: (nested['provider'] ?? map['provider'] ?? 'system').toString(),
      isStale: nested['is_stale'] == true || map['is_stale'] == true,
      lastUpdated: _parseDate(nested['last_updated'] ?? map['last_updated']),
      items: items,
    );
  }

  static List<dynamic> _extractItems(dynamic response) {
    if (response is List) return response;

    final direct = ResponseParser.parseList(response);
    if (direct.isNotEmpty) return direct;

    final map = ResponseParser.parseMap(response);

    for (final key in [
      'items',
      'data',
      'results',
      'currencies',
      'currency_rates',
      'currencyRates',
    ]) {
      final value = map[key];
      if (value is List) return value;
    }

    final rates = map['rates'];
    if (rates is List) return rates;

    if (rates is Map) {
      return rates.entries.map((entry) {
        return {
          'target_currency': entry.key,
          'currency_name': entry.key,
          'rate_to_vnd': entry.value,
          'source': map['source'] ?? 'database',
          'provider': map['provider'] ?? 'system',
          'is_active': true,
          'is_stale': map['is_stale'] ?? false,
          'last_updated': map['last_updated'],
        };
      }).toList();
    }

    return const [];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}