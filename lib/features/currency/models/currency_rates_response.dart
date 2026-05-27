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
    final list = ResponseParser.parseList(response);
    final rawItems = list.isNotEmpty ? list : ResponseParser.parseList(map['items'] ?? map['data'] ?? map['rates']);

    return CurrencyRatesResponse(
      base: (map['base'] ?? 'VND').toString(),
      source: (map['source'] ?? 'database').toString(),
      provider: (map['provider'] ?? 'system').toString(),
      isStale: map['is_stale'] == true,
      lastUpdated: map['last_updated'] == null ? null : DateTime.tryParse(map['last_updated'].toString()),
      items: rawItems
          .whereType<Map>()
          .map((item) => CurrencyRateModel.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.isActive)
          .toList(),
    );
  }
}
