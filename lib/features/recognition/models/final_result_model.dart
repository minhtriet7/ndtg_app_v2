import '../../../core/network/response_parser.dart';

class FinalResultModel {
  final String country;
  final String denomination;
  final String currency;
  final String status;
  final String method;
  final String matchedAgents;
  final int matchedAgentsCount;
  final int totalAgents;
  final String decisionReason;
  final String material;
  final String origin;
  final bool requireRerun;
  final int detectedCount;
  final int resolvedObjects;
  final int totalObjects;
  final List<Map<String, dynamic>> detectedObjects;
  final List<Map<String, dynamic>> summary;
  final List<Map<String, dynamic>> validVotes;
  final Map<String, dynamic> raw;

  const FinalResultModel({
    required this.country,
    required this.denomination,
    required this.currency,
    required this.status,
    required this.method,
    required this.matchedAgents,
    required this.matchedAgentsCount,
    required this.totalAgents,
    required this.decisionReason,
    required this.material,
    required this.origin,
    required this.requireRerun,
    required this.detectedCount,
    required this.resolvedObjects,
    required this.totalObjects,
    required this.detectedObjects,
    required this.summary,
    required this.validVotes,
    required this.raw,
  });

  factory FinalResultModel.empty() {
    return const FinalResultModel(
      country: 'Unknown',
      denomination: 'Unknown',
      currency: 'Unknown',
      status: 'Unknown',
      method: '',
      matchedAgents: '0/3 agents',
      matchedAgentsCount: 0,
      totalAgents: 3,
      decisionReason: '',
      material: '',
      origin: '',
      requireRerun: false,
      detectedCount: 0,
      resolvedObjects: 0,
      totalObjects: 0,
      detectedObjects: [],
      summary: [],
      validVotes: [],
      raw: {},
    );
  }

  factory FinalResultModel.fromJson(dynamic rawValue) {
    final json = ResponseParser.parseMap(rawValue);

    final detectedObjects = _listOfMap(
      ResponseParser.getValue(
        json,
        ['detected_objects', 'objects'],
        defaultValue: const [],
      ),
    );

    final summary = _listOfMap(
      ResponseParser.getValue(
        json,
        ['summary'],
        defaultValue: const [],
      ),
    );

    final validVotes = _listOfMap(
      ResponseParser.getValue(
        json,
        ['valid_votes'],
        defaultValue: const [],
      ),
    );

    final firstSummary = summary.isNotEmpty ? summary.first : <String, dynamic>{};

    final rawDenomination = _firstClean([
      ResponseParser.getValue(json, ['final_denomination']),
      ResponseParser.getValue(json, ['menh_gia']),
      ResponseParser.getValue(json, ['denomination']),
      ResponseParser.getValue(json, ['result']),
      ResponseParser.getValue(firstSummary, ['denomination']),
      ResponseParser.getValue(firstSummary, ['menh_gia']),
    ]);

    final rawCountry = _firstClean([
      ResponseParser.getValue(json, ['quoc_gia']),
      ResponseParser.getValue(json, ['country']),
      ResponseParser.getValue(firstSummary, ['country']),
      ResponseParser.getValue(firstSummary, ['quoc_gia']),
    ]);

    final rawCurrency = _firstClean([
      ResponseParser.getValue(json, ['currency']),
      ResponseParser.getValue(json, ['loai_tien']),
      ResponseParser.getValue(firstSummary, ['currency']),
      ResponseParser.getValue(firstSummary, ['loai_tien']),
      _currencyFromDenomination(rawDenomination),
    ]);

    final status = _firstClean([
      ResponseParser.getValue(json, ['status']),
      ResponseParser.getValue(firstSummary, ['status']),
    ], fallback: 'Unknown');

    final matched = _asInt(
      _firstClean([
        ResponseParser.getValue(json, ['matched_agents']),
        ResponseParser.getValue(json, ['so_luong_dong_thuan']),
        ResponseParser.getValue(firstSummary, ['matched_agents']),
        ResponseParser.getValue(firstSummary, ['so_luong_dong_thuan']),
      ], fallback: '0'),
    );

    final detectedCount = _asInt(
      _firstClean([
        ResponseParser.getValue(json, ['detected_count']),
        ResponseParser.getValue(json, ['detected_objects_count']),
        detectedObjects.length,
      ], fallback: '0'),
    );

    final totalObjects = _asInt(
      _firstClean([
        ResponseParser.getValue(json, ['total_objects']),
        detectedCount,
        summary.length,
      ], fallback: '0'),
    );

    final resolvedObjects = _asInt(
      _firstClean([
        ResponseParser.getValue(json, ['resolved_objects']),
        summary.length,
      ], fallback: '0'),
    );

    final displayDenomination =
    rawDenomination.isEmpty ? 'Unknown' : rawDenomination;
    final displayCountry = rawCountry.isEmpty ? 'Unknown' : rawCountry;
    final displayCurrency = rawCurrency.isEmpty
        ? _currencyFromDenomination(displayDenomination)
        : rawCurrency;

    final normalizedCurrency =
    displayCurrency.isEmpty ? 'Unknown' : displayCurrency;

    final bool multiBanknote = totalObjects > 1 || summary.length > 1;
    final String consensusText = multiBanknote
        ? '${resolvedObjects == 0 ? summary.length : resolvedObjects}/${totalObjects == 0 ? summary.length : totalObjects} objects'
        : '${matched == 0 ? _matchedFromVotes(validVotes) : matched}/3 agents';

    return FinalResultModel(
      country: displayCountry,
      denomination: displayDenomination,
      currency: normalizedCurrency,
      status: status,
      method: _firstClean([
        ResponseParser.getValue(json, ['method']),
        ResponseParser.getValue(json, ['phuong_phap']),
      ]),
      matchedAgents: consensusText,
      matchedAgentsCount: matched == 0 ? _matchedFromVotes(validVotes) : matched,
      totalAgents: 3,
      decisionReason: _firstClean([
        ResponseParser.getValue(json, ['quan_diem_trong_tai']),
        ResponseParser.getValue(json, ['decision_reason']),
        ResponseParser.getValue(json, ['reason']),
        ResponseParser.getValue(json, ['mo_ta']),
        ResponseParser.getValue(json, ['description']),
      ]),
      material: _firstClean([
        ResponseParser.getValue(json, ['chat_lieu']),
        ResponseParser.getValue(json, ['material']),
      ]),
      origin: _firstClean([
        ResponseParser.getValue(json, ['xuat_xu']),
        ResponseParser.getValue(json, ['origin']),
        displayCountry,
      ]),
      requireRerun: ResponseParser.getValue(
        json,
        ['require_rerun'],
        defaultValue: false,
      ) ==
          true,
      detectedCount: detectedCount,
      resolvedObjects: resolvedObjects,
      totalObjects: totalObjects,
      detectedObjects: detectedObjects,
      summary: summary,
      validVotes: validVotes,
      raw: json,
    );
  }

