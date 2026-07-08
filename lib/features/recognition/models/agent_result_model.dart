import '../../../core/network/response_parser.dart';

class AgentResultModel {
  final String agentName;
  final String status;
  final String summary;
  final String country;
  final String denomination;
  final String currency;
  final String method;
  final double confidence;
  final int? objectIndex;
  final Map<String, dynamic> rawJson;

  const AgentResultModel({
    required this.agentName,
    required this.status,
    required this.summary,
    required this.country,
    required this.denomination,
    required this.currency,
    required this.method,
    required this.confidence,
    required this.objectIndex,
    required this.rawJson,
  });

  factory AgentResultModel.fromJson(dynamic raw) {
    final json = ResponseParser.parseMap(raw);
    final data = ResponseParser.parseMap(
      json['data'] ?? json['result'] ?? json['raw'] ?? json,
    );

    final denomination = _firstClean([
      ResponseParser.getValue(json, ['denomination']),
      ResponseParser.getValue(data, ['menh_gia']),
      ResponseParser.getValue(data, ['denomination']),
      ResponseParser.getValue(data, ['final_denomination']),
      ResponseParser.getValue(data, ['result']),
    ]);

    final country = _firstClean([
      ResponseParser.getValue(json, ['country']),
      ResponseParser.getValue(data, ['quoc_gia']),
      ResponseParser.getValue(data, ['country']),
    ]);

    final currency = _firstClean([
      ResponseParser.getValue(json, ['currency']),
      ResponseParser.getValue(data, ['currency']),
      ResponseParser.getValue(data, ['currency_code']),
      ResponseParser.getValue(data, ['ma_tien_te']),
      ResponseParser.getValue(data, ['loai_tien']),
      _currencyFromDenomination(denomination),
    ]);

    final method = _firstClean([
      ResponseParser.getValue(data, ['method']),
      ResponseParser.getValue(data, ['phuong_phap']),
      ResponseParser.getValue(json, ['method']),
      ResponseParser.getValue(data, ['source']),
      ResponseParser.getValue(data, ['provider']),
    ]);

    final rawAgent = _firstClean([
      ResponseParser.getValue(json, ['agent']),
      ResponseParser.getValue(json, ['agent_name']),
      ResponseParser.getValue(data, ['agent']),
      ResponseParser.getValue(data, ['provider']),
      method,
      json.toString(),
    ], fallback: 'AI Agent');

    return AgentResultModel(
      agentName: _normalizeAgentName(rawAgent),
      status: _normalizeStatus(
        _firstClean([
          ResponseParser.getValue(json, ['status']),
          ResponseParser.getValue(data, ['status']),
        ], fallback: 'waiting'),
      ),
      summary: _firstClean([
        ResponseParser.getValue(json, ['summary']),
        ResponseParser.getValue(data, ['mo_ta']),
        ResponseParser.getValue(data, ['description']),
        ResponseParser.getValue(data, ['quan_diem']),
        ResponseParser.getValue(data, ['message']),
        denomination.isNotEmpty || country.isNotEmpty
            ? '$country $denomination'.trim()
            : null,
      ], fallback: 'Waiting for analysis result.'),
      country: country,
      denomination: denomination,
      currency: currency,
      method: method,
      confidence: _asDouble(
        _firstClean([
          ResponseParser.getValue(data, ['do_tin_cay']),
          ResponseParser.getValue(data, ['confidence']),
          ResponseParser.getValue(json, ['confidence']),
        ], fallback: '0'),
      ),
      objectIndex: _asNullableInt(
        _firstClean([
          ResponseParser.getValue(json, ['object_index']),
          ResponseParser.getValue(data, ['object_index']),
        ]),
      ),
      rawJson: json,
    );
  }

  String get displayResult {
    final parts = [
      if (country.trim().isNotEmpty) country,
      if (denomination.trim().isNotEmpty) denomination,
    ];
    return parts.isEmpty ? summary : parts.join(' · ');
  }

  static String _normalizeAgentName(String value) {
    final text = value.toLowerCase();

    if (text.contains('yolo') ||
        text.contains('ml') ||
        text.contains('vision') ||
        text.contains('openai') ||
        text.contains('chatgpt') ||
        text.contains('visual classification') ||
        text.contains('classifier')) {
      return 'ChatGPT Vision Agent';
    }

    if (text.contains('llm') ||
        text.contains('gemini') ||
        text.contains('gpt') ||
        text.contains('language') ||
        text.contains('reasoning')) {
      return 'LLM Agent';
    }

    if (text.contains('lens') ||
        text.contains('visual_search') ||
        text.contains('visual search') ||
        text.contains('serp') ||
        text.contains('google')) {
      return 'Visual Search';
    }

    if (text.contains('aggregator') ||
        text.contains('majority') ||
        text.contains('vote') ||
        text.contains('consensus')) {
      return 'Aggregator Decision';
    }

    return value == 'AI Agent' ? 'AI Agent' : value;
  }

  static String _normalizeStatus(String value) {
    final text = value.toLowerCase().trim();

    if (text.contains('completed') ||
        text.contains('success') ||
        text.contains('done')) {
      return 'completed';
    }

    if (text.contains('running') ||
        text.contains('processing') ||
        text.contains('analyzing')) {
      return 'running';
    }

    if (text.contains('failed') || text.contains('error')) {
      return 'failed';
    }

    if (text.contains('pending') || text.contains('waiting')) {
      return 'pending';
    }

    return value;
  }

  static String _firstClean(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isEmpty) continue;
      if (text.toLowerCase() == 'null') continue;
      return text;
    }
    return fallback;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    final text = value.toString().replaceAll('%', '').trim();
    return double.tryParse(text) ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  static String _currencyFromDenomination(String value) {
    final text = value.toUpperCase();

    const codes = [
      'VND',
      'MYR',
      'THB',
      'IDR',
      'SGD',
      'PHP',
      'KHR',
      'LAK',
      'MMK',
      'BND',
      'USD',
    ];

    for (final code in codes) {
      if (RegExp('\\b$code\\b').hasMatch(text)) return code;
    }

    return '';
  }
}
