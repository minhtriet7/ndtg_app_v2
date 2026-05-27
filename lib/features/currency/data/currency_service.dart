import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/response_parser.dart';
import '../models/currency_convert_response.dart';
import '../models/currency_rate_model.dart';
import '../models/currency_rates_response.dart';

class CurrencyService {
  final DioClient _client = DioClient();

  Future<CurrencyRatesResponse> getPublicRates() async {
    final response = await _client.get(ApiEndpoints.currencyRates);
    final parsed = CurrencyRatesResponse.fromJson(response.data);
    if (parsed.items.isNotEmpty) return parsed;

    final map = ResponseParser.parseMap(response.data);
    final rawRates = map['rates'];
    if (rawRates is Map) {
      final items = rawRates.entries.map((entry) {
        return CurrencyRateModel.fromJson({
          'target_currency': entry.key,
          'currency_name': entry.key,
          'rate_to_vnd': entry.value,
          'source': map['source'] ?? 'database',
          'provider': map['provider'] ?? 'system',
          'is_active': true,
          'is_stale': map['is_stale'] ?? false,
          'last_updated': map['last_updated'],
        });
      }).toList();

      return CurrencyRatesResponse(
        base: (map['base'] ?? 'VND').toString(),
        source: (map['source'] ?? 'database').toString(),
        provider: (map['provider'] ?? 'system').toString(),
        isStale: map['is_stale'] == true,
        lastUpdated: map['last_updated'] == null ? null : DateTime.tryParse(map['last_updated'].toString()),
        items: items,
      );
    }

    return parsed;
  }

  Future<CurrencyConvertResponse> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final response = await _client.post(
      ApiEndpoints.currencyConvert,
      data: {
        'amount': amount,
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
      },
    );

    return CurrencyConvertResponse.fromJson(ResponseParser.parseMap(response.data));
  }
}
