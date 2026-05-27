import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

class FinalResultModel {
  final String denomination;
  final String currency;
  final String country;
  final String material;
  final double confidence;
  final String matchedAgents;
  final int matchedCount;
  final int totalAgents;
  final String decisionReason;

  const FinalResultModel({
    required this.denomination,
    required this.currency,
    required this.country,
    required this.material,
    required this.confidence,
    required this.matchedAgents,
    required this.matchedCount,
    required this.totalAgents,
    required this.decisionReason,
  });

  factory FinalResultModel.empty() {
    return const FinalResultModel(
      denomination: 'Unknown',
      currency: 'Unknown',
      country: 'Unknown',
      material: 'Unknown',
      confidence: 0,
      matchedAgents: '0/0',
      matchedCount: 0,
      totalAgents: 0,
      decisionReason: 'No consensus data available.',
    );
  }

  factory FinalResultModel.fromJson(dynamic raw) {
    final json = JsonHelper.safeMap(raw);

    final matchedRaw = ResponseParser.getValue(
      json,
      ['matched_agents', 'so_luong_dong_thuan', 'consensus', 'vote_result'],
      defaultValue: '0/0',
    ).toString();

    final parsed = _parseMatchedAgents(matchedRaw);

    return FinalResultModel(
      denomination: JsonHelper.safeString(
        ResponseParser.getValue(
          json,
          [
            'final_denomination',
            'denomination',
            'menh_gia',
            'value',
            'banknote_value',
          ],
        ),
        fallback: 'Unknown',
      ),
      currency: JsonHelper.safeString(
        ResponseParser.getValue(
          json,
          ['currency', 'loai_tien', 'currency_code', 'money_code'],
        ),
        fallback: 'Unknown',
      ).toUpperCase(),
      country: JsonHelper.safeString(
        ResponseParser.getValue(
          json,
          ['country', 'quoc_gia', 'nation', 'issuer_country'],
        ),
        fallback: 'Unknown',
      ),
      material: JsonHelper.safeString(
        ResponseParser.getValue(
          json,
          ['material', 'chat_lieu', 'substrate'],
        ),
        fallback: 'Unknown',
      ),
      confidence: JsonHelper.safeDouble(
        ResponseParser.getValue(
          json,
          ['confidence', 'score', 'final_confidence', 'trust_score'],
          defaultValue: 0,
        ),
      ),
      matchedAgents: matchedRaw,
      matchedCount: parsed.$1,
      totalAgents: parsed.$2,
      decisionReason: JsonHelper.safeString(
        ResponseParser.getValue(
          json,
          ['decision_reason', 'reason', 'summary', 'explanation'],
        ),
        fallback: 'Final answer was produced by the multi-agent voting pipeline.',
      ),
    );
  }

  static (int, int) _parseMatchedAgents(String value) {
    final match = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(value);
    if (match == null) return (0, 0);

    return (
    int.tryParse(match.group(1) ?? '0') ?? 0,
    int.tryParse(match.group(2) ?? '0') ?? 0,
    );
  }

  bool get hasResult {
    return denomination.toLowerCase() != 'unknown' ||
        currency.toLowerCase() != 'unknown' ||
        country.toLowerCase() != 'unknown';
  }

  double get normalizedConfidence {
    if (confidence > 1) return confidence / 100;
    if (confidence < 0) return 0;
    return confidence;
  }
}