  bool get isKnown {
    return !_isUnknown(denomination) && !_isUnknown(country);
  }

  bool get isCompleted {
    final s = status.toLowerCase();
    return s.contains('completed') ||
        s.contains('success') ||
        s.contains('done');
  }

  bool get isMultiObject {
    return totalObjects > 1 || summary.length > 1;
  }

  String get displayTitle {
    if (isMultiObject && summary.isNotEmpty) {
      return '$resolvedObjects banknotes detected';
    }

    if (!isKnown) return 'Unknown Banknote';

    return formatMoneyLabel(denomination, currency);
  }

  static String formatMoneyLabel(String denomination, String currency) {
    final cleanDenomination = denomination.trim();
    final cleanCurrency = currency.trim().toUpperCase();

    if (cleanDenomination.isEmpty) return 'Unknown';
    if (cleanCurrency.isEmpty || cleanCurrency == 'UNKNOWN') {
      return cleanDenomination;
    }

    if (RegExp('\\b$cleanCurrency\\b').hasMatch(cleanDenomination.toUpperCase())) {
      return cleanDenomination;
    }

    return '$cleanDenomination $cleanCurrency';
  }

  static List<Map<String, dynamic>> _listOfMap(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static String _firstClean(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isEmpty) continue;
      if (_isNullLike(text)) continue;

      return text;
    }

    return fallback;
  }

  static bool _isNullLike(String value) {
    final text = value.toLowerCase().trim();
    return text == 'null' || text == 'none' || text == 'n/a' || text == 'na';
  }

  static bool _isUnknown(String value) {
    final text = value.toLowerCase().trim();
    return text.isEmpty ||
        text == 'unknown' ||
        text == 'không xác định' ||
        text == 'khong xac dinh' ||
        text == 'n/a';
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int _matchedFromVotes(List<Map<String, dynamic>> votes) {
    if (votes.isEmpty) return 0;
    final valid = votes.where((vote) {
      final status = (vote['status'] ?? '').toString().toLowerCase();
      return status.contains('completed') ||
          status.contains('success') ||
          status.contains('done');
    }).length;
    return valid == 0 ? votes.length.clamp(0, 3) : valid.clamp(0, 3);
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
      'EUR',
      'JPY',
      'CNY',
    ];

    for (final code in codes) {
      if (RegExp('\\b$code\\b').hasMatch(text)) return code;
    }

    return '';
  }
}